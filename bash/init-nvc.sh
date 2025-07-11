#!/bin/bash

# 配置变量
ODC_DATA_DIR="/data/var/cache/gitlab-runner/dependency-check"
ODC_VERSION="8.2.1"
NVD_BASE_URL="https://nvd.nist.gov/feeds/json/cve/1.1"
NVD_DIR="${ODC_DATA_DIR}/${ODC_VERSION}/nvd"  # 关键修正：添加/nvd子目录

# 创建正确的目录结构
mkdir -p "${NVD_DIR}"
cd "${NVD_DIR}" || exit 1

# 下载并解压函数
download_and_extract() {
  local url=$1
  local output_file=$2
  local max_retries=3
  
  for ((retry=1; retry<=max_retries; retry++)); do
    if wget --tries=3 --timeout=30 -q "$url" -O "${output_file}.gz"; then
      echo "[OK] 下载成功: ${output_file}.gz"
      gzip -df "${output_file}.gz" && return 0
    fi
    echo "[Retry $retry/$max_retries] 下载失败: $url"
    sleep 5
  done
  return 1
}

# 下载年度数据 (2002-2024)
echo "开始处理 NVD 数据..."
for year in {2002..2024}; do
  filename="nvdcve-1.1-${year}.json"  # 注意：目标文件名不含.gz
  download_and_extract "${NVD_BASE_URL}/${filename}.gz" "$filename"
done

# 下载增量数据
download_and_extract "${NVD_BASE_URL}/nvdcve-1.1-modified.json.gz" "nvdcve-1.1-modified.json"

# 验证
if find . -name "*.json" -type f -size -1k | grep -q .; then
  echo "[ERROR] 存在损坏文件！"
  exit 1
fi

# 设置权限
chown -R gitlab-runner:gitlab-runner "${ODC_DATA_DIR}"
chmod -R 755 "${ODC_DATA_DIR}"

echo "✅ NVD 数据已就绪于: ${NVD_DIR}"
ls -lh