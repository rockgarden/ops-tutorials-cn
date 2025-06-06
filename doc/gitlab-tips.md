# GitLab Tips

常用网址

<https://gitlab.com/gitlab-org/gitlab>
<https://docs.gitlab.com/omnibus/settings/nginx.html#supporting-proxied-ssl>
<https://docs.gitlab.cn/jh/administration/pages/index.html>
<https://docs.gitlab.cn/omnibus/settings/ssl/index.html>

## 常用命令

```sh
sudo gitlab-ctl start # 启动所有 gitlab 组件；
sudo gitlab-ctl stop # 停止所有 gitlab 组件；
sudo gitlab-ctl restart # 重启所有 gitlab 组件；
sudo gitlab-ctl status # 查看服务状态；
sudo gitlab-ctl reconfigure # 启动服务；
sudo vim /etc/gitlab/gitlab.rb # 修改默认的配置文件；
gitlab-rake gitlab:check SANITIZE=true --trace # 检查 gitlab；
gitlab-ctl tail puma
```

```sh
sudo gitlab-ctl pg-password-md5 gitlab
Enter password: 52230401
Confirm password:
2575508f0a158a23baa031363b17ac48
```

```sh
# CentOS 查看 gitlab 操作日志
sudo gitlab-ctl tail
# 以 ssh 或 easymail.eastcom.com 过滤
sudo gitlab-ctl tail | grep ssh
sudo gitlab-ctl tail | grep easymail.eastcom.com
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

## Fork 操作

1. B 首先要 fork 一个。
   在项目: <https://gitlab.com/A/durit>，单击 fork，然后你（B）的 gitlab 上就出现了一个 fork，位置是： <https://github.com/B/durit>
2. B 把自己的 fork 克隆到本地。
   `git clone https://gitlab.com/B/durit`
3. 现在你是主人，为了保持与 A 的 durit 的联系，你需要给 A 的 durit 起个名，供你来驱使。
   `cd durit`
   `git remote add upstream https://gitlab.com/A/durit`
   (现在改名为 upstream，这名随意，现在你（B）管 A 的 durit 叫 upstream，以后 B 就用 upstream 来和 A 的 durit 联系了)
4. 获取 A 上的更新(但不会修改你的文件)。
   `git fetch upstream`
5. 合并拉取的数据
   `git merge upstream/master`
   （又联系了一次，upstream/master，前者是你要合并的数据，后者是你要合并到的数据（在这里就是 B 本地的 durit 了））
6. 在 B 修改了本地部分内容后，把本地的更改推送到 B 的远程 github 上。
   git add 修改过的文件
   git commit -m "注释"
   git push origin master
7. 然后 B 还想让修改过的内容也推送到 A 上，这就要发起 pull request 了。
   打开 B 的 <https://gitlab.com/B/durit>
   点击 Pull Requests
   单击 new pull request
   单击 create pull request
   输入 title 和你更改的内容
   然后单击 send pull request
   这样 B 就完成了工作，然后就等着主人 A 来操作了。

## Install In CentOS 7

1. 安装并配置必要的依赖关系  
   On CentOS 7 (and RedHat/Oracle/Scientific Linux 7), the commands below will also open HTTP and SSH access in the system firewall.
   sudo yum install -y curl policycoreutils-python openssh-server
   sudo systemctl enable sshd
   sudo systemctl start sshd
   sudo firewall-cmd --permanent --add-service=http
   sudo systemctl reload firewalld

   Next, install Postfix to send notification emails. If you want to use another solution to send emails please skip this step and configure an external SMTP server after GitLab has been installed.
   sudo yum install postfix
   sudo systemctl enable postfix
   sudo systemctl start postfix
   During Postfix installation a configuration screen may appear. Select 'Internet Site' and press enter. Use your server's external DNS for 'mail name' and press enter. If additional screens appear, continue to press enter to accept the defaults.

2. In GreatWall add the GitLab package repository and install the package
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

   Next, install the GitLab package. Change `http://gitlab.example.com` to the URL at which you want to access your GitLab instance. Installation will automatically configure and start GitLab at that URL. HTTPS requires additional configuration after installation.

   接下来，安装 GitLab 软件包。将 <http://gitlab.example.com> 更改为您要访问您的GitLab实例的URL。安装将自动配置并启动该URL的GitLab。HTTPS安装后需要额外的配置。

   `sudo EXTERNAL_URL="http://gitlab.example.com"`
   `yum install -y gitlab-ee`

3. Browse to the hostname and login
   On your first visit, you'll be redirected to a password reset screen. Provide the password for the initial administrator account and you will be redirected back to the login screen. Use the default account's username root to login.
   See our documentation for detailed instructions on installing and configuration.

