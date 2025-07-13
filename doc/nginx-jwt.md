# Nginx + JWT 验证

通过 Nginx 反向代理 + JWT 验证，你可以在 **不修改 Dify 代码** 的前提下实现用户 Token 校验，并确保只有合法用户才能访问智能应用。该方案适用于 Dify 原生不支持 Token 认证的场景，同时提供了灵活的安全控制能力。

1. 方案目标

    | 目标 | 实现方式 |
    |------|----------|
    | **Token 校验** | Nginx 拦截请求并验证 JWT |
    | **用户身份传递** | 将 JWT 中的 `user_id` 透传到 Dify 后端 |
    | **WebSocket 支持** | 支持 WebSocket 协议升级和 Token 校验 |
    | **安全加固** | HTTPS 加密、防止 Token 泄露、限制请求方法 |

2. 技术选型

    | 组件 | 版本要求 | 说明 |
    |------|----------|------|
    | **Nginx** | 支持 `ngx_http_auth_jwt_module` 模块 | 核心反向代理 |
    | **JWT 验证模块** | `ngx_http_auth_jwt_module` 或 `OpenResty` | 验证 JWT 签名 |
    | **公钥/私钥** | RSA 2048 位 | 用于 JWT 签名与验证 |
    | **HTTPS** | TLS 1.2+ | 加密通信 |
    | **Dify** | 任意版本 | 不需要修改 Dify 代码 |

3. 核心流程

    ```mermaid
    graph TD
        A[前端携带 JWT 请求 Nginx] --> B[Nginx 验证 JWT]
        B -->|验证通过| C[转发请求到 Dify]
        B -->|验证失败| D[返回 401 未授权]
        C --> E[Dify 处理请求]
        E --> F[返回响应]
    ```

