---
title: "shell脚本基础"
date: 2018-10-20T16:15:57+08:00
description: ""
draft: false
tags: ["shell"]
categories: ["Linux运维"]
---

<!--more-->

# 1.变量

## 1.1 什么是变量？
变量即可以变化的量

## 1.2 变量名称注意事项

 - 只能包含字母、数字、下划线，并且不能以数字开头
 - 不应该跟系统中已有的环境变量重名，尽量不要全部使用大写，尽量不要用“_”下划线开头
 - 最好做到见名知义
 - 不能使用程序中的保留字，例如if、for等

## 1.3 变量类型

 - 字符型
 - 数值型
	 - [ ] 整型
	 - [ ] 浮点型
 - 布尔型

## 1.4 变量操作

 - 设置变量
 - 引用变量
 - 撤销变量

> 单引号与双引号的区别

## 1.5 bash变量类型

 - 环境变量
 - 本地变量（局部变量）
 - 位置变量
 - 特殊变量（bash内置的，用来保存某些特殊数据的变量，也称系统变量）

#### 1.5.1 本地变量

> VAR_NAME=VALUE     
> 本地变量，作用域为当前shell进程。对当前shell外的其它shell进程，包括当前shell的父shell、子shell进程均无效

> local VAR_NAME=VALUE    
> 局部变量，作用域为当前代码段，常用于函数

#### 1.5.2 环境变量

> export VAR_NAME=VALUE   
> 作用域为当前shell进程及其子进程

#### 1.5.3 位置变量

```
$1，$2，$3，....       //用来引用脚本的参数
    shift [num]         //位置变量使用完以后退出，后面的参数向前推进
```

#### 1.5.4 特殊变量

```
$#      //是传给脚本的参数个数
$0      //是脚本本身的名字
$!      //是shell最后运行的后台Process的PID
$@      //是传给脚本的所有参数的列表
$*      //是以一个单字符串显示所有向脚本传递的参数，与位置变量不同，参数可超过9个
$$      //是脚本运行的当前进程ID号
$?      //是显示上条命令的退出状态，0表示没有错误，其他表示有错误
```

#### 1.5.5 bash内建环境变量

> PATH
>
> SHELL
>
> UID
>
> HISTSIZE
>
> HOME
>
> PWD
>
> HISTFILE
>
> PS1

#### 1.5.6 只读变量（常量）

> readonly VAR_NAME=VALUE     
> 不能修改值，不能销毁，只能等shell进程终止时随之消亡

# 2. 脚本基础

## 2.1 什么是脚本？

**按实际需要，结合命令流程控制机制实现的源程序。说白点就是命令的堆砌。**

## 2.2 程序返回值

**程序执行以后有两类返回值：**

 - 程序执行的结果
 - 程序状态返回代码（0-255）
	 - [ ] 0：正确执行
	 - [ ] 1-255：错误执行，1、2、127系统预留，有特殊意义

## 2.3 脚本测试

bash如何测试脚本是否有错误？报错后如何排查？

```
bash -n scriptname      //检查脚本是否有语法错误
bash -x scriptname      //单步执行，检查脚本错在哪里
```

## 2.4 写脚本注意事项

 - 禁止将未成功执行过的代码直接写进脚本
 - 脚本中的命令一定要用绝对路径

## 2.5 shell算术运算

```
A=3
B=6

let C=$A+$B         //let 算术运算表达式

C=$[$A+$B]          //$[算术运算表达式]

C=$(($A+$B))         //$((算术运算表达式))

C=`expr $A + $B`    //expr 算术运算表达式，表达式中各操作数及运算符之间要有空隔，而且要使用命令引用
```

## 2.6 命令间的逻辑关系

```
逻辑与：&&
    第一个条件为假时，第二个条件不用再判断，最终结果已经有
    第一个条件为真时，第二个条件必须得判断
逻辑或：||
    前一个命令的结果为真时，第二个命令就不执行
    前一个命令的结果为假时，第二个命令必须执行
```

**示例:**

1.写一个脚本，要求如下：

 - 设定变量Fa的值为/etc/passwd
 - 依次向/etc/passwd中的每个用户问好，并且说出对方的ID是什么。结果输出如下：
	 - [ ] Hello,root，your UID is 0.
 - 统计当前系统一个有多少个用户并输出

```
cat >1.sh <<'EOF'
#!/bin/bash
Fa=/etc/passwd
number=`cat $Fa | wc -l`
#下面是一个管道，下面循环读文件中的每一行
cat $Fa |
while read line
do
    user=`echo $line|awk -F ':' '{print $1}'`
    #代表以 ：分段$1就是取第1段
    uid=`echo $line|awk -F ':' '{print $3}'`
    echo "Hello, $user, Your UID is $uid"
done
echo ""
#前面求得的用户数
echo "====Number of users:$number===="
echo ""
EOF
```

2.写一个脚本，传递两个整数给此脚本，让脚本分别计算并显示这两个整数的和，差，积，商

```
cat >2.sh <<'EOF'
#!/bin/bash
read -p "请输入第一个数字:" a
read -p "请输入第二个数字:" b
echo "$a+$b="$[a+b]
echo "$a-$b="$[a-b]
echo "$a×$b="$[a*b]
echo "$a÷$b=$(printf "%.2f" $(echo "scale=2;$a/$b"|bc))"
EOF
```
3.写一个脚本，要求如下：

 - 创建目录/tmp/scripts
 - 切换至此目录中
 - 复制/etc/pam.d目录至当前目录，并重命名为test
 - 将当前目录的test及其里面的文件和子目录的属主改为redhat
 - 将test及其子目录中的文件的其它用户的权限改为没有任何权限

```
cat >3.sh <<'EOF'
#!/bin/bash
rm -f /tmp/scripts/test/* || echo "正常报错,不影响脚本执行"
rmdir /tmp/scripts/test || echo "正常报错,不影响脚本执行"
userdel -r redhat || echo "正常报错,不影响脚本执行"
rmdir /tmp/scripts/ || echo "正常报错,不影响脚本执行"
mkdir /tmp/scripts
cd /tmp/scripts/
cp -r /etc/pam.d ./test
useradd redhat
chown -R redhat ./test
chmod -R o=--- ./test
cd ~
EOF
```

4.写一个脚本，要求如下：

 - 显示当前系统日期和时间，而后创建目录/tmp/lstest
 - 切换工作目录至/tmp/lstest
 - 创建目录a1d，b56e，6test
 - 创建空文件xy，x2y，732
 - 列出当前目录下以a，x或者6开头的文件或目录
 - 列出当前目录下以字母开头，后跟一个任意数字，而后跟任意长度字符的文件或目录

```
cat >4.sh <<'EOF'
#!/bin/bash
date
rm -rf /tmp/lstest || echo "正常报错,不影响脚本执行"
mkdir /tmp/lstest
cd /tmp/lstest/
mkdir -p a1d b56e 6test
touch xy x2y 732
echo "======"
find a* x* 6*
echo "======"
ls |egrep -i "^[a-z][0-9]"
cd ~
EOF
```