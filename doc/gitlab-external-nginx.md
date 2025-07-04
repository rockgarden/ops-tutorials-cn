# External Nginx

要在 GitLab CE 17.11.14 中配置通过外部 **Nginx** 访问，你需要禁用 GitLab 自带的 Nginx（即 `nginx` 服务），并使用你自己的外部 Nginx 来反向代理 GitLab。

以下是详细步骤：

---

## ✅ 环境说明

- 操作系统：CentOS 8
- GitLab 版本：GitLab CE 17.11.4
- 外部 Nginx：已安装且可运行
- 域名+子路径，并启用HTTPS：例如 `https://www.eastcomccmp.top/egitlab/`

---

### 1. **修改 GitLab 配置文件（`gitlab.rb`）**

> 此步骤确保 GitLab 以子路径 `/egitlab` 提供服务，并监听指定的 Unix Socket（通过 Unix Socket 与外部 Nginx 通信）。

编辑 `/etc/gitlab/gitlab.rb` 文件：

```ruby
# 设置 external_url 包含子路径和 HTTPS
external_url 'https://www.eastcomccmp.top/egitlab/'

# 禁用内置的 Nginx
nginx['enable'] = false

# 明确授权外部 Nginx 用户访问 GitLab 的关键资源
# 查看 外部 Nginx 运行用户相应命令 `grep 'user' /etc/nginx/nginx.conf`
web_server['external_users'] = ['nobody', 'www-data']

# 配置 GitLab Workhorse 使用 Unix Socket（推荐）
gitlab_workhorse['listen_network'] = "unix"
gitlab_workhorse['listen_addr'] = "/var/opt/gitlab/gitlab-workhorse/sockets/gitlab-workhorse.socket"

# 设置代理服务器 IP 范围（包含外部 Nginx）
gitlab_rails['trusted_proxies'] = ['192.168.1.0/24']

# 优化性能配置
# 根据 CPU 核心数调整，CPU配置查看命令 lscpu
# 设置 Puma 的工作进程数（默认：CPU 核心数 + 1）
puma['worker_processes'] = 5
# CPU 核心数 × 1.5
sidekiq['concurrency'] = 10
```

保存后应用配置：

```bash
sudo gitlab-ctl reconfigure
```

验证权限：配置后可通过以下命令检查套接字文件的权限：

`ls -l /var/opt/gitlab/gitlab-workhorse/sockets/gitlab-workhorse.socket`

输出应显示 nginx 用户或组有访问权限（如 "srwxrwx--- 1 git nobody"）

---

### 2. **配置外部 Nginx 反向代理（支持 HTTPS 和子路径）**

创建或编辑 Nginx 站点配置文件（如 `/etc/nginx/sites-available/gitlab`）：

```conf
upstream gitlab {
    server unix:/var/opt/gitlab/gitlab-workhorse/sockets/gitlab-workhorse.socket fail_timeout=0;
}

server {
    listen 443 ssl http2;
    server_name www.eastcomccmp.top;

    ssl_certificate /etc/nginx/ssl/eastcomccmp.top.crt;  # 替换为你的 SSL 证书路径
    ssl_certificate_key /etc/nginx/ssl/eastcomccmp.top.key;  # 替换为你的 SSL 私钥路径

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:20m;
    ssl_session_timeout 20m;

    client_max_body_size 50M;

    # GitLab 主配置
    location /egitlab/ {
        proxy_pass http://gitlab;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_read_timeout 300s;
        proxy_connect_timeout 300s;
        # 禁用缓冲
        proxy_request_buffering off;
        proxy_buffering off;
        proxy_http_version 1.1;

        # 关键头信息，确保 GitLab 正确识别请求路径
        proxy_set_header X-Forwarded-Prefix /egitlab;
    }

    # WebSocket 支持
    location /-/cable {
        proxy_pass http://gitlab-workhorse;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 禁止访问 .git 目录
    location ~ /\.git {
        deny all;
        return 404;
    }

    # 可选：安全头
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    # 可选：性能优化
    client_max_body_size 0;
    chunked_transfer_encoding on;
    keepalive_timeout 65;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    # 可选：静态资源缓存（处理优化）
    location ~ ^/egitlab/(assets|robots.txt|favicon.ico|sitemap.xml) {
        root /opt/gitlab/embedded/service/gitlab-rails/public;
        access_log off;
        gzip_static on;
        expires max;
        add_header Cache-Control public;
    }

    access_log /var/log/nginx/gitlab_access.log combined;
    error_log /var/log/nginx/gitlab_error.log;
}

# 强制 HTTP 跳转 HTTPS（可选）
server {
    listen 80;
    server_name www.eastcomccmp.top;
    server_tokens off;
    return 301 https://$host$request_uri;
}
```

启用配置并重启 Nginx：

```bash
sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

此配置确保 Nginx 通过 HTTPS 和子路径 `/egitlab` 正确代理 GitLab 请求 。

---

### 3. **设置权限以允许 Nginx 访问 socket 文件**

检查 GitLab 当前配置：

```sh
sudo grep "gitlab_workhorse\['listen_addr'\]" /etc/gitlab/gitlab.rb
gitlab_workhorse['listen_addr'] = "127.0.0.1:8181"
# 未用Unix socket
```

确保 Nginx 用户有权限访问 GitLab 的 socket 文件（假设用户为 `nobody`）：

```bash
sudo usermod -aG gitlab-www nobody
sudo chmod g+rx /var/opt/gitlab/gitlab-workhorse/sockets/
sudo chown :gitlab-www /var/opt/gitlab/gitlab-workhorse/sockets/gitlab-workhorse.socket
```

---

### 4. **验证访问**

访问 `https://www.eastcomccmp.top/egitlab/`，应能正常打开 GitLab 登录页面。

---

## 📌 注意事项

1. **子路径兼容性问题**：  
   GitLab 对子路径的支持可能不完全兼容某些功能（如 Webhook、CI/CD），建议测试关键功能。

2. **静态资源路径问题**：  
   若 CSS/JS 加载失败，检查 `/opt/gitlab/embedded/service/gitlab-rails/public` 路径是否存在，或在 Nginx 中添加静态资源 location 块 。

3. **SSL 配置建议**：  
   建议使用 Let's Encrypt 或其他受信任的 CA 签发的证书，以提高安全性。

4. **X-Forwarded-Prefix 头**：  
   必须设置此头信息，否则 GitLab 返回 404 错误 。

---
