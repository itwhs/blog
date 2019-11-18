---
title: "MySQL进阶"
date: 2018-11-25T16:15:57+08:00
description: ""
draft: false
tags: ["sql"]
categories: ["Linux运维"]
---

<!--more-->

# 1. 二进制格式mysql安装

```
下载二进制格式的mysql软件包
[root@wenhs5479 ~]# wget https://downloads.mysql.com/archives/get/file/mysql-5.7.25-linux-glibc2.12-x86_64.tar

创建用户和组
[root@wenhs5479 ~]# groupadd -r mysql
[root@wenhs5479 ~]# useradd -M -s /sbin/nologin -g mysql mysql

解压软件至/usr/local/
[root@wenhs5479 ~]# tar xf mysql-5.7.25-linux-glibc2.12-x86_64.tar -C /usr/local/
[root@wenhs5479 ~]# ls /usr/local/
apache    games    mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz
apr       include  mysql-test-5.7.25-linux-glibc2.12-x86_64.tar.gz
apr-util  lib      sbin
bin       lib64    share
etc       libexec  src
[root@wenhs5479 ~]# tar xf /usr/local/mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
[root@wenhs5479 ~]# ls /usr/local/
apache    lib64
apr       libexec
apr-util  mysql-5.7.25-linux-glibc2.12-x86_64
bin       mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz
etc       mysql-test-5.7.25-linux-glibc2.12-x86_64.tar.gz
games     sbin
include   share
lib       src
[root@wenhs5479 ~]# cd /usr/local/
[root@wenhs5479 local]# ln -sv mysql-5.7.25-linux-glibc2.12-x86_64/ mysql
"mysql" -> "mysql-5.7.25-linux-glibc2.12-x86_64/"
[root@wenhs5479 local]# ll
总用量 658620
drwxr-xr-x. 13 root root        152 4月  29 09:08 apache
drwxr-xr-x.  6 root root         58 4月  29 09:06 apr
drwxr-xr-x.  5 root root         43 4月  29 09:07 apr-util
drwxr-xr-x.  2 root root          6 4月  11 2018 bin
drwxr-xr-x.  2 root root          6 4月  11 2018 etc
drwxr-xr-x.  2 root root          6 4月  11 2018 games
drwxr-xr-x.  2 root root          6 4月  11 2018 include
drwxr-xr-x.  2 root root          6 4月  11 2018 lib
drwxr-xr-x.  2 root root          6 4月  11 2018 lib64
drwxr-xr-x.  2 root root          6 4月  11 2018 libexec
lrwxrwxrwx.  1 root root         36 4月  29 11:59 mysql -> mysql-5.7.25-linux-glibc2.12-x86_64/
drwxr-xr-x.  9 root root        129 4月  29 11:58 mysql-5.7.25-linux-glibc2.12-x86_64
-rw-r--r--.  1 7161 31415 644862820 12月 21 19:23 mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz
-rw-r--r--.  1 7161 31415  29556980 12月 21 19:21 mysql-test-5.7.25-linux-glibc2.12-x86_64.tar.gz
drwxr-xr-x.  2 root root          6 4月  11 2018 sbin
drwxr-xr-x.  5 root root         49 3月   6 20:35 share
drwxr-xr-x.  5 root root        145 4月  29 09:06 src

修改目录/usr/local/mysql的属主属组
[root@wenhs5479 ~]# chown -R mysql.mysql /usr/local/mysql
[root@wenhs5479 ~]# ll /usr/local/mysql -d
lrwxrwxrwx. 1 mysql mysql 36 4月  29 11:59 /usr/local/mysql -> mysql-5.7.25-linux-glibc2.12-x86_64/

添加环境变量
[root@wenhs5479 ~]# ls /usr/local/mysql
bin  COPYING  docs  include  lib  man  README  share  support-files
[root@wenhs5479 ~]# echo 'export PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysql.sh 
[root@wenhs5479 ~]# source /etc/profile.d/mysql.sh 
[root@wenhs5479 ~]# echo $PATH
/usr/local/mysql/bin:/usr/local/apache/bin:/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin

建立数据存放目录
[root@wenhs5479 ~]# mkdir /opt/data
[root@wenhs5479 ~]# chown -R mysql.mysql /opt/data/
[root@wenhs5479 ~]# ll /opt/
总用量 0
drwxr-xr-x. 2 mysql mysql 6 4月  29 12:07 data
drwxr-xr-x. 2 root  root  6 10月 31 03:17 rh

初始化数据库
[root@wenhs5479 ~]# /usr/local/mysql/bin/mysqld --initialize --user=mysql --datadir=/opt/data/
2019-04-29T04:25:29.411729Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2019-04-29T04:25:29.801636Z 0 [Warning] InnoDB: New log files created, LSN=45790
2019-04-29T04:25:29.881540Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2019-04-29T04:25:29.952437Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: d23d56a4-6a36-11e9-af12-000c298a2a2e.
2019-04-29T04:25:29.953823Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2019-04-29T04:25:29.955744Z 1 [Note] A temporary password is generated for root@localhost: gQBy9Sq(dr>h
请注意，这个命令的最后会生成一个临时密码，此处密码是gQBy9Sq(dr>h
再次注意，这个密码是随机的，你的不会跟我一样，一定要记住这个密码，因为一会登录时会用到

生成配置文件
[root@wenhs5479 ~]# cat >/etc/my.cnf <<EOF
> [mysqld]
> basedir = /usr/local/mysql
> datadir = /opt/data
> socket = /tmp/mysql.sock
> port = 3306
> pid-file = /opt/data/mysql.pid
> user = mysql
> skip-name-resolve
> EOF
> 
[root@wenhs5479 ~]# cat /etc/my.cnf
[mysqld]
basedir = /usr/local/mysql
datadir = /opt/data
socket = /tmp/mysql.sock
port = 3306
pid-file = /opt/data/mysql.pid
user = mysql
skip-name-resolve

配置服务启动脚本
[root@wenhs5479 ~]# cp -a /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
[root@wenhs5479 ~]# sed -ri 's#^(basedir=).*#\1/usr/local/mysql#g' /etc/init.d/mysqld
[root@wenhs5479 ~]# sed -ri 's#^(datadir=).*#\1/opt/data#g' /etc/init.d/mysqld

启动mysql
[root@wenhs5479 ~]# /etc/init.d/mysqld start
Starting MySQL.Logging to '/opt/data/wenhs5479.err'.
 SUCCESS! 
[root@wenhs5479 ~]# ps -ef|grep mysql
root      90916      1  0 13:55 pts/1    00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --datadir=/opt/data --pid-file=/opt/data/mysql.pid
mysql     91094  90916  2 13:55 pts/1    00:00:00 /usr/local/mysql/binmysqld --basedir=/usr/local/mysql --datadir=/opt/data --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=wenhs5479.err --pid-file=/opt/data/mysql.pid --socket=/tmp/mysql.sock --port=3306
root      91132  53676  0 13:55 pts/1    00:00:00 grep --color=auto mysql
[root@wenhs5479 ~]# ss -antl
State       Recv-Q Send-Q Local Address:Port               Peer Address:Port              
LISTEN      0      128     *:111                 *:*                  
LISTEN      0      5      192.168.122.1:53                  *:*                  
LISTEN      0      128     *:22                  *:*                  
LISTEN      0      128    127.0.0.1:631                 *:*                  
LISTEN      0      100    127.0.0.1:25                  *:*                  
LISTEN      0      128    127.0.0.1:6010                *:*                  
LISTEN      0      80     :::3306               :::*                  
LISTEN      0      128    :::111                :::*                  
LISTEN      0      128    :::80                 :::*                  
LISTEN      0      128    :::22                 :::*                  
LISTEN      0      128       ::1:631                :::*                  
LISTEN      0      100       ::1:25                 :::*                  
LISTEN      0      128       ::1:6010               :::*

修改密码
使用临时密码登录
[root@wenhs5479 ~]# /usr/local/mysql/bin/mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.25
Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.
Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql>

设置新密码
mysql> set password = password('jbgsn123!');
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

# 2. mysql配置文件

`mysql`的配置文件为`/etc/my.cnf`

配置文件查找次序：若在多个配置文件中均有设定，则最后找到的最终生效

```
/etc/my.cnf --> /etc/mysql/my.cnf --> --default-extra-file=/PATH/TO/CONF_FILE --> ~/.my.cnf
```

```
配置免密登录
[root@wenhs5479 ~]# cat >.my.cnf <<EOF
> [client]
> user=root
> password=jbgsn123!
> EOF
[root@wenhs5479 ~]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 5.7.25 MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

