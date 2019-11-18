---
title: "2019年计算机网络省赛Linux部分"
date: 2019-11-10T16:15:57+08:00
description: ""
draft: false
tags: ["省赛"]
categories: ["比赛"]
---

<!--more-->



### 管理员设备:

```
插在三层交换机vlan20下的其中一个口,vlan20上配置ip为:192.168.20.1
所以笔记本ip为:192.168.1.X,掩码:255.255.255.0,网关:192.168.20.1
云平台地址:http://192.168.100.100/dashboard,用户名:admin 密码:dcncloud
(因为笔记本WiFi开着,教师办公室有192.168.x.x的地址,所以给笔记本几条路由,让其走有线网卡)
Windows账号:administrator 密码:Qwer1234
linux账号:root 密码:dcncloud
cmd以管理员打开:
route add 192.168.100.0 mask 255.255.255.0 192.168.20.1
route add 192.168.10.0 mask 255.255.255.0 192.168.20.1
route add 192.168.20.0 mask 255.255.255.0 192.168.20.1
route add 192.168.30.0 mask 255.255.255.0 192.168.20.1
```

### 镜像模板初始化准备:

```shell
因为是一下创建多台,所以ip是自动分配的,注意看主机名称即可
---------------------------------------------
Win-A1-10.101  192.168.10.101/24 192.168.10.1
Win-A2-10.102  192.168.10.102/24 192.168.10.1
Win-B1-20.101  192.168.20.101/24 192.168.20.1
Win-B2-20.104  192.168.20.104/24 192.168.20.1
Win-B3-20.103  192.168.20.103/24 192.168.20.1
Win-B4-20.102  192.168.20.102/24 192.168.20.1
---------------------------------------------
Centos-A3  192.168.10.103/24 192.168.10.1
Centos-A4  192.168.10.104/24 192.168.10.1
Centos-C1  192.168.30.104/24 192.168.30.1
Centos-C2  192.168.30.101/24 192.168.30.1
Centos-C3  192.168.30.102/24 192.168.30.1
Centos-C4  192.168.30.103/24 192.168.30.1
------------------------------------------
```

### 题目操作方面(初始化):

#### win:

在web把远程的下面那个勾取消，设置静态IP，修改主机名，关闭防火墙，运行sysprep重置SID

#### linux:

设置selinux，配置软件源，改fstab永久挂载，改网卡DNS1地址，重启网络服务，改res那个dns文件，清空iptables规则(每个机器都要做的初始化) 名称问题，能复制则复制

注意事项:

1，按题目要求设置三层交换(要上三层)，接口等(左侧eth0云平台口vlan100，网关192.168.100.1，右侧eth1是trunk口，分别连上三层交换对应的口，物理机按照VLAN给ip和网关，保证能互相通信，注意神州数码三层交换的配置，注意光口转电口模式)

2,先创网络，再创实例(尤其注意，要在[管理员-网络，这里创建才能有VLAN标识，可在网络拓扑里面添加子网及地址池])

3,创建网络[管理员-网络]，那个共享和外部网络要勾上，不然实例没有可用网络

4,创建实例[项目-计算-实例]，按要求创建

5,创建卷[项目-计算-卷]，按要求创建后，连接到实例,连接上是vd*虚拟磁盘



#### 具体方法:

a,管理员-系统-网络-创建网络(名称,项目, 分段标识,外部网络)

b,项目-网络-网络-添加子网(子网名称,网络地址,网关ip;再下一步,启用dhcp,分配池,创建)

c,项目-实例c-创建实例(详细信息-实例名称-数量,镜像源,实例规格,网络,启动实例)

d,项目-计算-卷-d创建卷(卷名称,大小)-点击卷后下三角-管理连接-选择连接实例



### 神州数码云平台初始化准备:

