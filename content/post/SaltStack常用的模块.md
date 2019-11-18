---
title: "SaltStack常用的模块"
date: 2019-03-17T16:15:57+08:00
description: ""
draft: false
tags: ["自动化"]
categories: ["Linux运维"]
---

<!--more-->



## 1. SaltStack模块介绍

Module是日常使用SaltStack接触最多的一个组件，其用于管理对象操作，这也是SaltStack通过Push的方式进行管理的入口，比如我们日常简单的执行命令、查看包安装情况、查看服务运行情况等工作都是通过SaltStack Module来实现的。

当安装好Master和Minion包后，系统上会安装很多Module，大家可以通过以下命令查看支持的所有Module列表：

```
查看所有module列表
[root@master ~]# salt '192.168.153.141' sys.list_modules
192.168.153.141:
    - acl
    - aliases
    - alternatives
    - ansible
    - apache
    - archive
    - artifactory
    - augeas
    - beacons
    - bigip
    - btrfs
    - buildout
    - cloud
    - cmd
    - composer
    - config
    - 此处省略N行

查看指定module的所有function
[root@master ~]# salt '192.168.153.141' sys.list_functions cmd
192.168.153.141:
    - cmd.exec_code
    - cmd.exec_code_all
    - cmd.has_exec
    - cmd.powershell
    - cmd.powershell_all
    - cmd.retcode
    - cmd.run
    - cmd.run_all
    - cmd.run_bg
    - cmd.run_chroot
    - cmd.run_stderr
    - cmd.run_stdout
    - cmd.script
    - cmd.script_retcode
    - cmd.shell
    - cmd.shell_info
    - cmd.shells
    - cmd.tty
    - cmd.which
    - cmd.which_bin

查看指定module的用法
[root@master ~]# salt '192.168.153.141' sys.doc cmd
'cmd.exec_code:'

    Pass in two strings, the first naming the executable language, aka -
    python2, python3, ruby, perl, lua, etc. the second string containing
    the code you wish to execute. The stdout will be returned.

    CLI Example:

        salt '*' cmd.exec_code ruby 'puts "cheese"' 
...此处省略N行...


SaltStack默认也支持一次执行多个Module，Module之间通过逗号隔开，默认传参之间也是用逗号分隔，也支持指定传参分隔符号--args-separator=@即可
[root@master ~]# salt '192.168.153.141' test.echo,cmd.run,service.status hello,hostname,salt-minion
192.168.153.141:
    ----------
    cmd.run:
        minion
    service.status:
        True
    test.echo:
        hello
```

## 2. SaltStack常用模块

### 2.1 SaltStack常用模块之network

#### 2.1.1 network.active_tcp

返回所有活动的tcp连接

```
[root@master ~]# salt '*' network.active_tcp
192.168.153.141:
    ----------
    0:
        ----------
        local_addr:
            192.168.153.141
        local_port:
            35826
        remote_addr:
            192.168.153.136
        remote_port:
            4505
    1:
        ----------
        local_addr:
            192.168.153.141
        local_port:
            22
        remote_addr:
            192.168.153.1
        remote_port:
            11476
192.168.153.136:
    ----------
    0:
        ----------
        local_addr:
            192.168.153.136
        local_port:
            47888
        remote_addr:
            192.168.153.136
        remote_port:
            4505
    1:
        ----------
        local_addr:
            192.168.153.136
        local_port:
            4505
        remote_addr:
            192.168.153.136
        remote_port:
            47888
    2:
        ----------
        local_addr:
            192.168.153.136
        local_port:
            22
        remote_addr:
            192.168.153.1
        remote_port:
            10505
    3:
        ----------
        local_addr:
            192.168.153.136
        local_port:
            4505
        remote_addr:
            192.168.153.141
        remote_port:
            35826
```

#### 2.1.2 network.calc_net

通过IP和子网掩码计算出网段

```
[root@master ~]# salt '*' network.calc_net 192.168.153.141 255.255.255.0
192.168.153.141:
    192.168.153.0/24
192.168.153.136:
    192.168.153.0/24
    
[root@master ~]# salt '*' network.calc_net 192.168.153.141 255.255.255.240
192.168.153.141:
    192.168.153.128/28
192.168.153.136:
    192.168.153.128/28
```

#### 2.1.3 network.connect

测试minion至某一台服务器的网络是否连通

```
[root@master ~]# salt '*' network.connect baidu.com 80
192.168.153.141:
    ----------
    comment:
        Successfully connected to baidu.com (39.156.69.79) on tcp port 80
    result:
        True
192.168.153.136:
    ----------
    comment:
        Successfully connected to baidu.com (220.181.38.148) on tcp port 80
    result:
        True
```

#### 2.1.4 network.default_route

查看默认路由

```
[root@master ~]# salt '*' network.default_route
192.168.153.141:
    |_
      ----------
      addr_family:
          inet
      destination:
          0.0.0.0
      flags:
          UG
      gateway:
          192.168.153.2
      interface:
          ens32
      netmask:
          0.0.0.0
192.168.153.136:
    |_
      ----------
      addr_family:
          inet
      destination:
          0.0.0.0
      flags:
          UG
      gateway:
          192.168.153.2
      interface:
          ens32
      netmask:
          0.0.0.0
    |_
      ----------
      addr_family:
          inet6
      destination:
          ::/0
      flags:
          !n
      gateway:
          ::
      interface:
          lo
      netmask:
    |_
      ----------
      addr_family:
          inet6
      destination:
          ::/0
      flags:
          !n
      gateway:
          ::
      interface:
          lo
      netmask:
```

#### 2.1.5 network.get_fqdn

查看主机的fqdn(完全限定域名)

```
[root@master ~]# salt '*' network.get_fqdn
192.168.153.141:
    minion
192.168.153.136:
    master
```

#### 2.1.6 network.get_hostname

获取主机名

```
[root@master ~]# salt '*' network.get_hostname
192.168.153.141:
    minion
192.168.153.136:
    master
```

#### 2.1.7 network.get_route

查询到一个目标网络的路由信息

```
[root@master ~]# salt '*' network.get_route 10.0.34.209
192.168.153.136:
    ----------
    destination:
        10.0.34.209
    gateway:
        192.168.153.2
    interface:
        ens32
    source:
        192.168.153.136
192.168.153.141:
    ----------
    destination:
        10.0.34.209
    gateway:
        192.168.153.2
    interface:
        ens32
    source:
        192.168.153.141
```

#### 2.1.8 network.hw_addr

返回指定网卡的MAC地址

```
[root@master ~]# salt '*' network.hw_addr ens32
192.168.153.141:
    00:0c:29:65:2d:90
192.168.153.136:
    00:0c:29:95:7a:7f
```

#### 2.1.9 network.ifacestartswith

从特定CIDR检索接口名称

```
[root@master ~]# salt '*' network.ifacestartswith 192.168
192.168.153.141:
    - ens32
192.168.153.136:
    - ens32
```

#### 2.1.10 network.in_subnet

判断当前主机是否在某一个网段内

```
[root@master ~]# salt '*' network.in_subnet 192.168.153.0/24
192.168.153.136:
    True
192.168.153.141:
    True
```

#### 2.1.11 network.interface

返回指定网卡的信息

```
[root@master ~]# salt '*' network.interface ens32
192.168.153.141:
    |_
      ----------
      address:
          192.168.153.141
      broadcast:
          192.168.153.255
      label:
          ens32
      netmask:
          255.255.255.0
192.168.153.136:
    |_
      ----------
      address:
          192.168.153.136
      broadcast:
          192.168.153.255
      label:
          ens32
      netmask:
          255.255.255.0
```

#### 2.1.12 network.interface_ip

返回指定网卡的IP地址

```
[root@master ~]# salt '*' network.interface_ip ens32
192.168.153.136:
    192.168.153.136
192.168.153.141:
    192.168.153.141
```

#### 2.1.13 network.interfaces

返回当前系统中所有的网卡信息