**mysql常用配置文件参数：**

| 参数                             | 说明                                                         |
| -------------------------------- | ------------------------------------------------------------ |
| port = 3306                      | 设置监听端口                                                 |
| socket = /tmp/mysql.sock         | 指定套接字文件位置                                           |
| basedir = /usr/local/mysql       | 指定MySQL的安装路径                                          |
| datadir = /data/mysql            | 指定MySQL的数据存放路径                                      |
| pid-file = /data/mysql/mysql.pid | 指定进程ID文件存放路径                                       |
| user = mysql                     | 指定MySQL以什么用户的身份提供服务                            |
| skip-name-resolve                | 禁止MySQL对外部连接进行DNS解析<br>使用这一选项可以消除MySQL进行DNS解析的时间。<br>若开启该选项，则所有远程主机连接授权都要使用IP地址方<br>式否则MySQL将无法正常处理连接请求 |

# 3. mysql数据库备份与恢复

### 3.1 数据库常用备份方案

**数据库备份方案：**

 - 全量备份
 - 增量备份
 - 差异备份

| 备份方案 | 特点                                                         |
| -------- | ------------------------------------------------------------ |
| 全量备份 | 全量备份就是指对某一个时间点上的所有数据或应用进行的一个完全拷贝。<br>数据恢复快。<br>备份时间长 |
| 增量备份 | 增量备份是指在一次全备份或上一次增量备份后，以后每次的备份只需备份<br>与前一次相比增加和者被修改的文件。这就意味着，第一次增量备份的对象<br>是进行全备后所产生的增加和修改的文件；第二次增量备份的对象是进行第一次增量<br>备份后所产生的增加和修改的文件，如此类推。<br>没有重复的备份数据<br>备份时间短<br>恢复数据时必须按一定的顺序进行 |
| 差异备份 | 备份上一次的完全备份后发生变化的所有文件。<br>差异备份是指在一次全备份后到进行差异备份的这段时间内<br>对那些增加或者修改文件的备份。在进行恢复时，我们只需对第一次全量备份和最后一次差异备份进行恢复。 |

