---
title: "SaltStack之配置管理"
date: 2019-03-10T16:15:57+08:00
description: ""
draft: false
tags: ["自动化"]
categories: ["Linux运维"]
---

<!--more-->



## 1. YAML语言

`YAML`是一种直观的能够被电脑识别的数据序列化格式，是一个可读性高并且容易被人类阅读，容易和脚本语言交互，用来表达资料序列的编程语言。

它类似于标准通用标记语言的子集XML的数据描述语言，语法比XML简单很多。

`YAML`语言的格式如下：

```
house:
  family:
    name: Doe
    parents:
      - John
      - Jane
    children:
      - Paul
      - Mark
      - Simone
  address:
    number: 34
    street: Main Street
    city: Nowheretown
    zipcode: 12345
```

YAML的基本规则：

 - 使用缩进来表示层级关系，每层2个空格，禁止使用TAB键
 - 当冒号不是处于最后时，冒号后面必须有一个空格
 - 用 - 表示列表，- 的后面必须有一个空格
 - 用 # 表示注释

`YAML`配置文件要放到`SaltStack`让我们放的位置，可以在`SaltStack`的 Master 配置文件中查找`file_roots`即可看到。

```
[root@master ~]# vim /etc/salt/master
#定义基础环境目录位置
...此处省略N行
file_roots:
  base:
    - /srv/salt/base
  test:
    - /srv/salt/test
  dev:
    - /srv/salt/dev
  prod:
    - /srv/salt/prod
...此处省略N行
#修改配置必须重启服务(做完所有操作再重启)

[root@master ~]# mkdir -p /srv/salt/{base,test,dev,prod}
[root@master ~]# tree /srv/salt/
/srv/salt/
├── base
├── dev
├── prod
└── test

4 directories, 0 files
[root@master ~]# systemctl restart salt-master
```

**需要注意：**

 - base是默认的位置，如果file_roots只有一个，则base是必备的且必须叫base，不能改名

## 2. 用SaltStack配置一个apache实例

### 2.1 在Master上部署sls配置文件并执行

```
[root@master ~]# cd /srv/salt/base/
[root@master base]# ls
[root@master base]# mkdir -p web/apache
[root@master base]# tree web
web
└── apache

1 directory, 0 files

[root@master base]# cd web/apache/
[root@master apache]# touch apache.sls      //生成一个状态描述文件
[root@master apache]# ll
总用量 0
-rw-r--r-- 1 root root 0 7月  23 18:04 apache.sls

[root@master apache]# vim apache.sls
apache-install:
  pkg.installed:
    - name: httpd

apache-service:
  service.running:
    - name: httpd
    - enable: True

YAML 配置文件中顶格写的被称作ID，必须全局唯一，不能重复
SaltStack 读 YAML 配置文件时是从上往下读，所以要把先执行的写在前面

[root@master ~]# ls /srv/salt/base/web/apache/
apache.sls
执行状态描述文件
[root@master ~]# salt '192.168.153.141' state.sls web.apache.apache saltenv=base
192.168.153.141:
----------
          ID: apache-install
    Function: pkg.installed
        Name: httpd
      Result: True
     Comment: All specified packages are already installed
     Started: 18:26:24.745053
    Duration: 853.151 ms
     Changes:
----------
          ID: apache-service
    Function: service.running
        Name: httpd
      Result: True
     Comment: The service httpd is already running
     Started: 18:26:25.600138
    Duration: 45.182 ms
     Changes:   

Summary for 192.168.153.141
------------
Succeeded: 2
Failed:    0
------------
Total states run:     2
Total run time: 898.333 ms
```

### 2.2 在Minion上检查

```
[root@minion ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2019-07-23 18:08:23 CST; 20min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 6658 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/httpd.service
           ├─6658 /usr/sbin/httpd -DFOREGROUND
           ├─7293 /usr/sbin/httpd -DFOREGROUND
           ├─7294 /usr/sbin/httpd -DFOREGROUND
           ├─7295 /usr/sbin/httpd -DFOREGROUND
           ├─7296 /usr/sbin/httpd -DFOREGROUND
           └─7297 /usr/sbin/httpd -DFOREGROUND

7月 23 18:07:58 minion systemd[1]: Starting The Apache HTTP Server...
7月 23 18:08:13 minion httpd[6658]: AH00558: httpd: Could not reliably determine the server's ...sage
7月 23 18:08:23 minion systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```

由以上内容可知apache确实已部署成功。

执行状态文件的技巧：

 - 先用test.ping测试需要执行状态文件的主机是否能正常通信，然后再执行状态文件

## 3. top file

### 3.1 top file介绍