```
[root@master ~]# salt '*' network.interfaces
192.168.153.141:
    ----------
    ens32:
        ----------
        hwaddr:
            00:0c:29:65:2d:90
        inet:
            |_
              ----------
              address:
                  192.168.153.141
              broadcast:
                  192.168.153.255
              label:
                  ens32
              netmask:
                  255.255.255.0
        inet6:
            |_
              ----------
              address:
                  fe80::20c:29ff:fe65:2d90
              prefixlen:
                  64
              scope:
                  link
        up:
            True
    lo:
        ----------
        hwaddr:
            00:00:00:00:00:00
        inet:
            |_
              ----------
              address:
                  127.0.0.1
              broadcast:
                  None
              label:
                  lo
              netmask:
                  255.0.0.0
        inet6:
            |_
              ----------
              address:
                  ::1
              prefixlen:
                  128
              scope:
                  host
        up:
            True
192.168.153.136:
    ----------
    ens32:
        ----------
        hwaddr:
            00:0c:29:95:7a:7f
        inet:
            |_
              ----------
              address:
                  192.168.153.136
              broadcast:
                  192.168.153.255
              label:
                  ens32
              netmask:
                  255.255.255.0
        inet6:
            |_
              ----------
              address:
                  fe80::20c:29ff:fe95:7a7f
              prefixlen:
                  64
              scope:
                  link
        up:
            True
    lo:
        ----------
        hwaddr:
            00:00:00:00:00:00
        inet:
            |_
              ----------
              address:
                  127.0.0.1
              broadcast:
                  None
              label:
                  lo
              netmask:
                  255.0.0.0
        inet6:
            |_
              ----------
              address:
                  ::1
              prefixlen:
                  128
              scope:
                  host
        up:
            True
```

#### 2.1.14 network.ip_addrs

返回一个IPv4的地址列表
该函数将会忽略掉`127.0.0.1`的地址

```
[root@master ~]# salt '*' network.ip_addrs
192.168.153.141:
    - 192.168.153.141
192.168.153.136:
    - 192.168.153.136
```

#### 2.1.15 network.netstat

返回所有打开的端口和状态

```
[root@master ~]# salt '*' network.netstat
192.168.153.136:
    |_
      ----------
      inode:
          38622
      local-address:
          0.0.0.0:22
      program:
          6673/sshd
      proto:
          tcp
      recv-q:
          0
      remote-address:
          0.0.0.0:*
      send-q:
          0
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          92692
      local-address:
          0.0.0.0:4505
      program:
          23522/python
      proto:
          tcp
      recv-q:
          0
      remote-address:
          0.0.0.0:*
      send-q:
          0
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          40609
      local-address:
          127.0.0.1:25
      program:
          7166/master
      proto:
          tcp
      recv-q:
          0
      remote-address:
          0.0.0.0:*
      send-q:
          0
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          92698
      local-address:
          0.0.0.0:4506
      program:
          23528/python
      proto:
          tcp
      recv-q:
          0
      remote-address:
          0.0.0.0:*
      send-q:
          0
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          92882
      local-address:
          192.168.153.136:47888
      program:
          21887/python
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.136:4505
      send-q:
          0
      state:
          ESTABLISHED
      user:
          0
    |_
      ----------
      inode:
          92883
      local-address:
          192.168.153.136:4505
      program:
          23522/python
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.136:47888
      send-q:
          0
      state:
          ESTABLISHED
      user:
          0
    |_
      ----------
      inode:
          0
      local-address:
          192.168.153.136:54608
      program:
          -
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.136:4506
      send-q:
          0
      state:
          TIME_WAIT
      user:
          0
    |_
      ----------
      inode:
          41377
      local-address:
          192.168.153.136:22
      program:
          7358/sshd:
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.1:10505
      send-q:
          0
      state:
          ESTABLISHED
      user:
          0
    |_
      ----------
      inode:
          0
      local-address:
          192.168.153.136:54604
      program:
          -
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.136:4506
      send-q:
          0
      state:
          TIME_WAIT
      user:
          0
    |_
      ----------
      inode:
          92890
      local-address:
          192.168.153.136:4505
      program:
          23522/python
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.141:35826
      send-q:
          0
      state:
          ESTABLISHED
      user:
          0
    |_
      ----------
      inode:
          0
      local-address:
          127.0.0.1:48486
      program:
          -
      proto:
          tcp
      recv-q:
          0
      remote-address:
          127.0.0.1:4506
      send-q:
          0
      state:
          TIME_WAIT
      user:
          0
    |_
      ----------
      inode:
          0
      local-address:
          127.0.0.1:48478
      program:
          -
      proto:
          tcp
      recv-q:
          0
      remote-address:
          127.0.0.1:4506
      send-q:
          0
      state:
          TIME_WAIT
      user:
          0
    |_
      ----------
      inode:
          0
      local-address:
          127.0.0.1:48482
      program:
          -
      proto:
          tcp
      recv-q:
          0
      remote-address:
          127.0.0.1:4506
      send-q:
          0
      state:
          TIME_WAIT
      user:
          0
    |_
      ----------
      inode:
          69295
      local-address:
          :::21
      program:
          15811/vsftpd
      proto:
          tcp6
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          0
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          38631
      local-address:
          :::22
      program:
          6673/sshd
      proto:
          tcp6
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          0
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          40610
      local-address:
          ::1:25
      program:
          7166/master
      proto:
          tcp6
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          0
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          36433
      local-address:
          0.0.0.0:68
      program:
          6145/dhclient
      proto:
          udp
      recv-q:
          0
      remote-address:
          0.0.0.0:*
      send-q:
          0
      user:
          0
    |_
      ----------
      inode:
          33876
      local-address:
          127.0.0.1:323
      program:
          5948/chronyd
      proto:
          udp
      recv-q:
          0
      remote-address:
          0.0.0.0:*
      send-q:
          0
      user:
          0
    |_
      ----------
      inode:
          0
      local-address:
          192.168.153.136:35580
      program:
          99487
      proto:
          udp
      recv-q:
          0
      remote-address:
          192.168.153.2:53
      send-q:
          0
      user:
          ESTABLISHED
    |_
      ----------
      inode:
          33877
      local-address:
          ::1:323
      program:
          5948/chronyd
      proto:
          udp6
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          0
      user:
          0
192.168.153.141:
    |_
      ----------
      inode:
          36388
      local-address:
          *:68
      program:
          dhclient
      proto:
          udp
      recv-q:
          0
      remote-address:
          *:*
      send-q:
          0
      user:
          0
    |_
      ----------
      inode:
          33601
      local-address:
          127.0.0.1:323
      program:
          chronyd
      proto:
          udp
      recv-q:
          0
      remote-address:
          *:*
      send-q:
          0
      user:
          0
    |_
      ----------
      inode:
          33602
      local-address:
          ::1:323
      program:
          chronyd
      proto:
          udp
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          0
      user:
          0
    |_
      ----------
      inode:
          38691
      local-address:
          *:22
      program:
          sshd
      proto:
          tcp
      recv-q:
          0
      remote-address:
          *:*
      send-q:
          128
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          40631
      local-address:
          127.0.0.1:25
      program:
          master
      proto:
          tcp
      recv-q:
          0
      remote-address:
          *:*
      send-q:
          100
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          0
      local-address:
          192.168.153.141:43866
      program:
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.136:4506
      send-q:
          0
      state:
          TIME-WAIT
      user:
          0
    |_
      ----------
      inode:
          42111
      local-address:
          192.168.153.141:35826
      program:
          salt-minion
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.136:4505
      send-q:
          0
      state:
          ESTABLISHED
      user:
          0
    |_
      ----------
      inode:
          41776
      local-address:
          192.168.153.141:22
      program:
          sshd
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.1:11476
      send-q:
          0
      state:
          ESTABLISHED
      user:
          0
    |_
      ----------
      inode:
          0
      local-address:
          192.168.153.141:43864
      program:
      proto:
          tcp
      recv-q:
          0
      remote-address:
          192.168.153.136:4506
      send-q:
          0
      state:
          TIME-WAIT
      user:
          0
    |_
      ----------
      inode:
          39031
      local-address:
          :::80
      program:
          httpd
      proto:
          tcp
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          128
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          38618
      local-address:
          :::21
      program:
          vsftpd
      proto:
          tcp
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          32
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          38700
      local-address:
          :::22
      program:
          sshd
      proto:
          tcp
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          128
      state:
          LISTEN
      user:
          0
    |_
      ----------
      inode:
          40632
      local-address:
          ::1:25
      program:
          master
      proto:
          tcp
      recv-q:
          0
      remote-address:
          :::*
      send-q:
          100
      state:
          LISTEN
      user:
          0
```

