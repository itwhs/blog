---
title: "SaltStack之数据系统"
date: 2019-03-16T16:15:57+08:00
description: ""
draft: false
tags: ["自动化"]
categories: ["Linux运维"]
---

<!--more-->



## 1. SaltStack数据系统

SaltStack有两大数据系统，分别是：

 - Grains
 - Pillar

## 2. SaltStack数据系统组件

### 2.1 SaltStack组件之Grains

`Grains`是`SaltStack`的一个组件，其存放着minion启动时收集到的信息。

`Grains`是`SaltStack`组件中非常重要的组件之一，因为我们在做配置部署的过程中会经常使用它，`Grains`是`SaltStack`记录`minion`的一些静态信息的组件。可简单理解为`Grains`记录着每台`minion`的一些常用属性，比如CPU、内存、磁盘、网络信息等。我们可以通过`grains.items`查看某台`minion`的所有`Grains`信息。

Grains的功能：

 - 收集资产信息

Grains应用场景：

 - 信息查询
 - 在命令行下进行目标匹配
 - 在top file中进行目标匹配
 - 在模板中进行目标匹配

模板中进行目标匹配请看：https://docs.saltstack.com/en/latest/topics/pillar/

**信息查询实例：**

```
列出所有grains的key和value
[root@master ~]# salt '192.168.153.141' grains.items
192.168.153.141:
    ----------
    SSDs:
        - dm-0
        - dm-1
        - nvme0n1
    biosreleasedate:        //bios的时间
        04/13/2018
    biosversion:            //bios的版本
        6.00
    cpu_flags:              //cpu相关的属性
        - fpu
        - vme
        - de
        - pse
        - tsc
        - msr
        - pae
        - mce
        - cx8
        - apic
        - sep
        - mtrr
        - pge
        - mca
        - cmov
        - pat
        - pse36
        - clflush
        - mmx
        - fxsr
        - sse
        - sse2
        - ss
        - syscall
        - nx
        - pdpe1gb
        - rdtscp
        - lm
        - constant_tsc
        - arch_perfmon
        - nopl
        - xtopology
        - tsc_reliable
        - nonstop_tsc
        - eagerfpu
        - pni
        - pclmulqdq
        - vmx
        - ssse3
        - fma
        - cx16
        - pcid
        - sse4_1
        - sse4_2
        - x2apic
        - movbe
        - popcnt
        - tsc_deadline_timer
        - aes
        - xsave
        - avx
        - f16c
        - rdrand
        - hypervisor
        - lahf_lm
        - abm
        - 3dnowprefetch
        - ssbd
        - ibrs
        - ibpb
        - stibp
        - tpr_shadow
        - vnmi
        - ept
        - vpid
        - fsgsbase
        - tsc_adjust
        - bmi1
        - avx2
        - smep
        - bmi2
        - invpcid
        - mpx
        - rdseed
        - adx
        - smap
        - clflushopt
        - xsaveopt
        - xsavec
        - arat
        - spec_ctrl
        - intel_stibp
        - flush_l1d
        - arch_capabilities
    cpu_model:          //cpu的具体型号
        Intel(R) Core(TM) i7-7700HQ CPU @ 2.80GHz
    cpuarch:          //cpu的架构
        x86_64
    disks:
        - sr0
    dns:
        ----------
        domain:
        ip4_nameservers:
            - 192.168.153.2
        ip6_nameservers:
        nameservers:
            - 192.168.153.2
        options:
        search:
            - localdomain
        sortlist:
    domain:
    fqdn:
        minion
    fqdn_ip4:       //ip地址
        - 192.168.153.141
    fqdn_ip6:
        - fe80::20c:29ff:fe65:2d90
    fqdns:
    gid:
        0
    gpus:
        |_
          ----------
          model:
              SVGA II Adapter
          vendor:
              vmware
    groupname:
        root
    host:       //主机名
        minion
    hwaddr_interfaces:
        ----------
        ens32:
            00:0c:29:65:2d:90
        lo:
            00:00:00:00:00:00
    id:         //minion的ID
        192.168.153.141
    init:
        systemd
    ip4_gw:
        192.168.153.2
    ip4_interfaces:
        ----------
        ens32:
            - 192.168.153.141
        lo:
            - 127.0.0.1
    ip6_gw:
        False
    ip6_interfaces:
        ----------
        ens32:
            - fe80::20c:29ff:fe65:2d90
        lo:
            - ::1
    ip_gw:
        True
    ip_interfaces:
        ----------
        ens32:
            - 192.168.153.141
            - fe80::20c:29ff:fe65:2d90
        lo:
            - 127.0.0.1
            - ::1
    ipv4:
        - 127.0.0.1
        - 192.168.153.141
    ipv6:
        - ::1
        - fe80::20c:29ff:fe65:2d90
    kernel:
        Linux
    kernelrelease:
        3.10.0-957.el7.x86_64
    kernelversion:
        #1 SMP Thu Nov 8 23:39:32 UTC 2018
    locale_info:
        ----------
        defaultencoding:
            UTF-8
        defaultlanguage:
            zh_CN
        detectedencoding:
            UTF-8
    localhost:
        minion
    lsb_distrib_codename:
        CentOS Linux 7 (Core)
    lsb_distrib_id:
        CentOS Linux
    machine_id:
        6f280181d6cc47b0825de02f2c7e76a3
    manufacturer:
        VMware, Inc.
    master:
        192.168.153.136
    mdadm:
    mem_total:
        1538
    nodename:
        minion
    num_cpus:
        1
    num_gpus:
        1
    os:
        CentOS
    os_family:
        RedHat
    osarch:
        x86_64
    oscodename:
        CentOS Linux 7 (Core)
    osfinger:
        CentOS Linux-7
    osfullname:
        CentOS Linux
    osmajorrelease:
        7
    osrelease:
        7.6.1810
    osrelease_info:
        - 7
        - 6
        - 1810
    path:
        /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
    pid:
        7461
    productname:
        VMware Virtual Platform
    ps:
        ps -efHww
    pythonexecutable:
        /usr/bin/python
    pythonpath:
        - /usr/bin
        - /usr/lib64/python27.zip
        - /usr/lib64/python2.7
        - /usr/lib64/python2.7/plat-linux2
        - /usr/lib64/python2.7/lib-tk
        - /usr/lib64/python2.7/lib-old
        - /usr/lib64/python2.7/lib-dynload
        - /usr/lib64/python2.7/site-packages
        - /usr/lib64/python2.7/site-packages/gtk-2.0
        - /usr/lib/python2.7/site-packages
    pythonversion:
        - 2
        - 7
        - 5
        - final
        - 0
    saltpath:
        /usr/lib/python2.7/site-packages/salt
    saltversion:
        2019.2.0
    saltversioninfo:
        - 2019
        - 2
        - 0
        - 0
    selinux:
        ----------
        enabled:
            False
        enforced:
            Disabled
    serialnumber:
        VMware-56 4d aa 3c 10 d5 dc e0-87 ec ee 70 30 65 2d 90
    server_id:
        1797657207
    shell:
        /bin/sh
    swap_total:
        3071
    systemd:
        ----------
        features:
            +PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN
        version:
            219
    uid:
        0
    username:
        root
    uuid:
        3caa4d56-d510-e0dc-87ec-ee7030652d90
    virtual:
        VMware
    zfs_feature_flags:
        False
    zfs_support:
        False
    zmqversion:
        4.1.4

        
只查询所有的grains的key
[root@master ~]# salt '192.168.153.141' grains.ls
192.168.153.141:
    - SSDs
    - biosreleasedate
    - biosversion
    - cpu_flags
    - cpu_model
    - cpuarch
    - disks
    - dns
    - domain
    - fqdn
    - fqdn_ip4
    - fqdn_ip6
    - fqdns
    - gid
    - gpus
    - groupname
    - host
    - hwaddr_interfaces
    - id
    - init
    - ip4_gw
    - ip4_interfaces
    - ip6_gw
    - ip6_interfaces
    - ip_gw
    - ip_interfaces
    - ipv4
    - ipv6
    - kernel
    - kernelrelease
    - kernelversion
    - locale_info
    - localhost
    - lsb_distrib_codename
    - lsb_distrib_id
    - machine_id
    - manufacturer
    - master
    - mdadm
    - mem_total
    - nodename
    - num_cpus
    - num_gpus
    - os
    - os_family
    - osarch
    - oscodename
    - osfinger
    - osfullname
    - osmajorrelease
    - osrelease
    - osrelease_info
    - path
    - pid
    - productname
    - ps
    - pythonexecutable
    - pythonpath
    - pythonversion
    - saltpath
    - saltversion
    - saltversioninfo
    - selinux
    - serialnumber
    - server_id
    - shell
    - swap_total
    - systemd
    - uid
    - username
    - uuid
    - virtual
    - zfs_feature_flags
    - zfs_support
    - zmqversion




查询某个key的值，比如想获取ip地址
[root@master ~]# salt '*' grains.get fqdn_ip4
192.168.153.141:
    - 192.168.153.141
192.168.153.136:
    - 192.168.153.136

[root@master ~]# salt '*' grains.get ip4_interfaces
192.168.153.141:
    ----------
    ens32:
        - 192.168.153.141
    lo:
        - 127.0.0.1
192.168.153.136:
    ----------
    ens32:
        - 192.168.153.136
    lo:
        - 127.0.0.1

[root@master ~]# salt '*' grains.get ip4_interfaces:ens32
192.168.153.141:
    - 192.168.153.141
192.168.153.136:
    - 192.168.153.136
```

