---
title: "SaltStack之salt-ssh"
date: 2019-03-24T16:15:57+08:00
description: ""
draft: false
tags: ["自动化"]
categories: ["Linux运维"]
---

<!--more-->



## 1. salt-ssh介绍

`salt-ssh`可以让我们不需要在受控机上安装`salt-minion`客户端也能够实现管理操作。

### 1.1 salt-ssh的特点

 - 远程系统需要Python支持，除非使用-r选项发送原始ssh命令
 - salt-ssh是一个软件包，需安装之后才能使用，命令本身也是salt-ssh
 - salt-ssh不会取代标准的Salt通信系统，它只是提供了一个基于SSH的替代方案，不需要ZeroMQ和agent

**请注意，由于所有与Salt SSH的通信都是通过SSH执行的，因此它比使用ZeroMQ的标准Salt慢得多**

### 1.2 salt-ssh远程管理的方式

`salt-ssh`有两种方式实现远程管理，一种是在配置文件中记录所有客户端的信息，诸如 IP 地址、端口号、用户名、密码以及是否支持sudo等；另一种是使用密钥实现远程管理，不需要输入密码。

## 2. salt-ssh管理

**在 master 上安装 salt-ssh**

```
[root@master ~]# yum -y install salt-ssh
```

### 2.1 通过使用用户名密码的SSH实现远程管理

**修改配置文件，添加受控机信息**

```
[root@master ~]# vim /etc/salt/roster
....此处省略N行(注意使用yaml语法)
192.168.153.141:
  host: 192.168.153.141
  user: root
  passwd: 123
192.168.153.142:
  host: 192.168.153.142
  user: root
  passwd: 123
```

**测试连通性**

```
[root@master ~]# salt-ssh '*' test.ping
192.168.153.141:
    ----------
    retcode:
        254
    stderr:
    stdout:
        The host key needs to be accepted, to auto accept run salt-ssh with the -i flag:
        The authenticity of host '192.168.153.141 (192.168.153.141)' can't be established.
        ECDSA key fingerprint is SHA256:b0/t2BuTLEoyTzb+/CzG2GUdF5rExymafaf/NoqvCaQ.
        ECDSA key fingerprint is MD5:83:e3:1a:26:4e:6f:29:8f:a4:e1:98:91:da:c5:4a:33.
        Are you sure you want to continue connecting (yes/no)?
```

从上面的信息可以看出，第一次访问时需要输入 yes/no ，但是 saltstack 是不支持交互式操作的，所以为了解决这个问题，我们需要对其进行设置，让系统不进行主机验证。

```
[root@master ~]# vim ~/.ssh/config
StrictHostKeyChecking no

[root@master ~]# salt-ssh '*' test.ping
192.168.153.141:
    True
192.168.153.142:
    True
```

### 2.2 通过salt-ssh初始化系统安装salt-minion

**安装 salt-ssh**

```
[root@master ~]# yum -y install salt-ssh
```

**修改roster配置文件，添加受控主机**

```
[root@master ~]# vim /etc/salt/roster
....此处省略N行
192.168.153.148:
  host: 192.168.153.148
  user: root
  passwd: 123
```

**测试连通性**

```
[root@master ~]# salt-ssh '*' test.ping
192.168.153.148:
    True
192.168.153.141:
    True
192.168.153.142:
    True
```

**执行状态命令，初始化系统，安装salt-minion**

