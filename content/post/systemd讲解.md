---
title: "systemd讲解"
date: 2018-06-17T16:15:57+08:00
description: ""
draft: false
tags: ["控制服务"]
categories: ["Linux运维"]
---

<!--more-->

# 1. systemd

#### 1.1 systemd简介

`systemd`是用户空间的第一个应用程序，即`/sbin/init`

**init程序的类型：**

 - SysV风格：init（centos5），实现系统初始化时，随后的初始化操作都是借助于脚本来实现的
	 - [ ] 特点：
		 - 脚本中含有大量的命令，每个命令都要启动一个进程，命令执行完以后就要终止这个进程。如此一来，系统初始化时将大量的创建进程，销毁进程，工作效率会非常低
		 - 服务间可能会存在依赖关系，必须严格按照一定的顺序来启动服务，前一个服务没启动完后面的服务就无法执行启动过程。不能并行进行
		- [ ] 配置文件：/etc/inittab
 - Upstart风格：init（centos6），由ubuntu研发的，通过总线形式以接近于并行的方式工作，效率比SysV高
	 - [ ] 特点：
			- 基于总线方式能够让进程间互相通信的一个应用程序
			- 不用等服务启动完成，只要一初始化就可以把自己的状态返回给其他进程
	 - [ ] 配置文件：/etc/inittab，/etc/init/*.conf
 - Systemd风格：systemd（centos7）
	 - [ ] 特点：启动速度比SysV和Upstart都快
		 - 不需要通过任何脚本来启动服务，systemd自身就可以启动服务，其本身就是一个强大的解释器，启动服务时不需要sh/bash的参与
			 - systemd不真正在系统初始化时去启动任何一个服务
			 - 只要服务没用到，它告诉你启动了，实际上并没有启动。仅当第一次去访问时才会真正启动服务
	 - [ ] 配置文件：/usr/lib/systemd/system，/etc/systemd/system

系统启动和服务器进程由`systemd`系统和服务管理器进行管理。此程序提供了一种方式，可以在启动时和运行中的系统上激活系统资源、服务器守护进程和其他进程。

守护进程是在执行各种任务的后台等待或运行的进程。为了侦听连接，守护进程使用套接字。套接字可以由守护进程创建，或者与守护进程分离，并且可能由另一个进程创建（如systemd），随后在客户端建立连接时将套接字传递到守护进程。

服务通常指的是一个或多个守护进程，但启动或停止一项服务可能会对系统的状态进行一次性更改（如配置网络接口），不会留下守护进程之后继续运行。

#### 1.2 systemd的新特性

 - 系统引导时实现服务并行启动
 - 按需激活进程
 - 系统状态快照
 - 基于依赖关系定义服务控制逻辑

#### 1.3 systemd的核心概念Unit

**`systemd`使用`unit`的概念来管理服务，这些`unit`表现为一个个配置文件。
`systemd`通过对这些配置文件进行标识和配置达到管理服务的目的：**

>这些unit文件中主要包含了系统服务、监听socket、保存的系统快照 //及其它与init相关的信息保存至以下目录：
>
>`/usr/lib/systemd/system`
>
>`/run/systemd/system`
>
>`/etc/systemd/system`

**Unit的类型：**

>`Service unit`    //文件扩展名为.service，用于定义系统服务 
>
>`Target unit`   //文件扩展名为.target，用于模拟实现“运行级别”
>
>`runlevel0.target和poweroff.target`       //关机
>
>`runlevel1.target和rescue.target`         //单用户模式
>
>`runlevel2.target和multi-user.target`     //对于systemd来说，2/3/4级别没有区别
>
>`runlevel3.target和multi-user.target`     //对于systemd来说，2/3/4级别没有区别
>
>`runlevel4.target和multi-user.target`   //对于systemd来说，2/3/4级别没有区别
>
>`runlevel5.target和graphical.target`     //图形级别
>
>`runlevel6.target和reboot.target`          //重启 
>
>`Device unit`    //文件扩展名为.device，用于定义内核识别的设备 
>
>`Mount unit`    //文件扩展名为.mount，用于定义文件系统挂载点
>
>`Socket unit`   //文件扩展名为.socket，用于标识进程间通信用的socket文件
>
>`Snapshot unit` //文件扩展名为.snapshot，用于管理系统快照 
>
>`Swap unit`     //文件扩展名为.swap，用于标识swap设备
>
>`Automount unit` //文件扩展名为.automount，用于实现文件系统的自动挂载点 
>
>`Path unit`    //文件扩展名为.path，用于定义文件系统中的一个文件或目录

**Unit关键特性**

>`基于socket的激活机制：`

> socket与服务程序分离，当有人去访问时才会真正启动服务，以此来实现按需激活进程与服务的并行启动 

>`基于bus的激活机制：`

>所有使用dbus实现进程间通信的服务，可以在第一次被访问时按需激活 

>`基于device的激活机制：`

>支持基于device激活的系统服务，可以在特定类型的硬件接入到系统中时，按需激活其所需要用到的服务

>`基于path的激活机制：`

>某个文件路径变得可用，或里面出现新文件时就激活某服务 

>`系统快照：`

>保存各unit的当前状态信息于持久存储设备中，必要时能自动载入 

>`向后兼容sysv init脚本`

**不兼容特性**

>systemctl命令固定不变 
>
>非由systemd启动的服务，systemctl无法与之通信
>
>只有已经启动的服务在级别切换时才会执行stop，在centos6以前是所有S开头的服务全部start，所有K开头的服务全部stop
>
>系统服务不会读取任何来自标准输入的数据流 //每个服务的unit操作均受5分钟超时时间限制

# 2. 使用systemctl管理服务

>语法：`systemctl COMMAND name[.service｜.target] `
>
>常用COMMAND：
>
>`start name.service`     //启动服务
>
>`stop name.service`      //停止服务
>
>`restart name.service`    //重启服务
>
>`status name.service`    //查看服务状态
>
>`try-restart name.service`          //条件式重启服务，若服务已经启动则重启，若服务未启动则不做任何操作
>
>`reload-or-restart name.service`      //重载或重启服务，能reload则reload，否则restart
>
>`reload-or-try-restart name.service`  //重载或条件式重启服务，能reload则reload，否则try-restart
>
>`mask name.service `      //禁止设定为开机自启
>
>`unmask name.service`     //取消禁止设定为开机自启
>
>`list-dependencies name.service`      //查看服务的依赖关系
>
>`is-active name.service`      //查看某服务当前激活与否的状态
>
>`is-enable name.service`      //查看服务是否开机自动启动
>
>`enable name.service`     //设定某服务开机自动启动
>
>`disable name.service`   //禁止服务开机自动启动
>
>`isolate name.target`     //切换至某级别，如systemctl isolate graphical.target就是切换至图形界面
>
>`list-unit-files --type service`      //查看所有服务的开机自动启动状态（是否开机自启）
>
>`list-units --type service `        //查看所有已经激活的服务状态信息
>
>`list-units --type target`           //查看所有已装载的级别
>
>`list-units --type service --all`   //查看所有服务（已启动/已停止）的状态信息
>
>`list -units --type target --all`    //查看所有的级别
>
>`get-default`   //查看默认运行级别
>
>`set-default name.target`   //设置默认运行级别
>
>`rescue`     //切换至紧急救援模式（大多数服务不启动，但是会加载驱动）
>
>`emergency`  //切换至emergency模式（驱动不会加载，系统不会初始化，服务不会启动）
>
>`halt`    //关机
>
>`poweroff`   //关机
>
>`reboot`     //重启
>
>`suspend`    //挂起系统，此时不能关机，否则无用
>
>`hibernate`   //创建并保存系统快照，下次系统重启时会自动载入快照
>
>`hybrid-sleep `   //混合睡眠，快照并挂起