### 3.2 mysql备份工具mysqldump

```
语法：
    mysqldump [OPTIONS] database [tables ...]
    mysqldump [OPTIONS] --all-databases [OPTIONS]
    mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]
    
常用的OPTIONS：
    -uUSERNAME      //指定数据库用户名
    -hHOST          //指定服务器主机，请使用ip地址
    -pPASSWORD      //指定数据库用户的密码
    -P#             //指定数据库监听的端口，这里的#需用实际的端口号代替，如-P3307
 
备份整个数据库(全备)
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wenhs              |
+--------------------+
5 rows in set (0.00 sec)

mysql> use wenhs;
Database changed
mysql> show tables;
+-----------------+
| Tables_in_wenhs |
+-----------------+
| student         |
| teacher         |
+-----------------+
2 rows in set (0.00 sec)

mysql> exit
Bye
[root@wenhs5479 ~]# mysqldump -uroot -p -hlocalhost --all-databases >all-$(date +%F_%T).sql
Enter password: 
[root@wenhs5479 ~]# ls
all-2019-04-29_14:44:04.sql              公共  下载
anaconda-ks.cfg                          模板  音乐
apache                                   视频  桌面
initial-setup-ks.cfg                     图片
mysql-5.7.25-linux-glibc2.12-x86_64.tar  文档

备份wenhs库的student表和teacher表
[root@wenhs5479 ~]# mysqldump -uroot -p -hlocalhost wenhs student teacher >table-$(date +%F_%T).sql
Enter password: 
[root@wenhs5479 ~]# ls
all-2019-04-29_14:44:04.sql              模板
anaconda-ks.cfg                          视频
apache                                   图片
initial-setup-ks.cfg                     文档
mysql-5.7.25-linux-glibc2.12-x86_64.tar  下载
table-2019-04-29_14:45:41.sql            音乐
公共                                     桌面

备份wenhs库
[root@wenhs5479 ~]# mysqldump -uroot -p -hlocalhost --databases wenhs >wenhs-$(date +%F_%T).sql
Enter password: 
[root@wenhs5479 ~]# ls
all-2019-04-29_14:44:04.sql              模板
anaconda-ks.cfg                          视频
apache                                   图片
initial-setup-ks.cfg                     文档
mysql-5.7.25-linux-glibc2.12-x86_64.tar  下载
table-2019-04-29_14:45:41.sql            音乐
wenhs-2019-04-29_14:46:35.sql            桌面
公共

模拟误删wenhs数据库
mysql> drop database wenhs;
Query OK, 2 rows affected (0.01 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)
```