**目标匹配实例：**
用`Grains`来匹配`minion`：

```
在所有centos系统中执行命令
[root@master ~]# salt -G 'os:CentOS' cmd.run 'uptime'
192.168.153.141:
     19:41:29 up  1:33,  1 user,  load average: 0.00, 0.01, 0.05
192.168.153.136:
     19:41:29 up  1:33,  1 user,  load average: 0.00, 0.01, 0.05
```

在top file里面使用Grains：

```
[root@master ~]# vim /srv/salt/base/top.sls
base:
  '192.168.153.141':
    - web.apache.apache
  'os:CentOS':
    - match: grain
    - fspub.vsftpd


效果:141这个主机会执行apache这个文件,所有centos主机会执行vsftpd这个文件
```

**自定义Grains的两种方法：**

 - minion配置文件，在配置文件中搜索grains
 - 在/etc/salt下生成一个grains文件，在此文件中定义(推荐方式)

```
[root@master ~]# vim /etc/salt/grains
test-grains: linux-node1
[root@master ~]# systemctl restart salt-minion
[root@master ~]# salt '*' grains.get test-grains
192.168.153.141:
192.168.153.136:
    linux-node1
```

不重启的情况下自定义`Grains`：

```
[root@master ~]# vim /etc/salt/grains
test-grains: linux-node1
itwhs: design

[root@master ~]# salt '*' saltutil.sync_grains
192.168.153.136:
192.168.153.141:
[root@master ~]# salt '*' grains.get itwhs
192.168.153.136:
    design
192.168.153.141:
```