#### 2.1.16 network.ping

使用ping命令测试到某主机的连通性

```
[root@master ~]# salt '*' network.ping baidu.com
192.168.153.136:
    PING baidu.com (220.181.38.148) 56(84) bytes of data.
    64 bytes from 220.181.38.148 (220.181.38.148): icmp_seq=1 ttl=128 time=27.9 ms
    64 bytes from 220.181.38.148 (220.181.38.148): icmp_seq=2 ttl=128 time=31.8 ms
    64 bytes from 220.181.38.148 (220.181.38.148): icmp_seq=3 ttl=128 time=28.9 ms
    64 bytes from 220.181.38.148 (220.181.38.148): icmp_seq=4 ttl=128 time=28.7 ms
    
    --- baidu.com ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3005ms
    rtt min/avg/max/mdev = 27.986/29.376/31.888/1.505 ms
192.168.153.141:
    PING baidu.com (39.156.69.79) 56(84) bytes of data.
    64 bytes from 39.156.69.79 (39.156.69.79): icmp_seq=1 ttl=128 time=29.1 ms
    64 bytes from 39.156.69.79 (39.156.69.79): icmp_seq=2 ttl=128 time=33.2 ms
    64 bytes from 39.156.69.79 (39.156.69.79): icmp_seq=3 ttl=128 time=28.3 ms
    64 bytes from 39.156.69.79 (39.156.69.79): icmp_seq=4 ttl=128 time=28.7 ms
    
    --- baidu.com ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3007ms
    rtt min/avg/max/mdev = 28.324/29.860/33.217/1.973 ms
```

#### 2.1.17 network.reverse_ip

返回一个指定的IP地址的反向地址

```
[root@master ~]# salt '*' network.reverse_ip 10.0.34.209
192.168.153.141:
    209.34.0.10.in-addr.arpa
192.168.153.136:
    209.34.0.10.in-addr.arpa
```

### 2.2 SaltStack常用模块之service

#### 2.2.1 service.available

判断指定的服务是否存在

```
[root@master ~]# salt '*' service.available sshd
192.168.153.141:
    True
192.168.153.136:
    True
[root@master ~]# salt '*' service.available vsftpd
192.168.153.141:
    False    //已卸载,所以才显示false
192.168.153.136:
    True
```

#### 2.2.2 service.get_all

获取所有正在运行的服务

```
[root@master ~]# salt '*' service.get_all
192.168.153.141:
    - NetworkManager
    - NetworkManager-dispatcher
    - NetworkManager-wait-online
    - arp-ethers
    - auditd
    - autovt@
    - basic.target
    - blk-availability
    - bluetooth.target
    - brandbot
    - brandbot.path
    - console-getty
    - console-shell
    - container-getty@
    - cpupower
    - crond
    - 此处省略N行
```

#### 2.2.3 service.disabled

检查指定服务是否开机不自动启动

```
[root@master ~]# salt '*' service.disabled httpd
192.168.153.141:
    False      //这个是开机自启的,所以显示false
192.168.153.136:
    True   //本机并没有安装httpd服务,特别注意一下
```

#### 2.2.4 service.enabled

检查指定服务是否开机自动启动

```
[root@master ~]# salt '*' service.enabled httpd
192.168.153.141:
    True     //这个是开机自启的,所以显示true
192.168.153.136:
    False   //本机并没有安装httpd服务,特别注意一下
```

#### 2.2.5 service.disable

设置指定服务开机不自动启动

```
[root@master ~]# salt '*' service.disable httpd
192.168.153.136:
    False
192.168.153.141:
    True
[root@master ~]# salt '*' service.enabled httpd
192.168.153.141:
    False
192.168.153.136:
    False
```

#### 2.2.6 service.enable

设置指定服务开机自动启动

```
[root@master ~]# salt '*' service.enable httpd
192.168.153.136:   //因为未安装此服务
    ERROR: Running scope as unit run-26832.scope.
    Failed to execute operation: No such file or directory
192.168.153.141:
    True
ERROR: Minions returned with non-zero exit code
[root@master ~]# salt '*' service.enabled httpd
192.168.153.141:
    True
192.168.153.136:
    False
```

#### 2.2.7 service.reload

重新加载指定服务

```
[root@master ~]# salt '*' service.reload httpd
192.168.153.136:   //因为未安装此服务
    ERROR: Running scope as unit run-26957.scope.
    Failed to reload httpd.service: Unit not found.
192.168.153.141:
    True
ERROR: Minions returned with non-zero exit code
```

#### 2.2.8 service.stop

停止指定服务

```
[root@master ~]# salt '*' service.stop httpd
192.168.153.136:   //因为未安装此服务
    False
192.168.153.141:
    True
ERROR: Minions returned with non-zero exit code
```

#### 2.2.9 service.start

启动指定服务

```
[root@master ~]# salt '*' service.start httpd
192.168.153.136:   //因为未安装此服务
    ERROR: Running scope as unit run-27181.scope.
    Failed to start httpd.service: Unit not found.
192.168.153.141:
    True
ERROR: Minions returned with non-zero exit code
```

#### 2.2.10 service.restart

重启指定服务

```
[root@master ~]# salt '192.168.153.141' service.restart httpd
192.168.153.141:
    True
```

#### 2.2.11 service.status

查看指定服务的状态

```
[root@master ~]# salt '192.168.153.141' service.status httpd
192.168.153.141:
    True
```

### 2.3 SaltStack常用模块之pkg

#### 2.3.1 pkg.download

只下载软件包但不安装
此功能将会下载指定的软件包及其依赖的所有软件包，但是需要在minion端安装`yum-utils`，可以使用 cmd.run 进行远程安装

```
[root@master ~]# salt '*' pkg.download wget
192.168.153.141:
    ----------
    wget:
        /var/cache/yum/packages/wget-1.14-18.el7_6.1.x86_64.rpm
192.168.153.136:
    ----------
    wget:
        /var/cache/yum/packages/wget-1.14-18.el7_6.1.x86_64.rpm     //下载好的软件放在这里
```

#### 2.3.2 pkg.file_list

列出指定包或系统中已安装的所有包的文件

```
列出已安装的apache软件包提供的所有文件
[root@master ~]# salt '*' pkg.file_list httpd
192.168.153.141:
    ----------
    errors:
    files:
        - /etc/httpd
        - /etc/httpd/conf
        - /etc/httpd/conf.d
        - /etc/httpd/conf.d/README
        - /etc/httpd/conf.d/autoindex.conf
        - /etc/httpd/conf.d/userdir.conf
        - /etc/httpd/conf.d/welcome.conf
        - /etc/httpd/conf.modules.d
        -......省略n行......
        - /var/cache/httpd
        - /var/cache/httpd/proxy
        - /var/lib/dav
        - /var/log/httpd
        - /var/www
        - /var/www/cgi-bin
        - /var/www/html
192.168.153.136:     //没安装
    ----------
    errors:
    files:
        - package httpd is not installed
ERROR: Minions returned with non-zero exit code

当不提供参数时，将会列出当前系统中所有已安装软件的文件列表
[root@master ~]# salt '192.168.153.141' pkg.file_list
192.168.153.141
    ----------
    errors:
    files:
        - /lib/kbd/keymaps/legacy
        - /lib/kbd/keymaps/legacy/amiga
        - /lib/kbd/keymaps/legacy/amiga/amiga-de.map.gz
        - /lib/kbd/keymaps/legacy/amiga/amiga-us.map.gz
        - /lib/kbd/keymaps/legacy/atari
        - /lib/kbd/keymaps/legacy/atari/atari-de.map.gz
        - /lib/kbd/keymaps/legacy/atari/atari-se.map.gz
        - /lib/kbd/keymaps/legacy/atari/atari-uk-falcon.map.gz
        - /lib/kbd/keymaps/legacy/atari/atari-us.map.gz
        - /lib/kbd/keymaps/legacy/i386
        - /lib/kbd/keymaps/legacy/i386/azerty
        - /lib/kbd/keymaps/legacy/i386/azerty/azerty.map.gz
        - /lib/kbd/keymaps/legacy/i386/azerty/be-latin1.map.gz
        - /lib/kbd/keymaps/legacy/i386/azerty/fr-latin0.map.gz
        - /lib/kbd/keymaps/legacy/i386/azerty/fr-latin1.map.gz
        - /lib/kbd/keymaps/legacy/i386/azerty/fr-latin9.map.gz
```

