---
title: "limits.conf"
date: 2018-11-17T16:15:57+08:00
description: ""
draft: false
tags: ["web"]
categories: ["Linux运维"]
---

<!--more-->

limits.conf 文件实际是 Linux PAM（插入式认证模块，Pluggable Authentication Modules）中 pam_limits.so 的配置文件，而且只针对于单个会话。

### limits.conf的格式如下：

>username|@groupname type resource limit
>
>username|@groupname：设置需要被限制的用户名，组名前面加@和用户名区别。也可以用通配符*来做所有用户的限制。

### type：

>soft，hard 和 -，soft 指的是当前系统生效的设置值。
>hard 表明系统中所能设定的最大值。
>soft 的限制不能比har 限制高。
>用 - 就表明同时设置了 soft 和 hard 的值。

### resource：

```
core - 限制内核文件的大小
date - 最大数据大小
fsize - 最大文件大小
memlock - 最大锁定内存地址空间
nofile - 打开文件的最大数目
rss - 最大持久设置大小
stack - 最大栈大小
cpu - 以分钟为单位的最多 CPU 时间
noproc - 进程的最大数目
as - 地址空间限制
maxlogins - 此用户允许登录的最大数目
要使 limits.conf 文件配置生效，必须要确保 pam_limits.so 文件被加入到启动文件中。查看 /etc/pam.d/login 文件中有：
　　session required /lib/security/pam_limits.so
```

### vi /etc/security/limits.conf

```
* soft nofile 655360        # open files  (-n)，不要设置为unlimited
* hard nofile 655360        # 不要超过最大值1048576，不要设置为unlimited

* soft nproc 655650
* hard nproc 655650         # max user processes   (-u)

hive   - nofile 655650
hive   - nproc  655650
```

### 用户进程限制（某些系统nproc会在20-nproc.conf内限制）

```
# 加大普通用户限制  也可以改为unlimited
    
$ sed -i ‘s#4096#65535#g‘   /etc/security/limits.d/20-nproc.conf  
$ egrep -v "^$|^#" /etc/security/limits.d/20-nproc.conf        
    
- soft    nproc     65535
root       soft    nproc     unlimited
```