### 3.3 mysql数据恢复

```
恢复wenhs数据库
[root@wenhs5479 ~]# ls
all-2019-04-29_14:44:04.sql              模板
anaconda-ks.cfg                          视频
apache                                   图片
initial-setup-ks.cfg                     文档
mysql-5.7.25-linux-glibc2.12-x86_64.tar  下载
table-2019-04-29_14:45:41.sql            音乐
wenhs-2019-04-29_14:46:35.sql            桌面
公共
[root@wenhs5479 ~]# mysql <all-2019-04-29_14\:44\:04.sql 	配置了免密登录
[root@wenhs5479 ~]# mysql -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wenhs              |
+--------------------+

恢复wenhs数据库的student表和teacher表
mysql> use wenhs;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

mysql> source table-2019-04-29_14:45:41.sql
Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.00 sec)
......
Query OK, 0 rows affected (0.00 sec)

mysql> show tables;
+-----------------+
| Tables_in_wenhs |
+-----------------+
| student         |
| teacher         |
+-----------------+
2 rows in set (0.00 sec)

模拟删除整个数据库
mysql> drop database wenhs;
Query OK, 2 rows affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

恢复整个数据库
[root@wenhs5479 ~]# mysql < all-2019-04-29_14\:44\:04.sql 
[root@wenhs5479 ~]# mysql wenhs < table-2019-04-29_14\:45\:41.sql    此步多余,第一次全备中,库里面数据都已经备份,不需要这步
[root@wenhs5479 ~]# mysql -e 'select * from wenhs.student;'
+----+-------------+------+
| id | name        | age  |
+----+-------------+------+
|  1 | tom         |   20 |
|  2 | jerry       |   23 |
|  3 | wangqing    |   25 |
|  4 | sean        |   28 |
|  5 | zhangshan   |   26 |
|  7 | lisi        |   50 |
|  8 | chenshuo    |   10 |
|  9 | wangwu      |    3 |
| 10 | qiuyi       |   15 |
| 11 | qiuxiaotian |   20 |
+----+-------------+------+
```

### 3.4 差异备份与恢复

#### 3.4.1 MySQL的差异备份

**开启的MySQL服务器的二进制日志功能**

```
[root@wenhs5479 ~]# vim /etc/my.cnf
[mysqld]
basedir = /usr/local/mysql
datadir = /opt/data
socket = /tmp/mysql.sock
port = 3306
pid-file = /opt/data/mysql.pid
user = mysql
skip-name-resolve

server-id=1			设置服务器标识符
log-bin=mysql_bin				开启二进制日志功能
[root@wenhs5479 ~]# service mysqld restart
Shutting down MySQL.. SUCCESS! 
Starting MySQL. SUCCESS!
```

**对数据库进行完全备份**