#### 2.3.3 pkg.group_info

查看包组的信息

```
[root@master ~]# salt '192.168.153.141' pkg.group_info 'Development Tools'
192.168.153.141:
    ----------
    conditional:
    default:
        - byacc
        - cscope
        - ctags
        - diffstat
        - doxygen
        - elfutils
        - gcc-gfortran
        - git
        - indent
        - intltool
        - patchutils
        - rcs
        - subversion
        - swig
        - systemtap
    description:
        A basic development environment.
    group:
        Development Tools
    id:
        development
    mandatory:
        - autoconf
        - automake
        - binutils
        - bison
        - flex
        - gcc
        - gcc-c++
        - gettext
        - libtool
        - make
        - patch
        - pkgconfig
        - redhat-rpm-config
        - rpm-build
        - rpm-sign
    optional:
        - ElectricFence
        - ant
        - babel
        - bzr
        - ccache
        - chrpath
        - clips
        - clips-devel
        - clips-doc
        - clips-emacs
        - clips-xclips
        - clipsmm-devel
        - clipsmm-doc
        - cmake
        - cmucl
        - colordiff
        - compat-gcc-44
        - compat-gcc-44-c++
        - cvs
        - cvsps
        - darcs
        - dejagnu
        - email2trac
        - expect
        - ftnchek
        - gcc-gnat
        - gcc-objc
        - gcc-objc++
        - ghc
        - git
        - haskell-platform
        - imake
        - javapackages-tools
        - ksc
        - libstdc++-docs
        - lua
        - mercurial
        - mock
        - mod_dav_svn
        - nasm
        - nqc
        - nqc-doc
        - ocaml
        - perltidy
        - python-docs
        - qgit
        - rpmdevtools
        - rpmlint
        - sbcl
        - scorep
        - systemtap-sdt-devel
        - systemtap-server
        - trac
        - trac-git-plugin
        - trac-mercurial-plugin
        - trac-webadmin
        - translate-toolkit
    type:
        package group
```

#### 2.3.4 pkg.group_list

列出系统中所有的包组

```
[root@master ~]# salt '192.168.153.141' pkg.group_list
192.168.153.141:
    ----------
    available:
        - Additional Development
        - Anaconda Tools
        - Backup Client
        - Backup Server
        - Base
        - Buildsystem building group
        - CentOS Linux Client product core
        - CentOS Linux ComputeNode product core
        - CentOS Linux Server product core
        - CentOS Linux Workstation product core
        - Cinnamon
        - Common NetworkManager submodules
        - Compatibility Libraries
        - Conflicts (Client)
        - Conflicts (ComputeNode)
        - Conflicts (Server)
        - Conflicts (Workstation)
        - Console Internet Tools
        - Core
        - DNS Name Server
        - Debugging Tools
        - Desktop Debugging and Performance Tools
        - Dial-up Networking Support
        - Directory Client
        - Directory Server
        - E-mail Server
        - Educational Software
        - Electronic Lab
        - Emacs
        - FTP Server
        - Fedora Packager
        - File and Storage Server
        - Fonts
        - GNOME
        - GNOME Applications
        - General Purpose Desktop
        - Graphical Administration Tools
        - Graphics Creation Tools
        - Guest Agents
        - Guest Desktop Agents
        - Hardware Monitoring Utilities
        - Haskell
        - High Availability
        - Hyper-v platform specific packages
        - Identity Management Server
        - Infiniband Support
        - Input Methods
        - Internet Applications
        - Internet Browser
        - Java Platform
        - KDE
        - KDE Applications
        - KDE Multimedia Support
        - KVM platform specific packages
        - Large Systems Performance
        - Legacy UNIX Compatibility
        - Legacy X Window System Compatibility
        - Load Balancer
        - MATE
        - Mainframe Access
        - MariaDB Database Client
        - MariaDB Database Server
        - Milkymist
        - Multimedia
        - Network File System Client
        - Network Infrastructure Server
        - Networking Tools
        - Office Suite and Productivity
        - PHP Support
        - Performance Tools
        - Perl Support
        - Perl for Web
        - Platform Development
        - PostgreSQL Database Client
        - PostgreSQL Database Server
        - Print Server
        - Printing Client
        - Python
        - Remote Desktop Clients
        - Remote Management for Linux
        - Resilient Storage
        - Ruby Support
        - Scientific Support
        - Security Tools
        - Smart Card Support
        - System Administration Tools
        - System Management
        - Technical Writing
        - TurboGears application framework
        - VMware platform specific packages
        - Virtualization Client
        - Virtualization Hypervisor
        - Virtualization Platform
        - Virtualization Tools
        - Web Server
        - Web Servlet Engine
        - X Window System
        - Xfce
    available environments:
        - Minimal Install
        - Compute Node
        - Infrastructure Server
        - File and Print Server
        - Cinnamon Desktop
        - MATE Desktop
        - Basic Web Server
        - Virtualization Host
        - Server with GUI
        - GNOME Desktop
        - KDE Plasma Workspaces
        - Development and Creative Workstation
    available languages:
        ----------
    installed:
        - Development Tools
    installed environments:
```

#### 2.3.5 pkg.install

安装软件

```
[root@master ~]# salt '192.168.153.141' pkg.install wget
192.168.153.141:
    ----------
    wget:
        ----------
        new:
            1.14-18.el7_6.1
        old:
```

#### 2.3.6 pkg.list_downloaded

列出已下载到本地的软件包

```
[root@master ~]# salt '192.168.153.141' pkg.list_downloaded
192.168.153.141:
    ----------
    wget:
        ----------
        1.14-18.el7_6.1:
            ----------
            creation_date_time:
                2019-07-23T20:50:28
            creation_date_time_t:
                1563886228
            path:
                /var/cache/yum/packages/wget-1.14-18.el7_6.1.x86_64.rpm
            size:
                560272
```

#### 2.3.7 pkg.list_pkgs

以字典的方式列出当前已安装的软件包

```
[root@master ~]# salt '192.168.153.141' pkg.list_pkgs
192.168.153.141:
    ----------
    GeoIP:
        1.5.0-13.el7
    NetworkManager:
        1:1.12.0-6.el7
    NetworkManager-libnm:
        1:1.12.0-6.el7
    NetworkManager-team:
        1:1.12.0-6.el7
    NetworkManager-tui:
        1:1.12.0-6.el7
    PyYAML:
        3.11-1.el7
    abrt:
        2.1.11-52.el7.centos
    ...此处省略N行
```

#### 2.3.8 pkg.owner

列出指定文件是由哪个包提供的

```
[root@master ~]# salt '192.168.153.141' pkg.owner /usr/sbin/apachectl 
192.168.153.141:
    httpd
[root@master ~]# salt '192.168.153.141' pkg.owner /usr/sbin/apachectl /etc/httpd/conf/httpd.conf
192.168.153.141:
    ----------
    /etc/httpd/conf/httpd.conf:
        httpd
    /usr/sbin/apachectl:
        httpd
```

#### 2.3.9 pkg.remove

卸载指定软件

```
[root@master ~]# salt '192.168.153.141' cmd.run 'rpm -qa|grep wget'
192.168.153.141:
    wget-1.14-18.el7_6.1.x86_64
[root@master ~]# salt '192.168.153.141' pkg.remove wget
192.168.153.141:
    ----------
    wget:
        ----------
        new:
        old:
            1.14-18.el7_6.1
若要卸载多个文件，中间需要用逗号隔开
```

#### 2.3.10 pkg.upgrade

升级系统中所有的软件包或升级指定的软件包

```
[root@master ~]# salt '192.168.153.141' pkg.upgrade name=openssl
192.168.153.141:
    ----------
    openssl:
        ----------
        new:
            1:1.0.2k-16.el7_6.1
        old:
            1:1.0.2k-16.el7
    openssl-libs:
        ----------
        new:
            1:1.0.2k-16.el7_6.1
        old:
            1:1.0.2k-16.el7
若想升级系统中所有的软件包则把 name 参数去掉即可
```