4. Set up your communication preferences
   Visit our email subscription preference center to let us know when to communicate with you. We have an explicit email opt-in policy so you have complete control over what and how often we send you emails.
   Twice a month, we send out the GitLab news you need to know, including new features, integrations, docs, and behind the scenes stories from our dev teams. For critical security updates related to bugs and system performance, sign up for our dedicated security newsletter.
   IMPORTANT NOTE: If you do not opt-in to the security newsletter, you will not receive security alerts.

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

## Update In CentOS7

/// 运行备份
`sudo gitlab-backup create`
// 不压缩备份：`sudo gitlab-backup create STRATEGY=copy`
/// 备份文件存放路径：`['backup_path'] = "/data/gitlab/backups"`
/// 异地备份：`scp root@192.168.97.115://data/gitlab/backups/1667540632_2022_11_04_14.0.12_gitlab_backup.tar 1667540632_2022_11_04_14.0.12_gitlab_backup.tar`
/// 查看版本
`sudo rpm -q gitlab-ce`
// 确认升级路径<https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/>
/// 在升级前所有监控>后台迁移（Background Migrations）迁移都必须处于“完成”状态
/// 离线更新
/// 下载地址<https://packages.gitlab.com/gitlab/gitlab-ce>
`rpm -Uvh gitlab-ee-<version>.rpm`

/// 在线更新到最新版本

```sh
yum list | grep gitlab
yum --showduplicates list gitlab-ce
sudo yum install gitlab-ce
sudo EXTERNAL_URL=" https://gitlab.example.com" yum install -y gitlab-ce
```

/// 在线更新到指定版本

```sh
sudo yum install gitlab-ce-14.3.6-ce.0.el7
sudo yum install -y gitlab-ce-14.3.6
sudo yum install gitlab-ce-<version>
gitlab-psql -V
psql (PostgreSQL) 12.7
/opt/gitlab/var/unicorn/puma.pid
['log_directory'] = "/var/log/gitlab/unicorn"
```

/// 离线更新

// <https://docs.gitlab.com/ee/update/package/downgrade.html>

// If on Centos: remove the current package

```sh
sudo yum remove gitlab-ce
sudo gitlab-backup restore BACKUP=1649741711_2022_04_12_14.0.12
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
sudo gitlab-rake gitlab:check SANITIZE=true
```

Upgrade packaged PostgreSQL server
`sudo du -sh /var/opt/gitlab/postgresql/data`

## 配置

/// 开机启动
`systemctl enable gitlab-runsvdir.service`
/// 禁止开机自启动
`systemctl disable gitlab-runsvdir.service`

1. 启用 HTTPS
   /// 默认情况下，omnibus-gitlab 不使用 HTTPS。如果要为 gitlib.eastcomccmp.top.启用 HTTPS，请将以下语句添加到/etc/gitlab/gitlab.rb：
   `sudo vim /etc/gitlab/gitlab.rb`

   ```rb
       # 启用 https
       external_url ' https://gitlib.eastcomccmp.top.'
       ## 配置 nginx
       nginx['enable'] = true
       nginx['redirect_http_to_https'] = true
       nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlib.eastccmp.top.crt"
       nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlib.eastccmp.top.key"
   ```

   /// 创建/etc/gitlab/ssl 目录并在那里复制您的密钥 gitlib.eastcomccmp.top.key 和证书 gitlib.eastcomccmp.top.crt。
   `sudo mkdir -p /etc/gitlab/ssl`
   `sudo chmod 755 /etc/gitlab/ssl`
   `sudo cp gitlib.key gitlib.pem /etc/gitlab/ssl/`
   /// 远程 Copy:
   `scp gitlib.key gitlib.pem root@192.168.97.115://etc/gitlab/ssl`
   /// 运行重新配置命令
   `sudo gitlab-ctl reconfigure`
   /// GitLab 实例应该可以访问 <https://gitlib.eastcomccmp.top。>
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

8. 备份和恢复 Omnibus GitLab 配置
   /// 设置数据备份路径

   ```sh
   vim /etc/gitlab/gitlab.rb
   ###! Docs: https://docs.gitlab.com/omnibus/settings/backups.html
   gitlab_rails['manage_backup_path'] = true
   gitlab_rails['backup_path'] = "/data/gitlab/backups"
   ```

   /// 备份配置：在 /etc/gitlab/config_backup/ 中创建一个 tar 存档。 目录和备份文件只有 root 才能读取。
   `sudo gitlab-ctl backup-etc`

9. Embedded Nginx 配置
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

10. 导出 Issue
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

   把 issue.json 文件上传到：<https://json-csv.com/>，就会自动生成excel文件，然后可以下载到本机。

   导出 Issue.csv 通过 Excel 打开乱码，文件转码 UTF-8 with BOM。

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
