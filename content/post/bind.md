---
title: "bind服务"
date: 2018-11-10T16:15:57+08:00
description: ""
draft: false
tags: ["dns"]
categories: ["Linux运维"]
---

<!--more-->

# 安装bind

```
yum install bind-chroot bind-utils

# 开机启动
systemctl enable named-chroot
```

# 配置bind

```
> cat /etc/named.conf
options {
    listen-on port 53 { any; };  # 监听任何ip对53端口的请求
    listen-on-v6 port 53 { ::1; };
    directory   "/var/named";
    dump-file   "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query     { any; }; # 接收任何来源查询dns记录

    recursion yes;

    dnssec-enable yes;
    dnssec-validation yes;

    bindkeys-file "/etc/named.iscdlv.key";

    managed-keys-directory "/var/named/dynamic";

    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
    type hint;
    file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

## 添加正向解析域

```
vim /etc/named.rfc1912.zones
zone "wenhs.com" IN {
    type master;
    file "wenhs.com.zone";
};
```

## 添加反向解析域

```
vim /etc/named.rfc1912.zones
zone "161.168.192.in-addr.arpa" IN {
    type master;
    file "161.168.192.zone";
};
> cat /var/named/wenhs.com.zone 
$TTL 1D
@   IN  SOA wenhs.com.   admin.wenhs.com. (
            0   ; serial  
            1D  ; refresh  # 主从刷新时间
            1H  ; retry  # 主从通讯失败后重试间隔
            1W  ; expire  # 缓存过期时间
            3H )    ; minimum  # 没有TTL定义时的最小生存周期
        NS  www.wenhs.com.
        NS  ftp.wenhs.com.
        A   127.0.0.1
        AAAA    ::1
        MX  10 mx.wenhs.com.
ttl IN  A   192.168.161.88
www     IN  A   192.168.161.88   
bbs IN  CNAME   www
mx  IN  A   192.168.161.88
ftp IN  A   192.168.161.88

> > cat /var/named/161.168.192.zone 
$TTL 1D
@       IN      SOA     wenhs.com. admin.wenhs.com. (
                         0
                         2H
                         10M
                         7D
                         1D )
        NS  ttl.wenhs.com.
        A   127.0.0.1
        AAAA    ::1
88  IN      PTR     wenhs.com
88  IN      PTR     www.wenhs.com.
88  IN      PTR     ftp.wenhs.com.
88  IN      PTR     mx.wenhs.com.
```


**注意：一点要给权限***

```
chown named.named 161.168.192.zone 
chmod 755 wenhs.com.zone 
chmod 755 161.168.192.zone
```

# 启动bind

```
systemctl start named-chroot
```

# 检查配置

```
> named-checkzone "wenhs.com" /var/named/wenhs.com.zone
zone wenhs.com/IN: loaded serial 0
OK
```

# 本地测试解析

> 将本机的DNS修改为192.168.161.88(上面的dns服务器地址)， 打开cmd

## 查询 `wenhs.com` 的dns记录

```
C:\Users\Administrator>nslookup -qt=A wenhs.com
服务器:  UnKnown
Address:  192.168.161.88

名称:    wenhs.com
Addresses:  127.0.0.1
          192.168.161.88
```

## 查询 `www.wenhs.com` 的dns记录

```
C:\Users\Administrator>nslookup -qt=A www.wenhs.com
服务器:  UnKnown
Address:  192.168.161.88

名称:    www.wenhs.com
Address:  192.168.161.88

C:\Users\Administrator>nslookup mx.wenhs.com
服务器:  www.wenhs.com
Address:  192.168.161.88

名称:    mx.wenhs.com
Address:  192.168.161.88
```