### 2.4 SaltStack常用模块之state

#### 2.4.1 state.show_highstate

显示当前系统中有哪些高级状态

```
[root@master ~]# salt '192.168.153.141' state.show_highstate
192.168.153.141:
    ----------
    apache-install:
        ----------
        __env__:
            base
        __sls__:
            web.apache.apache
        pkg:
            |_
              ----------
              name:
                  httpd
            - installed
            |_
              ----------
              order:
                  10000
    apache-service:
        ----------
        __env__:
            base
        __sls__:
            web.apache.apache
        service:
            |_
              ----------
              name:
                  httpd
            |_
              ----------
              enable:
                  True
            - running
            |_
              ----------
              order:
                  10001
    vsftpd_install:
        ----------
        __env__:
            base
        __sls__:
            fspub.vsftpd
        pkg:
            |_
              ----------
              names:
                  - vsftpd
                  - httpd-tools
            - installed
            |_
              ----------
              order:
                  10002
    vsftpd_systemctl:
        ----------
        __env__:
            base
        __sls__:
            fspub.vsftpd
        service:
            |_
              ----------
              name:
                  vsftpd
            |_
              ----------
              enable:
                  True
            - running
            |_
              ----------
              order:
                  10003
```

#### 2.4.2 state.highstate

执行高级状态

```
[root@master ~]# salt '192.168.153.141' state.highstate web.apache.apache
192.168.153.141:
----------
          ID: apache-install
    Function: pkg.installed
        Name: httpd
      Result: True
     Comment: All specified packages are already installed
     Started: 21:15:25.562208
    Duration: 801.609 ms
     Changes:   
----------
          ID: apache-service
    Function: service.running
        Name: httpd
      Result: True
     Comment: The service httpd is already running
     Started: 21:15:26.364491
    Duration: 47.159 ms
     Changes:   
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: vsftpd
      Result: None
     Comment: The following packages would be installed/updated: vsftpd
     Started: 21:15:26.411943
    Duration: 29.414 ms
     Changes:   
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: httpd-tools
      Result: True
     Comment: All specified packages are already installed
     Started: 21:15:26.441517
    Duration: 16.284 ms
     Changes:   
----------
          ID: vsftpd_systemctl
    Function: service.running
        Name: vsftpd
      Result: None
     Comment: Service vsftpd not present; if created in this state run, it would have been started
     Started: 21:15:26.457960
    Duration: 13.709 ms
     Changes:   

Summary for 192.168.153.141
------------
Succeeded: 5 (unchanged=2)
Failed:    0
------------
Total states run:     5
Total run time: 908.175 ms
```

#### 2.4.3 state.show_state_usage

显示当前系统中的高级状态执行情况

```
[root@master ~]# salt '192.168.153.141' state.show_state_usage
192.168.153.141:
    ----------
    base:
        ----------
        count_all:
            3
        count_unused:
            1
        count_used:
            2
        unused:
            - top
        used:
            - fspub.vsftpd
            - web.apache.apache
    dev:
        ----------
        count_all:
            0
        count_unused:
            0
        count_used:
            0
        unused:
        used:
    prod:
        ----------
        count_all:
            0
        count_unused:
            0
        count_used:
            0
        unused:
        used:
    test:
        ----------
        count_all:
            0
        count_unused:
            0
        count_used:
            0
        unused:
        used:
```

#### 2.4.4 state.show_top

返回minion将用于highstate的顶级数据

```
[root@master ~]# salt '*' state.show_top
192.168.153.136:
    ----------
    base:
        - fspub.vsftpd
192.168.153.141:
    ----------
    base:
        - web.apache.apache
        - fspub.vsftpd
```

#### 2.4.5 state.top

执行指定的top file，而不是默认的

```
[root@master ~]# cd /srv/salt/base/
[root@master base]# ls
fspub  top.sls  web
[root@master base]# vim runtime.sls
[root@master base]# cat runtime.sls 
base:
  '192.168.153.141':
    - web.apache.apache
[root@master base]# salt '192.168.153.141' state.top runtime.sls
192.168.153.141:
----------
          ID: apache-install
    Function: pkg.installed
        Name: httpd
      Result: True
     Comment: All specified packages are already installed
     Started: 21:19:42.868584
    Duration: 776.231 ms
     Changes:   
----------
          ID: apache-service
    Function: service.running
        Name: httpd
      Result: True
     Comment: The service httpd is already running
     Started: 21:19:43.645611
    Duration: 50.381 ms
     Changes:   

Summary for 192.168.153.141
------------
Succeeded: 2
Failed:    0
------------
Total states run:     2
Total run time: 826.612 ms
```

#### 2.4.6 state.show_sls

显示 master 上特定sls或sls文件列表中的状态数据

```
[root@master base]# salt '192.168.153.141' state.show_sls web.apache.apache
192.168.153.141:
    ----------
    apache-install:
        ----------
        __env__:
            base
        __sls__:
            web.apache.apache
        pkg:
            |_
              ----------
              name:
                  httpd
            - installed
            |_
              ----------
              order:
                  10000
    apache-service:
        ----------
        __env__:
            base
        __sls__:
            web.apache.apache
        service:
            |_
              ----------
              name:
                  httpd
            |_
              ----------
              enable:
                  True
            - running
            |_
              ----------
              order:
                  10001
```

### 2.5 SaltStack常用模块之salt-cp

`salt-cp`能够很方便的把 master 上的文件批量传到 minion上

```
拷贝单个文件到目标主机的/usr/src目录下
[root@master base]# salt '192.168.153.141' cmd.run 'ls /usr/src/'
192.168.153.141:
    debug
    kernels
[root@master base]# salt-cp '192.168.153.141' /etc/passwd /usr/src/
192.168.153.141:
    ----------
    /usr/src/passwd:
        True
[root@master base]# salt '192.168.153.141' cmd.run 'ls /usr/src/'
192.168.153.141:
    debug
    kernels
    passwd
 
拷贝多个文件到目标主机的/usr/src目录下   
[root@master base]# salt-cp '192.168.153.141' /etc/shadow /etc/group /usr/src
192.168.153.141:
    ----------
    /usr/src/group:
        True
    /usr/src/shadow:
        True
[root@master base]# salt '192.168.153.141' cmd.run 'ls /usr/src'
192.168.153.141:
    debug
    group
    kernels
    passwd
    shadow
```

### 2.6 SaltStack常用模块之file

#### 2.6.1 file.access

检查指定路径是否存在

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls /usr/src'
192.168.153.141:
    debug
    group
    kernels
    passwd
    shadow
[root@master base]# salt '192.168.153.141' file.access /usr/src/passwd f
192.168.153.141:
    True
[root@master base]# salt '192.168.153.141' file.access /usr/src/abc f
192.168.153.141:
    False
```

检查指定文件的权限信息

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /usr/src/'
192.168.153.141:
    total 12
    drwxr-xr-x. 2 root root   6 Apr 11  2018 debug
    -rw-r--r--  1 root root 516 Jul 23 21:21 group
    drwxr-xr-x. 3 root root  35 Jun 13 21:32 kernels
    -rw-r--r--  1 root root 986 Jul 23 21:21 passwd
    -rw-r--r--  1 root root 624 Jul 23 21:21 shadow
    
[root@master ~]# salt '192.168.153.141' file.access /usr/src/passwd r     //是否有读权限
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' file.access /usr/src/passwd w     //是否有写权限
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' file.access /usr/src/passwd x     //是否有执行权限
192.168.153.141:
    False
```

#### 2.6.2 file.append

往一个文件里追加内容，若此文件不存在则会报异常

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root/a'
192.168.153.141:
    ls: cannot access /root/a: No such file or directory
ERROR: Minions returned with non-zero exit code
[root@master base]# salt '192.168.153.141' cmd.run 'touch /root/a'
192.168.153.141:
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root/a'
192.168.153.141:
    -rw-r--r-- 1 root root 0 Jul 23 21:25 /root/a
