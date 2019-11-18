---
title: "Rsync"
date: 2018-11-18T16:15:57+08:00
description: ""
draft: false
tags: ["文件共享"]
categories: ["Linux运维"]
---

<!--more-->

# 1. rsync简介

`rsync`是`linux`系统下的数据镜像备份工具。使用快速增量备份工具`Remote Sync`可以远程同步，支持本地复制，或者与其他`SSH`、`rsync`主机同步。

# 2. rsync特性

`rsync`支持很多特性：

 - 可以镜像保存整个目录树和文件系统
 - 可以很容易做到保持原来文件的权限、时间、软硬链接等等
 - 无须特殊权限即可安装
 - 快速：第一次同步时`rsync`会复制全部内容，但在下一次只传输修改过的文件。`rsync`在传输数据的过程中可以实行压缩及解压缩操作，因此可以使用更少的带宽
 - 安全：可以使用`scp`、`ssh`等方式来传输文件，当然也可以通过直接的socket连接
 - 支持匿名传输，以方便进行网站镜象

注意:rsync不要用来同步大文件,因为它同步占用的是网络,多数用来同步小文件,大文件要想同步建议使用nfs,然后备份整个物理硬盘

# 3. rsync的ssh认证协议

`rsync`命令来同步系统文件之前要先登录`remote`主机认证，认证过程中用到的协议有2种：

 - ssh协议
   
 - rsync协议

> `rsync server`端不用启动`rsync`的`daemon`进程，只要获取`remote host`的用户名和密码就可以直接`rsync`同步文件
> 
> `rsync server`端因为不用启动`daemon`进程，所以也不用配置文件`/etc/rsyncd.conf`

`ssh`认证协议跟`scp`的原理是一样的，如果在同步过程中不想输入密码就用`ssh-keygen -t rsa`打通通道

```
这种方式默认是省略了 -e ssh 的，与下面等价：
rsync -avz /SRC -e ssh root@192.168.161.189:/DEST 
    -a  	文件宿主变化，时间戳不变
    -z  	压缩数据传输
 
当遇到要修改端口的时候，我们可以：
rsync -avz /SRC -e "ssh -p2222" root@192.168.161.189:/DEST  
修改了ssh 协议的端口，默认是22
```

# 4. rsync命令

```
Rsync的命令格式常用的有以下三种：
    rsync [OPTION]... SRC DEST
    rsync [OPTION]... SRC [USER@]HOST:DEST
    rsync [OPTION]... [USER@]HOST:SRC DEST
　　
对应于以上三种命令格式，rsync有三种不同的工作模式：
1）拷贝本地文件。当SRC和DES路径信息都不包含有单个冒号":"分隔符时就启动这种工作模式。

2）使用一个远程shell程序(如rsh、ssh)来实现将本地机器的内容拷贝到远程机器。当DST路径地址包含单个冒号":"分隔符时启动该模式。


3）使用一个远程shell程序(如rsh、ssh)来实现将远程机器的内容拷贝到本地机器。当SRC地址路径包含单个冒号":"分隔符时启动该模式。


rsync常用选项：
    -a, --archive       //归档
    -v, --verbose       //啰嗦模式
    -q, --quiet         //静默模式
    -r, --recursive     //递归
    -p, --perms         //保持原有的权限属性
    -z, --compress      //在传输时压缩，节省带宽，加快传输速度
    --delete            //在源服务器上做的删除操作也会在目标服务器上同步
```

# 5. rsync+inotify

`rsync`与传统的`cp`、`tar`备份方式相比，`rsync`具有安全性高、备份迅速、支持增量备份等优点，通过`rsync`可以解决对实时性要求不高的数据备份需求，例如定期的备份文件服务器数据到远端服务器，对本地磁盘定期做数据镜像等。

随着应用系统规模的不断扩大，对数据的安全性和可靠性也提出的更好的要求，`rsync`在高端业务系统中也逐渐暴露出了很多不足，首先，`rsync`同步数据时，需要扫描所有文件后进行比对，进行差量传输。如果文件数量达到了百万甚至千万量级，扫描所有文件将是非常耗时的。而且正在发生变化的往往是其中很少的一部分，这是非常低效的方式。其次，`rsync`不能实时的去监测、同步数据，虽然它可以通过`linux`守护进程的方式进行触发同步，但是两次触发动作一定会有时间差，这样就导致了服务端和客户端数据可能出现不一致，无法在应用故障时完全的恢复数据。基于以上原因，`rsync+inotify`组合出现了！

