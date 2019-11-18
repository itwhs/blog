---
title: "安装Discuz论坛"
date: 2018-10-28T16:15:57+08:00
description: ""
draft: false
tags: ["建站"]
categories: ["Linux运维"]
---

<!--more-->

## 一、Discuz介绍

作为国内最大的社区软件及服务提供商，Comsenz旗下的 Discuz! 开发组具有丰富的 web应用程序设计经验，尤其在论坛产品及相关领域

## 二、Discuz实验环境

centos7.6虚拟机

ApacheHTTP丶PHP丶MySQL

## 三、Discuz安装步骤

1.Apache安装

2.PHP和MySQL安装

## 四、Apache安装

#### 1、通过yum安装Apache组件：

```
yum install httpd -y
-y:同意安装
```

#### 2、安装成功，启动httpd进程

```
systemctl start httpd.service
```

#### 3、通过http://ip直接访问

#### 4、把Httpd设置为开机启动

```
systemctl enable httpd.service
```

## 五、PHP和MySQL安装

#### 1、使用yum安装 PHP

```
yum install php php-fpm php-mysql mariadb-server mariadb-client -y
```

#### 2、安装之后，启动 PHP-FPM 进程

```
systemctl start php-fpm.service
```

#### 3、PHP-FPM，默认端口9000，通过netstat查看是否启动成功


#### 4、PHP-FPM也设置成开机自动启动

```
systemctl enable php-fpm.service
```

#### 5、启动数据库服务

```
systemctl start mariadb.service
```

#### 6、查看是否启用成功,默认端口3306

```
netstat -antupl|grep 3306      ##有的话,说明启动成功
```

#### 7、修改数据库密码

```
mysqladmin -u root password root
```

#### 8、创建论坛数据库，并创建数据库管理账户和密码：

```
mysql -u root  -p
```

显示为:

```
[root@wenhs ~]# mysql -u root  -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 5.5.60-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> create database bbs;

MariaDB [(none)]> grant all on bbs.* to 'bbs_admin'@'localhost' identified by 'root';

MariaDB [(none)]>exit;
```

## 六、Discuz安装

#### 1、通过wget,下载Discuz安装包

```
wget http://download.comsenz.com/DiscuzX/3.3/Discuz_X3.3_SC_UTF8.zip
```

#### 2、通过unzip解压压缩包

```
unzip Discuz_X3.3_SC_UTF8.zip
解压完后，会看到一个upload文件夹
```

#### 3、配置Discuz

##### a、由于PHP默认访问 /var/www/html/ 文件夹，所以我们需要把upload文件夹里的文件都复制到 /var/www/html/ 文件夹

```
cp -r upload/* /var/www/html/
```

##### b、通过chmod设置/var/www/html目录及其子目录赋予权限

```
chmod -R 777 /var/www/html
```

##### c、Apache重启

```
systemctl restart httpd.service
```

#### 4、Discuz安装向导,访问路径：

```
http://ip/install
```

剩下的就在网站操作了,其中数据库密码要和之前系统数据库密码一样,不然无法安装