```shell
#Centos-A3
sed -i "s/HOSTNAME=.*/HOSTNAME=Centos-A3/g" /etc/sysconfig/network
echo "192.168.10.103 Centos-A3" >>/etc/hosts
hostname Centos-A3
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
setenforce 0
iptables -F
iptables -X
service iptables save
mkdir /media/cdrom
rm -rf /etc/yum.repos.d/*
cat >>/etc/yum.repos.d/opt.repo<<'EOF'
[opt]
name=cdrom
baseurl=file:///media/cdrom
gpgcheck=0
enabled=1
EOF

echo "/opt/CentOS-6.5.iso /media/cdrom iso9660 defaults,ro,loop 0 0" >>/etc/fstab
mount -a
yum clean all
yum list all|wc -l
sed -i "s/DNS1=114.114.114.114/DNS1=192.168.10.103/g" /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart

yum -y install bind bind-utils
service named start
chkconfig named on

vim /etc/named.conf
listen-on port 53 { any; };
allow-query     { any; };
blackhole    { 192.168.70.0/24; };

cat >>/etc/named.rfc1912.zones<<'EDS'
zone "2019skills.com" IN {
    type forward;
    forward only;
    forwarders { 192.168.10.101; };
};

zone "lin.2019skills.com" IN {
        type master;
        file "lin.2019skills.com.zone";
        allow-update { none; };
};

zone "10.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.10.arpa";
        allow-update { none; };
};

zone "30.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.30.arpa";
        allow-update { none; };
};
EDS

#\cp -a /var/named/named.localhost /var/named/lin.2019skills.com.zone
#\cp -a /var/named/named.loopback /var/named/192.168.10.arpa
#\cp -a /var/named/named.loopback /var/named/192.168.30.arpa

cat >/var/named/lin.2019skills.com.zone<<'EDH'
$TTL 1D
@       IN SOA  lin.2019skills.com. root.lin.2019skills.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS    dns.lin.2019skills.com.
        MX 10 mail.lin.2019skills.com.
dns     A     192.168.10.103
www     A     192.168.10.104
ftp     A     192.168.30.104
mail    A     192.168.30.101
smb     A     192.168.30.102
data    A     192.168.30.103
EDH

cat >/var/named/192.168.10.arpa<<'EDG'
$TTL 1D
@       IN SOA  lin.2019skills.com. root.lin.2019skills.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS    dns.lin.2019skills.com.
103     PTR   dns.lin.2019skills.com.
104     PTR   www.lin.2019skills.com.
EDG

cat >/var/named/192.168.30.arpa<<'EDF'
$TTL 1D
@       IN SOA  lin.2019skills.com. root.lin.2019skills.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS    dns.lin.2019skills.com.
104     PTR   ftp.lin.2019skills.com.
101     PTR   mail.lin.2019skills.com.
102     PTR   smb.lin.2019skills.com.
103     PTR   data.lin.2019skills.com.
EDF

service named restart
#=============================================
yum -y install telnet-server telnet xinetd

vim /etc/xinetd.d/telnet
# default: on
# description: The telnet server serves telnet sessions; it uses \
#       unencrypted username/password pairs for authentication.
service telnet
{
        flags           = REUSE
        socket_type     = stream
        wait            = no
        user            = root
        server          = /usr/sbin/in.telnetd
        log_on_failure  += USERID
        disable         = no
}

service xinetd start
chkconfig xinetd on

iptables -F
iptables -A INPUT -p tcp ! -s 192.168.0.0/16 --dport 23 -m state --state NEW,ESTABLISHED -j REJECT
iptables -A INPUT -p udp ! -s 192.168.0.0/16 --dport 23 -m state --state NEW,ESTABLISHED -j REJECT
service iptables save
service iptables reload
iptables -L -v -n --line-numbers
useradd cta3-test
echo "cta3-test" |passwd --stdin cta3-test
reboot

-------------------------------------------------------------------------------------
#Centos-A4
sed -i "s/HOSTNAME=.*/HOSTNAME=Centos-A4/g" /etc/sysconfig/network
echo "192.168.10.104 Centos-A4" >>/etc/hosts
hostname Centos-A4
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
setenforce 0
iptables -F
iptables -X
service iptables save
mkdir /media/cdrom
rm -rf /etc/yum.repos.d/*
cat >>/etc/yum.repos.d/opt.repo<<'EOF'
[opt]
name=cdrom
baseurl=file:///media/cdrom
gpgcheck=0
enabled=1
EOF

echo "/opt/CentOS-6.5.iso /media/cdrom iso9660 defaults,ro,loop 0 0" >>/etc/fstab
mount -a
yum clean all
yum list all|wc -l
sed -i "s/DNS1=114.114.114.114/DNS1=192.168.10.103/g" /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart

yum -y install httpd
service httpd start
chkconfig httpd on
mkdir -p /www/8080
cat >>/etc/httpd/conf.d/httpd-vhosts.conf<<'EDS'
Listen 8080
ServerName www.lin.2019skills.com
<VirtualHost 192.168.10.104:8080>
    DocumentRoot "/www/8080"
    ServerName www.lin.2019skills.com
    Alias /vdir "/www/8080"
    <Directory "/www/8080">
        Allow from all
    </Directory>
    <IfModule dir_module>
        DirectoryIndex skills8080.html
    </IfModule>
</VirtualHost>
EDS

cat >/www/8080/skills8080.html<<'EDG'
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Welcome chinaskills’s website：8080
</div>
</body>
</html>
EDG

service httpd reload        
#====================================================
mkdir /www/jnds
cat >/www/jnds/skills.html<<'EDF'
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Welcome chinaskills’s website
</div>
</body>
</html>
EDF

cat >>/etc/httpd/conf.d/httpd-vhosts.conf<<'EDC'
<VirtualHost 192.168.10.104:80>
    DocumentRoot "/www/jnds"
    ServerName www.lin.2019skills.com
    <Directory "/www/jnds">
        AllowOverride AuthConfig
        AuthName "www.lin.2019skills.com user auth"
        AuthType Basic
        AuthUserFile /www/jnds/.htpasswd
        require valid-user
    </Directory>
    <IfModule dir_module>
        DirectoryIndex skills.html
    </IfModule>
</VirtualHost>
EDC

htpasswd -cm /www/jnds/.htpasswd webuser1
#设置密码
htpasswd -m /www/jnds/.htpasswd webuser2

cat /www/jnds/.htpasswd
service httpd reload
#=================================================
yum -y install mod_ssl openssl
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr <<'EDK'
CN
HuBei
WuHan
www.lin.2019skills.com
www.lin.2019skills.com
www.lin.2019skills.com
root@lin.2019skills.com


EDK
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
\cp server.crt /etc/pki/tls/certs
\cp server.key /etc/pki/tls/private/server.key
\cp server.csr /etc/pki/tls/private/server.csr
mkdir /www/ssl

cat >/www/ssl/skillsssl.html<<'ERT'
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Welcome chinaskills’s website：ssl
</div>
</body>
</html>
ERT

cat >>/etc/httpd/conf.d/httpd-vhosts.conf<<'END'
<VirtualHost 192.168.10.104:443>
    DocumentRoot "/www/ssl"
    ServerName www.lin.2019skills.com:443
    SSLEngine on
    SSLCertificateFile "/etc/pki/tls/certs/server.crt"
    SSLCertificateKeyFile "/etc/pki/tls/private/server.key"
    <Directory "/www/ssl">
        Allow from all
    </Directory>
    <IfModule dir_module>
        DirectoryIndex skillsssl.html
    </IfModule>
</VirtualHost>
END

service httpd reload
reboot

---------------------------------------------------------------------------------------
#Centos-C1
#注意,这个镜像是RedHat6.5-mini,所以网卡配置略有不同
sed -i "s/HOSTNAME=.*/HOSTNAME=Centos-C1/g" /etc/sysconfig/network
echo "192.168.30.104 Centos-C1" >>/etc/hosts
hostname Centos-C1
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
setenforce 0
iptables -F
iptables -X
service iptables save
mkdir /media/cdrom
rm -rf /etc/yum.repos.d/*
cat >>/etc/yum.repos.d/opt.repo<<'EOF'
[opt]
name=cdrom
baseurl=file:///media/cdrom
gpgcheck=0
enabled=1
EOF

echo "/opt/CentOS-6.5.iso /media/cdrom iso9660 defaults,ro,loop 0 0" >>/etc/fstab
mount -a
yum clean all
yum list all|wc -l
echo "DNS1=192.168.10.103" >>/etc/sysconfig/network-scripts/ifcfg-eth0
service network restart

yum -y install vsftpd
service vsftpd start
chkconfig vsftpd on

vi /etc/vsftpd/vsftpd.conf
#修改或添加以下参数
anonymous_enable=NO
local_root=/var/ftp
max_clients=50
max_per_ip=5
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40080
pasv_promiscuous=YES

service vsftpd restart
useradd -d /home/vsftpd -s /sbin/nologin vsftpd
chmod 755 /home/vsftpd/
cat >/etc/vsftpd/vuser_passwd.txt<<'EDV'
ftpuser1
ftpuser1
ftpuser2
ftpuser2
EDV

db_load -T -t hash -f /etc/vsftpd/vuser_passwd.txt /etc/vsftpd/vuser_passwd.db
chmod 600 /etc/vsftpd/vuser_passwd.db

vi /etc/pam.d/vsftpd
auth sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/vuser_passwd
account sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/vuser_passwd

mkdir /etc/vsftpd_user_conf
cat >/etc/vsftpd_user_conf/ftpuser1<<'ZXC'
local_root=/home/vsftpd
write_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
ZXC

vi /etc/vsftpd_user_conf/ftpuser2   #可以为空,默认只有下载权限
local_root=/home/vsftpd
anon_world_readable_only=no

vi /etc/vsftpd/vsftpd.conf
修改或添加以下参数
pam_service_name=vsftpd
guest_enable=YES
guest_username=vsftpd
user_config_dir=/etc/vsftpd_user_conf

service vsftpd restart
#======================================================
iptables -F
iptables -A INPUT -p tcp --dport 20:21 -j ACCEPT
iptables -A INPUT -p tcp --dport 4000:40080 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
service iptables save
service iptables reload

iptables -A OUTPUT -p icmp -d 192.168.10.0/24 -j DROP
service iptables save
service iptables reload

sed -i "s/^net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf
sysctl -p
iptables -t nat -A OUTPUT -p tcp -d 192.168.10.104 --dport 80 -j DNAT --to 192.168.10.104:8080
service iptables save
service iptables reload

iptables-save >/var/iptables
cat /var/iptables
chkconfig iptables on
reboot

---------------------------------------------------------------------------------------
#Centos-C2
sed -i "s/HOSTNAME=.*/HOSTNAME=mail.lin.2019skills.com/g" /etc/sysconfig/network
echo "192.168.30.101 mail.lin.2019skills.com" >>/etc/hosts
hostname mail.lin.2019skills.com
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
setenforce 0
iptables -F
iptables -X
service iptables save
mkdir /media/cdrom
rm -rf /etc/yum.repos.d/*
cat >>/etc/yum.repos.d/opt.repo<<'EOF'
[opt]
name=cdrom
baseurl=file:///media/cdrom
gpgcheck=0
enabled=1
EOF

echo "/opt/CentOS-6.5.iso /media/cdrom iso9660 defaults,ro,loop 0 0" >>/etc/fstab
mount -a
yum clean all
yum list all|wc -l
sed -i "s/DNS1=114.114.114.114/DNS1=192.168.10.103/g" /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart

service postfix stop
yum -y remove postfix
yum -y install sendmail sendmail-cf dovecot
service iptables stop
chkconfig iptables off
service sendmail start
service dovecot start
chkconfig sendmail on
chkconfig dovecot on

vi /etc/mail/sendmail.mc
define(`UUCP_MAILER_MAX', `5242880')dnl