`Inotify`是一种强大的、细粒度的、异步的文件系统事件监控机制，`linux`内核从`2.6.13`起，加入了`Inotify`支持，通过`Inotify`可以监控文件系统中添加、删除，修改、移动等各种细微事件，利用这个内核接口，第三方软件就可以监控文件系统下文件的各种变化情况，而`inotify-tools`就是这样的一个第三方软件。

在前面有讲到，`rsync`可以实现触发式的文件同步，但是通过`crontab`守护进程方式进行触发，同步的数据和实际数据会有差异，而`inotify`可以监控文件系统的各种变化，当文件有任何变动时，就触发`rsync`同步，这样刚好解决了同步数据的实时性问题。

**环境说明：**

| 服务器类型                    | IP地址          | 应用                           | 操作系统        |
| ----------------------------- | --------------- | ------------------------------ | --------------- |
| 源服务器<br>wenhs5479         | 192.168.161.188 | rsync<br>inotify-tools<br>脚本 | centos7/redhat7 |
| 目标服务器<br>wenhs-docker-ce | 192.168.161.189 | rsync                          | centos7/redhat7 |

**需求：**

 - 把源服务器上/etc目录实时同步到目标服务器的/NAME/下。这里的NAME是指你的名字，比如你叫tom，则要把/etc目录同步至目标服务器的/tom/下。

**在目标服务器上做以下操作：**

```
关闭防火墙与SELINUX
[root@wenhs-docker-ce ~]# systemctl stop firewalld
[root@wenhs-docker-ce ~]# systemctl disable firewalld
[root@wenhs-docker-ce ~]# getenforce
Enforcing
[root@wenhs-docker-ce ~]# setenforce 0
[root@wenhs-docker-ce ~]# sed -ri 's/^(SELINUX=).*/\1disabled/g' /etc/sysconfig/selinux

安装rsync服务端软件
[root@wenhs-docker-ce ~]# yum -y install rsync
已加载插件：fastestmirror, langpacks
Loading mirror speeds from cached hostfile
正在解决依赖关系
.......
已安装:
  rsync.x86_64 0:3.1.2-4.el7                                                                   
完毕！

设置rsyncd.conf配置文件
[root@wenhs-docker-ce ~]# cat >>/etc/rsyncd.conf <<EOF
> log file = /var/log/rsyncd.log    #日志文件位置，启动rsync后自动产生这个文件，无需提前创建#
> pidfile = /var/run/rsyncd.pid     #pid文件的存放位置#
> lock file = /var/run/rsync.lock   #支持max connections参数的锁文件#
> secrets file = /etc/rsync.pass    #用户认证配置文件，里面保存用户名称和密码，必须手动创建这个文件#
> 
> [etc_from_client]     #自定义同步名称#
> path = /wenhs/          #rsync服务端数据存放路径，客户端的数据将同步至此目录#
> comment = sync etc from client
> uid = root        #设置rsync运行权限为root#
> gid = root        #设置rsync运行权限为root#
> port = 873        #默认端口#
> ignore errors     #表示出现错误忽略错误#
> use chroot = no       #默认为true，修改为no，增加对目录文件软连接的备份#
> read only = no    #设置rsync服务端为读写权限#
> list = no     #不显示rsync服务端资源列表#
> max connections = 200     #最大连接数#
> timeout = 600     #设置超时时间#
> auth users = admin        #执行数据同步的用户名，可以设置多个，用英文状态下逗号隔开#
> hosts allow = 192.168.161.188   #允许进行数据同步的客户端IP地址，可以设置多个，用英文状态下逗号隔开#
> hosts deny = 192.168.1.1      #禁止数据同步的客户端IP地址，可以设置多个，用英文状态下逗号隔开#
> EOF
注意:配置文件里面这些中文注释禁止写入,否则会报配置文件错误
@ERROR: auth failed on module etc_from_client
rsync error: error starting client-server protocol (code 5) at main.c(1648) [sender=3.1.2]

创建用户认证文件
[root@wenhs-docker-ce ~]# echo 'admin:123456' > /etc/rsync.pass
[root@wenhs-docker-ce ~]# cat /etc/rsync.pass
admin:123456

创建共享目录
[root@wenhs-docker-ce ~]# mkdir /wenhs
不创建这个目录,会报--->@ERROR: chdir failed

设置文件权限
[root@wenhs-docker-ce ~]# chmod 600 /etc/rsync.pass 
[root@wenhs-docker-ce ~]# ll /etc/rsync*
-rw-r--r-- 1 root root 1863 4月  25 15:31 /etc/rsyncd.conf
-rw------- 1 root root   13 4月  25 15:33 /etc/rsync.pass

启动rsync服务并设置开机自启动
[root@wenhs-docker-ce ~]# systemctl start rsyncd
[root@wenhs-docker-ce ~]# systemctl enable rsyncd
Created symlink from /etc/systemd/system/multi-user.target.wants/rsyncd.service to /usr/lib/systemd/system/rsyncd.service.
[root@wenhs-docker-ce ~]# ss -antl
Netid State      Recv-Q Send-Q Local Address:Port               Peer Address:Port                      
tcp   LISTEN     0      5                 *:873                           *:*                  
tcp   LISTEN     0      128               *:111                           *:*                  
tcp   LISTEN     0      5      192.168.122.1:53                            *:*                  
tcp   LISTEN     0      128               *:22                            *:*                  
tcp   LISTEN     0      128       127.0.0.1:631                           *:*                  
tcp   LISTEN     0      100       127.0.0.1:25                            *:*                  
tcp   LISTEN     0      128       127.0.0.1:6010                          *:*                  
tcp   LISTEN     0      5                :::873                          :::*                  
tcp   LISTEN     0      128              :::111                          :::*                  
tcp   LISTEN     0      128              :::22                           :::*                  
tcp   LISTEN     0      128             ::1:631                          :::*                  
tcp   LISTEN     0      100             ::1:25                           :::*                  
tcp   LISTEN     0      128             ::1:6010                         :::*
```