[root@master base]# salt '192.168.153.141' file.append /root/a "hello world" "haha" "xixi"
192.168.153.141:
    Wrote 3 lines to "/root/a"
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root/a'
192.168.153.141:
    -rw-r--r-- 1 root root 22 Jul 23 21:25 /root/a
[root@master base]# salt '192.168.153.141' cmd.run 'cat /root/a'
192.168.153.141:
    hello world
    haha
    xixi
```

#### 2.6.3 file.basename

获取指定路径的基名

```
[root@master base]# salt '192.168.153.141' file.basename '/root/zabbix/abc'
192.168.153.141:
    abc
```

#### 2.6.4 file.dirname

获取指定路径的目录名

```
[root@master base]# salt '192.168.153.141' file.dirname '/root/zabbix/abc'
192.168.153.141:
    /root/zabbix
```

#### 2.6.5 file.check_hash

检查指定的文件与hash字符串是否匹配，匹配则返回 True 否则返回 False

```
[root@master base]# salt '192.168.153.141' cmd.run 'md5sum /etc/passwd'
192.168.153.141:
    10e702fb46cac2747dc8e048d2cad238  /etc/passwd
[root@master base]# salt '192.168.153.141' file.check_hash /etc/passwd 10e702fb46cac2747dc8e048d2cad238
192.168.153.141:
    True
```

#### 2.6.6 file.chattr

修改指定文件的属性

| 属性 | 对文件的意义                                                 | 对目录的意义                                            |
| :--: | :----------------------------------------------------------- | :------------------------------------------------------ |
|  a   | 只允许在这个文件之后追加数据， 不允许任何进程覆盖或截断这个文件 | 只允许在这个目录下建立和修改文件， 而不允许删除任何文件 |
|  i   | 不允许对这个文件进行任何的修改， 不能删除、更改、移动        | 任何的进程只能修改目录之下的文件， 不允许建立和删除文件 |

给指定文件添加属性

```
查看当前属性
[root@master ~]# salt '192.168.153.141' cmd.run 'lsattr /root'
192.168.153.141:
    ---------------- /root/anaconda-ks.cfg
    ---------------- /root/a
    
添加属性
[root@master base]# salt '192.168.153.141' file.chattr /root/a operator=add attributes=ai
192.168.153.141:
    True
[root@master base]# salt '192.168.153.141' cmd.run 'lsattr /root'
192.168.153.141:
    ---------------- /root/anaconda-ks.cfg
    ----ia---------- /root/a
```

给指定文件去除属性

```
[root@master base]# salt '192.168.153.141' file.chattr /root/a operator=remove attributes=i
192.168.153.141:
    True
[root@master base]# salt '192.168.153.141' cmd.run 'lsattr /root'
192.168.153.141:
    ---------------- /root/anaconda-ks.cfg
    -----a---------- /root/a
```

#### 2.6.7 file.chown

设置指定文件的属主、属组信息

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /home/itw/'
192.168.153.141:
    total 0
    -rw-rw-r-- 1 itw itw 0 Jul 23 21:31 a
[root@master base]# salt '192.168.153.141' file.chown /home/itw/a root root
192.168.153.141:
    None
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /home/itw/'
192.168.153.141:
    total 0
    -rw-rw-r-- 1 root root 0 Jul 23 21:31 a
```

#### 2.6.8 file.copy

在远程主机上复制文件或目录

拷贝文件

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 8
    -rw-r--r--  1 root root   22 Jul 23 21:25 a
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
[root@master base]# salt '192.168.153.141' file.copy /root/a /root/cc
192.168.153.141:
    True
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    -rw-r--r--  1 root root   22 Jul 23 21:25 a
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
```

覆盖并拷贝目录，将会覆盖同名文件或目录

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    -rw-r--r--  1 root root   22 Jul 23 21:25 a
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
[root@master base]# salt '192.168.153.141' file.copy /tmp/ /root/abc recurse=True
192.168.153.141:
    True
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 16
    -rw-r--r--   1 root root   22 Jul 23 21:25 a
    drwxrwxrwt  17 root root 4096 Jul 23 21:34 abc
    -rw-------.  1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--   1 root root   22 Jul 23 21:33 cc
```

删除目标目录中同名的文件或目录并拷贝新内容至其中

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root/abc'
192.168.153.141:
    total 0
    drwxr-xr-x 3 root root 17 Jul 23 21:34 systemd-private-5e805277f3ed440b8b6db03270de8f4c-chronyd.service-Suzhr4
    drwxr-xr-x 3 root root 17 Jul 23 21:34 systemd-private-5e805277f3ed440b8b6db03270de8f4c-httpd.service-dKWiiz
    drwxr-xr-x 2 root root  6 Jul 23 21:34 vmware-root_5879-1958554277
    drwxr-xr-x 2 root root  6 Jul 23 21:34 vmware-root_5887-1992240299
    drwxr-xr-x 2 root root  6 Jul 23 21:34 vmware-root_5888-969455348
    drwxr-xr-x 2 root root  6 Jul 23 21:34 vmware-root_5897-1950165796
    drwxr-xr-x 2 root root  6 Jul 23 21:34 vmware-root_5900-994685311
    drwxr-xr-x 2 root root  6 Jul 23 21:34 vmware-root_5904-1002483940
    drwxr-xr-x 2 root root  6 Jul 23 21:34 vmware-root_5905-1949772602
    drwxr-xr-x 2 root root  6 Jul 23 21:34 vmware-root_5916-960608111
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /opt/'
192.168.153.141:
    total 0
    drwxr-xr-x 2 root root 187 Jul 22 14:25 yum.bak
    
    
拷贝目录
[root@master base]# salt '192.168.153.141' file.copy /opt/ /root/abc/ recurse=True remove_existing=True
192.168.153.141:
    True
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root/abc'
192.168.153.141:
    total 0
    drwxr-xr-x 2 root root 187 Jul 22 14:25 yum.bak
```

#### 2.6.9 file.ditectory_exists

判断指定目录是否存在，存在则返回 True ，否则返回 False

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /opt'
192.168.153.141:
    total 0
    drwxr-xr-x 2 root root 187 Jul 22 14:25 yum.bak
[root@master base]# salt '192.168.153.141' file.directory_exists /opt/yum.bak
192.168.153.141:
    True
```

#### 2.6.10 file.diskusage

递归计算指定路径的磁盘使用情况并以字节为单位返回

```
[root@master base]# salt '192.168.153.141' cmd.run 'du -sb /opt'
192.168.153.141:
    11806	/opt
[root@master base]# salt '192.168.153.141' file.diskusage /opt
192.168.153.141:
    11598
```

#### 2.6.11 file.file_exists

判断指定文件是否存在

```
[root@master base]# salt '192.168.153.141' cmd.run 'ls -l /root/'
192.168.153.141:
    total 12
    -rw-r--r--  1 root root   22 Jul 23 21:25 a
    drwxr-xr-x  3 root root   21 Jul 22 14:25 abc
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
[root@master base]# salt '192.168.153.141' file.file_exists /root/a
192.168.153.141:
    True
[root@master base]# salt '192.168.153.141' file.file_exists /root/abc
192.168.153.141:
    False   //返回False是因为abc是目录而非文件
```

#### 2.6.12 file.find

类似 find 命令并返回符合指定条件的路径列表

**The options include match criteria:**

```
name    = path-glob                 # case sensitive
iname   = path-glob                 # case insensitive
regex   = path-regex                # case sensitive
iregex  = path-regex                # case insensitive
type    = file-types                # match any listed type
user    = users                     # match any listed user
group   = groups                    # match any listed group
size    = [+-]number[size-unit]     # default unit = byte
mtime   = interval                  # modified since date
grep    = regex                     # search file contents
```

**and/or actions:**

```
delete [= file-types]               # default type = 'f'
exec    = command [arg ...]         # where {} is replaced by pathname
print  [= print-opts]
```

**and/or depth criteria:**

```
maxdepth = maximum depth to transverse in path
mindepth = minimum depth to transverse before checking files or directories
```

**The default action is print=path**

**path-glob:**

```
*                = match zero or more chars
?                = match any char
[abc]            = match a, b, or c
[!abc] or [^abc] = match anything except a, b, and c
[x-y]            = match chars x through y
[!x-y] or [^x-y] = match anything except chars x through y
{a,b,c}          = match a or b or c
```