```
[root@wenhs5479 ~]# mysql			配置了免密登录
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.25-log MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wenhs              |
+--------------------+
5 rows in set (0.01 sec)

mysql> show tables from wenhs;
+-----------------+
| Tables_in_wenhs |
+-----------------+
| student         |
| teacher         |
+-----------------+
2 rows in set (0.00 sec)

mysql> select * from wenhs.student;
+----+-------------+------+
| id | name        | age  |
+----+-------------+------+
|  1 | tom         |   20 |
|  2 | jerry       |   23 |
|  3 | wangqing    |   25 |
|  4 | sean        |   28 |
|  5 | zhangshan   |   26 |
|  7 | lisi        |   50 |
|  8 | chenshuo    |   10 |
|  9 | wangwu      |    3 |
| 10 | qiuyi       |   15 |
| 11 | qiuxiaotian |   20 |
+----+-------------+------+
10 rows in set (0.01 sec)

完全备份
[root@wenhs5479 ~]# mysqldump --single-transaction --flush-logs --master-data=2 --all-databases --delete-master-logs > all-$(date +%F_%T).sql
[root@wenhs5479 ~]# ll
总用量 660192
-rw-r--r--. 1 root root    794130 4月  30 09:43 all-2019-04-30_09:43:24.sql

增加新内容
mysql> use wenhs;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> insert into student values(100,'hehe',20),(200,'xixi',34);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> 
mysql> select * from student;
+-----+-------------+------+
| id  | name        | age  |
+-----+-------------+------+
|   1 | tom         |   20 |
|   2 | jerry       |   23 |
|   3 | wangqing    |   25 |
|   4 | sean        |   28 |
|   5 | zhangshan   |   26 |
|   7 | lisi        |   50 |
|   8 | chenshuo    |   10 |
|   9 | wangwu      |    3 |
|  10 | qiuyi       |   15 |
|  11 | qiuxiaotian |   20 |
| 100 | hehe        |   20 |
| 200 | xixi        |   34 |
+-----+-------------+------+
12 rows in set (0.00 sec)

mysql> update student set age = 100 where id = 100;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from student;
+-----+-------------+------+
| id  | name        | age  |
+-----+-------------+------+
|   1 | tom         |   20 |
|   2 | jerry       |   23 |
|   3 | wangqing    |   25 |
|   4 | sean        |   28 |
|   5 | zhangshan   |   26 |
|   7 | lisi        |   50 |
|   8 | chenshuo    |   10 |
|   9 | wangwu      |    3 |
|  10 | qiuyi       |   15 |
|  11 | qiuxiaotian |   20 |
| 100 | hehe        |  100 |
| 200 | xixi        |   34 |
+-----+-------------+------+
12 rows in set (0.00 sec)
```

#### 3.4.2. mysql差异备份恢复

模拟误删数据库

```
[root@wenhs5479 ~]# mysql -e 'drop database wenhs;'
[root@wenhs5479 ~]# mysql -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
由上可以看到wenhs这个数据库已被删除
```

刷新创建新的二进制日志

