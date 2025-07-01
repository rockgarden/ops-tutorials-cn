# GitLab Tips

## 常用命令

```sh
# 启动所有 gitlab 组件
sudo gitlab-ctl start
# 停止所有 gitlab 组件
sudo gitlab-ctl stop
# 重启所有 gitlab 组件
sudo gitlab-ctl restart
# 查看服务状态
sudo gitlab-ctl status
# 配置服务
sudo gitlab-ctl reconfigure
# 修改默认的配置文件
sudo vim /etc/gitlab/gitlab.rb
# 检查服务
gitlab-rake gitlab:check SANITIZE=true --trace
# 查看操作日志
sudo gitlab-ctl tail
# 查看 puma 操作日志
sudo gitlab-ctl tail puma
# 以 ssh 或 easymail.eastcom.com 过滤
sudo gitlab-ctl tail | grep ssh
sudo gitlab-ctl tail | grep easymail.eastcom.com
```

```sh
sudo gitlab-ctl pg-password-md5 gitlab
Enter password: 52230401
Confirm password:
2575508f0a158a23baa031363b17ac48
```

```sh
// 查看数据库配置
cat /var/opt/gitlab/gitlab-rails/etc/database.yml
// 快速访问数据库
sudo gitlab-rails dbconsole --database main
// 查看用户信息
cat /etc/passwd
// 切换数据库用户
su - gitlab-psql
// 访问生产库
psql -h /var/opt/gitlab/postgresql -d gitlabhq_production
```

## 常用配置

/// 开机启动
`systemctl enable gitlab-runsvdir.service`
/// 禁止开机自启动
`systemctl disable gitlab-runsvdir.service`

1. 启用 HTTPS
    /// 默认情况下，omnibus-gitlab 不使用 HTTPS。
    `sudo vim /etc/gitlab/gitlab.rb`

    ```rb
    # 启用 https
    external_url 'https://gitlib.eastcomccmp.top'
    # 配置 nginx
    nginx['enable'] = true
    nginx['redirect_http_to_https'] = true
    nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlib.eastccmp.top.crt"
    nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlib.eastccmp.top.key"
    ```

    /// 创建/etc/gitlab/ssl 目录并在那里复制您的密钥 gitlib.eastcomccmp.top.key 和证书 gitlib.eastcomccmp.top.crt。
    `sudo mkdir -p /etc/gitlab/ssl`
    `sudo chmod 755 /etc/gitlab/ssl`
    `sudo cp gitlib.key gitlib.pem /etc/gitlab/ssl/`
    /// 远程 Copy
    `scp gitlib.key gitlib.pem root@192.168.97.115://etc/gitlab/ssl`
    /// 运行重新配置命令
    `sudo gitlab-ctl reconfigure`
    /// GitLab 实例应该可以访问 <https://gitlib.eastcomccmp.top>
    `sudo vim /var/opt/gitlab/gitlab-rails/etc/gitlab.yml`
    `sudo vim /var/opt/gitlab/nginx/conf/gitlab-http.conf`

2. Embedded Nginx
   /// 用 ps 命令查看路径：
   `ps -ef | grep nginx`
       root      3037 28554  0 14:10 ?
       00:00:00 nginx: master process /opt/gitlab/embedded/sbin/nginx -p /var/opt/gitlab/nginx
   /// 运行的 nginx 的路径是/opt/gitlab/embedded/sbin/nginx，而配置文件路径是/var/opt/gitlab/nginx，而不在/etc/nginx/nginx.conf 下没看到 gitlab 相关的配置。

   /// 注意：当用户运行  "sudo gitlab-ctl reconfigure”  会重置
   `cd /var/opt/gitlab/nginx/conf/nginx.conf` 下的 gitlab-http.conf nginx.conf  nginx-status.conf

3. 仓库存储位置的修改方法
   Repository storage paths: Url:help/administration/repository_storage_paths.md
   gitlab 通过 rpm 包安装后，默认存储位置在/var/opt/gitlab/git-data/repositories，通常需要更改此路径到单独的一个分区来存储仓库的数据。
   GitLab 允许您定义多个存储库存储路径来分发多个安装点之间的存储负载。
   注意：
   • 您必须至少有一个名为 default 的存储路径。
   • 路径是在键值对中定义的。 关键是你的任意名字
   • 可以选择命名文件路径。
   • 目标目录及其任何子路径不能是符号链接。
   /// 例如我这里把数据存放到  /data/gitlab 目录下
   /// 创建/data/gitlab 目录
   `mkdir -p /data/git-data`
   /// 修改 gitlab 配置文件，找到 git_data_dir
   `vim /etc/gitlab/gitlab.rb`
   /// 将 git_data_dir 改为以下配置：
   git_data_dirs({
     "default" => {
       "path" => "/data/git-data"
      },
     "alternative" => { "path" => "/mnt/data/git-data" }
   })
   `gitlab-ctl reconfigure`
   `gitlab-ctl stop`
   `sudo rsync -av /var/opt/gitlab/git-data/repositories /data/git-data/`
   `gitlab-ctl upgrade`
   `gitlab-ctl start`

   hashed-storage
   <https://docs.gitlab.com/ee/administration/raketasks/storage.html#migrate-existing-projects-to-hashed-storage>

