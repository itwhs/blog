---
title: "SaltStack之return与job管理"
date: 2019-03-23T16:15:57+08:00
description: ""
draft: false
tags: ["自动化"]
categories: ["Linux运维"]
---

<!--more-->



## 1. SaltStack组件之return

return组件可以理解为SaltStack系统对执行Minion返回后的数据进行存储或者返回给其他程序，它支持多种存储方式，比如用MySQL、MongoDB、Redis、Memcache等，通过return我们可以对SaltStack的每次操作进行记录，对以后日志审计提供了数据来源。目前官方已经支持30种return数据存储与接口，我们可以很方便的配置与使用它。当然也支持自己定义的return，自定义的return需由python来编写。在选择和配置好要使用的return后，只需在salt命令后面指定return即可。

```
查看所有return列表
[root@master ~]# salt '192.168.153.141' sys.list_returners
192.168.153.141:
    - carbon
    - couchdb
    - elasticsearch
    - etcd
    - highstate
    - hipchat
    - local
    - local_cache
    - mattermost
    - multi_returner
    - pushover
    - rawfile_json
    - slack
    - smtp
    - splunk
    - sqlite3
    - syslog
    - telegram
```

### 1.1 return流程

return是在Master端触发任务，然后Minion接受处理任务后直接与return存储服务器建立连接，然后把数据return存到存储服务器。关于这点一定要注意，因为此过程都是Minion端操作存储服务器，所以要确保Minion端的配置跟依赖包是正确的，这意味着我们将必须在每个Minion上安装指定的return方式依赖包，假如使用Mysql作为return存储方式，那么我们将在每台Minion上安装python-mysql模块。

### 1.2 使用mysql作为return存储方式

**在所有minion上安装Mysql-python模块**

```
[root@master ~]# salt '192.168.153.141' pkg.install MySQL-python
192.168.153.141:
    ----------
    MySQL-python:
        ----------
        new:
            1.2.5-1.el7
        old:
[root@master ~]# salt '192.168.153.141' cmd.run 'rpm -qa|grep MySQL-python'
192.168.153.141:
    MySQL-python-1.2.5-1.el7.x86_64
```

**部署一台mysql服务器用作存储服务器，此处就直接在192.168.153.142这台主机上部署**

```
部署mysql
[root@mysql142 ~]# yum install MySQL-python mariadb-server mariadb -y
[root@mysql142 ~]# systemctl start mariadb
[root@mysql142 ~]# systemctl enable mariadb
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
[root@mysql142 ~]# ss -antl
State      Recv-Q Send-Q      Local Address:Port                     Peer Address:Port              
LISTEN     0      50                      *:3306                                *:*                  
LISTEN     0      128                     *:22                                  *:*                  
LISTEN     0      100             127.0.0.1:25                                  *:*                  
LISTEN     0      128                    :::22                                 :::*                  
LISTEN     0      100                   ::1:25                                 :::*

创建数据库和表结构
[root@mysql142 ~]# mysql
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
......
#建立远程登录账户
MariaDB [(none)]> grant all on salt.* to salt@'%' identified by 'salt'; 

#创建对应的库和表
CREATE DATABASE  `salt`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

USE `salt`;

DROP TABLE IF EXISTS `jids`;
CREATE TABLE `jids` (
  `jid` varchar(255) NOT NULL,
  `load` mediumtext NOT NULL,
  UNIQUE KEY `jid` (`jid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE INDEX jid ON jids(jid) USING BTREE;

