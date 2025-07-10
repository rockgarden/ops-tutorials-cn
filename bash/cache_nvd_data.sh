#!/bin/bash

# ==============================================
# 自动下载并缓存 OWASP Dependency-Check 的 NVD 数据集
# 适用于 GitLab CI/CD 或本地环境
# 最后更新: 2023-10-20
# ==============================================

# 配置变量
ODC_DATA_DIR="/data/var/cache/gitlab-runner/dependency-check"  # 缓存目录
ODC_VERSION="8.2.1"                                           # 对应 dependency-check 版本
NVD_BASE_URL="https://nvd.nist.gov/feeds/json/cve/1.1"        # NVD 数据源

# 创建缓存目录
echo "创建缓存目录: ${ODC_DATA_DIR}/${ODC_VERSION}"
mkdir -p "${ODC_DATA_DIR}/${ODC_VERSION}" || {
    echo "无法创建目录，请检查权限"
    exit 1
}
cd "${ODC_DATA_DIR}/${ODC_VERSION}" || exit 1

# 下载函数（自动重试）
download_with_retry() {
  local url=$1
  local output_file=$2
  local max_retries=3
  local retry_count=0

  while [ $retry_count -lt $max_retries ]; do
    if wget --tries=3 --timeout=30 -q "$url" -O "$output_file"; then
      echo "[OK] 下载成功: $output_file"
      return 0
    else
      retry_count=$((retry_count + 1))
      echo "[Retry $retry_count/$max_retries] 下载失败: $url"
      sleep 5
    fi
  done

  echo "[ERROR] 无法下载文件: $url"
  return 1
}

# 1. 下载年度数据 (2002-2024)
echo "开始下载 NVD 年度数据 (2002-2024)..."
for year in {2002..2024}; do
  filename="nvdcve-1.1-${year}.json.gz"
  download_with_retry "${NVD_BASE_URL}/${filename}" "$filename"
done

# 2. 下载增量更新数据
echo "下载增量更新数据..."
download_with_retry "${NVD_BASE_URL}/nvdcve-1.1-modified.json.gz" "nvdcve-1.1-modified.json.gz" || exit 1

# 3. 验证文件完整性
echo "验证下载的文件..."
bad_files=$(find . -name "*.json.gz" -type f -size -10k)
if [ -n "$bad_files" ]; then
  echo "[WARNING] 以下文件可能损坏:"
  echo "$bad_files"
  echo "请手动重新下载"
else
  echo "所有文件验证通过"
fi

# 4. 设置权限（允许 GitLab Runner 访问）
chmod -R 755 "${ODC_DATA_DIR}"
echo "缓存目录: ${ODC_DATA_DIR}/${ODC_VERSION}"
ls -lh

echo "NVD 数据缓存完成！"