直接通过命令执行sls文件时够自动化吗？答案是否定的，因为我们还要告诉某台主机要执行某个任务，自动化应该是我们让它干活时，它自己就知道哪台主机要干什么活，但是直接通过命令执行sls文件并不能达到这个目的，为了解决这个问题，top file 应运而生。

top file就是一个入口，top file的文件名可通过在 Master的配置文件中搜索top.sls找出，且此文件必须在 base 环境中，默认情况下此文件必须叫top.sls。

top file的作用就是告诉对应的主机要干什么活，比如让web服务器启动web服务，让数据库服务器安装mysql等等。

**top file 实例：**

```
[root@master ~]# cd /srv/salt/base/
[root@master base]# ls
web
[root@master base]# vim top.sls
base:   //要执行状态文件的环境
  '192.168.153.141':     //要执行状态文件的目标
    - web.apache.apache   //要执行的状态文件
    - fspub.vsftpd
(注意语法,写错无效,别丢了:和空格)

停止minion的httpd
[root@minion ~]# systemctl stop httpd


    
[root@master base]# cd
[root@master ~]# salt '*' state.highstate   //使用高级状态来执行
192.168.153.136:
----------
          ID: states
    Function: no.None
      Result: False
     Comment: No Top file or master_tops data matches found.    //在top file里没找到它要干啥
     Changes:

Summary for 192.168.153.136
------------
Succeeded: 0
Failed:    1
------------
Total states run:     1
Total run time:   0.000 ms
192.168.153.141:
----------
          ID: apache-install
    Function: pkg.installed
        Name: httpd
      Result: True
     Comment: All specified packages are already installed
     Started: 18:34:05.500453
    Duration: 821.228 ms
     Changes:   
----------
          ID: apache-service
    Function: service.running
        Name: httpd
      Result: True
     Comment: The service httpd is already running
     Started: 18:34:06.322411
    Duration: 51.338 ms
     Changes:   

Summary for 192.168.153.141
------------
Succeeded: 2
Failed:    0
------------
Total states run:     2
Total run time: 872.566 ms
ERROR: Minions returned with non-zero exit code


查看minion的httpd状态
[root@minion ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2019-07-23 18:34:00 CST; 2min 52s ago
     Docs: man:httpd(8)
           man:apachectl(8)
  Process: 7723 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=0/SUCCESS)
 Main PID: 7794 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/httpd.service
           ├─7794 /usr/sbin/httpd -DFOREGROUND
           ├─7802 /usr/sbin/httpd -DFOREGROUND
           ├─7803 /usr/sbin/httpd -DFOREGROUND
           ├─7804 /usr/sbin/httpd -DFOREGROUND
           ├─7805 /usr/sbin/httpd -DFOREGROUND
           └─7806 /usr/sbin/httpd -DFOREGROUND

7月 23 18:33:35 minion systemd[1]: Starting The Apache HTTP Server...
7月 23 18:33:50 minion httpd[7794]: AH00558: httpd: Could not reliably determine the server's ...sage
7月 23 18:34:00 minion systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.

```

**注意：**

> 若top file里面的目标是用 * 表示的，要注意的是，top file里面的 * 表示的是所有要执行状态的目标，而 `salt '*' state.highstate` 里面的 * 表示通知所有机器干活，而是否要干活则是由top file来指定的

### 3.2 高级状态highstate的使用

管理`SaltStack`时一般最常用的管理操作就是执行高级状态

```
[root@master ~]# salt '*' state.highstate   //生产环境禁止这样使用salt命令
```

**注意：**
上面让所有人执行高级状态，但实际工作当中，一般不会这么用，工作当中一般都是通知某台或某些台目标主机来执行高级状态，具体是否执行则是由top file来决定的。

若在执行高级状态时加上参数`test=True`，则它会告诉我们它将会做什么，但是它不会真的去执行这个操作。