#m4 /etc/mail/sendmail.mc /etc/mail/sendmail.cf
#yum install -y quota
dd if=/dev/zero of=/mailbox bs=1M count=2048
mkfs.ext4 /mailbox
#确定y

echo "/mailbox /var/spool/mail ext4 defaults,loop,usrquota,grpquota 0 0" >>/etc/fstab
mount -av

#yum -y install quota
quotacheck -cugm /var/spool/mail/
useradd -s /sbin/nologin linmail
useradd -s /sbin/nologin winmail
echo "linmail" |passwd --stdin linmail
echo "winmail" |passwd --stdin winmail
setquota -u linmail 0 30720 0 0 /var/spool/mail/
setquota -u winmail 0 30720 0 0 /var/spool/mail/
#edquota -u linmail
quotaoff -av
quotaon -av


vi /etc/mail/sendmail.mc
DAEMON_OPTIONS(`Port=smtp,Addr=0.0.0.0, Name=MTA')dnl
LOCAL_DOMAIN(`lin.2019skills.com')dnl

#m4 /etc/mail/sendmail.mc /etc/mail/sendmail.cf

cat >>/etc/mail/local-host-names<<'END'
2019skills.com
lin.2019skills.com
END

cat >>/etc/mail/access<<'EOF'
Connect:192.168.10                      RELAY
Connect:192.168.20                      RELAY
Connect:192.168.30                      RELAY
Connect:lin.2019skills.com              RELAY
Connect:2019skills.com                  RELAY
EOF

makemap hash /etc/mail/access.db < /etc/mail/access

cat >>/etc/mail/sendmail.mc<<'END'
define(QUEUE_DIR, `/var/spool/mqueue/everyone/*')
END

m4 /etc/mail/sendmail.mc /etc/mail/sendmail.cf
mkdir -p /var/spool/mqueue/everyone/{linmail,winmail}

service sendmail restart

sed -i "s/^#protocols.*/protocols = pop3/g" /etc/dovecot/dovecot.conf
sed -i "s/^protocols.*/&\ndisable_plaintext_auth = no/g" /etc/dovecot/dovecot.conf
echo "mail_location = mbox:~/mail:INBOX=/var/mail/%u" >> /etc/dovecot/conf.d/10-mail.conf
service dovecot restart

#telnet mail.lin.2019skills.com 25
#Trying 192.168.30.101...
#Connected to mail.lin.2019skills.com.
#Escape character is '^]'.
#220 mail.lin.2019skills.com ESMTP Sendmail 8.14.4/8.14.4; Thu, 22 Aug 2019 04:22:47 +0800
helo mail.lin.2019skills.com
#250 mail.lin.2019skills.com Hello mail.lin.2019skills.com [192.168.30.101], pleased to meet you
mail from:linmail@lin.2019skills.com
#250 2.1.0 linmail@lin.2019skills.com... Sender ok
rcpt to:winmail@lin.2019skills.com
#250 2.1.5 winmail@lin.2019skills.com... Recipient ok
data
#354 Enter mail, end with "." on a line by itself
欢迎大家.
.
#250 2.0.0 x7LKMlDx003530 Message accepted for delivery
quit
#221 2.0.0 mail.lin.2019skills.com closing connection
#Connection closed by foreign host.
#[root@mail ~]# cat /var/mail/winmail
#From linmail@lin.2019skills.com  Thu Aug 22 04:25:45 2019
#Return-Path: <linmail@lin.2019skills.com>
#Received: from mail.lin.2019skills.com (mail.lin.2019skills.com [192.168.30.101])
#        by mail.lin.2019skills.com (8.14.4/8.14.4) with SMTP id x7LKMlDx003530
#        for winmail@lin.2019skills.com; Thu, 22 Aug 2019 04:25:14 +0800
#Date: Thu, 22 Aug 2019 04:22:47 +0800
#From: linmail@lin.2019skills.com
#Message-Id: <201908212025.x7LKMlDx003530@mail.lin.2019skills.com>
#
#test.test
#欢迎大家.

#====================================================
chkconfig ntpd on
/etc/init.d/ntpd start
/etc/init.d/ntpd status
reboot

---------------------------------------------------------------------------------------
#Centos-C3
sed -i "s/HOSTNAME=.*/HOSTNAME=Centos-C3/g" /etc/sysconfig/network
echo "192.168.30.102 Centos-C3" >>/etc/hosts
hostname Centos-C3
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
setenforce 0
iptables -F
iptables -X
service iptables save
mkdir /media/cdrom
rm -rf /etc/yum.repos.d/*
cat >>/etc/yum.repos.d/opt.repo<<'EOF'
[opt]
name=cdrom
baseurl=file:///media/cdrom
gpgcheck=0
enabled=1
EOF

echo "/opt/CentOS-6.5.iso /media/cdrom iso9660 defaults,ro,loop 0 0" >>/etc/fstab
mount -a
yum clean all
yum list all|wc -l
sed -i "s/DNS1=114.114.114.114/DNS1=192.168.10.103/g" /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart

vi /etc/ntp.conf
server 192.168.30.102 iburst

/etc/init.d/ntpd restart
ntpq -pn
ntpstat

yum -y install samba samba-client
service smb start
service nmb start
chkconfig smb on
chkconfig nmb on
groupadd administration
groupadd sales
groupadd manager
useradd -g administration -s /sbin/nologin tom
useradd -g administration -s /sbin/nologin jerry
useradd -g sales -s /sbin/nologin jack
useradd -g manager -s /sbin/nologin man
usermod -a -G sales jerry

smbpasswd -a tom
smbpasswd -a jerry
smbpasswd -a jack
smbpasswd -a man

cp /etc/samba/smb.conf{,.bak}

vi /etc/samba/smb.conf
#[global]全局参数里加上：
hosts deny = 172.16.0.0/255.255.0.0

service smb reload

mkdir /var/administration_share
mkdir /var/sales_share
chmod 757 /var/sales_share
chmod 757 /var/administration_share

cat >>/etc/samba/smb.conf<<'EOF'
[admin]
        path = /var/administration_share
        browseable = yes
        writable = no
        valid users = @manager,@administration,@sales
        write list = @manager,@administration

[sales]
        path = /var/sales_share
        browseable = yes
        writable = no
        valid users = @manager,@sales
        write list = @manager,@sales
EOF

service smb reload
mkdir /var/public_share
cat >>/etc/samba/smb.conf<<'END'
[share]
        path = /var/public_share
        browseable = yes
        public = yes
END

service smb reload
testparm
#====================================================
lsblk
fdisk /dev/vdb
fdisk /dev/vdc
fdisk /dev/vdd
#Command (m for help): n
#Command action
#   e   extended
#   p   primary partition (1-4)
#p
#Partition number (1-4): 1
#First cylinder (1-522, default 1):
#Using default value 1
#Last cylinder, +cylinders or +size{K,M,G} (1-522, default 522): +2G
#
#Command (m for help): t
#Selected partition 1
#Hex code (type L to list codes): fd
#Changed system type of partition 1 to fd (Linux raid autodetect)
#
#Command (m for help): n
#Command action
#   e   extended
#   p   primary partition (1-4)
#p
#Partition number (1-4): 2
#First cylinder (263-522, default 263):
#Using default value 263
#Last cylinder, +cylinders or +size{K,M,G} (263-522, default 522):
#Using default value 522
#
#Command (m for help): t
#Partition number (1-4): 2
#Hex code (type L to list codes): fd
#Changed system type of partition 2 to fd (Linux raid autodetect)
#
#Command (m for help): p
#   Device Boot      Start         End      Blocks   Id  System
#/dev/sdd1               1         262     2104483+  fd  Linux raid autodetect
#/dev/sdd2             263         522     2088450   fd  Linux raid autodetect
#
#Command (m for help): w

#yum -y install mdadm

mdadm --create /dev/md10 --level=10 --raid-devices=4 /dev/vd{b1,c1,d1,d2}
watch -n1 cat /proc/mdstat

mdadm -E /dev/vd{b1,c1,d1,d2}

fdisk /dev/md10
mkswap /dev/md10p1
swapon /dev/md10p1
echo "/dev/md10p1 swap swap defaults 0 0" >>/etc/fstab
echo "swapon /dev/md10p1" >>/etc/rc.local
chmod +x /etc/rc.d/rc.local
mdadm --detail --scan --verbose >> /etc/mdadm.conf
reboot

---------------------------------------------------------------------------------------
#Centos-C4
sed -i "s/HOSTNAME=.*/HOSTNAME=Centos-C4/g" /etc/sysconfig/network
echo "192.168.30.103 Centos-C4" >>/etc/hosts
hostname Centos-C4
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
setenforce 0
iptables -F
iptables -X
service iptables save
mkdir /media/cdrom
rm -rf /etc/yum.repos.d/*
cat >>/etc/yum.repos.d/opt.repo<<'EOF'
[opt]
name=cdrom
baseurl=file:///media/cdrom
gpgcheck=0
enabled=1
EOF

echo "/opt/CentOS-6.5.iso /media/cdrom iso9660 defaults,ro,loop 0 0" >>/etc/fstab
mount -a
yum clean all
yum list all|wc -l
sed -i "s/DNS1=114.114.114.114/DNS1=192.168.10.103/g" /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart
echo "nameserver 192.168.10.103" >/etc/resolv.conf

yum -y install telnet
telnet 192.168.10.103
#cta3-test

yum install -y mysql mysql-server mysql-devel
service mysqld start
/usr/bin/mysqladmin -u root password '687145'
chkconfig mysqld on
mysql -uroot -p687145
create database myDB;
use myDB;
create table baseinfo (studentID varchar(10) primary key,name varchar(10) not null,sex char(1) default 'M',birthday date,school char(20));
insert into baseinfo values(1,'w',1,'2009-06-08','skills'),(2,'h',1,'2009-06-08','skills'),(3,'s',1,'2009-06-08','skills'),(4,'d',1,'2009-06-08','skills'),(5,'j',1,'2009-06-08','skills');
desc baseinfo;
exit

#mysqldump -uroot -p687145 -hlocalhost 库名 表名 >/root/mysql.sql
mysqldump -uroot -p687145 -hlocalhost myDB baseinfo >/root/mysql.sql
cat /root/mysql.sql

#===================================================================
lsblk
fdisk /dev/vdb
fdisk /dev/vdc
#yum -y install mdadm
mdadm --create /dev/md5 --level=5 --raid-devices=3 /dev/vd{b1,c1,c2}
watch -n1 cat /proc/mdstat

mdadm --detail /dev/md5
mdadm --detail --scan --verbose >> /etc/mdadm.conf
reboot
```