4. Nginx JWT 验证配置步骤

    1. 安装 Nginx 并启用 JWT 模块

        方法一：使用 `ngx_http_auth_jwt_module`
        - 编译 Nginx 时添加 `--add-module=../njet/nginx`（[njet](https://github.com/bakins/nginx-jwt) 提供的模块）。

        方法二：使用 OpenResty
        - OpenResty 内置 JWT 支持，推荐使用。

    2. 生成 RSA 公钥/私钥

        ```bash
        # 生成私钥
        openssl genrsa -out jwt.key 2048

        # 生成公钥
        openssl rsa -in jwt.key -pubout > jwt.pub
        ```

    3. Nginx 配置文件示例

        ```nginx
        # Nginx 配置文件（/etc/nginx/conf.d/dify.conf）

        # 定义 JWT 公钥
        http {
            auth_jwt_key_file /etc/nginx/jwt.pub;

            server {
                listen 443 ssl;
                server_name dify.example.com;

                ssl_certificate /etc/nginx/ssl/dify.crt;
                ssl_certificate_key /etc/nginx/ssl/dify.key;

                # JWT 验证配置
                location / {
                    # 启用 JWT 验证
                    auth_jwt "closed site";
                    auth_jwt_key_file /etc/nginx/jwt.pub;

                    # 将 JWT 中的 user_id 透传到 Dify
                    proxy_set_header X-User-ID $jwt_claim_sub;

                    # 反向代理到 Dify
                    proxy_pass http://localhost:5000;

                    # WebSocket 升级配置
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "upgrade";
                }

                # 允许无需 Token 的路径（如登录接口）
                location /login {
                    proxy_pass http://localhost:5000/login;
                }

                # Token 校验失败时的响应
                error_page 498 401 /401.html;
                location = /401.html {
                    return 401 '{"error": "Invalid or missing token"}';
                }
            }
        }
        ```

    4. WebSocket 路径配置

        ```nginx
        location /ws/ {
            # 启用 JWT 验证
            auth_jwt "closed site";
            auth_jwt_key_file /etc/nginx/jwt.pub;

            # WebSocket 升级头
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            proxy_pass http://localhost:5000/ws/;
        }
        ```

5. 安全加固措施

    1. **HTTPS 强制加密**

        ```nginx
        # 强制 HTTPS 重定向
        server {
            listen 80;
            return 301 https://$host$request_uri;
        }
        ```

    2. **限制请求方法**

        ```nginx
        if ($request_method !~ ^(GET|POST)$ ) {
            return 405;
        }
        ```

    3. **IP 白名单（可选）**

        ```nginx
        location / {
            allow 192.168.1.0/24;
            deny all;
            # 其他配置...
        }
        ```

    4. **Token 有效期控制**

        - 在生成 JWT 时设置 `exp` 字段（如 15 分钟）。
        - 前端定期刷新 Token（通过 `/login` 接口）。

6. JWT 生成与测试示例

    1. **生成 JWT（Python 示例）**

        ```python
        import jwt
        from datetime import datetime, timedelta

        def generate_jwt(user_id):
            payload = {
                "sub": user_id,  # 用户唯一标识
                "exp": datetime.utcnow() + timedelta(minutes=15)  # 15 分钟有效期
            }
            with open("jwt.key", "rb") as f:
                private_key = f.read()
            return jwt.encode(payload, private_key, algorithm="RS256")
        ```

    2. **测试请求（curl）**

        ```bash
        # 生成 Token
        token=$(python3 generate_jwt.py "user-123")

        # 发送请求
        curl -H "Authorization: Bearer $token" https://dify.example.com/api/v1/chat
        ```

7. 注意事项

    | 事项 | 说明 |
    |------|------|
    | **Nginx 模块兼容性** | 确保 Nginx 版本与 `ngx_http_auth_jwt_module` 兼容，或使用 OpenResty。 |
    | **公钥同步** | Dify 和 Nginx 应使用相同的 JWT 公钥/私钥对。 |
    | **WebSocket 路径匹配** | 确保 Nginx 的 `location` 路径与 Dify 的 WebSocket 路径一致。 |
    | **Token 刷新机制** | 前端需实现 Token 刷新逻辑，避免频繁 401 错误。 |
    | **日志记录** | 在 Nginx 中记录 Token 验证失败日志，用于安全审计。 |

## Nginx + 外部 Token

Nginx 验证外部 JWT Token 并透传用户身份到 Dify 的完整方案，涵盖 HTTPS 流式传输、WebSocket 支持、安全加固 和 与外部认证系统集成 的全流程配置。

1. 架构概览

    ```txt
    [Vue 前端]
        │
        └─── HTTPS 请求 Nginx（携带 JWT Token）
            │
            ▼
    [Nginx 反向代理]
            │
            ├──── JWT 验证（公钥验证签名）
            │
            ├──── 提取 user_id（从 JWT claim）
            │
            └──── 透传 X-User-ID 到 Dify
                │
                ▼
            [Dify + Qwen3 32B 服务]
    ```

2. 核心需求与实现方式

    | 功能 | 实现方式 |
    |------|----------|
    | **Token 由外部系统生成** | 使用 OAuth2/JWT 标准，如 Auth0、Keycloak、自建服务 |
    | **Nginx 验证 Token** | 使用 `auth_jwt` 模块验证 JWT 签名 |
    | **用户身份透传** | Nginx 提取 `sub` 字段并设置 `X-User-ID` 请求头 |
    | **HTTPS 流式支持** | 禁用 Nginx 缓冲，确保实时输出 |
    | **WebSocket 支持** | 配置协议升级头（Upgrade + Connection） |
    | **安全加固** | HTTPS 加密、防止 Token 泄露、限制请求方法 |

3. Nginx 完整配置（支持 JWT + 流式 + WebSocket）

    1. **Nginx 模块要求**
        - **启用 `ngx_http_auth_jwt_module`**（用于 JWT 验证）
        - **启用 `http_ssl_module`**（用于 HTTPS）
        - **启用 `http_v2_module`**（用于 HTTP/2 提升性能）

    2. **Nginx 配置文件（`/etc/nginx/conf.d/dify.conf`）**

        ```nginx
        # Nginx JWT 验证配置
        auth_jwt_key_file /etc/nginx/external-auth.pub;

        server {
            listen 443 ssl http2;
            server_name dify.example.com;

            # SSL 配置
            ssl_certificate /etc/nginx/ssl/dify.crt;
            ssl_certificate_key /etc/nginx/ssl/dify.key;
            ssl_protocols TLSv1.2 TLSv1.3;
            ssl_ciphers HIGH:!aNULL:!MD5;
            ssl_prefer_server_ciphers on;
            ssl_session_cache shared:SSL:10m;
            ssl_session_timeout 10m;
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

            # 主路径（支持流式输出）
            location / {
                # JWT 验证
                auth_jwt "closed site";
                auth_jwt_key_file /etc/nginx/external-auth.pub;

                # 透传用户身份
                proxy_set_header X-User-ID $jwt_claim_sub;

                # 反向代理配置
                proxy_pass http://localhost:5000;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";

                # 流式传输配置（禁用缓冲）
                proxy_buffering off;
                proxy_cache off;
                proxy_buffer_size 4k;
                proxy_buffers 8 4k;
                proxy_busy_buffers_size 8k;
            }

            # WebSocket 路径
            location /ws/ {
                auth_jwt "closed site";
                auth_jwt_key_file /etc/nginx/external-auth.pub;

                proxy_pass http://localhost:5000/ws/;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";

                proxy_buffering off;
                proxy_cache off;
            }

            # 允许无需 Token 的路径（如登录接口）
            location /login {
                proxy_pass http://localhost:5000/login;
            }

            # Token 校验失败时的响应
            error_page 498 401 /401.html;
            location = /401.html {
                return 401 '{"error": "Invalid or missing token"}';
            }
        }
        ```

4. 外部 Token 生成示例（Python）

    ```python
    import jwt
    from datetime import datetime, timedelta

    def generate_jwt(user_id):
        payload = {
            "sub": user_id,  # 用户唯一标识（user_id）
            "exp": datetime.utcnow() + timedelta(minutes=15),  # 15 分钟有效期
            "iat": datetime.utcnow(),
            "aud": "dify-app",  # 受众（可选）
            "iss": "external-auth"  # 签发者（可选）
        }
        with open("external-auth.key", "rb") as f:
            private_key = f.read()
        return jwt.encode(payload, private_key, algorithm="RS256")
    ```

5. Dify 接收用户身份信息

    1. **Dify 请求处理逻辑（Python Flask 示例）**

        ```python
        @app.before_request
        def validate_user():
            excluded_routes = ['/login', '/ws']
            if request.path in excluded_routes:
                return

            user_id = request.headers.get('X-User-ID')
            if not user_id:
                return jsonify({'error': 'Missing X-User-ID header'}), 400

            # 将 user_id 绑定到会话或上下文
            request.user_id = user_id
        ```

    2. **绑定上下文**

        ```python
        def get_user_context(user_id):
            # 从 Redis 或数据库查询用户上下文
            return redis.get(f"context:{user_id}")
        ```

6. 安全加固措施

    1. **HTTPS 强制加密**

        ```nginx
        # 强制 HTTPS 重定向
        server {
            listen 80;
            return 301 https://$host$request_uri;
        }
        ```

    2. **防止 Token 泄露**
        - **HttpOnly Cookie**：前端存储 Token 时使用 `HttpOnly + Secure` Cookie。
        - **短期 Token**：设置 Token 生命周期为 15 分钟，配合刷新机制。

    3. **WebSocket 安全**
        - **一次性 Token**：WebSocket 连接时使用短期 Token，避免长期暴露。
        - **Token 参数化**：URL 参数传递 Token（如 `wss://dify.example.com/ws/chat?token=<token>`）。

    4. **日志与审计**

        ```nginx
        log_format jwt_log '$remote_addr - $remote_user [$time_local] '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer" "$http_user_agent" '
                        'JWT: $auth_jwt_status';

        access_log /var/log/nginx/dify-access.log jwt_log;
        ```

7. 验证与测试

    1. **流式输出测试**

        ```bash
        curl -H "Authorization: Bearer <your-jwt-token>" https://dify.example.com/api/v1/chat
        ```

        如果能看到 **逐行输出** 的 AI 回答内容，则说明流式传输配置成功。

    2. **WebSocket 连接测试**

        ```bash
        wscat -c wss://dify.example.com/ws/chat?token=<your-jwt-token>
        ```

    3. **Token 校验失败测试**

        ```bash
        curl -I https://dify.example.com/api/v1/chat
        # 应返回 401 Unauthorized
        ```

## JWT Token 签名合法性验证

在标准实现中，每个用户应拥有独立的 Token，具有 Token 的唯一性：

- **JWT 结构**：每个 Token 包含 `sub` 字段（Subject），即用户唯一标识（如 `user-123`, `user-456`）。
- **示例 Token**：

  ```json
  {
    "sub": "user-123",  // 用户唯一标识
    "exp": 1717182000,  // 过期时间
    "iss": "auth-system" // 签发者
  }
  ```

认证系统生成规则：

- 外部认证系统（如 Auth0、Keycloak）为每个用户生成独立 Token。
- **不会出现多个用户共用同一个 Token**，除非认证系统配置错误（如固定 `sub` 字段）。

用户隔离机制：

- **Nginx 提取 `sub` 字段** 并透传到 Dify（如 `X-User-ID: user-123`）。
- **Dify 根据 `X-User-ID` 管理上下文**，确保用户数据隔离。

1. **JWT 验证原理**

    Nginx 通过 `auth_jwt` 模块验证 Token 的 **签名有效性**，而非用户身份。具体流程如下：

    验证流程：

    ```mermaid
    graph TD
        A[用户携带 Token 请求 Nginx] --> B[Nginx 提取 Token]
        B --> C[使用公钥验证 JWT 签名]
        C -->|签名有效| D[提取 Token 中的 claim（如 sub/exp）]
        D --> E[设置请求头 X-User-ID]
        E --> F[转发请求到 Dify]
    ```

    关键点：

    - **签名验证**：Nginx 使用公钥验证 Token 是否由可信认证系统签发。
    - **用户身份提取**：Nginx 从 Token 的 `sub` 字段提取用户 ID（无需修改 Token 内容）。
    - **动态支持所有用户**：只要 Token 的签名合法，Nginx 即可接受该 Token，无论用户是谁。

    动态支持多用户的关键：

    - **签名统一验证**：Nginx 使用同一公钥验证所有 Token 的签名。
    - **用户身份透传**：Nginx 将 Token 中的 `sub` 字段作为 `X-User-ID` 透传到 Dify。
    - **Dify 用户隔离**：Dify 根据 `X-User-ID` 管理会话和数据隔离。

2. 用户隔离与权限控制

    Nginx 的角色：

    - **仅验证 Token 合法性**：确保 Token 是由可信认证系统签发的。
    - **不涉及权限控制**：用户权限由 Dify 或后端服务管理。

    Dify 的用户隔离实现：

    - **基于 `X-User-ID` 的上下文管理**：

    ```python
    # 示例：Python Flask 服务
    @app.before_request
    def validate_user():
        user_id = request.headers.get('X-User-ID')
        if not user_id:
            return jsonify({'error': 'Missing X-User-ID header'}), 400

        # 将 user_id 绑定到会话或上下文
        request.user_id = user_id
    ```

    - **数据库/Redis 用户隔离**：

    ```python
    def get_user_context(user_id):
        # 从 Redis 查询用户专属上下文
        return redis.get(f"context:{user_id}")
    ```

3. 安全加固建议

    **Token 安全管理**

    - **短期 Token**：设置 Token 生命周期为 15 分钟，配合刷新机制。
    - **HTTPS 加密**：所有通信强制 HTTPS，防止 Token 泄露。
    - **HttpOnly Cookie**：前端存储 Token 时使用 `HttpOnly + Secure` Cookie。

    **防止 Token 滥用**

    - **黑名单机制**：当用户注销时，将 Token 加入黑名单（需认证系统支持）。
    - **IP 绑定**：在 Token 中加入 `ip` 字段，限制 Token 使用 IP（需认证系统支持）。

    **Nginx 日志审计**

    - **记录 Token 验证状态**：

    ```nginx
    log_format jwt_log '$remote_addr - $remote_user [$time_local] '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer" "$http_user_agent" '
                        'JWT: $auth_jwt_status';

    access_log /var/log/nginx/dify-access.log jwt_log;
    ```