```
停掉minon上的httpd服务
[root@minion ~]# systemctl stop httpd
[root@minion ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since 二 2019-07-23 18:37:40 CST; 1s ago
     Docs: man:httpd(8)
           man:apachectl(8)
  Process: 8014 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=0/SUCCESS)
  Process: 7794 ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND (code=exited, status=0/SUCCESS)
 Main PID: 7794 (code=exited, status=0/SUCCESS)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"

7月 23 18:33:35 minion systemd[1]: Starting The Apache HTTP Server...
7月 23 18:33:50 minion httpd[7794]: AH00558: httpd: Could not reliably determine the server's ...sage
7月 23 18:34:00 minion systemd[1]: Started The Apache HTTP Server.
7月 23 18:37:39 minion systemd[1]: Stopping The Apache HTTP Server...
7月 23 18:37:40 minion systemd[1]: Stopped The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.


在master上执行高级状态的测试
[root@master ~]# salt '192.168.153.141' state.highstate test=True
192.168.153.141:
----------
          ID: apache-install
    Function: pkg.installed
        Name: httpd
      Result: True
     Comment: All specified packages are already installed
     Started: 18:38:27.061982
    Duration: 816.863 ms
     Changes:   
----------
          ID: apache-service
    Function: service.running
        Name: httpd
      Result: None
     Comment: Service httpd is set to start
     Started: 18:38:27.879596
    Duration: 51.454 ms
     Changes:   

Summary for 192.168.153.141
------------
Succeeded: 2 (unchanged=1)
Failed:    0
------------
Total states run:     2
Total run time: 868.317 ms



在minion上查看httpd是否启动
[root@minion ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since 二 2019-07-23 18:37:40 CST; 1min 58s ago
     Docs: man:httpd(8)
           man:apachectl(8)
  Process: 8014 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=0/SUCCESS)
  Process: 7794 ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND (code=exited, status=0/SUCCESS)
 Main PID: 7794 (code=exited, status=0/SUCCESS)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"

7月 23 18:33:35 minion systemd[1]: Starting The Apache HTTP Server...
7月 23 18:33:50 minion httpd[7794]: AH00558: httpd: Could not reliably determine the server's ...sage
7月 23 18:34:00 minion systemd[1]: Started The Apache HTTP Server.
7月 23 18:37:39 minion systemd[1]: Stopping The Apache HTTP Server...
7月 23 18:37:40 minion systemd[1]: Stopped The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.

由此可见高级状态并没有执行，因为httpd并没有启动(如果想启动,可以把test=True去掉再执行,第一次可能会无响应)
```

### 4.扩展

