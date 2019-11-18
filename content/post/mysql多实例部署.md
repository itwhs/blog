---
title: "MySQL多实例"
date: 2018-12-09T16:15:57+08:00
description: ""
draft: false
tags: ["MySQL"]
categories: ["Linux运维"]
---

<!--more-->

# mysql多实例部署

软件下载

```
下载二进制格式的mysql软件包
[root@localhost ~]# cd /usr/src/
[root@localhost src]# wget https://downloads.mysql.com/archives/get/file/mysql-5.7.22-linux-glibc2.12-x86_64.tar.gz
```

配置用户和组并解压二进制程序至/usr/local下

```
创建用户和组
[root@localhost src]# groupadd -r mysql
[root@localhost src]# useradd -M -s /sbin/nologin -g mysql mysql


解压软件至/usr/local/
[root@localhost src]# ls
debug  kernels  mysql-5.7.22-linux-glibc2.12-x86_64.tar.gz
[root@localhost src]# tar xf mysql-5.7.22-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
[root@localhost ~]# ls /usr/local/
bin  games    lib    libexec                              sbin   src
etc  include  lib64  mysql-5.7.22-linux-glibc2.12-x86_64  share
[root@localhost ~]# cd /usr/local/
[root@localhost local]# ln -sv mysql-5.7.22-linux-glibc2.12-x86_64/ mysql
‘mysql’ -> ‘mysql-5.7.22-linux-glibc2.12-x86_64/’
[root@localhost local]# ll
total 0
drwxr-xr-x. 2 root root   6 4月  11 2018 bin
drwxr-xr-x. 2 root root   6 4月  11 2018 etc
drwxr-xr-x. 2 root root   6 4月  11 2018 games
drwxr-xr-x. 2 root root   6 4月  11 2018 include
drwxr-xr-x. 2 root root   6 4月  11 2018 lib
drwxr-xr-x. 2 root root   6 4月  11 2018 lib64
drwxr-xr-x. 2 root root   6 4月  11 2018 libexec
lrwxrwxrwx  1 root root  36 5月  14 18:07 mysql -> mysql-5.7.22-linux-glibc2.12-x86_64/
drwxr-xr-x  9 root root 129 5月  14 18:06 mysql-5.7.22-linux-glibc2.12-x86_64
drwxr-xr-x. 2 root root   6 4月  11 2018 sbin
drwxr-xr-x. 5 root root  49 5月   3 20:12 share
drwxr-xr-x. 2 root root   6 4月  11 2018 src


修改目录/usr/local/mysql的属主属组
[root@localhost ~]# chown -R mysql.mysql /usr/local/mysql
[root@localhost ~]# ll /usr/local/mysql -d
lrwxrwxrwx 1 mysql mysql 36 5月  14 18:07 /usr/local/mysql -> mysql-5.7.22-linux-glibc2.12-x86_64/

//配置环境变量
[root@localhost ~]# echo 'export PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysql.sh
[root@localhost ~]# . /etc/profile.d/mysql.sh
[root@localhost ~]# echo $PATH
/usr/local/mysql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
```

创建各实例数据存放的目录

```
[root@localhost ~]# mkdir -p /opt/data/{3306,3307,3308}

[root@localhost ~]# chown -R mysql.mysql /opt/data/

[root@localhost ~]# ll /opt/data/
总用量 0
drwxr-xr-x 2 mysql mysql 6 5月  14 18:09 3306
drwxr-xr-x 2 mysql mysql 6 5月  14 18:09 3307
drwxr-xr-x 2 mysql mysql 6 5月  14 18:09 3308

[root@localhost ~]# tree /opt/data/
/opt/data/
├── 3306
├── 3307
└── 3308

3 directories, 0 files
```

初始化各实例

