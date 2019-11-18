---
title: "MySQL基础"
date: 2018-11-24T16:15:57+08:00
description: ""
draft: false
tags: ["sql"]
categories: ["Linux运维"]
---

<!--more-->

# 1. 关系型数据库介绍

### 1.1 数据结构模型
数据结构模型主要有：

 - 层次模型
 - 网状结构
 - 关系模型

关系模型：
二维关系：row，column

数据库管理系统：DBMS
关系：Relational，RDBMS

### 1.2 RDBMS专业名词

**常见的关系型数据库管理系统：**

 - MySQL：MySQL，MariaDB，Percona-Server
 - PostgreSQL：简称为pgsql
 - Oracle
 - MSSQL


**记录**:数据库中表的每行是一条记录

**事务**：多个操作被当作一个整体对待就称为一个事务

要看一个关系型数据库是否支持事务，需要看其是否支持并满足ACID测试
ACID：ACID是事务的一个基本标准

 - A：Automicity，原子性
 - C：Consistency，一致性
 - I：Isolation，隔离性
 - D：Durability，持久性

ACID，可以查看[这里](https://baike.baidu.com/item/acid/10738)了解详细说明，

**SQL**：Structure Query Language，结构化查询语言

**约束**：constraint，向数据表提供的数据要遵守的限制

 - 主键约束：一个或多个字段的组合，填入的数据必须能在本表中唯一标识本行。且必须提供数据，不能为空（NOT NULL）。
	 - [ ] 一个表只能存在一个
 - 惟一键约束：一个或多个字段的组合，填入的数据必须能在本表中唯一标识本行。允许为空（NULL）
	 - [ ] 一个表可以存在多个
 - 外键约束：一个表中的某字段可填入数据取决于另一个表的主键已有的数据
 - 检查性约束

**索引**：将表中的一个或多个字段中的数据复制一份另存，并且这些数据需要按特定次序排序存储

**关系运算**：

 - 选择：挑选出符合条件的行（部分行）
 - 投影：挑选出需要的字段
 - 连接

**数据抽象方式**：

 - 物理层：决定数据的存储格式，即RDBMS在磁盘上如何组织文件
 - 逻辑层：描述DB存储什么数据，以及数据间存在什么样的关系
 - 视图层：描述DB中的部分数据

### 1.3 关系型数据库的常见组件

关系型数据库的常见组件有：

 - 数据库：database
 - 表：table，由行（row）和列（column）组成
 - 索引：index
 - 视图：view
 - 用户：user
 - 权限：privilege
 - 存储过程：procedure
 - 存储函数：function
 - 触发器：trigger
 - 事件调度器：event scheduler

### 1.4 SQL语句

SQL语句有三种类型：

 - DDL：Data Defination Language，数据定义语言
 - DML：Data Manipulation Language，数据操纵语言
 - DCL：Data Control Language，数据控制语言

| SQL语句类型 | 对应操作                                                     |
| ----------- | ------------------------------------------------------------ |
| DDL         | CREATE：创建<br>DROP：删除<br>ALTER：修改                    |
| DML         | INSERT：向表中插入数据<br>DELETE：删除表中数据<br>UPDATE：更新表中数据<br>SELECT：查询表中数据 |
| DCL         | GRANT：授权<br>REVOKE：移除授权                              |

# 2. mysql安装与配置

### 2.1 mysql安装

mysql安装方式有三种：

 - 源代码：编译安装
 - 二进制格式的程序包：展开至特定路径，并经过简单配置后即可使用
 - 程序包管理器管理的程序包：
	- [ ] rpm：有两种
		 - OS Vendor：操作系统发行商提供的
		 - 项目官方提供的
	 - [ ] deb

```
配置MySQL安装源:
[root@ip-10-0-100-141 ~]# cd /usr/src/
[root@ip-10-0-100-141 src]# ls
debug  kernels
[root@ip-10-0-100-141 src]# wget http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
--2019-04-22 15:04:45--  http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
正在解析主机 dev.mysql.com (dev.mysql.com)... 137.254.60.11
......

100%[=============================================>] 25,548      --.-K/s 用时 0.04s   

2019-04-22 15:04:55 (572 KB/s) - 已保存 “mysql57-community-release-el7-10.noarch.rpm” [25548/25548])

[root@ip-10-0-100-141 src]# ls
debug  kernels  mysql57-community-release-el7-10.noarch.rpm
[root@ip-10-0-100-141 src]# rpm -ivh mysql57-community-release-el7-10.noarch.rpm 
警告：mysql57-community-release-el7-10.noarch.rpm: 头V3 DSA/SHA1 Signature, 密钥 ID 5072e1f5: NOKEY
准备中...                          ################################# [100%]
正在升级/安装...
   1:mysql57-community-release-el7-10 ################################# [100%]
[root@ip-10-0-100-141 src]# ls /etc/yum.repos.d/
mysql-community.repo         redhat-rhui-client-config.repo  rhui-load-balancers.conf
mysql-community-source.repo  redhat-rhui.repo
[root@ip-10-0-100-141 src]#

安装MySQL5.7
[root@ip-10-0-100-141 ~]# yum -y install mysql-community-server mysql-community-client mysql-community-common mysql-community-devel
......
Installed:
  mysql-community-client.x86_64 0:5.7.25-1.el7                                         
  mysql-community-common.x86_64 0:5.7.25-1.el7                                         
  mysql-community-devel.x86_64 0:5.7.25-1.el7                                          
  mysql-community-libs.x86_64 0:5.7.25-1.el7                                           
  mysql-community-libs-compat.x86_64 0:5.7.25-1.el7                                    
  mysql-community-server.x86_64 0:5.7.25-1.el7                                         

Dependency Installed:
  libaio.x86_64 0:0.3.109-13.el7                                                       

Replaced:
  mariadb-libs.x86_64 1:5.5.60-1.el7_5                                                 

Complete!
```

### 2.2MySQL配置

```
启动MySQL
[root@ip-10-0-100-141 ~]# systemctl start mysqld
[root@ip-10-0-100-141 ~]# systemctl status mysqld
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2019-04-22 07:46:26 UTC; 11s ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
  Process: 4802 ExecStart=/usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid $MYSQLD_OPTS (code=exited, status=0/SUCCESS)
  Process: 4725 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
 Main PID: 4805 (mysqld)
   CGroup: /system.slice/mysqld.service
           └─4805 /usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid...


Apr 22 07:46:21 ip-10-0-100-141.ap-northeast-1.compute.internal systemd[1]: Starting...
Apr 22 07:46:26 ip-10-0-100-141.ap-northeast-1.compute.internal systemd[1]: Started ...
Hint: Some lines were ellipsized, use -l to show in full.

确认3306端口已经监听起来
[root@ip-10-0-100-141 ~]# ss -aultn
Netid State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
udp   UNCONN     0      0             *:68                        *:*                  
udp   UNCONN     0      0      127.0.0.1:323                       *:*                  
udp   UNCONN     0      0           ::1:323                      :::*                  
tcp   LISTEN     0      128           *:22                        *:*                  
tcp   LISTEN     0      100    127.0.0.1:25                        *:*                  
tcp   LISTEN     0      80           :::3306                     :::*                  
tcp   LISTEN     0      128          :::80                       :::*                  
tcp   LISTEN     0      128          :::22                       :::*                  
tcp   LISTEN     0      100         ::1:25                       :::*                  
tcp   LISTEN     0      128          :::443                      :::*

在日志文件中找出临时密码
[root@ip-10-0-100-141 ~]# grep password /var/log/mysqld.log 
2019-04-22T07:46:24.034205Z 1 [Note] A temporary password is generated for root@localhost: HtCqw44K),Li
[root@ip-10-0-100-141 ~]# grep password /var/log/mysqld.log |awk '{print $NF}' 
HtCqw44K),Li

使用获取到的临时密码登录MySQL
[root@ip-10-0-100-141 ~]# mysql -uroot -p'HtCqw44K),Li'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.25

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 看到有这样的标识符则表示成功登录了
注意事项:密码有特殊字符的话,必须要用'',就像上面那样,否则不能登录


修改mysql登录密码
mysql> set global validate_password_policy=0;
Query OK, 0 rows affected (0.00 sec)

mysql> set global validate_password_length=1;
Query OK, 0 rows affected (0.00 sec)

mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'wenhs5479!';
Query OK, 0 rows affected (0.00 sec)

mysql> quit
Bye


为避免mysql自动升级，这里需要卸载最开始安装的yum源
[root@ip-10-0-100-141 ~]# rpm -qa|grep mysql
mysql-community-libs-5.7.25-1.el7.x86_64
mysql-community-libs-compat-5.7.25-1.el7.x86_64
mysql57-community-release-el7-10.noarch
mysql-community-client-5.7.25-1.el7.x86_64
mysql-community-devel-5.7.25-1.el7.x86_64
mysql-community-common-5.7.25-1.el7.x86_64
mysql-community-server-5.7.25-1.el7.x86_64
[root@ip-10-0-100-141 ~]# yum -y remove mysql57-community-release-el7-10.noarch
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Resolving Dependencies
--> Running transaction check
---> Package mysql57-community-release.noarch 0:el7-10 will be erased
--> Finished Dependency Resolution
......
  Erasing    : mysql57-community-release-el7-10.noarch                             1/1 
  Verifying  : mysql57-community-release-el7-10.noarch                             1/1 

Removed:
  mysql57-community-release.noarch 0:el7-10                                            

Complete!
```

# 3. mysql的程序组成

 - 客户端
	 - [ ] mysql：CLI交互式客户端程序
	 - [ ] mysql_secure_installation：安全初始化，强烈建议安装完以后执行此命令
	 - [ ] mysqldump：mysql备份工具
	 - [ ] mysqladmin
 - 服务器端
	 - [ ] mysqld

### 3.1 mysql工具使用

```
语法：mysql [OPTIONS] [database]
常用的OPTIONS：
    -uUSERNAME      指定用户名，默认为root
    -hHOST          指定服务器主机，默认为localhost，推荐使用ip地址
    -pPASSWORD      指定用户的密码
    -P#             指定数据库监听的端口，这里的#需用实际的端口号代替，如-P3307
    -V              查看当前使用的mysql版本
    -e          不登录mysql执行sql语句后退出，常用于脚本

[root@ip-10-0-100-141 ~]# mysql -V
mysql  Ver 14.14 Distrib 5.7.25, for Linux (x86_64) using  EditLine wrapper

[root@ip-10-0-100-141 ~]# mysql -uroot -pwenhs5479! -h127.0.0.1
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.7.25 MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>

注意，不推荐直接在命令行里直接用-pPASSWORD的方式登录，而是使用-p选项，然后交互式输入密码
[root@ip-10-0-100-141 ~]# mysql -uroot -p -h 127.0.0.1 -e 'SHOW DATABASES;'
Enter password: 	----->密码不会回显
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```

### 3.2 服务器监听的两种socket地址

**socket类型**

 - **ip socket**	:默认监听在tcp的3306端口，支持远程通信
 - **unix sock**	:监听在sock文件上（/tmp/mysql.sock，/var/lib/mysql/mysql.sock） 仅支持本地通信 server地址只能是：localhost，127.0.0.1



# 4.mysql数据库操作

### 4.1 DDL操作

#### 4.1.1 数据库操作

```
创建数据库
语法：CREATE DATABASE [IF NOT EXISTS] 'DB_NAME';
创建数据库wenhs
mysql> CREATE DATABASE IF NOT EXISTS wenhs;
Query OK, 1 row affected (0.00 sec)

查看当前有哪些数据库
mysql> SHOW DATABASES;
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

删除数据库
语法：DROP DATABASE [IF EXISTS] 'DB_NAME';
删除数据库wenhs
mysql> DROP DATABASE IF EXISTS wenhs;
Query OK, 0 rows affected (0.00 sec)

mysql> SHOW DATABASES;
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

#### 4.1.2 表操作

```
创建表
语法：CREATE TABLE table_name (col1 datatype 修饰符,col2 datatype 修饰符) ENGINE='存储引擎类型';
在数据库wenhs里创建表jbgsn
mysql> CREATE DATABASE wenhs;
Query OK, 1 row affected (0.00 sec)

mysql> USE wenhs;		进入wenhs数据库
Database changed

mysql> CREATE TABLE jbgsn (id int NOT NULL,name VARCHAR(100) NOT NULL,age tinyint);
Query OK, 0 rows affected (0.02 sec)

查看当前数据库有哪些表
mysql> SHOW TABLES;
+-----------------+
| Tables_in_wenhs |
+-----------------+
| jbgsn           |
+-----------------+
1 row in set (0.00 sec)

删除表
语法：DROP TABLE [ IF EXISTS ] 'table_name';
删除表jbgsn
mysql> DROP TABLE jbgsn;
Query OK, 0 rows affected (0.00 sec)

mysql> SHOW TABLES;
Empty set (0.00 sec)
```

#### 4.1.3 用户操作

> mysql用户帐号由两部分组成，如'USERNAME'@'HOST'，表示此USERNAME只能从此HOST上远程登录

这里（'USERNAME'@'HOST'）的HOST用于限制此用户可通过哪些主机远程连接mysql程序，其值可为：

 - IP地址，如：10.0.100.141
 - 通配符
	 - [ ] %：匹配任意长度的任意字符，常用于设置允许从任何主机登录
	 - [ ] _：匹配任意单个字符

```
数据库用户创建
语法：CREATE USER 'username'@'host' [IDENTIFIED BY 'password'];
创建数据库用户wenhs
mysql> CREATE USER 'wenhs'@'127.0.0.1' IDENTIFIED BY 'wenhs5479!';
Query OK, 0 rows affected (0.00 sec)

使用新创建的用户和密码登录
[root@ip-10-0-100-141 ~]# mysql -uwenhs -pwenhs5479! -h127.0.0.1
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 5.7.25 MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>

删除数据库用户
语法：DROP USER 'username'@'host'; 
mysql> DROP USER 'wenhs'@'127.0.0.1';
Query OK, 0 rows affected (0.00 sec)
注意:自己不能删自己,所以要换root账号登录数据库
```

#### 4.1.4 查看命令SHOW

```
mysql> SHOW CHARACTER SET;			查看支持的所有字符集
+----------+---------------------------------+---------------------+--------+
| Charset  | Description                     | Default collation   | Maxlen |
+----------+---------------------------------+---------------------+--------+
| big5     | Big5 Traditional Chinese        | big5_chinese_ci     |      2 |
| dec8     | DEC West European               | dec8_swedish_ci     |      1 |
| cp850    | DOS West European               | cp850_general_ci    |      1 |
| hp8      | HP West European                | hp8_english_ci      |      1 |
| koi8r    | KOI8-R Relcom Russian           | koi8r_general_ci    |      1 |
| latin1   | cp1252 West European            | latin1_swedish_ci   |      1 |
| latin2   | ISO 8859-2 Central European     | latin2_general_ci   |      1 |
| swe7     | 7bit Swedish                    | swe7_swedish_ci     |      1 |
| ascii    | US ASCII                        | ascii_general_ci    |      1 |
| ujis     | EUC-JP Japanese                 | ujis_japanese_ci    |      3 |
| sjis     | Shift-JIS Japanese              | sjis_japanese_ci    |      2 |
| hebrew   | ISO 8859-8 Hebrew               | hebrew_general_ci   |      1 |
| tis620   | TIS620 Thai                     | tis620_thai_ci      |      1 |
| euckr    | EUC-KR Korean                   | euckr_korean_ci     |      2 |
| koi8u    | KOI8-U Ukrainian                | koi8u_general_ci    |      1 |
| gb2312   | GB2312 Simplified Chinese       | gb2312_chinese_ci   |      2 |
| greek    | ISO 8859-7 Greek                | greek_general_ci    |      1 |
| cp1250   | Windows Central European        | cp1250_general_ci   |      1 |
| gbk      | GBK Simplified Chinese          | gbk_chinese_ci      |      2 |
| latin5   | ISO 8859-9 Turkish              | latin5_turkish_ci   |      1 |
| armscii8 | ARMSCII-8 Armenian              | armscii8_general_ci |      1 |
| utf8     | UTF-8 Unicode                   | utf8_general_ci     |      3 |
| ucs2     | UCS-2 Unicode                   | ucs2_general_ci     |      2 |
| cp866    | DOS Russian                     | cp866_general_ci    |      1 |
| keybcs2  | DOS Kamenicky Czech-Slovak      | keybcs2_general_ci  |      1 |
| macce    | Mac Central European            | macce_general_ci    |      1 |
| macroman | Mac West European               | macroman_general_ci |      1 |
| cp852    | DOS Central European            | cp852_general_ci    |      1 |
| latin7   | ISO 8859-13 Baltic              | latin7_general_ci   |      1 |
| utf8mb4  | UTF-8 Unicode                   | utf8mb4_general_ci  |      4 |
| cp1251   | Windows Cyrillic                | cp1251_general_ci   |      1 |
| utf16    | UTF-16 Unicode                  | utf16_general_ci    |      4 |
| utf16le  | UTF-16LE Unicode                | utf16le_general_ci  |      4 |
| cp1256   | Windows Arabic                  | cp1256_general_ci   |      1 |
| cp1257   | Windows Baltic                  | cp1257_general_ci   |      1 |
| utf32    | UTF-32 Unicode                  | utf32_general_ci    |      4 |
| binary   | Binary pseudo charset           | binary              |      1 |
| geostd8  | GEOSTD8 Georgian                | geostd8_general_ci  |      1 |
| cp932    | SJIS for Windows Japanese       | cp932_japanese_ci   |      2 |
| eucjpms  | UJIS for Windows Japanese       | eucjpms_japanese_ci |      3 |
| gb18030  | China National Standard GB18030 | gb18030_chinese_ci  |      4 |
+----------+---------------------------------+---------------------+--------+
41 rows in set (0.00 sec)

mysql> SHOW ENGINES;			查看当前数据库支持的所有存储引擎
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
9 rows in set (0.00 sec)

mysql> SHOW DATABASES;			查看数据库信息
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

mysql> SHOW TABLES FROM wenhs;			不进入某数据库而列出其包含的所有表
+-----------------+
| Tables_in_wenhs |
+-----------------+
| jbgsn           |
+-----------------+
1 row in set (0.00 sec)		

查看表结构
语法：DESC [db_name.]table_name;
mysql> DESC wenhs.jbgsn;
+-------+--------------+------+-----+---------+-------+
| Field | Type         | Null | Key | Default | Extra |
+-------+--------------+------+-----+---------+-------+
| id    | int(11)      | NO   |     | NULL    |       |
| name  | varchar(100) | NO   |     | NULL    |       |
| age   | tinyint(4)   | YES  |     | NULL    |       |
+-------+--------------+------+-----+---------+-------+
3 rows in set (0.01 sec)

查看某表的创建命令
语法：SHOW CREATE TABLE table_name;
mysql> SHOW CREATE TABLE wenhs.jbgsn;
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table | Create Table                                                                                                                                           |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------------+
| jbgsn | CREATE TABLE `jbgsn` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `age` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

查看某表的状态
语法：SHOW TABLE STATUS LIKE 'table_name'\G
mysql> SHOW TABLE STATUS LIKE 'jbgsn'\G;
*************************** 1. row ***************************
           Name: jbgsn
         Engine: InnoDB
        Version: 10
     Row_format: Dynamic
           Rows: 0
 Avg_row_length: 0
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2019-04-22 10:54:02
    Update_time: NULL
     Check_time: NULL
      Collation: latin1_swedish_ci
       Checksum: NULL
 Create_options: 
        Comment: 
1 row in set (0.00 sec)
```

#### 4.1.5 获取帮助

```
获取命令使用帮助
语法：HELP keyword;

mysql> HELP CREATE TABLE;			获取创建表的帮助
Name: 'CREATE TABLE'
Description:
Syntax:
CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name
    (create_definition,...)
    [table_options]
    [partition_options]

CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name
    [(create_definition,...)]
    [table_options]
    [partition_options]
    [IGNORE | REPLACE]
    [AS] query_expression

CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name
    { LIKE old_tbl_name | (LIKE old_tbl_name) }
.......
```

### 4.2 DML操作

**DML操作包括增(INSERT)、删(DELETE)、改(UPDATE)、查(SELECT)，均属针对表的操作。**

#### 4.2.1 INSERT语句

```
DML操作之增操作insert
修改字段类型:alter table tb_name modify column 字段名 data_type;
语法：INSERT [INTO] table_name [(column_name,...)] {VALUES | VALUE} (value1,...),(...),...;
	INSERT INTO tb_name VALUE(value1,value2,...);	完整插入一条记录
	INSERT INTO tb_name VALUES(value1,value2,...),(value1,value2,...),...;		完整插入多条记录
	INSERT INTO tb_name(key1,key2,...) VALUE(value1,value2,...);		给指定字段插入一条记录
	INSERT INTO tb_name(key1,key2,...) VALUES(value1,value2,...),(value1,value2,...),...;		给指定字段插入多条记录
mysql> USE wenhs;
Database changed
mysql> INSERT INTO jbgsn (id,name,age) VALUE (1,'tom',20);		一次插入一条记录
Query OK, 1 row affected (0.00 sec)
mysql> INSERT INTO jbgsn (id,name,age) VALUES (2,'nbhr',23),(3,'whs',25),(4,'wen',28),(55,'ym',26),(6,'wuym',20),(7,'expl',NULL);
Query OK, 6 rows affected (0.00 sec)
Records: 6  Duplicates: 0  Warnings: 0			一次插入多条记录
mysql> INSERT INTO jbgsn(name,id) VALUES('bhg',93),('mnb',67),('jkl',85),('fg',75),('dbffd',27),('fsdf',43);
Query OK, 6 rows affected (0.01 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> select * from jbgsn;
+----+------+------+
| id | name | age  |
+----+------+------+
|  1 | tom  |   20 |
|  2 | nbhr |   23 |
|  3 | whs  |   25 |
|  4 | wen  |   28 |
|  5 | ym   |   26 |
|  6 | wuym |   20 |
|  7 | expl | NULL |
| 93 | bhg  | NULL |
| 67 | mnb  | NULL |
| 85 | jkl  | NULL |
| 75 | fg   | NULL |
| 27 | dbfd | NULL |
| 43 | fsdf | NULL |
+----+------+------+
13 rows in set (0.00 sec)
```

#### 4.2.2 SELECT语句

**字段column表示法**

| 表示符 | 代表什么？                                           |
| ------ | ---------------------------------------------------- |
| \*     | 所有字段                                             |
| as     | 字段别名，如col1 AS alias1<br>当表名很长时用别名代替 |

**条件判断语句WHERE**

| 操作类型     | 常用操作符                                                   |
| ------------ | ------------------------------------------------------------ |
| 操作符       | >，<，>=，<=，=，!=<br>BETWEEN column# AND column#<br>LIKE：模糊匹配<br>RLIKE：基于正则表达式进行模式匹配<br>ISNOT NULL：非空<br>IS NULL：空 |
| 条件逻辑操作 | AND<br>OR<br>NOT                                             |

**ORDER BY：排序，默认为升序（ASC）**

| ORDER BY语句                     | 意义                                                         |
| -------------------------------- | ------------------------------------------------------------ |
| ORDER BY ‘column_name'           | 根据column_name进行升序排序                                  |
| ORDER BY 'column_name' DESC      | 根据column_name进行降序排序                                  |
| ORDER BY ’column_name' LIMIT 2   | 根据column_name进行升序排序<br>并只取前2个结果               |
| ORDER BY ‘column_name' LIMIT 1,2 | 根据column_name进行升序排序<br>并且略过第1个结果取后面的2个结果 |

```
DML操作之查操作select
语法：SELECT column1,column2,... FROM table_name [WHERE clause] [ORDER BY 'column_name' [DESC]] [LIMIT [m,]n];

mysql> SELECT * FROM jbgsn;		原表情况,下列查询语句均为此表操作
+----+------+------+
| id | name | age  |
+----+------+------+
|  1 | tom  |   20 |
|  2 | nbhr |   23 |
|  3 | whs  |   25 |
|  4 | wen  |   28 |
|  5 | ym   |   26 |
|  6 | wuym |   20 |
|  7 | expl | NULL |
| 93 | bhg  | NULL |
| 67 | mnb  | NULL |
| 85 | jkl  | NULL |
| 75 | fg   | NULL |
| 27 | dbfd | NULL |
| 43 | fsdf | NULL |
+----+------+------+
13 rows in set (0.00 sec)

mysql> SELECT name,age FROM jbgsn WHERE age BETWEEN 21 AND 27;
+------+------+
| name | age  |
+------+------+
| nbhr |   23 |
| whs  |   25 |
| ym   |   26 |
+------+------+
3 rows in set (0.01 sec)

mysql> SELECT * FROM jbgsn WHERE name LIKE 'y';
Empty set (0.00 sec)

mysql> SELECT * FROM jbgsn WHERE name LIKE 'y%';
+----+------+------+
| id | name | age  |
+----+------+------+
|  5 | ym   |   26 |
+----+------+------+
1 row in set (0.00 sec)

mysql> SELECT * FROM jbgsn WHERE name LIKE 'w%';
+----+------+------+
| id | name | age  |
+----+------+------+
|  3 | whs  |   25 |
|  4 | wen  |   28 |
|  6 | wuym |   20 |
+----+------+------+
3 rows in set (0.01 sec)

mysql> SELECT * FROM jbgsn WHERE name LIKE 'w*';
Empty set (0.00 sec)

mysql> SELECT * FROM jbgsn WHERE name RLIKE 'w*';
+----+------+------+
| id | name | age  |
+----+------+------+
|  1 | tom  |   20 |
|  2 | nbhr |   23 |
|  3 | whs  |   25 |
|  4 | wen  |   28 |
|  5 | ym   |   26 |
|  6 | wuym |   20 |
|  7 | expl | NULL |
| 93 | bhg  | NULL |
| 67 | mnb  | NULL |
| 85 | jkl  | NULL |
| 75 | fg   | NULL |
| 27 | dbfd | NULL |
| 43 | fsdf | NULL |
+----+------+------+
13 rows in set (0.00 sec)

mysql> SELECT * FROM jbgsn WHERE name RLIKE 'w%';
Empty set (0.00 sec)

mysql> SELECT * FROM jbgsn WHERE age IS null;
+----+------+------+
| id | name | age  |
+----+------+------+
|  7 | expl | NULL |
| 93 | bhg  | NULL |
| 67 | mnb  | NULL |
| 85 | jkl  | NULL |
| 75 | fg   | NULL |
| 27 | dbfd | NULL |
| 43 | fsdf | NULL |
+----+------+------+
7 rows in set (0.00 sec)

mysql> SELECT * FROM jbgsn WHERE age IS NOT null;
+----+------+------+
| id | name | age  |
+----+------+------+
|  1 | tom  |   20 |
|  2 | nbhr |   23 |
|  3 | whs  |   25 |
|  4 | wen  |   28 |
|  5 | ym   |   26 |
|  6 | wuym |   20 |
+----+------+------+
6 rows in set (0.00 sec)

mysql> SELECT * FROM jbgsn ORDER BY id;		按id字段升序排序
+----+------+------+
| id | name | age  |
+----+------+------+
|  1 | tom  |   20 |
|  2 | nbhr |   23 |
|  3 | whs  |   25 |
|  4 | wen  |   28 |
|  5 | ym   |   26 |
|  6 | wuym |   20 |
|  7 | expl | NULL |
| 27 | dbfd | NULL |
| 43 | fsdf | NULL |
| 67 | mnb  | NULL |
| 75 | fg   | NULL |
| 85 | jkl  | NULL |
| 93 | bhg  | NULL |
+----+------+------+
13 rows in set (0.00 sec)

mysql> SELECT * FROM jbgsn ORDER BY id DESC;		按id字段降序排序
+----+------+------+
| id | name | age  |
+----+------+------+
| 93 | bhg  | NULL |
| 85 | jkl  | NULL |
| 75 | fg   | NULL |
| 67 | mnb  | NULL |
| 43 | fsdf | NULL |
| 27 | dbfd | NULL |
|  7 | expl | NULL |
|  6 | wuym |   20 |
|  5 | ym   |   26 |
|  4 | wen  |   28 |
|  3 | whs  |   25 |
|  2 | nbhr |   23 |
|  1 | tom  |   20 |
+----+------+------+
13 rows in set (0.00 sec)

mysql> SELECT * FROM jbgsn WHERE age IS NOT NULL ORDER BY id DESC;		取出age非空的字段并对id进行降序排序
+----+------+------+
| id | name | age  |
+----+------+------+
|  6 | wuym |   20 |
|  5 | ym   |   26 |
|  4 | wen  |   28 |
|  3 | whs  |   25 |
|  2 | nbhr |   23 |
|  1 | tom  |   20 |
+----+------+------+
6 rows in set (0.00 sec)

mysql> SELECT * FROM jbgsn WHERE age IS NOT NULL ORDER BY age DESC LIMIT 1,3;
+----+------+------+		取出age字段非空的记录并对其进行降序排序,然后跳过第一条记录,取3条记录
| id | name | age  |		order by 必须放在where语句后面
+----+------+------+
|  5 | ym   |   26 |
|  3 | whs  |   25 |
|  2 | nbhr |   23 |
+----+------+------+
3 rows in set (0.00 sec)
```

#### 4.2.3 update语句

```
DML操作之改操作update
语法：UPDATE table_name SET column1 = new_value1[,column2 = new_value2,...] [WHERE clause] [ORDER BY 'column_name' [DESC]] [LIMIT [m,]n];
mysql> select * from jbgsn;
+----+------+------+
| id | name | age  |
+----+------+------+
|  1 | tom  |   20 |
|  2 | nbhr |   23 |
|  3 | whs  |   25 |
|  4 | wen  |   28 |
|  5 | ym   |   26 |
|  6 | wuym |   20 |
|  7 | expl | NULL |
| 93 | bhg  | NULL |
| 67 | mnb  | NULL |
| 85 | jkl  | NULL |
| 75 | fg   | NULL |
| 27 | dbfd | NULL |
| 43 | fsdf | NULL |
+----+------+------+
13 rows in set (0.00 sec)

mysql> UPDATE jbgsn SET age = 88 WHERE name = 'tom';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> UPDATE jbgsn SET age = 66,id = 66  WHERE name = 'whs';
Query OK, 1 row affected (0.00 sec)		更新一条记录里面的多个字段
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from jbgsn;
+----+------+------+
| id | name | age  |
+----+------+------+
|  1 | tom  |   88 |
|  2 | nbhr |   23 |
| 66 | whs  |   66 |
|  4 | wen  |   28 |
|  5 | ym   |   26 |
|  6 | wuym |   20 |
|  7 | expl | NULL |
| 93 | bhg  | NULL |
| 67 | mnb  | NULL |
| 85 | jkl  | NULL |
| 75 | fg   | NULL |
| 27 | dbfd | NULL |
| 43 | fsdf | NULL |
+----+------+------+
13 rows in set (0.00 sec)
```

#### 4.2.4 delete语句

```
DML操作之删操作delete
语法：DELETE FROM table_name [WHERE clause] [ORDER BY 'column_name' [DESC]] [LIMIT [m,]n];
mysql> DELETE FROM jbgsn WHERE id = 1;		删除某条记录
Query OK, 1 row affected (0.00 sec)

mysql> select * from jbgsn;
+----+------+------+
| id | name | age  |
+----+------+------+
|  2 | nbhr |   23 |
| 66 | whs  |   66 |
|  4 | wen  |   28 |
|  5 | ym   |   26 |
|  6 | wuym |   20 |
|  7 | expl | NULL |
| 93 | bhg  | NULL |
| 67 | mnb  | NULL |
| 85 | jkl  | NULL |
| 75 | fg   | NULL |
| 27 | dbfd | NULL |
| 43 | fsdf | NULL |
+----+------+------+
12 rows in set (0.00 sec)

mysql> DELETE FROM jbgsn;		删除整张表的内容
Query OK, 12 rows affected (0.00 sec)

mysql> select * from jbgsn;
Empty set (0.00 sec)

mysql> SHOW TABLES;
+-----------------+
| Tables_in_wenhs |
+-----------------+
| jbgsn           |
+-----------------+
1 row in set (0.00 sec)

mysql> DESC jbgsn;
+-------+--------------+------+-----+---------+-------+
| Field | Type         | Null | Key | Default | Extra |
+-------+--------------+------+-----+---------+-------+
| id    | int(11)      | NO   |     | NULL    |       |
| name  | varchar(100) | NO   |     | NULL    |       |
| age   | tinyint(4)   | YES  |     | NULL    |       |
+-------+--------------+------+-----+---------+-------+
3 rows in set (0.00 sec)
```

#### 4.2.5 truncate语句

**truncate与delete的区别：**

| 语句类型 | 特点                                                         |
| -------- | ------------------------------------------------------------ |
| delete   | DELETE删除表内容时仅删除内容，但会保留表结构<br>DELETE语句每次删除一行，并在事务日志中为所删除的每行记录一项<br>可以过回滚事务日志恢复数据<br>非常占用空间 |
| truncate | 删除表中所有数据，且无法恢复<br>表结构、约束和索引等保持不变，新添加的行计数值重置为初始值<br>执行速度比DELETE快，且使用的系统和事务日志资源少<br>通过释放存储表数据所用的数据页来删除数据，并且只在事务日志中记录页的释放<br>对于有外键约束引用的表，不能使用TRUNCATE TABLE删除数据<br>不能用于加入了索引视图的表 |

```
语法：TRUNCATE table_name;

mysql> select * from jbgsn;
+----+-----------+------+
| id | name      | age  |
+----+-----------+------+
|  1 | tom       |   20 |
|  2 | jerry     |   23 |
|  3 | whs       |   25 |
|  4 | shen      |   28 |
|  5 | zsdfcddan |   26 |
|  6 | adwffdsan |   20 |
|  7 | scfs      | NULL |
+----+-----------+------+
7 rows in set (0.00 sec)

mysql> truncate table jbgsn;		这个table可加可不加
Query OK, 0 rows affected (0.01 sec)

mysql> select * from jbgsn;
Empty set (0.00 sec)

mysql> DESC jbgsn;                                                                  
+-------+--------------+------+-----+---------+-------+
| Field | Type         | Null | Key | Default | Extra |
+-------+--------------+------+-----+---------+-------+
| id    | int(11)      | NO   |     | NULL    |       |
| name  | varchar(100) | NO   |     | NULL    |       |
| age   | tinyint(4)   | YES  |     | NULL    |       |
+-------+--------------+------+-----+---------+-------+
3 rows in set (0.00 sec)
```

### 4.3 DCL操作

#### 4.3.1 创建授权grant

**权限类型(priv_type)**

| 权限类型 | 代表什么？     |
| -------- | -------------- |
| ALL      | 所有权限       |
| SELECT   | 读取内容的权限 |
| INSERT   | 插入内容的权限 |
| UPDATE   | 更新内容的权限 |
| DELETE   | 删除内容的权限 |

**指定要操作的对象db_name.table_name**

| 表示方式           | 意义           |
| ------------------ | -------------- |
| \*.\*              | 所有库的所有表 |
| db_name            | 指定库的所有表 |
| db_name.table_name | 指定库的指定表 |

> WITH GRANT OPTION：被授权的用户可将自己的权限副本转赠给其他用户，说白点就是将自己的权限完全复制给另一个用户。不建议使用。

```
语法:GRANT priv_type,... ON [object_type] db_name.table_name TO ‘username'@'host' [IDENTIFIED BY 'password'] [WITH GRANT OPTION];
mysql> SHOW DATABASES;
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

授权wenhs用户在数据库本机上登录访问所有数据库
mysql> GRANT ALL ON *.* TO 'wenhs'@'localhost' IDENTIFIED BY 'WSFwdaSDFF3232?:"<>';
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> GRANT ALL ON *.* TO 'wenhs'@'127.0.0.1' IDENTIFIED BY 'WSFwdaSDFF3232?:"<>';
Query OK, 0 rows affected, 1 warning (0.00 sec)

授权wenhs用户在10.0.100.111上远程登录访问wenhs数据库
mysql> GRANT ALL ON wenhs.* TO 'wenhs'@'10.0.100.111' IDENTIFIED BY 'WSFwdaSDFF3232?:"<>'; 
Query OK, 0 rows affected, 1 warning (0.00 sec)

授权wenhs用户在所有位置上远程登录访问wenhs数据库
mysql> GRANT ALL ON *.* TO 'wenhs'@'%' IDENTIFIED BY 'WSFwdaSDFF3232?:"<>';
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

#### 4.3.2 查看授权

```
查看当前登录用户的授权信息
mysql> SHOW GRANTS;
+---------------------------------------------------------------------+
| Grants for root@localhost                                           |
+---------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION |
| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION        |
+---------------------------------------------------------------------+
2 rows in set (0.00 sec)

查看指定用户wenhs的授权信息
mysql> SHOW GRANTS FOR wenhs;
+--------------------------------------------+
| Grants for wenhs@%                         |
+--------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'wenhs'@'%' |
+--------------------------------------------+
1 row in set (0.00 sec)
mysql> SHOW GRANTS FOR 'wenhs'@'127.0.0.1';
+----------------------------------------------------+
| Grants for wenhs@127.0.0.1                         |
+----------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'wenhs'@'127.0.0.1' |
+----------------------------------------------------+
1 row in set (0.00 sec)

mysql> SHOW GRANTS FOR 'wenhs'@'localhost';
+----------------------------------------------------+
| Grants for wenhs@localhost                         |
+----------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'wenhs'@'localhost' |
+----------------------------------------------------+
1 row in set (0.00 sec)
```

#### 4.3.3 取消授权REVOKE

```
语法：REVOKE priv_type,... ON db_name.table_name FROM 'username'@'host';
mysql> REVOKE ALL ON *.* FROM 'wenhs'@'10.0.100.111';
Query OK, 0 rows affected (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)
```

**注意：mysql服务进程启动时会读取mysql库中的所有授权表至内存中：**

 - GRANT或REVOKE等执行权限操作会保存于表中，mysql的服务进程会自动重读授权表，并更新至内存中
 - 对于不能够或不能及时重读授权表的命令，可手动让mysql的服务进程重读授权表

```
mysql> FLUSH PRIVILEGES;
```

## 示例

##### 1.创建一个以你名字为名的数据库，并创建一张表student，该表包含三个字段（id，name，age），表结构如下：

```
mysql> CREATE DATABASE IF NOT EXISTS wenhongsheng;
Query OK, 1 row affected (0.00 sec)

mysql> USE wenhongsheng;
Database changed
mysql> CREATE TABLE student (id int primary key auto_increment NOT NULL,name VARCHAR(100) NOT NULL,age tinyint);
Query OK, 0 rows affected (0.01 sec)

mysql> DESC student;
+-------+--------------+------+-----+---------+-------+
| Field | Type         | Null | Key | Default | Extra |
+-------+--------------+------+-----+---------+-------+
| id    | int(11)      | NO   |     | NULL    |       |
| name  | varchar(100) | NO   |     | NULL    |       |
| age   | tinyint(4)   | YES  |     | NULL    |       |
+-------+--------------+------+-----+---------+-------+
3 rows in set (0.00 sec)
```

##### 2.查看下该新建的表有无内容（用select语句）

```
mysql> SELECT * FROM student;
Empty set (0.00 sec)
```

##### 3.往新建的student表中插入数据（用insert语句），结果应如下所示：

```
mysql> insert into student values(1,'tom',20),(2,'jerry',23),(3,'wangqing',25),(4,'sean',28),
    -> (5,'zhangshan',26),(6,'zhangshan',20),(7,'lisi',null),(8,'chenshuo',10),(9,'wangwu',3),
    -> (10,'qiuyi',15),(11,'qiuxiaotian',20);
Query OK, 11 rows affected (0.00 sec)
Records: 11  Duplicates: 0  Warnings: 0
mysql> select * from student;     #查询表内容
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
11 rows in set (0.00 sec)
```

##### 4.修改lisi的年龄为50

```
mysql> UPDATE student SET age = 50 WHERE name = 'lisi';                                        
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * FROM student;
+----+-------------+------+
| id | name        | age  |
+----+-------------+------+
|  1 | tom         |   20 |
|  2 | jerry       |   23 |
|  3 | wangqing    |   25 |
|  4 | sean        |   28 |
|  5 | zhangshan   |   26 |
|  6 | zhangshan   |   20 |
|  7 | lisi        |   50 |
|  8 | chenshuo    |   10 |
|  9 | wangwu      |    3 |
| 10 | qiuyi       |   15 |
| 11 | qiuxiaotian |   20 |
+----+-------------+------+
11 rows in set (0.00 sec)
```

##### 5.以age字段降序排序

```
mysql> SELECT * FROM student ORDER BY age DESC;
+----+-------------+------+
| id | name        | age  |
+----+-------------+------+
|  7 | lisi        |   50 |
|  4 | sean        |   28 |
|  5 | zhangshan   |   26 |
|  3 | wangqing    |   25 |
|  2 | jerry       |   23 |
|  1 | tom         |   20 |
|  6 | zhangshan   |   20 |
| 11 | qiuxiaotian |   20 |
| 10 | qiuyi       |   15 |
|  8 | chenshuo    |   10 |
|  9 | wangwu      |    3 |
+----+-------------+------+
11 rows in set (0.00 sec)
```

##### 6.查询student表中年龄最小的3位同学

```
mysql> SELECT * FROM student ORDER BY age LIMIT 3;
+----+----------+------+
| id | name     | age  |
+----+----------+------+
|  9 | wangwu   |    3 |
|  8 | chenshuo |   10 |
| 10 | qiuyi    |   15 |
+----+----------+------+
3 rows in set (0.00 sec)
```

##### 7.查询student表中年龄最大的4位同学

```
mysql> SELECT * FROM student ORDER BY age DESC LIMIT 4;
+----+-----------+------+
| id | name      | age  |
+----+-----------+------+
|  7 | lisi      |   50 |
|  4 | sean      |   28 |
|  5 | zhangshan |   26 |
|  3 | wangqing  |   25 |
+----+-----------+------+
4 rows in set (0.00 sec)
```

##### 8.查询student表中名字叫zhangshan的记录

```
mysql> SELECT * FROM student WHERE name = 'zhangshan';
+----+-----------+------+
| id | name      | age  |
+----+-----------+------+
|  5 | zhangshan |   26 |
|  6 | zhangshan |   20 |
+----+-----------+------+
2 rows in set (0.00 sec)
```

##### 9.查询student表中名字叫zhangshan且年龄大于20岁的记录

```
mysql> SELECT * FROM student WHERE name = 'zhangshan' AND age > 20;
+----+-----------+------+
| id | name      | age  |
+----+-----------+------+
|  5 | zhangshan |   26 |
+----+-----------+------+
1 row in set (0.00 sec)
```

##### 10.查询student表中年龄在23到30之间的记录

```
mysql> SELECT * FROM student WHERE age BETWEEN 23 AND 30;
+----+-----------+------+
| id | name      | age  |
+----+-----------+------+
|  3 | wangqing  |   25 |
|  4 | sean      |   28 |
|  5 | zhangshan |   26 |
+----+-----------+------+
3 rows in set (0.00 sec)
```

##### 11.修改wangwu的年龄为100

```
mysql> UPDATE student SET age = 100 WHERE name = 'wangwu';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * FROM student;
+----+-------------+------+
| id | name        | age  |
+----+-------------+------+
|  1 | tom         |   20 |
|  2 | jerry       |   23 |
|  3 | wangqing    |   25 |
|  4 | sean        |   28 |
|  5 | zhangshan   |   26 |
|  6 | zhangshan   |   20 |
|  7 | lisi        |   50 |
|  8 | chenshuo    |   10 |
|  9 | wangwu      |  100 |
| 10 | qiuyi       |   15 |
| 11 | qiuxiaotian |   20 |
+----+-------------+------+
11 rows in set (0.00 sec)
```

##### 12.删除student中名字叫zhangshan且年龄小于等于20的记录

```
mysql> DELETE FROM student WHERE name = 'zhangshan' AND age <= 20;
Query OK, 1 row affected (0.00 sec)

mysql> SELECT * FROM student;
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
|  9 | wangwu      |  100 |
| 10 | qiuyi       |   15 |
| 11 | qiuxiaotian |   20 |
+----+-------------+------+
10 rows in set (0.00 sec)
```