```
接着上面的操作
在master上
[root@master ~]# cd /srv/salt/base/
[root@master base]# ls
top.sls  web
[root@master base]# mkdir fspub
[root@master base]# ll web/
总用量 0
drwxr-xr-x 2 root root 24 7月  23 18:05 apache
[root@master base]# vim fspub/vsftpd.sls
[root@master base]# vim top.sls 
[root@master base]# salt '192.168.153.141' state.sls fspub.vsftpd saltenv=base
192.168.153.141:
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: vsftpd
      Result: True
     Comment: The following packages were installed/updated: vsftpd
     Started: 18:55:39.594617
    Duration: 12818.265 ms
     Changes:   
              ----------
              vsftpd:
                  ----------
                  new:
                      3.0.2-25.el7
                  old:
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: httpd-tools
      Result: True
     Comment: All specified packages are already installed
     Started: 18:55:52.474144
    Duration: 1190.439 ms
     Changes:   
----------
          ID: vsftpd_systemctl
    Function: service.running
        Name: vsftpd
      Result: True
     Comment: Service vsftpd has been enabled, and is running
     Started: 18:55:53.665635
    Duration: 203.686 ms
     Changes:   
              ----------
              vsftpd:
                  True

Summary for 192.168.153.141
------------
Succeeded: 3 (changed=2)
Failed:    0
------------
Total states run:     3
Total run time:  14.212 s


在minion上查看vsftpd是否启动
[root@minion ~]# systemctl status vsftpd
● vsftpd.service - Vsftpd ftp daemon
   Loaded: loaded (/usr/lib/systemd/system/vsftpd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2019-07-23 18:55:53 CST; 17min ago
 Main PID: 9453 (vsftpd)
   CGroup: /system.slice/vsftpd.service
           └─9453 /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

7月 23 18:55:53 minion systemd[1]: Starting Vsftpd ftp daemon...
7月 23 18:55:53 minion systemd[1]: Started Vsftpd ftp daemon.

在master上修改top.sls
[root@master base]# cat top.sls 
base:
  '192.168.153.141':
    - web.apache.apache
    - fspub.vsftpd
  '192.168.153.136':
    - fspub.vsftpd

在minion上停止vsftpd和httpd
[root@minion ~]# systemctl stop vsftpd
[root@minion ~]# systemctl stop httpd

在master上
[root@master ~]# salt '*' state.highstate   //使用高级状态来执行
192.168.153.136:
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: vsftpd
      Result: True
     Comment: All specified packages are already installed
     Started: 19:19:28.682811
    Duration: 1021.589 ms
     Changes:   
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: httpd-tools
      Result: True
     Comment: All specified packages are already installed
     Started: 19:19:29.704748
    Duration: 23.736 ms
     Changes:   
----------
          ID: vsftpd_systemctl
    Function: service.running
        Name: vsftpd
      Result: True
     Comment: The service vsftpd is already running
     Started: 19:19:29.729510
    Duration: 112.628 ms
     Changes:   

Summary for 192.168.153.136
------------
Succeeded: 3
Failed:    0
------------
Total states run:     3
Total run time:   1.158 s
192.168.153.141:
----------
          ID: apache-install
    Function: pkg.installed
        Name: httpd
      Result: True
     Comment: All specified packages are already installed
     Started: 19:19:28.896306
    Duration: 972.152 ms
     Changes:   
----------
          ID: apache-service
    Function: service.running
        Name: httpd
      Result: True
     Comment: The service httpd is already running
     Started: 19:19:29.869776
    Duration: 55.83 ms
     Changes:   
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: vsftpd
      Result: True
     Comment: All specified packages are already installed
     Started: 19:19:29.925877
    Duration: 20.429 ms
     Changes:   
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: httpd-tools
      Result: True
     Comment: All specified packages are already installed
     Started: 19:19:29.946472
    Duration: 19.286 ms
     Changes:   
----------
          ID: vsftpd_systemctl
    Function: service.running
        Name: vsftpd
      Result: True
     Comment: The service vsftpd is already running
     Started: 19:19:29.965930
    Duration: 42.776 ms
     Changes:   

Summary for 192.168.153.141
------------
Succeeded: 5
Failed:    0
------------
Total states run:     5
Total run time:   1.110 s
由上可见,在master上执行了vsftpd的安装,启动和开机自启操作,而httpd的相关操作都没有做,是根据top.sls文件来的
[root@master base]# systemctl status vsftpd
● vsftpd.service - Vsftpd ftp daemon
   Loaded: loaded (/usr/lib/systemd/system/vsftpd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2019-07-23 19:19:11 CST; 7min ago
 Main PID: 15064 (vsftpd)
   CGroup: /system.slice/vsftpd.service
           └─15064 /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

7月 23 19:19:11 master systemd[1]: Starting Vsftpd ftp daemon...
7月 23 19:19:11 master systemd[1]: Started Vsftpd ftp daemon.
[root@master ~]# systemctl stop vsftpd.service 
[root@master ~]# salt '192.168.153.136' state.highstate
192.168.153.136:
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: vsftpd
      Result: True
     Comment: All specified packages are already installed
     Started: 19:27:59.676342
    Duration: 756.205 ms
     Changes:   
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: httpd-tools
      Result: True
     Comment: All specified packages are already installed
     Started: 19:28:00.432840
    Duration: 16.727 ms
     Changes:   
----------
          ID: vsftpd_systemctl
    Function: service.running
        Name: vsftpd
      Result: True
     Comment: Service vsftpd is already enabled, and is running
     Started: 19:28:00.450363
    Duration: 103.183 ms
     Changes:   
              ----------
              vsftpd:
                  True

Summary for 192.168.153.136
------------
Succeeded: 3 (changed=1)
Failed:    0
------------
Total states run:     3
Total run time: 876.115 ms
[root@master ~]# systemctl status vsftpd.service 
● vsftpd.service - Vsftpd ftp daemon
   Loaded: loaded (/usr/lib/systemd/system/vsftpd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2019-07-23 19:28:00 CST; 12s ago
  Process: 15810 ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf (code=exited, status=0/SUCCESS)
 Main PID: 15811 (vsftpd)
   CGroup: /system.slice/vsftpd.service
           └─15811 /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

7月 23 19:28:00 master systemd[1]: Starting Vsftpd ftp daemon...
7月 23 19:28:00 master systemd[1]: Started Vsftpd ftp daemon.


在minion上查看状态
[root@minion ~]# systemctl status vsftpd
● vsftpd.service - Vsftpd ftp daemon
   Loaded: loaded (/usr/lib/systemd/system/vsftpd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2019-07-23 19:19:23 CST; 55s ago
  Process: 9703 ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf (code=exited, status=0/SUCCESS)
 Main PID: 9704 (vsftpd)
   CGroup: /system.slice/vsftpd.service
           └─9704 /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

7月 23 19:19:23 minion systemd[1]: Starting Vsftpd ftp daemon...
7月 23 19:19:23 minion systemd[1]: Started Vsftpd ftp daemon.
[root@minion ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2019-07-23 19:19:23 CST; 1min 1s ago
     Docs: man:httpd(8)
           man:apachectl(8)
  Process: 9622 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=0/SUCCESS)
 Main PID: 9683 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/httpd.service
           ├─9683 /usr/sbin/httpd -DFOREGROUND
           ├─9690 /usr/sbin/httpd -DFOREGROUND
           ├─9691 /usr/sbin/httpd -DFOREGROUND
           ├─9692 /usr/sbin/httpd -DFOREGROUND
           ├─9693 /usr/sbin/httpd -DFOREGROUND
           └─9694 /usr/sbin/httpd -DFOREGROUND

7月 23 19:18:58 minion systemd[1]: Starting The Apache HTTP Server...
7月 23 19:19:13 minion httpd[9683]: AH00558: httpd: Could not reliably determine the server's ...sage
7月 23 19:19:23 minion systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```

