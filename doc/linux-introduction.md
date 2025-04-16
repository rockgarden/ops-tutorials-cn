# 快速入门

## 常用命令

查看系统版本

centOS：`cat /etc/redhat-release`

查看运行模式

`runlevel`

切换运行模式：0 关机 3 命令CLI 5 图形GUI 6 重启

`init 3`

查看内核版本

`uname -r`

查看CPU

centOS：`lscpu`

查看内存占用

`free -h`

查看磁盘

centOS：`lsblk`

查看主机地址

`hostname -I`

查看录终端

`tty`

查看当前用户

`whoami`

查看登录用户+登录终端+登录时间

`who am i`

查看所有登录用户

`who`

```console
who
wangkan          console      10 13 10:33  
wangkan          ttys000      10 20 21:33
```

查看运行程序

`ps`

```zsh
ps
  PID TTY           TIME CMD
61922 ttys000    0:00.07 -zsh
```

查看当前Shell

`echo $SHELL`

查看安装的Shell列表

`cat /etc/shells`

设置主机名-不支持下下划线

`hostnamectl set-hostname bj-yz-k8s-node1-100-10.magedu. local`

显示提示符格式

`echo SPS1`

修改提示符格式范例

`PS1="\[\e[1;5;41;33m\][\u@\h \w]\\$\[\e[Om\]"`

```bash
# centOS
echo
'PS1="\[\e[1;32m\] [\t \[\e[1;33m\]\u\[\e[35m\]@\h\[\e[1;31m\] \W\[\e[1;32m\]]\[\e[0m\]\\$"' > /etc/profile.d/env.sh
. /etc/profile.d/env.sh

# Ubuntu
tail -1 .bashrc 
PS1='\[\e[1;35m\] [\u@\h \WI\$\[\e[Om\]'
```