```
[root@wenhs5479 ~]# ll /opt/data/
总用量 122944
-rw-r-----. 1 mysql mysql       56 4月  29 12:25 auto.cnf
-rw-r-----. 1 mysql mysql     1008 4月  30 09:38 ib_buffer_pool
-rw-r-----. 1 mysql mysql 12582912 4月  30 09:58 ibdata1
-rw-r-----. 1 mysql mysql 50331648 4月  30 09:58 ib_logfile0
-rw-r-----. 1 mysql mysql 50331648 4月  29 12:25 ib_logfile1
-rw-r-----. 1 mysql mysql 12582912 4月  30 09:43 ibtmp1
drwxr-x---. 2 mysql mysql     4096 4月  29 15:09 mysql
-rw-r-----. 1 mysql mysql      877 4月  30 09:58 mysql_bin.000002
-rw-r-----. 1 mysql mysql       19 4月  30 09:43 mysql_bin.index
-rw-r-----. 1 mysql mysql        6 4月  30 09:38 mysql.pid
drwxr-x---. 2 mysql mysql     8192 4月  29 12:25 performance_schema
drwxr-x---. 2 mysql mysql     8192 4月  29 12:25 sys
-rw-r-----. 1 mysql mysql    12748 4月  30 09:38 wenhs5479.err
[root@wenhs5479 ~]# mysqladmin flush-logs
[root@wenhs5479 ~]# ll /opt/data/
总用量 122948
-rw-r-----. 1 mysql mysql       56 4月  29 12:25 auto.cnf
-rw-r-----. 1 mysql mysql     1008 4月  30 09:38 ib_buffer_pool
-rw-r-----. 1 mysql mysql 12582912 4月  30 09:58 ibdata1
-rw-r-----. 1 mysql mysql 50331648 4月  30 09:58 ib_logfile0
-rw-r-----. 1 mysql mysql 50331648 4月  29 12:25 ib_logfile1
-rw-r-----. 1 mysql mysql 12582912 4月  30 09:43 ibtmp1
drwxr-x---. 2 mysql mysql     4096 4月  29 15:09 mysql
-rw-r-----. 1 mysql mysql      924 4月  30 09:59 mysql_bin.000002
-rw-r-----. 1 mysql mysql      154 4月  30 09:59 mysql_bin.000003
-rw-r-----. 1 mysql mysql       38 4月  30 09:59 mysql_bin.index
-rw-r-----. 1 mysql mysql        6 4月  30 09:38 mysql.pid
drwxr-x---. 2 mysql mysql     8192 4月  29 12:25 performance_schema
drwxr-x---. 2 mysql mysql     8192 4月  29 12:25 sys
-rw-r-----. 1 mysql mysql    12748 4月  30 09:38 wenhs5479.err
```

恢复完全备份

```
[root@wenhs5479 ~]# mysql <all-2019-04-30_09\:43\:24.sql 
[root@wenhs5479 ~]# mysql -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wenhs              |
+--------------------+
[root@wenhs5479 ~]# mysql -e 'show tables from wenhs;'
+-----------------+
| Tables_in_wenhs |
+-----------------+
| student         |
| teacher         |
+-----------------+
[root@wenhs5479 ~]# mysql -e 'select * from wenhs.student;'
+----+-------------+------+
| id | name        | age  |
+----+-------------+------+
|  1 | tom         |   20 |
|  2 | jerry       |   23 |
|  3 | wangqing    |   25 |
|  4 | sean        |   28 |
|  5 | zhangshan   |   26 |
|  7 | lisi        |   50 |
|  8 | chenshuo    |   10 |
|  9 | wangwu      |    3 |
| 10 | qiuyi       |   15 |
| 11 | qiuxiaotian |   20 |
+----+-------------+------+
[root@wenhs5479 ~]# mysql -e 'select * from wenhs.teacher;'
+----+-------------+------+
| id | name        | age  |
+----+-------------+------+
|  1 | tom         |   20 |
|  2 | jerry       |   23 |
|  3 | wangqing    |   25 |
|  4 | sean        |   28 |
|  5 | zhangshan   |   26 |
|  6 | zhangshan   |   20 |
|  7 | lisi        | NULL |
|  8 | chenshuo    |   10 |
|  9 | wangwu      |    3 |
| 10 | qiuyi       |   15 |
| 11 | qiuxiaotian |   20 |
+----+-------------+------+
```

恢复差异备份