DROP TABLE IF EXISTS `salt_returns`;
CREATE TABLE `salt_returns` (
  `fun` varchar(50) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `return` mediumtext NOT NULL,
  `id` varchar(255) NOT NULL,
  `success` varchar(10) NOT NULL,
  `full_ret` mediumtext NOT NULL,
  `alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY `id` (`id`),
  KEY `jid` (`jid`),
  KEY `fun` (`fun`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `salt_events`;
CREATE TABLE `salt_events` (
`id` BIGINT NOT NULL AUTO_INCREMENT,
`tag` varchar(255) NOT NULL,
`data` mediumtext NOT NULL,
`alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
`master_id` varchar(255) NOT NULL,
PRIMARY KEY (`id`),
KEY `tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

MariaDB [salt]> show tables;
+----------------+
| Tables_in_salt |
+----------------+
| jids           |
| salt_events    |
| salt_returns   |
+----------------+
3 rows in set (0.00 sec)

刷新后退出
MariaDB [salt]> flush privileges;
Query OK, 0 rows affected (0.00 sec)
```

**配置minion**

```
[root@minion ~]# yum install MySQL-python -y
[root@minion ~]# vim /etc/salt/minion
.....此处省略N行
mysql.host: '192.168.153.142'
mysql.user: 'salt'
mysql.pass: 'salt'
mysql.db: 'salt'
mysql.port: 3306

[root@minion ~]# systemctl restart salt-minion
```

**在Master上测试存储到mysql中**

```
[root@master ~]# salt '192.168.153.141' test.ping --return mysql
192.168.153.141:
    True
```

**在数据库中查询**

```
MariaDB [(none)]> select * from salt.salt_returns\G
*************************** 1. row ***************************
       fun: test.ping
       jid: 20190724153418459123
    return: true
        id: 192.168.153.141
   success: 1
  full_ret: {"fun_args": [], "jid": "20190724153418459123", "return": true, "retcode": 0, "success": true, "fun": "test.ping", "id": "192.168.153.141"}
alter_time: 2019-07-24 15:34:18
1 row in set (0.00 sec)
```

## 2. job cache

### 2.1 job cache流程

return时是由Minion直接与存储服务器进行交互，因此需要在每台Minion上安装指定的存储方式的模块，比如python-mysql，那么我们能否直接在Master上就把返回的结果给存储到存储服务器呢？

答案是肯定的，这种方式被称作 job cache 。意思是当Minion将结果返回给Master后，由Master将结果给缓存在本地，然后将缓存的结果给存储到指定的存储服务器，比如存储到mysql中。

**开启master端的master_job_cache**

```
[root@master ~]# vim /etc/salt/master
....此处省略N行
master_job_cache: mysql
mysql.host: '192.168.153.142'
mysql.user: 'salt'
mysql.pass: 'salt'
mysql.db: 'salt'
mysql.port: 3306

[root@master ~]# systemctl restart salt-master
```

**在数据库服务器中清空表内容**

```
[root@mysql142 ~]# mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 9
Server version: 5.5.60-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> delete from salt.salt_returns;
Query OK, 4 rows affected (0.00 sec)

MariaDB [(none)]> select * from salt.salt_returns;
Empty set (0.00 sec)
```

**在master上再次测试能否存储至数据库**

```
[root@master ~]# salt '*' cmd.run 'ls /root/'
192.168.153.141:
    anaconda-ks.cfg
    b
    cca
    haha
192.168.153.142:
    anaconda-ks.cfg
192.168.153.136:
    anaconda-ks.cfg
```

**在数据库中查询**

```
MariaDB [(none)]> select * from salt.salt_returns\G
*************************** 1. row ***************************
       fun: cmd.run
       jid: 20190724154112399435
    return: "anaconda-ks.cfg\nb\ncca\nhaha"
        id: 192.168.153.141
   success: 1
  full_ret: {"fun_args": ["ls /root/"], "jid": "20190724154112399435", "return": "anaconda-ks.cfg\nb\ncca\nhaha", "retcode": 0, "success": true, "cmd": "_return", "_stamp": "2019-07-24T07:41:12.480205", "fun": "cmd.run", "id": "192.168.153.141"}
alter_time: 2019-07-24 15:41:12
*************************** 2. row ***************************
       fun: cmd.run
       jid: 20190724154112399435
    return: "anaconda-ks.cfg"
        id: 192.168.153.142
   success: 1
  full_ret: {"fun_args": ["ls /root/"], "jid": "20190724154112399435", "return": "anaconda-ks.cfg", "retcode": 0, "success": true, "cmd": "_return", "_stamp": "2019-07-24T07:41:12.482260", "fun": "cmd.run", "id": "192.168.153.142"}
alter_time: 2019-07-24 15:41:12
*************************** 3. row ***************************
       fun: cmd.run
       jid: 20190724154112399435
    return: "anaconda-ks.cfg"
        id: 192.168.153.136
   success: 1
  full_ret: {"fun_args": ["ls /root/"], "jid": "20190724154112399435", "return": "anaconda-ks.cfg", "retcode": 0, "success": true, "cmd": "_return", "_stamp": "2019-07-24T07:41:12.502037", "fun": "cmd.run", "id": "192.168.153.136"}
alter_time: 2019-07-24 15:41:12
3 rows in set (0.00 sec
```



### 2.2.Salt Job管理

**2.2.1.job概述**

`salt`每次运行任务都会将任务发布到`pub-sub`总线，`minion`会对任务作出响应，为区分不同的任务`SaltMaster`每次发布一个任务都会为该任务创建一个`jobid`。
`master`默认情况下会缓存24小时内的所有`job`的详细操作。

> 1.master缓存目录 /var/cache/salt/master/jobs
>
> 2.minion端每次执行任务都会缓存在 /var/cache/salt/minion/proc目录中创建jobid为名称的文件，任务执行完后文件会被删除

在`master`主机上执行一个长时间的任务

```
[root@master ~]# salt '192.168.153.141' cmd.run "sleep 100"
```

登陆`minion`执行

```
[root@minion ~]# ls /var/cache/salt/minion/proc
20190724155324683248


#用strings查看文件的文本部分内容
[root@minion ~]# strings /var/cache/salt/minion/proc/20190724155324683248
tgt_type
glob
20190724155324683248
192.168.153.141
user
root
sleep 100
cmd.run
```

`20190724155324683248`这串数字就是`jobid`一个以时间戳形式建立的唯一id。我们了解了jpbid的概念，下面来学习如果对job进行管理

**2.2.2.job管理**

通过`salt-run`命令来管理`job`也可以使用另一种管理`job`的方式`salt util`模块。

在`master`中执行一个长时间执行的命令

```
[root@master ~]# salt '192.168.153.141' cmd.run "sleep 1000;echo hehe"
^C
Exiting gracefully on Ctrl-c
This job's jid is: 20190724155612509222
The minions may not have all finished running and any remaining minions will return upon completion. To look up the return data for this job later, run the following command:

salt-run jobs.lookup_jid 20190724155612509222
     //CTRL+C
```

获取`jobid`后登陆`minion`查看

```
[root@minion ~]# ls /var/cache/salt/minion/proc
20190724155612509222
```

通过`saltutil.find_job`查看相关job信息

```
[root@master ~]# salt '192.168.153.141' saltutil.find_job 20190724155612509222
192.168.153.141:
    ----------
    arg:
        - sleep 1000;echo hehe
    fun:
        cmd.run
    jid:
        20190724155612509222
    pid:
        7908
    ret:
    tgt:
        192.168.153.141
    tgt_type:
        glob
    user:
        root
Kill`指定的`job
[root@master ~]# salt '192.168.153.141' saltutil.kill_job 20190724155612509222
192.168.153.141:
    Signal 9 sent to job 20190724155612509222 at pid 7908
```

查看`master`上`cache`的所有`job`

```
[root@master ~]# salt '*' saltutil.runner jobs.list_jobs|more
192.168.153.136:
    ----------
    .........省略n行...........
    20190724155501240253:
        ----------
        Arguments:
            - 20190724155324683248
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 15:55:01.240253
        Target:
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724155612509222:
        ----------
        Arguments:
            - sleep 1000;echo hehe
        Function:
            cmd.run
        StartTime:
            2019, Jul 24 15:56:12.509222
        Target:
            192.168.153.141
        Target-type:
            glob
        User:
            root
    20190724155741177897:
        ----------
        Arguments:
            - 20190724155612509222
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 15:57:41.177897
        Target:
            192.168.153.141
        Target-type:
            glob
        User:
            root
    20190724155801053200:
        ----------
        Arguments:
            - 20190724155612509222
        Function:
            saltutil.kill_job
        StartTime:
            2019, Jul 24 15:58:01.053200
        Target:
            192.168.153.141
        Target-type:
            glob
        User:
            root
    20190724155818591105:
        ----------
        Arguments:
            - jobs.list_jobs
        Function:
            saltutil.runner
        StartTime:
            2019, Jul 24 15:58:18.591105
        Target:
            192.168.153.141
        Target-type:
            glob
        User:
            root
    20190724155823729491:
        ----------
        Arguments:
            - 20190724155818591105
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 15:58:23.729491
        Target:
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724155833936773:
        ----------
        Arguments:
            - 20190724155818591105
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 15:58:33.936773
        Target:
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724155844137880:
        ----------
        Arguments:
            - 20190724155818591105
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 15:58:44.137880
        Target:
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724155854339557:
        ----------
        Arguments:
            - 20190724155818591105
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 15:58:54.339557
        Target:
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724155904545219:
        ----------
        Arguments:
            - 20190724155818591105
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 15:59:04.545219
        Target:
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724155914762497:
        ----------
        Arguments:
            - 20190724155818591105
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 15:59:14.762497
        Target:
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724155958568799:
        ----------
        Arguments:
            - jobs.list_jobs
        Function:
            saltutil.runner
        StartTime:
            2019, Jul 24 15:59:58.568799
        Target:
            *
        Target-type:
            glob
        User:
            root
    20190724160003643087:
        ----------
        Arguments:
            - 20190724155958568799
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 16:00:03.643087
        Target:
            - 192.168.153.142
            - 192.168.153.136
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724160013667699:
        ----------
        Arguments:
            - 20190724155958568799
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 16:00:13.667699
        Target:
            - 192.168.153.142
            - 192.168.153.136
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724160023684209:
        ----------
        Arguments:
            - 20190724155958568799
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 16:00:23.684209
        Target:
            - 192.168.153.142
            - 192.168.153.136
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724160033902700:
        ----------
        Arguments:
            - 20190724155958568799
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 16:00:33.902700
        Target:
            - 192.168.153.142
            - 192.168.153.136
            - 192.168.153.141
        Target-type:
            list
        User:
            root
    20190724160053973497:
        ----------
        Arguments:
            - 20190724155958568799
        Function:
            saltutil.find_job
        StartTime:
            2019, Jul 24 16:00:53.973497
        Target:
            - 192.168.153.142
            - 192.168.153.136
            - 192.168.153.141
        Target-type:
            list
        User:
            root
192.168.153.141:
    ----------
192.168.153.142:
    Exception occurred in runner jobs.list_jobs: Traceback (most recent call last):
      File "/usr/lib/python2.7/site-packages/salt/client/mixins.py", line 377, in low
        data['return'] = func(*args, **kwargs)
      File "/usr/lib/python2.7/site-packages/salt/runners/jobs.py", line 308, in list_jobs
        ret = mminion.returners['{0}.get_jids'.format(returner)]()
      File "/usr/lib/python2.7/site-packages/salt/returners/local_cache.py", line 376, in get_jids
        for jid, job, _, _ in _walk_through(_job_dir()):
      File "/usr/lib/python2.7/site-packages/salt/returners/local_cache.py", line 62, in _walk_through
        for top in os.listdir(job_dir):
    OSError: [Errno 2] No such file or directory: '/var/cache/salt/master/jobs'
```

### 2.2.3 job管理

**获取任务的jid**

```
[root@master ~]# salt '*' cmd.run 'uptime' -v
Executing job with jid 20190724154514953595       //此处就是此命令的jid
-------------------------------------------

92.168.153.141:
     15:45:15 up 35 min,  1 user,  load average: 0.06, 0.03, 0.05
192.168.153.136:
     15:45:15 up 34 min,  1 user,  load average: 0.00, 0.35, 0.47
192.168.153.142:
     15:45:15 up 28 min,  1 user,  load average: 0.00, 0.01, 0.05
```

**通过jid获取此任务的返回结果**

```
[root@master ~]# salt-run jobs.lookup_jid 20190724154514953595
192.168.153.136:
     15:45:15 up 34 min,  1 user,  load average: 0.00, 0.35, 0.47
192.168.153.141:
     15:45:15 up 35 min,  1 user,  load average: 0.06, 0.03, 0.05
192.168.153.142:
     15:45:15 up 28 min,  1 user,  load average: 0.00, 0.01, 0.05
     
数据库中:
*************************** 5. row ***************************
       fun: runner.jobs.lookup_jid
       jid: 20190724154613576437
    return: {"fun_args": ["20190724154514953595"], "jid": "20190724154613576437", "return": {"192.168.153.142": " 15:45:15 up 28 min,  1 user,  load average: 0.00, 0.01, 0.05", "192.168.153.136": " 15:45:15 up 34 min,  1 user,  load average: 0.00, 0.35, 0.47", "192.168.153.141": " 15:45:15 up 35 min,  1 user,  load average: 0.06, 0.03, 0.05"}, "success": true, "_stamp": "2019-07-24T07:46:49.136381", "user": "root", "fun": "runner.jobs.lookup_jid"}
        id: master_master
   success: 0
  full_ret: {"jid": "20190724154613576437", "return": {"fun_args": ["20190724154514953595"], "jid": "20190724154613576437", "return": {"192.168.153.142": " 15:45:15 up 28 min,  1 user,  load average: 0.00, 0.01, 0.05", "192.168.153.136": " 15:45:15 up 34 min,  1 user,  load average: 0.00, 0.35, 0.47", "192.168.153.141": " 15:45:15 up 35 min,  1 user,  load average: 0.06, 0.03, 0.05"}, "success": true, "_stamp": "2019-07-24T07:46:49.136381", "user": "root", "fun": "runner.jobs.lookup_jid"}, "tgt": "master_master", "user": "root", "fun": "runner.jobs.lookup_jid", "id": "master_master"}
alter_time: 2019-07-24 15:47:49
5 rows in set (0.00 sec)
```
