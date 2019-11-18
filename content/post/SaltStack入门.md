---
title: "SaltStack入门"
date: 2019-03-09T16:15:57+08:00
description: ""
draft: false
tags: ["自动化"]
categories: ["Linux运维"]
---

<!--more-->



## 1. SaltStack介绍

### 1.1 自动化运维工具

作为一个运维人员，很大一部分工作是在业务的配置管理和状态维护以及版本发布上，而当业务场景及公司规模上了一定规模后，人为手工的去做这些工作将变得极其困难，此时我们将需要利用一些自动化运维的工具来达到批量管理的目的。

常用的自动化运维工具有：

 - puppet
 - ansible
 - saltstack

此三款属同类工具，皆可用来提高运维管理的效率，但它们又各有优势，目前主流的自动化运维工具是`ansible`和`saltstack`。其中`ansible`无需安装客户端，这是其最大的优势，而`saltstack`则需要安装客户端工具，类似`zabbix`的agent。应用场景方面，`ansible`常用于小型企业，而`saltstack`则常用于中大型企业，因为`ansible`无法并行执行而`saltstack`可以并行。但不论其特点如何，本质上均属同类，所以只需要掌握一种即可轻松胜任运维工作。

**可以将SaltStack理解为神笔马良的那只笔！**

### 1.2 saltstack的特点

 - 基于python开发的C/S架构配置管理工具
 - 底层使用ZeroMQ消息队列pub/sub方式通信
 - 使用SSL证书签发的方式进行认证管理，传输采用AES加密

### 1.3 saltstack服务架构

在`saltstack`架构中服务器端叫`Master`，客户端叫`Minion`。

在`Master`和`Minion`端都是以守护进程的模式运行，一直监听配置文件里面定义的ret_port(接受minion请求)和publish_port(发布消息)的端口。

当`Minion`运行时会自动连接到配置文件里面定义的`Master`地址ret_port端口进行连接认证。

`saltstack`除了传统的C/S架构外，其实还有一种叫做`masterless`的架构，其不需要单独安装一台 master 服务器，只需要在每台机器上安装 `Minion`端，然后采用本机只负责对本机的配置管理机制服务的模式。

## 2. SaltStack四大功能与四大运行方式

`SaltStack`有四大功能，分别是：

 - 远程执行
 - 配置管理/状态管理
 - 云管理(cloud)
 - 事件驱动

`SaltStack`可以通过远程执行实现批量管理，并且通过描述状态来达到实现某些功能的目的。

`SaltStack`四大运行方式：

 - `local`本地运行
 - `Master/Minion`传统方式
 - `Syndic`分布式
 - `Salt ssh`

## 3. SaltStack组件介绍

| 组件                   | 功能                                                         |
| :--------------------- | :----------------------------------------------------------- |
| Salt Master            | 用于将命令和配置发送到在受管系统上运行的Salt minion          |
| Salt Minions           | 从Salt master接收命令和配置                                  |
| Execution Modules      | 从命令行针对一个或多个受管系统执行的临时命令。对...有用：<br>1. 实时监控，状态和库存<br>2. 一次性命令和脚本<br>3. 部署关键更新 |
| Formulas (States)      | 系统配置的声明性或命令式表示                                 |
| Grains                 | Grains是有关底层受管系统的静态信息，包括操作系统，内存和许多其他系统属性。 |
| Pillar                 | 用户定义的变量。这些安全变量被定义并存储在Salt Master中，然后使用目标“分配”给一个或多个Minion。 Pillar数据存储诸如端口，文件路径，配置参数和密码之类的值。 |
| Top File               | 将Formulas (States)和Salt Pillar数据与Salt minions匹配。     |
| Runners                | 在Salt master上执行的模块，用于执行支持任务。Salt runners报告作业状态，连接状态，从外部API读取数据，查询连接的Salt minions等。 |
| Returners              | 将Salt minions返回的数据发送到另一个系统，例如数据库。Salt Returners可以在Salt minion或Salt master上运行。 |
| Reactor                | 在SaltStack环境中发生事件时触发反应。                        |
| Salt Cloud / Salt Virt | 在云提供商/虚拟机管理程序上提供系统，并立即将其置于管理之下。 |
| Salt SSH               | 在没有Salt minion的系统上通过SSH运行Salt命令。               |