`path-regex`: a Python Regex (regular expression) pattern to match pathnames

`file-types`: a string of one or more of the following:

```
a: all file types
b: block device
c: character device
d: directory
p: FIFO (named pipe)
f: plain file
l: symlink
s: socket
```

`users`: a space and/or comma separated list of user names and/or uids

`groups`: a space and/or comma separated list of group names and/or gids

`size-unit`:

```
b: bytes
k: kilobytes
m: megabytes
g: gigabytes
t: terabytes
```

**interval:**

```
[<num>w] [<num>d] [<num>h] [<num>m] [<num>s]

where:
    w: week
    d: day
    h: hour
    m: minute
    s: second
```

**print-opts: a comma and/or space separated list of one or more of the following:**

```
group: group name
md5:   MD5 digest of file contents
mode:  file permissions (as integer)
mtime: last modification time (as time_t)
name:  file basename
path:  file absolute path
size:  file size in bytes
type:  file type
user:  user name
```

**示例：**

```
salt '*' file.find / type=f name=\*.bak size=+10m
salt '*' file.find /var mtime=+30d size=+10m print=path,size,mtime
salt '*' file.find /var/log name=\*.[0-9] mtime=+30d size=+10m delete
```

#### 2.6.13 file.get_gid

获取指定文件的gid

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/a'
192.168.153.141:
    -rw-r--r-- 1 root root 22 Jul 23 21:25 /root/a
[root@master ~]# salt '192.168.153.141' file.get_gid /root/a
192.168.153.141:
    0
```

#### 2.6.14 file.get_group

获取指定文件的组名

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/a'
192.168.153.141:
    -rw-r--r-- 1 root root 22 Jul 23 21:25 /root/a
[root@master ~]# salt '192.168.153.141' file.get_group /root/a
192.168.153.141:
    root
```

#### 2.6.15 file.get_hash

获取指定文件的hash值，该值通过 sha256 算法得来

```
[root@master ~]# salt '192.168.153.141' cmd.run 'sha256sum /root/a'
192.168.153.141:
    11129dfb248c6bc5784c1d439877552aa34f3408f14dbb38572e802e4831b77a  /root/a
[root@master ~]# salt '192.168.153.141' file.get_hash /root/a
192.168.153.141:
    11129dfb248c6bc5784c1d439877552aa34f3408f14dbb38572e802e4831b77a
```

#### 2.6.16 file.get_mode

获取指定文件的权限，以数字方式显示

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/a'
192.168.153.141:
    -rw-r--r-- 1 root root 22 Jul 23 21:25 /root/a
[root@master ~]# salt '192.168.153.141' file.get_mode /root/a
192.168.153.141:
    0644
```

#### 2.6.17 file.get_selinux_context

获取指定文件的 SELINUX 上下文信息

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -Z /root/a'
192.168.153.141:
    -rw-r--r-- root root ?                                /root/a
[root@master ~]# salt '192.168.153.141' file.get_selinux_context /root/a
192.168.153.141:
    No selinux context information is available for /root/a
```

#### 2.6.18 file.get_sum

按照指定的算法计算指定文件的特征码并显示，默认使用的sha256算法。
该函数可使用的算法参数有：

 - md5
 - sha1
 - sha224
 - sha256 (default)
 - sha384
 - sha512

```
[root@master ~]# salt '192.168.153.141' cmd.run 'sha256sum /root/a'
192.168.153.141:
    11129dfb248c6bc5784c1d439877552aa34f3408f14dbb38572e802e4831b77a  /root/a
[root@master ~]# salt '192.168.153.141' file.get_sum /root/a
192.168.153.141:
    11129dfb248c6bc5784c1d439877552aa34f3408f14dbb38572e802e4831b77a
[root@master ~]# salt '192.168.153.141' cmd.run 'md5sum /root/a'
192.168.153.141:
    671ded4ec86c82a8779c8df17823f810  /root/a
[root@master ~]# salt '192.168.153.141' file.get_sum /root/a md5
192.168.153.141:
    671ded4ec86c82a8779c8df17823f810
```

#### 2.6.19 file.get_uid与file.get_user

获取指定文件的 uid 或 用户名

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/a'
192.168.153.141:
    -rw-r--r-- 1 root root 22 Jul 23 21:25 /root/a
[root@master ~]# salt '192.168.153.141' file.get_uid /root/a
192.168.153.141:
    0
[root@master ~]# salt '192.168.153.141' file.get_user /root/a
192.168.153.141:
    root
```

#### 2.6.20 file.gid_to_group

将指定的 gid 转换为组名并显示

```
[root@master ~]# salt '192.168.153.141' file.gid_to_group 1000
192.168.153.141:
    itw
[root@master ~]# salt '192.168.153.141' file.gid_to_group 0
192.168.153.141:
    root
```

#### 2.6.21 file.group_to_gid

将指定的组名转换为 gid 并显示

```
[root@master ~]# salt '192.168.153.141' file.group_to_gid root
192.168.153.141:
    0
[root@master ~]# salt '192.168.153.141' file.group_to_gid itw
192.168.153.141:
    1000
```

#### 2.6.22 file.grep

在指定文件中检索指定内容
该函数支持通配符，若在指定的路径中用通配符则必须用双引号引起来

```
salt '*' file.grep /etc/passwd nobody
salt '*' file.grep /etc/sysconfig/network-scripts/ifcfg-eth0 ipaddr -- -i
salt '*' file.grep /etc/sysconfig/network-scripts/ifcfg-eth0 ipaddr -- -i -B2
salt '*' file.grep "/etc/sysconfig/network-scripts/*" ipaddr -- -i -l
```

#### 2.6.23 file.is_blkdev

判断指定的文件是否是块设备文件

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /dev/sr0'
192.168.153.141:
    brw-rw---- 1 root cdrom 11, 0 Jul 23 20:06 /dev/sr0
[root@master ~]# salt '192.168.153.141' file.is_blkdev /dev/sr0
192.168.153.141:
    True
```

#### 2.6.24 file.lsattr

检查并显示出指定文件的属性信息

```
[root@master ~]# salt '192.168.153.141' cmd.run 'lsattr /root/a'
192.168.153.141:
    -----a---------- /root/a
[root@master ~]# salt '192.168.153.141' cmd.run 'chattr +i /root/a'
192.168.153.141:
[root@master ~]# salt '192.168.153.141' cmd.run 'lsattr /root/a'
192.168.153.141:
    ----ia---------- /root/a
[root@master ~]# salt '192.168.153.141' file.lsattr /root/a
192.168.153.141:
    ----------
    /root/a:
        - i
        - a
加了这些属性,如果不解锁,无法操作这些文件
```

#### 2.6.25 file.mkdir

创建目录并设置属主、属组及权限

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    -rw-r--r--  1 root root   22 Jul 23 21:25 a
    drwxr-xr-x  3 root root   21 Jul 22 14:25 abc
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
[root@master ~]# salt '192.168.153.141' file.mkdir /root/abc
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    -rw-r--r--  1 root root   22 Jul 23 21:25 a
    drwxr-xr-x  3 root root   21 Jul 22 14:25 abc
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
[root@master ~]# salt '192.168.153.141' file.mkdir /root/haha itw itw 400
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/'
192.168.153.141:
    total 12
    -rw-r--r--  1 root root   22 Jul 23 21:25 a
    drwxr-xr-x  3 root root   21 Jul 22 14:25 abc
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
```

#### 2.6.26 file.move

移动或重命名

```
重命名
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    -rw-r--r--  1 root root   22 Jul 23 21:25 a
    drwxr-xr-x  3 root root   39 Jul 23 21:50 abc
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
[root@master ~]# salt '192.168.153.141' file.move /root/a /root/b
192.168.153.141:
    ----------
    comment:
        '/root/a' moved to '/root/b'
    result:
        True
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    drwxr-xr-x  3 root root   39 Jul 23 21:50 abc
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:25 b
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
    
    
移动
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    drwxr-xr-x  3 root root   39 Jul 23 21:50 abc
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   22 Jul 23 21:25 b
    -rw-r--r--  1 root root   22 Jul 23 21:33 cc
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /opt'
192.168.153.141:
    total 4
    -rw-r--r-- 1 root root  22 Jul 23 21:25 a
    drwxr-xr-x 2 root root 187 Jul 22 14:25 yum.bak