**在源服务器上做以下操作：**

```
关闭防火墙与SELINUX
[root@wenhs5479 ~]# systemctl stop firewalld
[root@wenhs5479 ~]# systemctl disable firewalld
[root@wenhs5479 ~]# getenforce
Enforcing
[root@wenhs5479 ~]# setenforce 0
[root@wenhs5479 ~]# sed -ri 's/^(SELINUX=).*/\1disabled/g' /etc/sysconfig/selinux

配置yum源
[root@wenhs5479 ~]# cd /etc/yum.repos.d/
[root@wenhs5479 yum.repos.d]# wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
--2019-04-25 15:41:23--  http://mirrors.163.com/.help/CentOS7-Base-163.repo
正在解析主机 mirrors.163.com (mirrors.163.com)... 59.111.0.251
正在连接 mirrors.163.com (mirrors.163.com)|59.111.0.251|:80... 已连接。
已发出 HTTP 请求，正在等待回应... 200 OK
长度：1572 (1.5K) [application/octet-stream]
正在保存至: “CentOS7-Base-163.repo”

100%[=====================================================>] 1,572       --.-K/s 用时 0s      

2019-04-25 15:41:23 (185 MB/s) - 已保存 “CentOS7-Base-163.repo” [1572/1572])

[root@wenhs5479 yum.repos.d]# sed -i 's/\$releasever/7/g' /etc/yum.repos.d/CentOS7-Base-163.repo
[root@wenhs5479 yum.repos.d]# sed -i 's/^enabled=.*/enabled=1/g' /etc/yum.repos.d/CentOS7-Base-163.repo
[root@wenhs5479 yum.repos.d]# yum -y install epel-release
已加载插件：fastestmirror, langpacks
Determining fastest mirrors
 * base: mirrors.huaweicloud.com
 * extras: mirrors.huaweicloud.com
 * updates: mirrors.huaweicloud.com
正在解决依赖关系
--> 正在检查事务
---> 软件包 epel-release.noarch.0.7-11 将被 安装
--> 解决依赖关系完成
.......
已安装:
  epel-release.noarch 0:7-11                                                                   
完毕！

安装rsync服务端软件，只需要安装，不要启动，不需要配置
[root@wenhs5479 ~]# yum -y install rsync
已加载插件：fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.huaweicloud.com
 * epel: mirrors.njupt.edu.cn
 * extras: mirrors.huaweicloud.com
 * updates: mirrors.huaweicloud.com
正在解决依赖关系
--> 正在检查事务
---> 软件包 rsync.x86_64.0.3.1.2-4.el7 将被 安装
--> 解决依赖关系完成
.......
Transaction test succeeded
Running transaction
  正在安装    : rsync-3.1.2-4.el7.x86_64                                                   1/1 
  验证中      : rsync-3.1.2-4.el7.x86_64                                                   1/1 
已安装:
  rsync.x86_64 0:3.1.2-4.el7                                                                   
完毕！

创建认证密码文件
[root@wenhs5479 ~]# echo '123456' > /etc/rsync.pass
[root@wenhs5479 ~]# cat /etc/rsync.pass 
123456

设置文件权限，只设置文件所有者具有读取、写入权限即可
[root@wenhs5479 ~]# chmod 600 /etc/rsync.pass 
[root@wenhs5479 ~]# ll /etc/rsync*
-rw-r--r--. 1 root root 458 4月  11 2018 /etc/rsyncd.conf
-rw-------. 1 root root   7 4月  25 15:52 /etc/rsync.pass

在源服务器上创建测试目录，然后在源服务器运行以下命令
[root@wenhs5479 ~]# rsync -avH --port 873 --progress --delete /root/etc/ admin@192.168.161.189::etc_from_client --password-file=/etc/rsync.pass
sending incremental file list
deleting wen/
./
test/

sent 77 bytes  received 35 bytes  224.00 bytes/sec
total size is 0  speedup is 0.00
运行完成后，在目标服务器上查看，在/tmp目录下有test目录，说明数据同步成功
[root@wenhs-docker-ce ~]# ll /wenhs/
总用量 0
drwxr-xr-x 2 root root 6 4月  25 16:30 test

安装inotify-tools工具，实时触发rsync进行同步

查看服务器内核是否支持inotify
[root@wenhs5479 ~]# ll /proc/sys/fs/inotify/
总用量 0
-rw-r--r--. 1 root root 0 4月  25 16:33 max_queued_events
-rw-r--r--. 1 root root 0 4月  25 16:33 max_user_instances
-rw-r--r--. 1 root root 0 4月  15 15:14 max_user_watches

安装inotify-tools
[root@wenhs5479 ~]# yum -y install make gcc gcc-c++ inotify-tools
Loading mirror speeds from cached hostfile
 * base: mirrors.huaweicloud.com
 * epel: mirrors.njupt.edu.cn
 * extras: mirrors.huaweicloud.com
 * updates: mirrors.huaweicloud.com
软件包 1:make-3.82-23.el7.x86_64 已安装并且是最新版本
软件包 gcc-4.8.5-36.el7_6.1.x86_64 已安装并且是最新版本
软件包 gcc-c++-4.8.5-36.el7_6.1.x86_64 已安装并且是最新版本
正在解决依赖关系
........
inotify-tools-3.14-8.el7.x86_64.rpm                                     |  50 kB  00:00:15     
从 file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 检索密钥
导入 GPG key 0x352C64E5:
 用户ID     : "Fedora EPEL (7) <epel@fedoraproject.org>"
 指纹       : 91e9 7d7c 4a5e 96f1 7f3e 888f 6a2f aea2 352c 64e5
 软件包     : epel-release-7-11.noarch (@extras)
 来自       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
....... 
已安装:
  inotify-tools.x86_64 0:3.14-8.el7                                                            
完毕！

写同步脚本，此步乃最最重要的一步，请慎之又慎。让脚本自动去检测我们制定的目录下 \
文件发生的变化，然后再执行rsync的命令把它同步到我们的服务器端去
[root@wenhs5479 ~]# mkdir /scripts
[root@wenhs5479 ~]# touch /scripts/inotify.sh
[root@wenhs5479 ~]# chmod 755 /scripts/inotify.sh
[root@wenhs5479 ~]# ll /scripts/inotify.sh
-rwxr-xr-x. 1 root root 0 4月  25 16:36 /scripts/inotify.sh
[root@wenhs5479 ~]# vim /scripts/inotify.sh
#!/bin/bash
#目标服务器的ip(备份服务器)
host=192.168.161.189
#在源服务器上所要监控的备份目录（此处可以自定义，但是要保证存在）
src=/etc
#自定义的模块名，需要与目标服务器上定义的同步名称一致
des=etc_from_client
#执行数据同步的密码文件
password=/etc/rsync.pass
#执行数据同步的用户名
user=admin
inotifywait=/usr/bin/inotifywait

$inotifywait -mrq --timefmt '%Y%m%d %H:%M' --format '%T %w%f%e' -e modify,delete,create,attrib $src \
| while read files ;do
    rsync -avzP --delete  --timeout=100 --password-file=${password} $src $user@$host::$des
    echo "${files} was rsynced" >>/tmp/rsync.log 2>&1
done
注意:写脚本所有的标点符号为英文符号,否则报错,另外src这个变量,要在目录下,所以要加/

启动脚本
[root@wenhs5479 ~]# nohup bash /scripts/inotify.sh &
[1] 33126
[root@wenhs5479 ~]# nohup: ignoring input and appending output to ‘nohup.out’

[root@wenhs5479 ~]# ps -ef|grep inotify
root      33290  22106  0 16:51 pts/1    00:00:00 bash /scripts/inotify.sh
root      33291  33290  0 16:51 pts/1    00:00:00 /usr/bin/inotifywait -mrq --timefmt %Y%m%d %H:%M --format %T %w%f%e -e modify,delete,create,attrib /etc/
root      33292  33290  0 16:51 pts/1    00:00:00 bash /scripts/inotify.sh
root      33330  22106  0 16:53 pts/1    00:00:00 bash /scripts/inotify.sh

在源服务器上生成一个新文件
[root@wenhs5479 ~]# ls /etc/httpd/
alias  conf  conf.d  conf.modules.d  logs  modules  run
[root@wenhs5479 ~]# echo 'hello word' >/etc/httpd/test

查看inotify生成的日志
[root@wenhs5479 ~]# tail /tmp/rsync.log
20190425 17:06 /etc/httpd/testCREATE was rsynced
20190425 17:06 /etc/httpd/testCREATE was rsynced
20190425 17:06 /etc/httpd/testMODIFY was rsynced
20190425 17:06 /etc/httpd/testMODIFY was rsynced
20190425 17:06 /etc/httpd/testCREATE was rsynced
20190425 17:06 /etc/httpd/testCREATE was rsynced
20190425 17:06 /etc/httpd/testMODIFY was rsynced
20190425 17:06 /etc/httpd/testMODIFY was rsynced
从日志上可以看到，我们生成了一个test文件，并且添加了内容到其里面
```