### 2.2 SaltStack组件之Pillar

Pillar也是SaltStack组件中非常重要的组件之一，是数据管理中心，经常配置states在大规模的配置管理工作中使用它。Pillar在SaltStack中主要的作用就是存储和定义配置管理中需要的一些数据，比如软件版本号、用户名密码等信息，它的定义存储格式与Grains类似，都是YAML格式。

在Master配置文件中有一段Pillar settings选项专门定义Pillar相关的一些参数：

```
#pillar_roots:
#  base:
#    - /srv/pillar
```

默认Base环境下Pillar的工作目录在/srv/pillar目录下。若你想定义多个环境不同的Pillar工作目录，只需要修改此处配置文件即可。

Pillar的特点：

 - 可以给指定的minion定义它需要的数据
 - 只有指定的人才能看到定义的数据
 - 在master配置文件里设置

```
查看pillar的信息
[root@master ~]# salt '*' pillar.items
192.168.153.136:
    ----------
192.168.153.141:
    ----------
```

默认`pillar`是没有任何信息的，如果想查看信息，需要在 master 配置文件上把 `pillar_opts`的注释取消，并将其值设为 True。

```
[root@master ~]# vim /etc/salt/master
# master config file that can then be used on minions.
pillar_opts: True

# The pillar_safe_render_error option prevents the master from passing pillar


重启master并查看pillar的信息
[root@master ~]# systemctl restart salt-master
[root@master ~]# salt '*' pillar.items
....此处省略N行
        winrepo_passphrase:
        winrepo_password:
        winrepo_privkey:
        winrepo_pubkey:
        winrepo_refspecs:
            - +refs/heads/*:refs/remotes/origin/*
            - +refs/tags/*:refs/tags/*
        winrepo_remotes:
            - https://github.com/saltstack/salt-winrepo.git
        winrepo_remotes_ng:
            - https://github.com/saltstack/salt-winrepo-ng.git
        winrepo_ssl_verify:
            True
        winrepo_user:
        worker_floscript:
            /usr/lib/python2.7/site-packages/salt/daemons/flo/worker.flo
        worker_threads:
            5
        zmq_backlog:
            1000
        zmq_filtering:
            False
        zmq_monitor:
            False
```