4. 关闭开放注册
   去掉 Sign-up enabled 的对勾
   Admin-->settings --> Sign-in Restrictions
   Sign-upenbaled  关闭注册功能
   Sign-inenbaled  关闭注册登录功能

5. 客户端设置下 git 的用户名和邮箱
   在提交代码前，还需要设置下 git 的用户名和邮箱（最好用英文，不要出现中文），这样提交记录才会在 gitlab 上显示带有你名字的记录。
   在命令行窗口输入（windows 需要安装打开 Git Bash 工具才行）：
   `git config --global user.name "wangkan"`
   `git config --global user.email "wangakn@eastcom.com"`
   /// 导新项目到 gitlab 上，如果项目存在，需要导入到 gitlab，可以通过命令行直接将项目导入上去。

   ```sh
   cd "本地存在项目的路径"
   git init
   git remote add origin wangakn@eastcom.com:root/elasticsearch-python.git
   git add .
   git commit -m 'first git demo'
   git push -u origin master
   ```

   注：将 USERNAME 和 PROJECTNAME 替换成用户名和项目的名称

6. SMTP on localhost
   如果您希望通过 SMTP 服务器而不是通过 Sendmail 发送应用程序电子邮件，请将以下配置信息添加到/etc/gitlab/gitlab.rb 并运行 gitlab-ctl reconfigure。
   警告：您的 smtp_password 不应包含 Ruby 或 YAML（f.e.'）中使用的任何字符串分隔符，以避免在处理配置设置期间发生意外行为。
   This configuration, which simply enables SMTP and otherwise uses the default settings, can be used for an MTA running on localhost that does not provide a sendmail interface or that provides a sendmail interface that is incompatible with GitLab, such as Exim.这种配置简单地启用 SMTP，使用默认 my 设置，可用于在 localhost 上运行的 MTA，该 MTA 不提供 sendmail 界面或提供与 GitLab 不兼容的 sendmail 界面，如 Exim。
   SMTP settings
   If you would rather send application email via an SMTP server instead of via Sendmail, add the following configuration information to /etc/gitlab/gitlab.rb and run gitlab-ctl reconfigure.
   Warning: Your smtp_password should not contain any String delimiters used in Ruby or YAML (f.e. ') to avoid unexpected behavior during the processing of config settings.

7. SMTP_Settings
   <https://docs.gitlab.com/omnibus/settings/smtp.html#smtp-settings>

   测试：

   ```shsh
   sudo gitlab-rails console production
   Notify.test_email('wangkan@eastcom.com','Message Subjec','Message Body').deliver_now
   ```

   /// 配置示例 /etc/gitlab/gitlab.rb

   ```rb
   gitlab_rails['smtp_enable'] = true
   gitlab_rails['smtp_address'] = "10.0.0.2"
   gitlab_rails['smtp_port'] = 25
   gitlab_rails['smtp_user_name'] = "wangkan"
   gitlab_rails['smtp_password'] = "Eastcom30401"
   # gitlab_rails['smtp_domain'] = "eastcom.com"
   gitlab_rails['smtp_authentication'] = "login"
   gitlab_rails['smtp_enable_starttls_auto'] = false
   gitlab_rails['smtp_tls'] = false
   gitlab_rails['gitlab_email_from'] = 'wangkan@eastcom.com'
   gitlab_rails['gitlab_email_reply_to'] = 'wangkan@eastcom.com'
   ```

   重启服务：`sudo gitlab-ctl reconfigure`

8. Embedded Nginx 配置
   <https://docs.gitlab.com/omnibus/settings/nginx.html>

   ```sh
   cd /var/opt/gitlab/nginx/conf
   vim nginx.conf
   cd /var/log/gitlab/nginx
   vim /var/log/gitlab/nginx/error.log
   ///  Update the SSL Certificates
   sudo gitlab-ctl hup nginx
   /// 重启 embedded nginx
   sudo gitlab-ctl restart nginx
   sudo gitlab-ctl tail nginx
   ```

9. 导出 Issue
   相应 API 接口说明文档网址为： <https://docs.gitlab.com/ce/api/>

   首先要获取 gitlab 里所有 group 的 id

   `curl --header "PRIVATE-TOKEN: spsazQxnWK_H5x4znKU2" https://192.168.97.115/api/v3/groups/`
     PRIVATE-TOKEN  的值是在 gitlab 里的 <https://192.168.97.115/profile/personal_access_tokens> 页面生成的
     v3 表示 API 的版本
     gitlab 返回的数据是 json 格式的字符串，可以用如下方式直接在本地生成一个 json 文件，以方便后续处理：
   `curl --header "PRIVATE-TOKEN: spsazQxnWK_H5x4znKU2"  https://192.168.97.115/api/v4/groups > /Users/wangkan/Downloads/group.json`

   如 project 所属的 group id 为 10，用以下方式可以获得 project 的 id
   `curl --header "PRIVATE-TOKEN: xxx"   https://192.168.97.115/api/v4/groups/11/projects > /Users/xxx/Downloads/project.json`
     project.json 中包含此 group 里所有 project 的信息

   如 project 的 id 是 100，用以下方式可以获得 project 的 issue
   `curl --header "PRIVATE-TOKEN: xxx" https://192.168.97.115/api/v4/projects/59/issues >/Users/ruwang/Downloads/issue.json`
   gitlab 默认服务器端每次只返回 20 条数据给客户端，可以用设置 page 和 per_page 参数的值，指定服务器端返回的数据个数。
   `curl --header "PRIVATE-TOKEN: xxx" https://192.168.97.115/api/v4/projects/59/issues?per_page=500&page=1 >/Users/ruwang/Downloads/issue.json`
   执行上述代码，服务器端会返回 50 条数据，且是在服务器端对数据进行分页处理后，第二页的 50 条数据。

   把 issue.json 文件上传到：<https://json-csv.com/>，就会自动生成 excel 文件，然后可以下载到本机。

   导出 Issue.csv 通过 Excel 打开乱码，文件转码 UTF-8 with BOM。

### NGINX 配置设置

要配置不同服务的 NGINX 设置，请编辑 `/etc/gitlab/gitlab.rb` 文件。

你可以使用 `nginx['<setting>']` 来配置 GitLab Rails 应用的 NGINX 设置。GitLab 同样为其他服务提供了类似的配置项，例如：\

- `pages_nginx`
- `mattermost_nginx`
- `registry_nginx`

这些服务的 NGINX 配置与 GitLab 主 NGINX 使用相同的默认值。

> 如果你想单独运行某些服务（如 Mattermost），应使用 `gitlab_rails['enable'] = false` 而不是 `nginx['enable'] = false`。更多信息请参阅：[在独立服务器上运行 GitLab Mattermost](https://docs.gitlab.com/ee/administration/mattermost/setup.html)。

当你修改 `gitlab.rb` 文件时，**需要为每个服务单独配置 NGINX 设置**。例如，使用 `nginx['foo']` 设置的参数不会自动复制到 `registry_nginx['foo']` 或 `mattermost_nginx['foo']` 中。

示例：为 GitLab、Mattermost 和 Registry 启用 HTTP 到 HTTPS 重定向：

```ruby
nginx['redirect_http_to_https'] = true
registry_nginx['redirect_http_to_https'] = true
mattermost_nginx['redirect_http_to_https'] = true
```

1. 启用 HTTPS

   默认情况下，Linux 包安装 **不启用 HTTPS**。要为 `gitlab.example.com` 启用 HTTPS，有以下两种方式：

   1. **使用 Let’s Encrypt 提供免费、自动化的 HTTPS 支持**
   2. **手动配置 HTTPS 并使用你自己的证书**

   如果你使用了代理、负载均衡器或其他外部设备来终止 SSL，请参考：[外部代理和负载均衡器的 SSL 终止配置](https://docs.gitlab.com/ee/administration/nginx.html#external-proxy-and-load-balancer-ssl-termination)

2. 修改默认的代理请求头（Proxy Headers）

   默认情况下，当你设置了 `external_url`，Linux 包安装会自动配置适合大多数环境的 NGINX 请求头。

   例如，如果你在 `external_url` 中指定了 `https` 协议，系统将自动设置以下请求头：

   ```ruby
   "X-Forwarded-Proto" => "https",
   "X-Forwarded-Ssl" => "on"
   ```

   如果你的 GitLab 实例部署在更复杂的环境中（例如位于反向代理之后），可能需要自定义这些请求头，以避免出现如下错误：

   ```log
   The change you wanted was rejected
   Can't verify CSRF token authenticity Completed 422 Unprocessable
   ```

   要覆盖默认的请求头：

   编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   nginx['proxy_set_headers'] = {
   "X-Forwarded-Proto" => "http",
   "CUSTOM_HEADER" => "VALUE"
   }
   ```

   保存文件后，重新配置 GitLab 使更改生效：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

   你可以指定任何 NGINX 支持的请求头字段。

3. 配置 GitLab 可信代理和 NGINX 的 real_ip 模块

   默认情况下，**NGINX 和 GitLab 会记录连接客户端的 IP 地址**。

   如果你在 GitLab 前面使用了 **反向代理（reverse proxy）**，你可能不希望显示的是代理服务器的 IP 地址，而是客户端的真实 IP。

   要配置 NGINX 使用客户端真实 IP，请将你的反向代理地址添加到 `real_ip_trusted_addresses` 列表中：

   ```ruby
   # 每个地址都会被写入 NGINX 配置为：'set_real_ip_from <address>;'
   # 反向代理地址为：183.247.163.49
   nginx['real_ip_trusted_addresses'] = [ '192.168.1.0/24', '192.168.2.1', '2001:0db8::/32' ]

   # 其他 real_ip 相关配置选项
   nginx['real_ip_header'] = 'X-Forwarded-For'
   nginx['real_ip_recursive'] = 'on'
   ```

   有关这些配置项的详细说明，请参阅：[NGINX realip 模块文档](http://nginx.org/en/docs/http/ngx_http_realip_module.html)

   默认情况下，Linux 包安装方式会将 `real_ip_trusted_addresses` 中列出的地址作为 GitLab 的 **可信代理（trusted proxies）**。  
   这样做的目的是防止用户在日志或界面中显示为从这些代理 IP 登录。

   应用更改步骤：

   1. 编辑 `/etc/gitlab/gitlab.rb`
   2. 添加或修改相关配置项
   3. 保存文件
   4. 执行以下命令使配置生效：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

4. 配置 PROXY 协议

   如果你想在 GitLab 前面使用支持 **PROXY 协议** 的代理（如 HAProxy），请按以下步骤配置：

   编辑 `/etc/gitlab/gitlab.rb` 文件：

   ```ruby
   # 启用 NGINX 对 PROXY 协议的支持
   nginx['proxy_protocol'] = true

   # 配置可信的上游代理地址（启用 proxy_protocol 后此配置为必填）
   nginx['real_ip_trusted_addresses'] = [ "127.0.0.0/8", "代理服务器的IP地址/32" ]
   ```

   保存文件后，重新配置 GitLab 以使更改生效：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

   注意事项：

   启用该设置后，NGINX **只会接受符合 PROXY 协议的流量** 进入这些监听端口。  
   如果你有其他依赖普通 HTTP 请求的环境（例如监控系统、健康检查等），你需要相应地进行调整，以确保它们也能够使用 PROXY 协议或绕过代理直接访问。

5. 设置 NGINX 监听地址

   默认情况下，NGINX 会监听本地所有的 IPv4 地址。

   如果你想更改监听的地址列表：

   编辑 `/etc/gitlab/gitlab.rb` 文件：

   ```ruby
   # 监听所有 IPv4 和 IPv6 地址
   nginx['listen_addresses'] = ["0.0.0.0", "[::]"]
   registry_nginx['listen_addresses'] = ['*', '[::]']
   mattermost_nginx['listen_addresses'] = ['*', '[::]']
   pages_nginx['listen_addresses'] = ['*', '[::]']
   ```

   保存文件后，重新配置 GitLab 以使更改生效：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

6. 设置 NGINX 监听端口

   默认情况下，NGINX 会监听你在 `external_url` 中指定的端口，如果没有指定，则使用标准端口（HTTP 使用 80，HTTPS 使用 443）。

   如果你在反向代理后面运行 GitLab，可能需要修改监听端口。

   要更改监听端口：

   编辑 `/etc/gitlab/gitlab.rb` 文件。例如，使用端口 `8081`：

   ```ruby
   nginx['listen_port'] = 8081
   ```

   保存文件并重新配置 GitLab：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

7. 更改 NGINX 日志的详细级别（日志等级）

   默认情况下，NGINX 的日志等级为 `error` 级别。

   如果你想更改日志等级（例如调试时需要更详细的日志）：

   编辑 `/etc/gitlab/gitlab.rb` 文件：

   ```ruby
   nginx['error_log_level'] = "debug"
   ```

   保存文件并重新配置 GitLab：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

   > ✅ 支持的日志等级包括：`debug`、`info`、`notice`、`warn`、`error`、`crit`、`alert`、`emerg`  
   > 更多信息请参考 [NGINX 官方文档](http://nginx.org/en/docs/ngx_core_module.html#LogLevel)

8. 设置 `Referrer-Policy` 请求头

   默认情况下，GitLab 会在所有响应中设置 `Referrer-Policy` 请求头为 `strict-origin-when-cross-origin`。该设置会使客户端：

   - 对**同源请求**发送完整的 URL 作为 referrer。
   - 对**跨域请求**仅发送源（origin）信息。

   要更改此请求头：

   编辑 `/etc/gitlab/gitlab.rb` 文件：

   ```ruby
   nginx['referrer_policy'] = 'same-origin'
   ```

   如果你想禁用该请求头，使用浏览器默认行为：

   ```ruby
   nginx['referrer_policy'] = false
   ```

   保存文件后，重新配置 GitLab 以使更改生效：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

   > ⚠️ 注意：将 `referrer_policy` 设置为 `origin` 或 `no-referrer` 可能会导致某些需要完整 referrer URL 的 GitLab 功能异常。

   如需了解更多，请参考 [Referrer Policy 规范](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Referrer-Policy)

9. 禁用 Gzip 压缩

   默认情况下，GitLab 会对大于 10240 字节的文本数据启用 Gzip 压缩。如果你希望禁用 Gzip 压缩：

   编辑 `/etc/gitlab/gitlab.rb` 文件：

   ```ruby
   nginx['gzip_enabled'] = false
   ```

   保存文件并重新配置 GitLab：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

   > ✅ 此设置**仅影响主 GitLab 应用程序**，不影响其他服务（如 Registry、Pages 等）。

10. 禁用代理请求缓冲（Request Buffering）

对于某些特定路径（如上传大文件或执行 Git 操作），你可能希望**关闭请求缓冲**以提升性能或避免内存问题。

要禁用特定路径的请求缓冲：

编辑 `/etc/gitlab/gitlab.rb` 文件：

```ruby
nginx['request_buffering_off_path_regex'] = "/api/v\\d/jobs/\\d+/artifacts$|/import/gitlab_project$|\\.git/git-receive-pack$|\\.git/ssh-receive-pack$|\\.git/ssh-upload-pack$|\\.git/gitlab-lfs/objects|\\.git/info/lfs/objects/batch$"
```

保存文件后，重新配置 GitLab：

```bash
sudo gitlab-ctl reconfigure
```

平滑重载 NGINX 配置

在修改 NGINX 配置后，你可以使用以下命令**平滑重载配置**（不中断现有连接）：

```bash
sudo gitlab-ctl hup nginx
```

如需了解 `hup` 命令的更多细节，请参考 [NGINX 官方文档](https://nginx.org/en/docs/control.html)

## 常用操作

### 安装

在 CentOS 7（以及 RedHat/Oracle/Scientific Linux 7）上

1. 安装并配置必要的依赖关系  

    ```sh
    # 安装依赖
    sudo yum install -y curl policycoreutils-python openssh-server
    # 开启 SSH 访问权限
    sudo systemctl enable sshd
    sudo systemctl start sshd
    # 开启 HTTP 访问权限
    sudo firewall-cmd --permanent --add-service=http
    sudo systemctl reload firewalld
    ```

    接下来，安装 Postfix 以发送通知邮件。如果您希望使用其他方案来发送邮件，请跳过此步骤，并在安装 GitLab 后配置外部 SMTP 服务器。

    ```sh
    sudo yum install postfix
    sudo systemctl enable postfix
    sudo systemctl start postfix
    ```

    在安装 Postfix 过程中可能会出现配置界面。请选择“Internet Site”，然后按回车键。在“mail name”一栏中，输入您的服务器的外部 DNS 名称，然后按回车键。如果后续还有其他配置界面出现，请继续按回车键以接受默认选项。

    /// 调整安装目录
    GitLab 默认将其数据存储在 `/var/opt/gitlab` 目录中。如果您希望将数据存储在其他分区上，可以将该目录移动到新的位置，并创建一个指向它的符号链接。

    例如，如果您希望将数据存储在 `/data/opt/gitlab` 中，可以按照以下步骤操作：

    ```sh
    sudo mkdir -p /data/var/opt/gitlab
    <!-- sudo gitlab-ctl stop -->
    sudo mv /var/opt/gitlab/* /data/var/opt/gitlab/
    sudo rm -rf /var/opt/gitlab
    sudo ln -sf /data/var/opt/gitlab /var/opt/gitlab
    ```

    > 注意：sudo ln 要在 sudo rm 之后执行，否则无法创建符号链接。
    > 注意：如果你在安装 GitLab 之前更改了数据目录，请确保在 `/etc/gitlab/gitlab.rb` 中设置了 `git_data_dir` 和其他相关配置。

2. 在 GreatWall 内要添加 GitLab 软件包仓库并安装 GitLab 的步骤如下：

    安装 cent-os 的配置时，可不新建 repo 文件，直接在 CentOS-Base.repo 最后加入文档中描述的内容：

    ```txt
    [gitlab-ce]
    name=Gitlab CE Repository
    baseurl= https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
    gpgcheck=0
    enabled=1

    [root@localhost ~]# cat << EOF > /etc/yum.repos.d/gitlab-ce.repo

    > [gitlab-ce]
    > name=gitlab-ce
    > baseurl= https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/
    > repo_gpgcheck=0
    > gpgcheck=0
    > enable=1
    > gpgkey= https://packages.gitlab.com/gpg.key
    > EOF
    ```

    后保存并运行：
    yum clean all
    yum makecache
    yum update
    yum install gitlab-ce

    注意：若已经运行过 Add the GitLab package repository 命令
    `curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash`
    需要删除  gitlab_gitlab-ce.repo / gitlab_gitlab-ee.repo 否则仍使用海外地址。

    接下来，安装 GitLab 软件包。将 <http://gitlab.example.com> 更改为您要访问您的 GitLab 实例的 URL。安装将自动配置并启动该 URL 的 GitLab。HTTPS 安装后需要额外的配置。

    `sudo EXTERNAL_URL="http://gitlab.example.com"`
    `yum install -y gitlab-ce`

3. 访问主机名并登录

    首次访问时，页面会将你重定向到密码重置界面。请输入初始管理员账户的密码，然后你会被重定向回登录界面。使用默认账户用户名 **root** 进行登录。

4. 设置您的沟通偏好

    如需获取有关漏洞和系统性能的**关键安全更新**，请访问我们的邮件订阅偏好中心订阅我们的专属安全通讯。

    **重要提示：** 如果您未订阅安全通讯，将**不会收到安全警报**。

5. Make SSH Key
    `ssh -keygen -t rsa -C "wangkan@eastcom.com" -b 4096`
    pbcopy < /Users/wangkan/.ssh/id_gitlab_rsa.pub
    Note：Enter passphrase (empty for no passphrase) :时，可以直接按两次回车键输入一个空的 passphrase；也可以选择输入一个 passphrase 口令，如果此时你输入了一个 passphrase，请牢记，之后每次提交时都需要输入这个口令来确认。
    实践过程中 Android studio 如果有密码无法同步，建议不要密码。
    获取 SSH 公钥信息：
    SSH 密钥生成结束后，根据提示信息找到 SSH 目录，会看到私钥 id_rsa 和公钥 id_rsa.pub 这两个文件，不要把私钥文件 id_rsa 的信息透露给任何人。我们可以通过 cat 命令或文本编辑器来查看 id_rsa.pub 公钥信息。
    （1）通过文本编辑器，如 Sublime Text 等软件打开 id_rsa.pub，复制里面的所有内容以备下一步使用。
    （2）通过 cat 命令。在命令行中敲入 cat id_rsa.pub，回车执行后命令行界面中会显示 id_rsa.pub 文件里的内容，复制后在下一步使用。
    （3）通过直接使用命令将 id_rsa.pub 文件里的内容复制到剪切板中
    Windows: clip < ~/.ssh/id_rsa.pub
    Mac: pbcopy < ~/.ssh/id_rsa.pub
    GNU/Linux (requires xclip): xclip -sel clip < ~/.ssh/id_rsa.pub

6. Mac 要自己配置 config 来添加自定义的 SSH 私钥

    github

    Host github.com
    HostName github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_rsa_github //github 对应的私钥

    wangkan$ cd /etc/ssh/
    ssh wangkan$ ls ssh_config sshd_config
    ssh wangkan$ vim ssh_config
    ssh wangkan$ vim sshd_config

### 升级

/// 查看版本
`sudo rpm -q gitlab-ce`
// 确认升级路径<https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/>
15.11.13 => 16.3.9 => 16.7.10 => 16.11.10 => 17.1.8 => 17.3.7 => 17.5.5 => 17.8.7 => 17.11.4 => 18.0.2
/// 在升级前所有监控>后台迁移（Background Migrations）迁移都必须处于“完成”状态

/// 离线更新
/// 下载地址<https://packages.gitlab.com/gitlab/gitlab-ce>，下载指定版本的 rpm 包

```bash
# 本地下载后复制到服务器上
scp gitlab-ce-16.3.9-ce.0.el7.x86_64.rpm root@192.168.97.105://data/software/
# 通过 yum 安装指定版本的 rpm 包
cd /data/software
sudo yum install gitlab-ce-16.3.9-ce.0.el7.x86_64.rpm`
# 或者使用 rpm 命令安装指定版本的 rpm 包
rpm -Uvh gitlab-ce-16.3.9-ce.0.el7.x86_64.rpm
```

/// 在线更新

```sh
# 查看版本列表
yum list | grep gitlab
yum --showduplicates list gitlab-ce
# 更新到指定版本
sudo yum install -y gitlab-ce-17.11.4
```

/// gitlab-ce 与内置的 PostgreSQL 版本不兼容，需要单独升级 PostgreSQL 版本。

```sh
gitlab-psql -V
psql (PostgreSQL) 12.7

gitlab-ctl pg-upgrade
Checking for an omnibus managed postgresql: OK
Checking if postgresql['version'] is set: OK
Checking if we already upgraded: NOT OK
Checking for a newer version of PostgreSQL to install
Upgrading PostgreSQL to 13.11
Checking if disk for directory /data/gitlab/postgresql/data has enough free space for PostgreSQL upgrade: OK
Checking if PostgreSQL bin files are symlinked to the expected location: OK
Waiting 30 seconds to ensure tasks complete before PostgreSQL upgrade.
See https://docs.gitlab.com/omnibus/settings/database.html#upgrade-packaged-postgresql-server for details
...
==== Upgrade has completed ====
Please verify everything is working and run the following if so
sudo rm -rf /var/opt/gitlab/postgresql/data.12
sudo rm -f /var/opt/gitlab/postgresql-version.old
```

### 备份

<https://docs.gitlab.com/omnibus/settings/backups.html>

设置数据备份路径

```sh
# 创建目录
sudo mkdir -p /data/gitlab/backups
# 编辑配置
vim /etc/gitlab/gitlab.rb
# 启用备份目录管理：设置ture时，该目录归运行GitLab的用户所有；设置false时，只有user['username'] 中指定的用户访问。
# gitlab_rails['manage_backup_path'] = true
# 默认路径 /var/opt/gitlab/backups
# gitlab_rails['backup_path'] = "/data/gitlab/backups"
# 生效配置
sudo gitlab-ctl reconfigure
```

```bash
# 停止可选服务
sudo gitlab-ctl stop sidekiq
# 验证状态：
sudo gitlab-ctl status
# 运行备份
sudo gitlab-backup create
# 备份文件确认
cd /data/gitlab/backups
# 复制到目标服务器
scp 1667540632_2022_11_04_14.0.12_gitlab_backup.tar root@192.168.97.105://var/opt/gitlab/backups/
```

### 恢复

<https://docs.gitlab.com/administration/backup_restore/restore_gitlab/>

GitLab 的恢复操作用于从备份中恢复数据，以维持系统的连续性并应对数据丢失情况。

恢复操作包括：

- 恢复数据库记录和配置信息
- 恢复 Git 仓库、容器镜像仓库中的镜像以及上传的内容
- 恢复包仓库数据和 CI/CD 构建产物（artifacts）
- 恢复用户账户和群组设置
- 恢复项目和群组的 Wiki 页面
- 恢复项目级别的安全文件
- 恢复外部合并请求的差异（diff）内容

> 恢复流程要求使用与备份**版本一致**的 GitLab 安装环境。

1. 恢复的前提条件

   - 目标 GitLab 实例必须已经正常运行
     在执行恢复操作之前，你需要有一个正常运行的 GitLab 安装实例。这是因为执行恢复操作的系统用户（通常是 git 用户）通常没有权限创建或删除要导入数据的 SQL 数据库（例如 gitlabhq_production）。所有现有的数据将被清除（如 SQL 数据库）或者移动到其他目录（如仓库和上传文件）。SQL 数据恢复过程中会跳过由 PostgreSQL 扩展所拥有的视图。

   - 目标 GitLab 实例必须是完全相同的版本
     你只能将备份恢复到与其创建时**完全相同版本和类型**的 GitLab 上。
     如果你的当前 GitLab 安装版本与备份版本不一致，则必须先对 GitLab 进行升级或降级，然后再进行恢复。

   - 必须恢复 GitLab 密钥（secrets）
     要成功恢复备份，还必须恢复 GitLab 的密钥文件。如果你正在迁移到新的 GitLab 实例上，则需要从旧服务器复制 GitLab 的密钥文件。这些密钥包括数据库加密密钥、CI/CD 变量以及用于双因素认证的变量。如果没有这些密钥，会导致多个问题，例如启用了双因素认证的用户无法访问系统，以及 GitLab Runner 无法登录等问题。

     需要恢复的密钥文件包括：

     - 对于 Linux 包安装方式：/etc/gitlab/gitlab-secrets.json
     - 对于自行编译安装方式：/home/git/gitlab/.secret

   - 某些 GitLab 配置必须与原始备份环境一致  
     你可能需要单独恢复之前的配置文件 `/etc/gitlab/gitlab.rb`（适用于 Linux 包安装）或 `/home/git/gitlab/config/gitlab.yml`（适用于自行编译安装），以及任何 TLS 或 SSH 密钥和证书。

     某些配置与 PostgreSQL 中的数据相关联。例如：

     - 如果原始环境中配置了三个仓库存储路径，那么目标环境的配置中也必须至少包含这些相同的存储名称。
     - 即使目标环境使用的是对象存储，从使用本地存储的环境中恢复备份时，仍将恢复到本地存储。迁移到对象存储的操作必须在恢复之前或之后完成。

2. 针对 Linux 包安装方式的恢复流程

   本流程假设你已经：

   - 安装了与备份创建时**完全相同版本和类型**的 GitLab。
   - 至少运行过一次 `sudo gitlab-ctl reconfigure` 命令。
   - GitLab 当前正在运行。如果不是，请使用以下命令启动：`sudo gitlab-ctl start`

   首先，确保你的备份 `.tar` 文件位于 `gitlab.rb` 配置中指定的备份目录中：  
   `gitlab_rails['backup_path']`。默认路径是 `/var/opt/gitlab/backups`。  
   该备份文件需要由 `git` 用户拥有。

   Shell 示例：

   ```bash
   sudo scp 1751342891_2025_07_01_17.5.5_gitlab_backup.tar root@192.168.97.105://var/opt/gitlab/backups/
   sudo chown git:git /var/opt/gitlab/backups/1751342891_2025_07_01_17.5.5_gitlab_backup.tar
   ```

   停止连接数据库的服务进程，但保留 GitLab 的其他部分继续运行：

   ```bash
   sudo gitlab-ctl stop puma
   sudo gitlab-ctl stop sidekiq

   # 验证状态：
   sudo gitlab-ctl status
   ```

   接下来，请确保你已完成恢复前提条件中的步骤，并且在从原始安装复制了 GitLab 配置与密钥文件后，已执行过 `gitlab-ctl reconfigure`。

   Shell 示例：

   ```bash
   # 复制备份的 gitlab.rb 配置文件到目标服务器
   scp gitlab.rb root@192.168.97.105://etc/gitlab/
   # 复制密钥文件到目标服务器
   scp /etc/gitlab/gitlab-secrets.json root@192.168.97.105://etc/gitlab/
   # 复制TLS证书到目标服务器
   scp /etc/pki/tls/ssl/. root@192.168.97.105://etc/pki/tls/ssl/
   # 执行
   sudo gitlab-ctl reconfigure
   ```

   然后，开始恢复备份，需指定你要恢复的备份 ID：

   ```bash
   # 注意：名称中不包含 "_gitlab_backup.tar"
   sudo gitlab-backup restore BACKUP=1751342891_2025_07_01_17.5.5
   ```

   > 如果备份文件中的 GitLab 版本与当前安装的版本不一致，恢复命令会中止并提示错误信息：`GitLab version mismatch`，请安装正确的 GitLab 版本后重试。

   restore命令执行完成后，在 PostgreSQL 节点上执行重新配置：

   ```bash
   sudo gitlab-ctl reconfigure
   ```

   然后启动并检查 GitLab 状态：

   ```bash
   sudo gitlab-ctl start
   sudo gitlab-rake gitlab:check SANITIZE=true
   # 验证数据库值是否可以解密，特别是当你恢复了 `/etc/gitlab/gitlab-secrets.json` 文件，或者目标服务器不是原来的服务器时：
   sudo gitlab-rake gitlab:doctor:secrets
   ```

   为了进一步确认数据完整性，你可以对上传的文件执行完整性检查：

   ```bash
   sudo gitlab-rake gitlab:artifacts:check
   sudo gitlab-rake gitlab:lfs:check
   sudo gitlab-rake gitlab:uploads:check
   ```

   在恢复完成后，建议生成数据库统计信息以提升性能并避免 UI 中出现不一致问题：

   进入数据库控制台，执行以下 SQL 命令：

   ```sql
   SET STATEMENT_TIMEOUT=0;
   ANALYZE VERBOSE;
   ```

### 配置同时支持域名访问和内网访问

要让 GitLab-CE 通过域名访问，同时内网访问时指向内网服务器，可以通过以下几种方式实现：

方案一：使用 DNS 分流（推荐）

1. 配置外部 DNS
   - 公网域名解析指向你的公网 IP 或负载均衡器
   - 例如：`gitlab.yourcompany.com` → 公网 IP

2. 配置内网 DNS
   - 在内网 DNS 服务器上为同一域名配置内网 IP
   - 例如：`gitlab.yourcompany.com` → 192.168.1.100

3. GitLab 配置
    保持 `/etc/gitlab/gitlab.rb` 简单配置：

    ```ruby
    external_url 'https://gitlab.yourcompany.com'
    ```

方案二：使用 Nginx 多监听配置

修改 GitLab 配置文件

```ruby
external_url 'https://gitlab.yourcompany.com'

# 监听所有接口
nginx['listen_addresses'] = ['0.0.0.0']

# 同时监听内网IP
nginx['additional_listen_addresses'] = {
  '192.168.1.100:80' => {},
  '192.168.1.100:443' => {
    'ssl_certificate' => '/etc/gitlab/ssl/gitlab.yourcompany.com.crt',
    'ssl_certificate_key' => '/etc/gitlab/ssl/gitlab.yourcompany.com.key'
  }
}
```

方案四：使用反向代理

1. 内网部署 Nginx 反向代理

    ```nginx
    server {
        listen 80;
        server_name gitlab.yourcompany.com;
        
        location / {
            proxy_pass http://192.168.1.100;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
    ```

2. GitLab 配置

    ```ruby
    external_url 'https://gitlab.yourcompany.com'
    nginx['listen_port'] = 8080
    nginx['listen_addresses'] = ['127.0.0.1']
    ```

方案五：区分内外网域名

```ruby
# 主配置使用外网域名
external_url 'https://gitlab.yourcompany.com'

# 内网使用不同域名或主机名
gitlab_rails['gitlab_ssh_host'] = 'gitlab.internal'
```

注意事项

1. **SSL 证书**：确保为域名配置了有效的 SSL 证书
2. **防火墙设置**：开放必要的端口（80, 443, 22等）
3. **配置生效**：每次修改后运行：

   ```bash
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart
   ```

4. **SSH 克隆**：如果需要内外网不同的 SSH 地址，可以设置：

   ```ruby
   gitlab_rails['gitlab_ssh_host'] = 'gitlab.internal'
   ```

验证配置

1. 外网访问：

   ```bash
   curl -I https://gitlab.yourcompany.com
   ```

2. 内网访问

   ```bash
   curl -I http://192.168.1.100
   ```

选择哪种方案取决于你的网络架构和需求。对于大多数企业环境，方案一（DNS 分流）是最简单和可维护的解决方案。

## bug

### 附件地址未转为外网地址

```json
"webUrl": "https://192.168.97.115/root/EN_ManagementPlatform/-/issues/801",
"webPath": "/root/EN_ManagementPlatform/-/issues/801",
```

查 issue 表中有否 webPath

vim /var/opt/gitlab/nginx/conf/gitlab-http.conf

```conf
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-For $remote_addr:$remote_port;

# Pass headers because we are serving monitoring endpoints directly without

# redirection

proxy_set_header Host $http_host_with_default;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;
proxy_set_header X-Forwarded-Proto https;
proxy_set_header X-Forwarded-Ssl on;
```

### ERROR: Registering runner... failed

`status=couldn't execute POST against https://gitlab.example.com/api/v4/runners: x509: certificate signed by unknown authority`

/// gitlab 使用自签名证书时，注册时需要加应用服务证书用于验证
/// 使用"--tls-ca-file"参数，指定自签名应用证书（server-gitlab.crt）

```txt
gitlab-runner register \
 --non-interactive \
 --tls-ca-file=/etc/pki/tls/ssl/server-gitlab.crt \
 --url " https://192.168.97.115/" \
 --registration-token "zsAZVAWHoX5ngXmzyi18" \
 --executor "shell" \
 --description "runner " \
 --tag-list "run" \
 --run-untagged \
 --locked="false"
gitlab-runner register \
 --non-interactive \
 --tls-ca-file=/etc/gitlab/ssl/server-gitlab.crt \
 --url " https://192.168.97.115/" \
 --registration-token "zsAZVAWHoX5ngXmzyi18" \
 --executor "docker" \
 --docker-image maven:latest \
 --description "runner " \
 --tag-list "run" \
 --run-untagged \
 --locked="false"
```

`status=502 Bad Gateway`
/// 网站给出的 url `https://192.168.97.115` 应改为 url `https://192.168.97.115/`

### Git clone SSL certificate error

`Error: unable to access ' https://192.168.97.115/root/EN_ManagementPlatform.git/': SSL: no alternative certificate subject name matches target host name '192.168.97.115’`

出现这样的情况是因为 git clone 默认采用 SSL 认证的时候，证书主机名不符，可以通过关掉验证来解决这一问题，就是在 git 命令前面加上：env GIT_SSL_NO_VERIFY=true
所以完整的命令是这样：`env GIT_SSL_NO_VERIFY=true git clone https://github.com/…`

For a single repo
`sudo git config http.sslVerify false`

For all repo
`sudo git config --global http.sslVerify false`

git clone --no-ssl-check https://...

全局关闭：`git config --global http.sslVerify false`

### 搜索两个字的中文没有结果

前端限制了搜索关键字长度：

`sed -i 's/MIN_CHARS_FOR_PARTIAL_MATCHING = 3/MIN_CHARS_FOR_PARTIAL_MATCHING = 2/g' /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/sql/pattern.rb`

手动修改：

```sh
vim /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/sql/pattern.rb
MIN_CHARS_FOR_PARTIAL_MATCHING = 3 change to
MIN_CHARS_FOR_PARTIAL_MATCHING = 2
```
