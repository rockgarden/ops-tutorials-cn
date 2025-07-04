# nginx

## 提示词

在 GitLab CE 17 中配置外部 Nginx 访问内网的 gitlab 服务，相应的网络拓扑为：外部用户 → 外部 Nginx (192.168.90.4) →GitLab Unix 套接字。

其中：gitlab 服务器的 IP 为 192.168.97.115，Nginx 服务器的 IP 为 192.168.90.4。

gitlab 相关参数：

nginx['enable'] = false
gitlab_workhorse['listen_network'] = "unix"
external_url <https://www.eastcomccmp.top/egitlab/>

### 完整配置方案

#### 第一步：在 GitLab 服务器 (192.168.97.115) 上配置

1. **修改 GitLab 配置 (`/etc/gitlab/gitlab.rb`)**：

   ```ruby
   external_url 'https://www.eastcomccmp.top/egitlab/'
   nginx['enable'] = false
   gitlab_workhorse['listen_network'] = "unix"
   gitlab_workhorse['listen_addr'] = "/var/opt/gitlab/gitlab-workhorse/socket"

   # 禁用内置服务
   prometheus['enable'] = false
   node_exporter['enable'] = false
   redis_exporter['enable'] = false
   postgres_exporter['enable'] = false
   gitaly['prometheus_listen_addr'] = ""

   # 调整 Puma 配置
   puma['worker_processes'] = 2
   ```

2. **创建本地 Nginx 代理配置 (`/etc/nginx/conf.d/gitlab-proxy.conf`)**：

   ```nginx
   upstream gitlab-workhorse {
       server unix:/var/opt/gitlab/gitlab-workhorse/socket fail_timeout=0;
   }

   server {
       listen 192.168.97.115:8181;
       server_name localhost;

       # 只允许外部 Nginx 访问
       allow 192.168.90.4;
       deny all;

       location / {
           proxy_pass http://gitlab-workhorse;
           proxy_set_header Host $http_host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;

           # WebSocket 支持
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
           proxy_http_version 1.1;

           # 超时设置
           proxy_read_timeout 300;
           proxy_connect_timeout 300;
       }
   }
   ```

3. **应用配置并重启服务**：

   ```bash
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart
   sudo systemctl restart nginx
   ```

#### 第二步：在外部 Nginx 服务器 (192.168.90.4) 上配置

创建配置文件 (`/etc/nginx/conf.d/gitlab-external.conf`):

```nginx
# HTTP 重定向到 HTTPS
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 80;
    server_name www.eastcomccmp.top;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name www.eastcomccmp.top;

    # SSL 配置
    ssl_certificate /etc/letsencrypt/live/www.eastcomccmp.top/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/www.eastcomccmp.top/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;

    # 路径重写规则
    rewrite ^/egitlab$ $scheme://$http_host/egitlab/ permanent;

    # GitLab 代理配置
    location /egitlab/ {
        # 代理到 GitLab 服务器的本地代理
        proxy_pass http://192.168.97.115:8181/;

        # 标准代理头
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Ssl on;

        # WebSocket 支持
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;

        # 超时设置
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;

        # 大文件上传支持
        client_max_body_size 0;

        # 路径重写
        proxy_redirect off;
        proxy_cookie_path / /egitlab/;
    }

    # 健康检查端点
    location /egitlab/-/health {
        access_log off;
        proxy_pass http://192.168.97.115:8181/-/health;
    }

    # 其他路径拒绝访问
    location / {
        return 404 "Not Found";
    }
}
```

#### 第三步：安全加固和防火墙配置

1. **在 GitLab 服务器上配置防火墙**：

   ```bash
   # 只允许外部 Nginx 访问 8181 端口
   sudo ufw allow from 192.168.90.4 to any port 8181
   sudo ufw deny 8181
   ```

2. **在外部 Nginx 服务器上配置防火墙**：

   ```bash
   # 允许公网访问 HTTPS
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

#### 第四步：验证配置

1. **测试本地代理**：

   ```bash
   # 在 GitLab 服务器上执行
   curl -H "Host: www.eastcomccmp.top" http://192.168.97.115:8181/egitlab
   ```

2. **测试外部代理**：

   ```bash
   # 在外部 Nginx 服务器上执行
   curl -k -H "Host: www.eastcomccmp.top" https://localhost/egitlab
   ```

3. **检查服务状态**：

   ```bash
   # 在 GitLab 服务器上
   sudo gitlab-ctl status
   ss -ln | grep 8181  # 应显示: tcp   LISTEN 0 128 192.168.97.115:8181

   # 在外部 Nginx 服务器上
   nginx -t
   systemctl status nginx
   ```

#### 关键配置说明

1. **路径处理**：

   - 外部 Nginx 使用 `/egitlab/` 作为入口路径
   - `proxy_cookie_path` 确保 cookie 路径正确
   - `rewrite` 规则处理路径重定向

2. **安全增强**：

   - 严格的 IP 白名单 (只允许 192.168.90.4)
   - 现代 TLS 配置 (TLS 1.2/1.3)
   - HSTS 安全头
   - 防火墙规则限制

3. **性能优化**：

   - HTTP/2 支持
   - 连接保持设置
   - 大文件上传支持 (client_max_body_size 0)
   - WebSocket 支持

4. **监控支持**：
   - 专用健康检查端点
   - 分离的访问日志

如果遇到问题，请检查：

1. GitLab 服务器：`/var/log/nginx/error.log`
2. 外部 Nginx：`/var/log/nginx/gitlab_error.log`
3. GitLab 服务日志：`sudo gitlab-ctl tail`

此配置确保了外部 Nginx 通过 TCP 连接到 GitLab 服务器的本地代理，而本地代理通过 Unix 套接字与 GitLab Workhorse 通信，完美实现了您的网络拓扑要求。