## 4. SaltStack安装与最小化配置

**环境说明：**

| 主机类型 |       IP        | 要安装的应用                                                 |
| :------: | :-------------: | :----------------------------------------------------------- |
|  控制机  | 192.168.153.136 | salt<br>salt-cloud<br>salt-master<br>salt-minion<br>salt-ssh<br>salt-syndic |
|  被控机  | 192.168.153.141 | salt-minion                                                  |

官方yum源地址：[https://repo.saltstack.com](https://repo.saltstack.com/)

### 4.1 在控制机上安装saltstack主控端软件

```
配置yum源
[root@master ~]# rpm -ivh https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm
获取https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm
准备中...                          ################################# [100%]
正在升级/安装...
   1:salt-repo-latest-2.el7           ################################# [100%]

[root@master ~]# yum clean all
已加载插件：fastestmirror
正在清理软件源： base centosplus epel extras salt-latest updates
Cleaning up list of fastest mirrors

安装saltstack主控端
[root@master ~]# yum -y install salt salt-cloud salt-master salt-minion salt-ssh salt-syndic
安装过程略....


修改主控端的配置文件(如果不改id,则是默认,例如master)
[root@master ~]# sed -i '/^#master:/a master: 192.168.153.136' /etc/salt/minion
[root@master ~]# sed -n '/^master/p' /etc/salt/minion
master: 192.168.153.136
[root@master ~]# sed -i "/^#id:/a id: $(ip a|grep -w 'inet'|grep 'global'|sed 's/^.*inet //g'|sed 's/\/[0-9][0-9].*$//g')" /etc/salt/minion
[root@master ~]# sed -n '/^id:/p' /etc/salt/minion
id: 192.168.153.136

启动主控端的salt-master和salt-minion，并设置开机自启
[root@master ~]# systemctl start salt-master
[root@master ~]# systemctl start salt-minion
[root@master ~]# systemctl enable salt-master
Created symlink from /etc/systemd/system/multi-user.target.wants/salt-master.service to /usr/lib/systemd/system/salt-master.service.
[root@localhost ~]# systemctl enable salt-minion
Created symlink from /etc/systemd/system/multi-user.target.wants/salt-minion.service to /usr/lib/systemd/system/salt-minion.service.

[root@master ~]# ss -antl
State       Recv-Q Send-Q Local Address:Port                Peer Address:Port              
LISTEN      0      128                *:22                             *:*                  
LISTEN      0      128                *:4505                           *:*                  
LISTEN      0      100        127.0.0.1:25                             *:*                  
LISTEN      0      128                *:4506                           *:*                  
LISTEN      0      128               :::22                            :::*                  
LISTEN      0      100              ::1:25                            :::*
```

### 4.2 在被控机上安装salt-minion客户端

```
配置yum源
[root@minion ~]# rpm -ivh https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm
获取https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm
准备中...                          ################################# [100%]
正在升级/安装...
   1:salt-repo-latest-2.el7           ################################# [100%]

[root@minion ~]# yum clean all
已加载插件：fastestmirror
正在清理软件源： base centosplus epel extras salt-latest updates
Cleaning up list of fastest mirrors


[root@minion ~]# yum -y install salt-minion
安装过程略....

修改被控端的配置文件，将master设为主控端的IP(如果不改id,则是默认,例如minion)
[root@minion ~]# sed -i '/^#master:/a master: 192.168.153.136' /etc/salt/minion
[root@minion ~]# sed -n '/^master/p' /etc/salt/minion
master: 192.168.153.136
[root@minion ~]# sed -i "/^#id:/a id: $(ip a|grep -w 'inet'|grep 'global'|sed 's/^.*inet //g'|sed 's/\/[0-9][0-9].*$//g')" /etc/salt/minion
[root@minion ~]# sed -n '/^id:/p' /etc/salt/minion
id: 192.168.153.141

启动受控端的salt-minion并设置开机自启
[root@minion ~]# systemctl start salt-minion
[root@minion ~]# systemctl enable salt-minion
Created symlink from /etc/systemd/system/multi-user.target.wants/salt-minion.service to /usr/lib/systemd/system/salt-minion.service.
```

### 4.3 saltstack配置文件

`saltstack`的配置文件在`/etc/salt`目录

**saltstack配置文件说明：**

| 配置文件         | 说明                   |
| :--------------- | :--------------------- |
| /etc/salt/master | 主控端(控制端)配置文件 |
| /etc/salt/minion | 受控端配置文件         |

配置文件`/etc/salt/master`默认的配置就可以很好的工作，故无需修改此配置文件。

**配置文件/etc/salt/minion常用配置参数**

 - master：设置主控端的IP
 - master_port:  指定认证和执⾏结果发送到master的哪个端⼝,  与master配置⽂件中的ret_port对应(默认为4506)
 - id：设置受控端本机的唯一标识符，可以是ip也可以是主机名或自取某有意义的单词(默认为完整主机名)
 - user:  指定运⾏minion的⽤户.由于安装包,启动服务等操作需要特权⽤户, 推荐使⽤root( 默认为root)
 - cache_jobs :  minion是否缓存执⾏结果(默认为False)
 - backup_mode:  在⽂件操作(file.managed 或file.recurse) 时,  如果⽂件发⽣变更,指定备份目录.当前有效
 - providers :  指定模块对应的providers, 如在RHEL系列中, pkg对应的providers 是yumpkg5
 - renderer:  指定配置管理系统中的渲染器(默认值为:yaml_jinja )
 - file_client :  指定file clinet 默认去哪⾥(remote 或local) 寻找⽂件(默认值为remote)
 - loglevel:  指定⽇志级别(默认为warning)
 - tcp_keepalive :  minion 是否与master 保持keepalive 检查, zeromq3(默认为True)

在日常使用过程中，经常需要调整或修改`Master`配置文件，SaltStack大部分配置都已经指定了默认值，只需根据自己的实际需求进行修改即可。下面的几个参数是比较重要的

 - max_open_files：可根据Master将Minion数量进行适当的调整
 - timeout：可根据Master和Minion的网络状况适当调整
 - auto_accept和autosign_file：在大规模部署Minion时可设置自动签证
 - master_tops和所有以external开头的参数：这些参数是SaltStack与外部系统进行整合的相关配置参数
 - interface:  指定bind 的地址(默认为0.0.0.0)
 - publish_port:  指定发布端⼝(默认为4505)
 - ret_port:  指定结果返回端⼝,  与minion配置⽂件中的master_port对应(默认为4506)
 - user:  指定master进程的运⾏⽤户,如果调整, 则需要调整部分目录的权限(默认为root)
 - keep_jobs:  minion执⾏结果返回master, master会缓存到本地的cachedir目录,该参数指定缓存多⻓时间,可查看之间执行结果会占⽤磁盘空间(默认为24h)
 - job_cache:  master是否缓存执⾏结果,如果规模庞⼤(超过5000台),建议使⽤其他⽅式来存储jobs,关闭本选项(默认为True)
 - file_recv :  是否允许minion传送⽂件到master 上(默认是Flase)
 - log_level:  ⽇志级别,⽀持的⽇志级别有'garbage', 'trace', 'debug', info', 'warning', 'error', ‘critical ’ ( 默认为’warning’)

## 5. SaltStack认证机制

`saltstack`主控端是依靠`openssl`证书来与受控端主机认证通讯的，受控端启动后会发送给主控端一个公钥证书文件，在主控端用`salt-key`命令来管理证书。

**salt-minion与salt-master的认证过程：**

 - minion在第一次启动时，会在/etc/salt/pki/minion/下自动生成一对密钥，然后将公钥发给master
 - master收到minion的公钥后，通过salt-key命令接受该公钥。此时master的/etc/salt/pki/master/minions目录将会存放以minion id命名的公钥，然后master就能对minion发送控制指令了

```
salt-key常用选项
    -L      //列出所有公钥信息
    -a minion    //接受指定minion等待认证的key
    -A      //接受所有minion等待认证的key
    -r minion    //拒绝指定minion等待认证的key
    -R      //拒绝所有minion等待认证的key
    -f minion   //显示指定key的指纹信息
    -F      //显示所有key的指纹信息
    -d minion   //删除指定minion的key
    -D      //删除所有minion的key
    -y      //自动回答yes

查看当前证书情况(在此之前关闭防火墙,或者配置相关规则,否则查看不到)
[root@master ~]# salt-key -L
Accepted Keys：  #已经接受的key
Denied Keys：    #拒绝的key
Unaccepted Keys：#未加入的key
192.168.153.136
192.168.153.141
Rejected Keys：#吊销的key

接受指定minion的新证书
[root@master ~]# salt-key -ya 192.168.153.141
The following keys are going to be accepted:
Unaccepted Keys:
192.168.153.141
Key for minion 192.168.153.141 accepted.
[root@master ~]# salt-key -L
Accepted Keys:
192.168.153.141
Denied Keys:
Unaccepted Keys:
192.168.153.136
Rejected Keys:


接受所有minion的新证书
[root@master ~]# salt-key -yA
The following keys are going to be accepted:
Unaccepted Keys:
192.168.153.136
Key for minion 192.168.153.136 accepted.
[root@master ~]# salt-key -L
Accepted Keys:
192.168.153.136
192.168.153.141
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```

## 6. SaltStack远程执行

```
测试指定受控端192.168.153.141主机是否存活
[root@master ~]# salt "192.168.153.141" test.ping
192.168.153.141:
    True
[root@master ~]# salt "192.168.153.141" cmd.run hostname
192.168.153.141:
    minion
    
测试所有受控端主机是否存活
[root@master ~]# salt '*' test.ping
192.168.153.141:
    True
192.168.153.136:
    True
[root@master ~]# salt "*" cmd.run hostname
192.168.153.136:
    master
192.168.153.141:
    minion

```

## 7. salt命令使用

```
语法：salt [options] '<target>' <function> [arguments]

常用的options
    --version       //查看saltstack的版本号
    --versions-report   //查看saltstack以及依赖包的版本号
    -h      //查看帮助信息
    -c CONFIG_DIR   //指定配置文件目录(默认为/etc/salt/)
    -t TIMEOUT      //指定超时时间(默认是5s)
    --async     //异步执行
    -v      //verbose模式，详细显示执行过程
    --username=USERNAME     //指定外部认证用户名
    --password=PASSWORD     //指定外部认证密码
    --log-file=LOG_FILE     //指定日志记录文件
    
常用target参数
    -E      //正则匹配
    -L      //列表匹配 
    -S      //CIDR匹配网段
    -G      //grains匹配
    --grain-pcre    //grains加正则匹配
    -N      //组匹配
    -R      //范围匹配
    -C      //综合匹配（指定多个匹配）
    -I      //pillar值匹配




示例
[root@master ~]# salt -E '192*' test.ping
192.168.153.141:
    True
192.168.153.136:
    True

[root@master ~]# salt -L 192.168.153.136,192.168.153.141 cmd.run 'uptime'
192.168.153.141:
     16:48:29 up 11 min,  1 user,  load average: 0.00, 0.03, 0.05
192.168.153.136:
     16:48:29 up 11 min,  1 user,  load average: 0.03, 0.24, 0.27

[root@master ~]# salt -S '192.168.153.0/24' grains.item fqdn_ip4
192.168.153.141:
    ----------
    fqdn_ip4:
        - 192.168.153.141
192.168.153.136:
    ----------
    fqdn_ip4:
        - 192.168.153.136

[root@master ~]# salt -G 'os:centos' test.ping
192.168.153.141:
    True
192.168.153.136:
    True

[root@master ~]# salt -N redhat test.ping
192.168.153.136:
    True
192.168.153.141:
    True
    
此处的redhat是一个组名，需要在master配置文件中定义nodegroups参数，且需要知道minion的id信息才能将其定义至某个组中(或者用其他方式匹配)
vim /etc/salt/master
nodegroups:
  redhat: 'G@os:centos'    (grains匹配的组,一般不建议,此处只是测试)
...

[root@master ~]# salt -C 'G@os:centos or L@192.168.153.141' test.ping
192.168.153.136:
    True
192.168.153.141:
    True
    
G@os:centos or L@192.168.153.141是一个复合组合，支持使用and和or关联多个条件
```