[root@master ~]# salt '192.168.153.141' file.move /root/cc /opt/
192.168.153.141:
    ----------
    comment:
        '/root/cc' moved to '/opt/'
    result:
        True
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /opt'
192.168.153.141:
    total 8
    -rw-r--r-- 1 root root  22 Jul 23 21:25 a
    -rw-r--r-- 1 root root  22 Jul 23 21:33 cc
    drwxr-xr-x 2 root root 187 Jul 22 14:25 yum.bak
```

#### 2.6.27 file.prepend

把文本插入指定文件的开头

```
[root@master ~]# salt '192.168.153.141' cmd.run 'cat /root/b'
192.168.153.141:
    hello world
    haha
    xixi
[root@master ~]# salt '192.168.153.141' file.prepend /root/b "hehe" "xixi" "haha"
192.168.153.141:
    Prepended 3 lines to "/root/b"
[root@master ~]# salt '192.168.153.141' cmd.run 'cat /root/b'
192.168.153.141:
    hehe
    xixi
    haha
    hello world
    haha
    xixi
```

#### 2.6.28 file.sed

修改文本文件的内容

```
[root@master ~]# salt '192.168.153.141' cmd.run 'cat /root/b'
192.168.153.141:
    hehe
    xixi
    haha
    hellow hellow hellow world
    hellow
    hellow
    haha
    xixi
[root@master ~]# salt '192.168.153.141' file.sed /root/b 'hello' 'itw'
192.168.153.141:
    ----------
    pid:
        10202
    retcode:
        0
    stderr:
    stdout:
[root@master ~]# salt '192.168.153.141' cmd.run 'cat /root/b'
192.168.153.141:
    hehe
    xixi
    haha
    itww itww itww world
    itww
    itww
    haha
    xixi 
[root@master ~]# salt '192.168.153.141' file.sed /root/b 'itw' 'design' flags=2
192.168.153.141:
    ----------
    pid:
        10214
    retcode:
        0
    stderr:
    stdout:
[root@master ~]# salt '192.168.153.141' cmd.run 'cat /root/b'
192.168.153.141:
    hehe
    xixi
    haha
    itww designw itww world
    itww
    itww
    haha
    xixi
```

#### 2.6.29 file.read

读取文件内容

```
[root@master ~]# salt '192.168.153.141' cmd.run 'cat /root/cca'
192.168.153.141:
    hellow world
    hellow itw
    itw.design
[root@master ~]# salt '192.168.153.141' file.read /root/cca
192.168.153.141:
    hellow world
    hellow itw
    itw.design
```

#### 2.6.30 file.readdir

列出指定目录下的所有文件或目录，包括隐藏文件

```
[root@master ~]# salt '192.168.153.141' file.readdir /root
192.168.153.141:
    - .
    - ..
    - .bash_logout
    - .bash_profile
    - .bashrc
    - .cshrc
    - .tcshrc
    - anaconda-ks.cfg
    - .bash_history
    - .pki
    - abc
    - haha
    - b.bak
    - b
    - cca
    - .viminfo
```

#### 2.6.31 file.remove

删除指定的文件或目录，若给出的是目录，将递归删除

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/'
192.168.153.141:
    total 16
    drwxr-xr-x  3 root root   39 Jul 23 21:50 abc
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   59 Jul 23 22:23 b
    -rw-r--r--  1 root root   56 Jul 23 22:22 b.bak
    -rw-r--r--  1 root root   35 Jul 23 22:25 cca
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
[root@master ~]# salt '192.168.153.141' file.remove /root/b
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' file.remove /root/abc
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/'
192.168.153.141:
    total 12
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   56 Jul 23 22:22 b.bak
    -rw-r--r--  1 root root   35 Jul 23 22:25 cca
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
```

#### 2.6.32 file.rename

重命名文件或目录

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/'
192.168.153.141:
    total 12
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   56 Jul 23 22:22 b.bak
    -rw-r--r--  1 root root   35 Jul 23 22:25 cca
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
[root@master ~]# salt '192.168.153.141' file.rename /root/b.bak /root/b
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/'
192.168.153.141:
    total 12
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   56 Jul 23 22:22 b
    -rw-r--r--  1 root root   35 Jul 23 22:25 cca
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
```

#### 2.6.33 file.set_mode

给指定文件设置权限

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -rw-r--r--  1 root root   56 Jul 23 22:22 b
    -rw-r--r--  1 root root   35 Jul 23 22:25 cca
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
[root@master ~]# salt '192.168.153.141' file.set_mode /root/b 0400
192.168.153.141:
    0400
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root'
192.168.153.141:
    total 12
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -r--------  1 root root   56 Jul 23 22:22 b
    -rw-r--r--  1 root root   35 Jul 23 22:25 cca
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
```

#### 2.6.34 file.symlink

给指定的文件创建软链接

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root/'
192.168.153.141:
    total 12
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -r--------  1 root root   56 Jul 23 22:22 b
    -rw-r--r--  1 root root   35 Jul 23 22:25 cca
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
[root@master ~]# salt '192.168.153.141' file.symlink /root/b /opt/a
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /root;ls -l /opt/'
192.168.153.141:
    total 12
    -rw-------. 1 root root 1313 Jun 13 21:37 anaconda-ks.cfg
    -r--------  1 root root   56 Jul 23 22:22 b
    -rw-r--r--  1 root root   35 Jul 23 22:25 cca
    dr--------  2 itw  itw     6 Jul 23 21:47 haha
    total 4
    lrwxrwxrwx 1 root root   7 Jul 23 22:30 a -> /root/b
    -rw-r--r-- 1 root root  22 Jul 23 21:33 cc
    drwxr-xr-x 2 root root 187 Jul 22 14:25 yum.bak
```

#### 2.6.35 file.touch

创建空文件或更新时间戳

```
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /opt'
192.168.153.141:
    total 4
    lrwxrwxrwx 1 root root   7 Jul 23 22:30 a -> /root/b
    -rw-r--r-- 1 root root  22 Jul 23 21:33 cc
    drwxr-xr-x 2 root root 187 Jul 22 14:25 yum.bak
[root@master ~]# salt '192.168.153.141' file.touch /opt/aa
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' file.touch /opt/bb
192.168.153.141:
    True
[root@master ~]# salt '192.168.153.141' cmd.run 'ls -l /opt'
192.168.153.141:
    total 4
    lrwxrwxrwx 1 root root   7 Jul 23 22:30 a -> /root/b
    -rw-r--r-- 1 root root   0 Jul 23 22:31 aa
    -rw-r--r-- 1 root root   0 Jul 23 22:31 bb
    -rw-r--r-- 1 root root  22 Jul 23 21:33 cc
    drwxr-xr-x 2 root root 187 Jul 22 14:25 yum.bak
```

#### 2.6.36 file.uid_to_user

将指定的 uid 转换成用户名显示出来

```
[root@master ~]# salt '192.168.153.141' file.uid_to_user 0
192.168.153.141:
    root
[root@master ~]# salt '192.168.153.141' file.uid_to_user 1000
192.168.153.141:
    itw
```

#### 2.6.37 file.user_to_uid

将指定的用户转换成 uid 并显示出来

```
[root@master ~]# salt '192.168.153.141' file.user_to_uid itw
192.168.153.141:
    1000
[root@master ~]# salt '192.168.153.141' file.user_to_uid root
192.168.153.141:
    0
```

#### 2.6.38 file.write

往一个指定的文件里覆盖写入指定内容

```
[root@master ~]# salt '192.168.153.141' cmd.run 'cat /root/b'
192.168.153.141:
    hehe
    xixi
    haha
    itww itww itww world
    itww
    itww
    haha
    xixi
[root@master ~]# salt '192.168.153.141' file.write /root/b "I'm tom" "haha" "xixi"
192.168.153.141:
    Wrote 3 lines to "/root/b"
[root@master ~]# salt '192.168.153.141' cmd.run 'cat /root/b'
192.168.153.141:
    I'm tom
    haha
    xixi
```