```
[root@wenhs5479 ~]# ll /opt/data/
总用量 123704
-rw-r-----. 1 mysql mysql       56 4月  29 12:25 auto.cnf
-rw-r-----. 1 mysql mysql     1008 4月  30 09:38 ib_buffer_pool
-rw-r-----. 1 mysql mysql 12582912 4月  30 10:00 ibdata1
-rw-r-----. 1 mysql mysql 50331648 4月  30 10:00 ib_logfile0
-rw-r-----. 1 mysql mysql 50331648 4月  29 12:25 ib_logfile1
-rw-r-----. 1 mysql mysql 12582912 4月  30 09:43 ibtmp1
drwxr-x---. 2 mysql mysql     4096 4月  30 10:00 mysql
-rw-r-----. 1 mysql mysql      924 4月  30 09:59 mysql_bin.000002
-rw-r-----. 1 mysql mysql   776980 4月  30 10:00 mysql_bin.000003
-rw-r-----. 1 mysql mysql       38 4月  30 09:59 mysql_bin.index
-rw-r-----. 1 mysql mysql        6 4月  30 09:38 mysql.pid
drwxr-x---. 2 mysql mysql     8192 4月  29 12:25 performance_schema
drwxr-x---. 2 mysql mysql     8192 4月  29 12:25 sys
drwxr-x---. 2 mysql mysql       96 4月  30 10:00 wenhs
-rw-r-----. 1 mysql mysql    12748 4月  30 09:38 wenhs5479.err
[root@wenhs5479 ~]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 5.7.25-log MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show binlog events in 'mysql_bin.000002';
+------------------+-----+----------------+-----------+-------------+---------------------------------------+
| Log_name         | Pos | Event_type     | Server_id | End_log_pos | Info                                  |
+------------------+-----+----------------+-----------+-------------+---------------------------------------+
| mysql_bin.000002 |   4 | Format_desc    |         1 |         123 | Server ver: 5.7.25-log, Binlog ver: 4 |
| mysql_bin.000002 | 123 | Previous_gtids |         1 |         154 |                                       |
| mysql_bin.000002 | 154 | Anonymous_Gtid |         1 |         219 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'  |
| mysql_bin.000002 | 219 | Query          |         1 |         292 | BEGIN                                 |
| mysql_bin.000002 | 292 | Table_map      |         1 |         347 | table_id: 141 (wenhs.student)         |
| mysql_bin.000002 | 347 | Write_rows     |         1 |         404 | table_id: 141 flags: STMT_END_F       |
| mysql_bin.000002 | 404 | Xid            |         1 |         435 | COMMIT /* xid=487 */                  |
| mysql_bin.000002 | 435 | Anonymous_Gtid |         1 |         500 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'  |
| mysql_bin.000002 | 500 | Query          |         1 |         573 | BEGIN                                 |
| mysql_bin.000002 | 573 | Table_map      |         1 |         628 | table_id: 141 (wenhs.student)         |
| mysql_bin.000002 | 628 | Update_rows    |         1 |         686 | table_id: 141 flags: STMT_END_F       |
| mysql_bin.000002 | 686 | Xid            |         1 |         717 | COMMIT /* xid=489 */                  |
| mysql_bin.000002 | 717 | Anonymous_Gtid |         1 |         782 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'  |
| mysql_bin.000002 | 782 | Query          |         1 |         877 | drop database wenhs                   |
| mysql_bin.000002 | 877 | Rotate         |         1 |         924 | mysql_bin.000003;pos=4                |
+------------------+-----+----------------+-----------+-------------+---------------------------------------+
15 rows in set (0.00 sec)

使用mysqlbinlog恢复差异备份
[root@wenhs5479 ~]# mysqlbinlog --stop-position=782 /opt/data/mysql_bin.000002 |mysql-----配置了密码登录,否则要-u和-p
[root@wenhs5479 ~]# mysql -e 'select * from wenhs.student;'
+-----+-------------+------+
| id  | name        | age  |
+-----+-------------+------+
|   1 | tom         |   20 |
|   2 | jerry       |   23 |
|   3 | wangqing    |   25 |
|   4 | sean        |   28 |
|   5 | zhangshan   |   26 |
|   7 | lisi        |   50 |
|   8 | chenshuo    |   10 |
|   9 | wangwu      |    3 |
|  10 | qiuyi       |   15 |
|  11 | qiuxiaotian |   20 |
| 100 | hehe        |  100 |
| 200 | xixi        |   34 |
+-----+-------------+------+
```

# 4.xtrabackup

Percona XtraBackup工具提供了一种在系统运行时执行MySQL数据热备份的方法。Percona XtraBackup是一款免费的在线开源完整数据库备份解决方案，适用于所有版本的Percona Server for MySQL和MySQL®。Percona XtraBackup在事务性系统上执行在线非阻塞，紧密压缩，高度安全的完整备份，以便应用程序在计划维护窗口期间保持完全可用。