**设置脚本开机自动启动：**

```
[root@wenhs5479 ~]# chmod +x /etc/rc.d/rc.local
[root@wenhs5479 ~]# ll /etc/rc.d/rc.local
-rwxr-xr-x. 1 root root 473 2月  20 01:35 /etc/rc.d/rc.local
[root@wenhs5479 ~]# echo 'nohup /bin/bash /scripts/inotify.sh' >> /etc/rc.d/rc.local
[root@wenhs5479 ~]# tail /etc/rc.d/rc.local
# to run scripts during boot instead of using this file.
#
# In contrast to previous versions due to parallel execution during boot
# this script will NOT be run after all other services.
#
# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.

touch /var/lock/subsys/local
nohup /bin/bash /scripts/inotify.sh
```

**到目标服务器上去查看是否把新生成的文件自动传上去了：**

```
[root@wenhs-docker-ce wenhs]# pwd
/wenhs
[root@wenhs-docker-ce wenhs]# ls
aaaaa                       hostname                  popt.d
abrt                        hosts                     portreserve
adjtime                     hosts.allow               postfix
akonadi                     hosts.deny                ppp
aliases                     hp                        prelink.conf.d
aliases.db                  httpd                     printcap
...
[root@wenhs-docker-ce wenhs]# ls /wenhs/httpd/
alias  conf  conf.d  conf.modules.d  logs  modules  run  test
由此可见，已将源服务器的/etc目录整个同步到了目标服务器，且新增的test文件也自动同步了
```