```
初始化3306实例
[root@localhost ~]# mysqld --initialize --datadir=/opt/data/3306 --user=mysql
2019-05-14T10:21:09.607685Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2019-05-14T10:21:09.822454Z 0 [Warning] InnoDB: New log files created, LSN=45790
2019-05-14T10:21:09.858420Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2019-05-14T10:21:09.916381Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: fe0bac5b-7631-11e9-bec6-000c299f3251.
2019-05-14T10:21:09.917673Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2019-05-14T10:21:09.918517Z 1 [Note] A temporary password is generated for root@localhost: AG/j:g?ob1CO
[root@localhost ~]# echo 'AG/j:g?ob1CO' > 3306_pass


初始化3307实例
[root@localhost ~]# mysqld --initialize --datadir=/opt/data/3307 --user=mysql
2019-05-14T10:24:10.367114Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2019-05-14T10:24:10.572462Z 0 [Warning] InnoDB: New log files created, LSN=45790
2019-05-14T10:24:10.610295Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2019-05-14T10:24:10.669903Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 69c878d3-7632-11e9-82ab-000c299f3251.
2019-05-14T10:24:10.670681Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2019-05-14T10:24:10.671566Z 1 [Note] A temporary password is generated for root@localhost: rfY5Ys(u:s!s
[root@localhost ~]# echo 'rfY5Ys(u:s!s' > 3307_pass


初始化3308实例
[root@localhost ~]# mysqld --initialize --datadir=/opt/data/3308 --user=mysql
2019-05-14T10:25:03.584110Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2019-05-14T10:25:03.795984Z 0 [Warning] InnoDB: New log files created, LSN=45790
2019-05-14T10:25:03.832243Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2019-05-14T10:25:03.891271Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 89816891-7632-11e9-85fa-000c299f3251.
2019-05-14T10:25:03.892710Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2019-05-14T10:25:03.893870Z 1 [Note] A temporary password is generated for root@localhost: +g9h.g(%g2>E
[root@localhost ~]# echo '+g9h.g(%g2>E' > 3308_pass
```

安装perl

```
[root@localhost ~]# yum -y install perl
```

配置配置文件/etc/my.cnf

```
[root@localhost ~]# vim /etc/my.cnf
[mysqld_multi]
mysqld = /usr/local/mysql/bin/mysqld_safe
mysqladmin = /usr/local/mysql/bin/mysqladmin
user = root
password = wangqing123!

[mysqld3306]
datadir = /opt/data/3306
port = 3306
socket = /tmp/mysql3306.sock
pid-file = /opt/data/3306/mysql_3306.pid
log-error=/var/log/3306.log

[mysqld3307]
datadir = /opt/data/3307
port = 3307
socket = /tmp/mysql3307.sock
pid-file = /opt/data/3307/mysql_3307.pid
log-error=/var/log/3307.log

[mysqld3308]
datadir = /opt/data/3308
port = 3308
socket = /tmp/mysql3308.sock
pid-file = /opt/data/3308/mysql_3308.pid
log-error=/var/log/3308.log
```

启动各实例

```
[root@localhost ~]# mysqld_multi start 3306
[root@localhost ~]# mysqld_multi start 3307
[root@localhost ~]# mysqld_multi start 3308
[root@localhost ~]# ss -antl
State      Recv-Q Send-Q     Local Address:Port                    Peer Address:Port
LISTEN     0      128                    *:22                                 *:*
LISTEN     0      100            127.0.0.1:25                                 *:*
LISTEN     0      80                    :::3307                              :::*
LISTEN     0      80                    :::3308                              :::*
LISTEN     0      128                   :::22                                :::*
LISTEN     0      100                  ::1:25                                :::*
LISTEN     0      80                    :::3306                              :::*
```

初始化密码

```
[root@localhost ~]# ls
3306_pass  3307_pass  3308_pass  anaconda-ks.cfg
[root@localhost ~]# cat 3306_pass
AG/j:g?ob1CO
[root@localhost ~]# mysql -uroot -p'AG/j:g?ob1CO' -S /tmp/mysql3306.sock
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.22

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> set password = password('itwhs123!');
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> quit
Bye



[root@localhost ~]# cat 3307_pass
rfY5Ys(u:s!s
[root@localhost ~]# mysql -uroot -p'rfY5Ys(u:s!s' -S /tmp/mysql3307.sock -e 'set password = password("itwhs123!");' --connect-expired-password
mysql: [Warning] Using a password on the command line interface can be insecure.


[root@localhost ~]# cat 3308_pass
+g9h.g(%g2>E
[root@localhost ~]# mysql -uroot -p'+g9h.g(%g2>E' -S /tmp/mysql3308.sock -e 'set password = password("itwhs123!");' --connect-expired-password
mysql: [Warning] Using a password on the command line interface can be insecure.
```