**pillar自定义数据：**
在master的配置文件里找pillar_roots可以看到其存放pillar的位置

```
[root@master ~]# vim /etc/salt/master
...省略N行
#####         Pillar settings        #####
##########################################
# Salt Pillars allow for the building of global data that can be made selectively
# available to different minions based on minion grain filtering. The Salt
# Pillar is laid out in the same fashion as the file server, with environments,
# a top file and sls files. However, pillar data does not need to be in the
# highstate format, and is generally just key/value pairs.
pillar_roots:
  base:
    - /srv/pillar/base
  prod:
    - /srv/pillar/prod

#ext_pillar:
#  - hiera: /etc/hiera.yaml
#  - cmd_yaml: cat /etc/salt/yaml


[root@master ~]# mkdir -p /srv/pillar/{base,prod}
[root@master ~]# tree /srv/pillar/
/srv/pillar/
├── base
└── prod

2 directories, 0 files


[root@master ~]# systemctl restart salt-master
[root@master ~]# vim /srv/pillar/base/apache.sls
{% if grains['os'] == 'CentOS' %}
apache: httpd
{% elif grains['os'] == 'Debian' %}
apache: apache2
{% endif %}

定义top file入口文件
[root@master ~]# vim /srv/pillar/base/top.sls
base:       //指定环境
  '192.168.153.141':     //指定目标
    - apache            //引用apache.sls或apache/init.sls
这个top.sls文件的意思表示的是192.168.153.141这台主机的base环境能够访问到apache这个pillar

[root@master ~]# salt '*' pillar.items
192.168.153.141:
    ----------
    apache:
        httpd
    master:     //这里的master就是136这个主机
        ----------
        ........
    
在salt下修改apache的状态文件，引用pillar的数据
[root@master ~]# vim /srv/salt/base/web/apache/apache.sls
apache-install:
  pkg.installed:
    - name: {{ pillar['apache'] }}

apache-service:
  service.running:
    - name: {{ pillar['apache'] }}
    - enable: True


执行高级状态文件
[root@master ~]# salt '192.168.153.141' state.highstate
192.168.153.141:
----------
          ID: apache-install
    Function: pkg.installed
        Name: httpd      //根据系统类型,自动安装的是httpd
      Result: True
     Comment: All specified packages are already installed
     Started: 20:18:05.355675
    Duration: 952.802 ms
     Changes:   
----------
          ID: apache-service
    Function: service.running
        Name: httpd
      Result: True
     Comment: The service httpd is already running
     Started: 20:18:06.310231
    Duration: 52.423 ms
     Changes:   
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: vsftpd
      Result: True
     Comment: All specified packages are already installed
     Started: 20:18:06.363005
    Duration: 19.337 ms
     Changes:   
----------
          ID: vsftpd_install
    Function: pkg.installed
        Name: httpd-tools
      Result: True
     Comment: All specified packages are already installed
     Started: 20:18:06.382502
    Duration: 16.545 ms
     Changes:   
----------
          ID: vsftpd_systemctl
    Function: service.running
        Name: vsftpd
      Result: True
     Comment: The service vsftpd is already running
     Started: 20:18:06.399288
    Duration: 39.108 ms
     Changes:   

Summary for 192.168.153.141
------------
Succeeded: 5
Failed:    0
------------
Total states run:     5
Total run time:   1.080 s
```

### 2.3 Grains与Pillar的区别

|        | 存储位置 | 类型 | 采集方式                                         | 应用场景                                                     |
| :----: | :------: | :--- | :----------------------------------------------- | :----------------------------------------------------------- |
| Grains |  minion  | 静态 | minion启动时采集<br>可通过刷新避免重启minion服务 | 1.信息查询<br>2.在命令行下进行目标匹配<br>3.在top file中进行目标匹配<br>4.在模板中进行目标匹配 |
| Pillar |  master  | 动态 | 指定，实时生效                                   | 1.目标匹配<br>2.敏感数据配置                                 |