可在事务系统上执行在线无阻塞，紧密压缩，高度安全的完整MySQL备份，以便在计划维护窗口期间完全可用任务关键型应用程序。

在本地和云中工作

 - Percona XtraBackup与当今的云提供商（如AWS，Google Cloud，Microsoft
   Azure等）完全兼容，完全部署在云中或作为混合解决方案。

保持数据库的实时

 - 企业准备就绪 Percona XtraBackup具有企业所需的所有工具和功能，可确保数据文件的一致性和安全性。

保持数据库的实时

 - 简化操作 
 - 通过使用Percona XtraBackup加速数据库操作并将数据复制到新的复制从属，可以节省时间和金钱。

保持数据库的实时

 - 非阻塞备份 
 - Percona XtraBackup允许您在生产中备份数据库，而不会影响正常运行时间或数据更改。

保持数据库的实时

 - 备份自动化 
 - 您可以自动执行备份过程并验证自动备份。

当与Percona Server for MySQL结合使用时，Percona XtraBackup为当前可用的事务系统提供唯一真正的非阻塞在线实时MySQL备份。

**Percona XtraBackup提供：**

 - 快速可靠的数据库备份（例如热备份，增量备份，bacula备份等）
 - 备份期间不间断的事务处理
 - 通过更好的压缩节省磁盘空间和网络带宽
 - 自动备份验证
 - 由于更快的恢复时间，正常运行时间更长
 - 时间点恢复

[点这里,了解此工具详解](https://www.cnblogs.com/f-ck-need-u/p/9018716.html)

# 5.冷备,温备,热备详解

**按备份系统的准备程度，可将其分为 冷备份、温备份和热备份三大类 :**

 - **冷备份** : 备份系统未安装或未配置成与当前使用的系统相同或相似的运行环境，应用系统数据没有及时装入备份系统。一旦发生灾难，需安装配置所需的运行环境，用数据备份介质(磁带或光盘)
   恢复应用数据，手工逐笔或自动批量追补孤立数据，将终端用户通过通讯线路切换到备份系统，恢复业务运行
	 - [ ] 优点 : 设备投资较少，节省通信费用，通信环境要求不高
	 - [ ] 缺点 : 恢复时间较长，一般要数天至1周，数据完整性与一致性较差

 - **温备份** : 将备份系统已安装配置成与当前使用的系统相同或相似的系统和网络运行环境，安装应用系统业务定期备份数据。一旦发生灾难，直接使用定期备份数据，手工逐笔或自动批量追补孤立数据或将终端用户通过通讯线路切换到备份系统，恢复业务运行
	 - [ ] 优点 : 设备投资较少，通信环境要求不高
	 - [ ] 缺点 : 恢复时间长，一般要十几个小时至数天，数据完整性与一致性较差

 - **热备份** : 备份处于联机状态，当前应用系统通过高速通信线路将数据实时传送到备份系统，保持备份系统与当前应用系统数据的同步；也可定时在备份系统上恢复应用系统的数据。一旦发生灾难，不用追补或只需追补很少的孤立数据，备份系统可快速接替生产系统运行，恢复营业
	 - [ ] 优点 : 恢复时间短，一般几十分钟到数小时，数据完整性与一致性最好，数据丢失可能性最小
	 - [ ] 缺点 : 设备投资大，通信费用高，通信环境要求高，平时运行管理较复杂

**在计算机服务器备份和恢复中**
　

 - 冷备份服务器(cold server)
   是在主服务器丢失的情况下才使用的备份服务器。冷备份服务器基本上只在软件安装和配置的情况下打开，然后关闭直到需要时再打开
 - 温备份服务器(warm server) 一般都是周期性开机，根据主服务器内容进行更新，然后关机。经常用温备份服务器来进行复制和镜像操作
 - 热备份服务器(hot server) 时刻处于开机状态，同主机保持同步。当主机失灵时，可以随时启用热备份服务器来代替