```
[root@master ~]# mkdir -p /srv/salt/base/{repo,files}
[root@master ~]# \cp /etc/yum.repos.d/salt-latest.repo /srv/salt/base/repo/salt-latest.repo
[root@master ~]# \cp /etc/pki/rpm-gpg/saltstack-signing-key /srv/salt/base/repo/saltstack-signing-key
[root@master ~]# cp /etc/salt/minion /srv/salt/base/files/
[root@master ~]# vim /srv/salt/base/files/minion
master: 192.168.153.136               //已经有了,无需更改(没有则要更改)
id: {{id}}                    //这个要改成这样,否则minion端无法取到id值
[root@master ~]# vim /srv/salt/base/files/minion_id
{{id}}             //直接写成这样

[root@master ~]# vim /srv/salt/base/repo.sls
salt-repo:
  file.managed:
    - name: /etc/yum.repos.d/salt-latest.repo
    - source: salt://repo/salt-latest.repo
    - user: root
    - group: root
    - mode: 644

salt-repo-key:
  file.managed:
    - name: /etc/pki/rpm-gpg/saltstack-signing-key
    - source: salt://repo/saltstack-signing-key
    - user: root
    - group: root
    - mode: 644

[root@master ~]# vim /srv/salt/base/minion.sls
salt-minion-install:
  pkg.installed:
    - name: salt-minion

salt-minion-id:
  file.managed:
    - name: /etc/salt/minion_id
    - source: salt://files/minion_id
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - id: {{ grains['id'] }}

salt-minion-conf:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://files/minion
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      id: {{ grains['id'] }}
    - require:
      - pkg: salt-minion-install

salt-minion-service:
  service.running:
    - name: salt-minion
    - enable: True
    - start: True
    - watch:
       - file: /etc/salt/minion


[root@master ~]# salt-ssh '192.168.153.148' state.sls repo
192.168.153.148:
----------
          ID: salt-repo
    Function: file.managed
        Name: /etc/yum.repos.d/salt-latest.repo
      Result: True
     Comment: File /etc/yum.repos.d/salt-latest.repo updated
     Started: 20:43:34.094961
    Duration: 84.342 ms
     Changes:   
              ----------
              diff:
                  New file
              mode:
                  0644
----------
          ID: salt-repo-key
    Function: file.managed
        Name: /etc/pki/rpm-gpg/saltstack-signing-key
      Result: True
     Comment: File /etc/pki/rpm-gpg/saltstack-signing-key updated
     Started: 20:43:34.179432
    Duration: 3.606 ms
     Changes:   
              ----------
              diff:
                  New file
              mode:
                  0644

Summary for 192.168.153.148
------------
Succeeded: 2 (changed=2)
Failed:    0
------------
Total states run:     2
Total run time:  87.948 ms

[root@master ~]# salt-ssh '192.168.153.148' state.sls minion
192.168.153.148:
----------
          ID: salt-minion-install
    Function: pkg.installed
        Name: salt-minion
      Result: True
     Comment: The following packages were installed/updated: salt-minion
     Started: 20:49:22.601189
    Duration: 29013.111 ms
     Changes:   
              ----------
              PyYAML:
                  ----------
                  new:
                      3.11-1.el7
                  old:
              gpg-pubkey.(none):
                  ----------
                  new:
                      352c64e5-52ae6884,de57bfbe-53a9be98,f4a80eb5-53a7ff4b
                  old:
                      f4a80eb5-53a7ff4b
              libsodium:
                  ----------
                  new:
                      1.0.18-1.el7
                  old:
              libtomcrypt:
                  ----------
                  new:
                      1.17-26.el7
                  old:
              libtommath:
                  ----------
                  new:
                      0.42.0-6.el7
                  old:
              libyaml:
                  ----------
                  new:
                      0.1.4-11.el7_0
                  old:
              openpgm:
                  ----------
                  new:
                      5.2.122-2.el7
                  old:
              python-babel:
                  ----------
                  new:
                      0.9.6-8.el7
                  old:
              python-backports:
                  ----------
                  new:
                      1.0-8.el7
                  old:
              python-backports-ssl_match_hostname:
                  ----------
                  new:
                      3.5.0.1-1.el7
                  old:
              python-chardet:
                  ----------
                  new:
                      2.2.1-1.el7_1
                  old:
              python-ipaddress:
                  ----------
                  new:
                      1.0.16-2.el7
                  old:
              python-jinja2:
                  ----------
                  new:
                      2.7.2-3.el7_6
                  old:
              python-kitchen:
                  ----------
                  new:
                      1.1.1-5.el7
                  old:
              python-markupsafe:
                  ----------
                  new:
                      0.11-10.el7
                  old:
              python-requests:
                  ----------
                  new:
                      2.6.0-1.el7_1
                  old:
              python-tornado:
                  ----------
                  new:
                      4.2.1-4.el7
                  old:
              python-urllib3:
                  ----------
                  new:
                      1.10.2-5.el7
                  old:
              python-zmq:
                  ----------
                  new:
                      15.3.0-3.el7
                  old:
              python2-crypto:
                  ----------
                  new:
                      2.6.1-16.el7
                  old:
              python2-msgpack:
                  ----------
                  new:
                      0.5.6-5.el7
                  old:
              python2-psutil:
                  ----------
                  new:
                      2.2.1-5.el7
                  old:
              salt:
                  ----------
                  new:
                      2019.2.0-1.el7
                  old:
              salt-minion:
                  ----------
                  new:
                      2019.2.0-1.el7
                  old:
              yum-utils:
                  ----------
                  new:
                      1.1.31-50.el7
                  old:
              zeromq:
                  ----------
                  new:
                      4.1.4-7.el7
                  old:
----------
          ID: salt-minion-id
    Function: file.managed
        Name: /etc/salt/minion_id
      Result: True
     Comment: File /etc/salt/minion_id updated
     Started: 20:49:51.621572
    Duration: 48.089 ms
     Changes:   
              ----------
              diff:
                  New file
              mode:
                  0644
----------
          ID: salt-minion-conf
    Function: file.managed
        Name: /etc/salt/minion
      Result: True
     Comment: File /etc/salt/minion updated
     Started: 20:49:51.669988
    Duration: 38.132 ms
     Changes:   
              ----------
              diff:
                  --- 
                  +++ 
                  @@ -14,6 +14,7 @@
                   # Set the location of the salt master server. If the master server cannot be
                   # resolved, then the minion will fail to start.
                   #master: salt
                  +master: 192.168.153.136
                   
                   # Set http proxy information for the minion when doing requests
                   #proxy_host:
                  @@ -109,7 +110,7 @@
                   # Since salt uses detached ids it is possible to run multiple minions on the
                   # same machine but with different ids, this can be useful for salt compute
                   # clusters.
                  -#id:
                  +id: 192.168.153.148 
                   
                   # Cache the minion id to a file when the minion's id is not statically defined
                   # in the minion config. Defaults to "True". This setting prevents potential
              mode:
                  0644
----------
          ID: salt-minion-service
    Function: service.running
        Name: salt-minion
      Result: True
     Comment: Service salt-minion has been enabled, and is running
     Started: 20:49:52.632802
    Duration: 396.886 ms
     Changes:   
              ----------
              salt-minion:
                  True

Summary for 192.168.153.148
------------
Succeeded: 4 (changed=4)
Failed:    0
------------
Total states run:     4
Total run time:  29.496 s

[root@master ~]# salt-ssh '192.168.153.148' cmd.run 'systemctl restart salt-minion'
192.168.153.148:
[root@master ~]# salt-key -L
Accepted Keys:
192.168.153.136
192.168.153.141
192.168.153.142
Denied Keys:
Unaccepted Keys:
192.168.153.148
master
Rejected Keys:

[root@master ~]# salt-key -ya 192.168.153.148
The following keys are going to be accepted:
Unaccepted Keys:
192.168.153.148
Key for minion 192.168.153.148 accepted.
[root@master ~]# salt-key -L
Accepted Keys:
192.168.153.136
192.168.153.141
192.168.153.142
192.168.153.148
Denied Keys:
Unaccepted Keys:
master
Rejected Keys:

验证(不加-ssh):
[root@master ~]# salt '192.168.153.148' state.sls minion
192.168.153.148:
----------
          ID: salt-minion-install
    Function: pkg.installed
        Name: salt-minion
      Result: True
     Comment: All specified packages are already installed
     Started: 20:55:26.634729
    Duration: 834.346 ms
     Changes:   
----------
          ID: salt-minion-id
    Function: file.managed
        Name: /etc/salt/minion_id
      Result: True
     Comment: File /etc/salt/minion_id is in the correct state
     Started: 20:55:27.471827
    Duration: 34.679 ms
     Changes:   
----------
          ID: salt-minion-conf
    Function: file.managed
        Name: /etc/salt/minion
      Result: True
     Comment: File /etc/salt/minion is in the correct state
     Started: 20:55:27.506853
    Duration: 25.315 ms
     Changes:   
----------
          ID: salt-minion-service
    Function: service.running
        Name: salt-minion
      Result: True
     Comment: Service salt-minion is already enabled, and is running
     Started: 20:55:27.533049
    Duration: 212.535 ms
     Changes:   
              ----------
              salt-minion:
                  True

Summary for 192.168.153.148
------------
Succeeded: 4 (changed=1)
Failed:    0
------------
Total states run:     4
Total run time:   1.107 s
```