---
title: "shell脚本进阶"
date: 2018-10-21T16:15:57+08:00
description: ""
draft: false
tags: ["shell"]
categories: ["Linux运维"]
---

<!--more-->

# 1. bash条件判断

## 1.1 条件测试类型

 - 整数测试
 - 字符测试
 - 文件测试 

## 1.2 条件测试的表达式

> [ expression ] 
> 
> [[ expression ]] 
> 
> test expression

## 1.3 整数测试（双目）

```
-eq      测试两个整数是否相等
-ne      测试两个整数是否不等
-gt      测试一个数是否大于另一个数
-lt      测试一个数是否小于另一个数
-ge      大于或等于
-le      小于或等于
```

## 1.4 字符测试

```
==       等值比较，检查==两边的内容是否一致，==两边都要有空格
!=       检查两边内容是否不一致，不一致为真，一致为假
=~       左侧字符串是否能够被右侧的PATTERN所匹配到。此表达式应用于双中括号[[]]中
-z "string"      测试指定字符串是否为空，空则为真，不空则为假
-n "string"      测试指定字符串是否不空，不空则为真，空则为假
```

## 1.5 文件测试

```
存在性测试：
    -e       测试文件是否存在
 存在性及类别测试：
    -b       测试文件是否为块设备文件
    -c       测试文件是否为字符设备文件
    -f       测试文件是否为普通文件
    -d       测试指定路径是否为目录
    -h       测试文件是否为符号链接文件
    -L       测试文件是否为符号链接文件
    -p       测试文件是否为命名管道文件
    -S       测试文件是否为套接字文件
 文件权限测试：
    -r       测试当前用户对指定文件是否有读权限
    -w       测试当前用户对指定文件是否有写权限
    -x       测试当前用户对指定文件是否有执行权限
 文件特殊权限测试：
    -g       测试文件是否有sgid权限
    -u       测试文件是否有suid权限
    -k       测试文件是否有sticky权限
 文件大小测试：
    -s       测试文件是否非空
 文件是否打开测试：
    -t fd    fd表示的文件描述符是否已经打开且与某终端相关
 双目测试：
    file1 -ef file2      测试file1与file2是否指向同一个设备上的相同inode，说白点就是两者是不是同一个文件
    file1 -nt file2      测试file1是否比file2新
    file1 -ot file2      测试file1是否比file2旧
 无分类：
    -N       测试文件自从上一次被读取之后是否被修改过
    -O       测试文件是否存在并且被当前用户拥有
    -G       测试文件是否存在并且默认组是否为当前用户组
```

## 1.6 组合测试条件

```
-a       与关系
-o       或关系
!        非关系

[ $# -gt 1 -a $# -le 3 ]
[ $# -gt 1 ] && [ $# -le 3 ]
```

## 1.7 条件判断，控制结构

#### 1.7.1 单分支if语句

```
if 判断条件; then
    statement1
    statement2
    ......
fi
```

#### 1.7.2 双分支if语句

```
if 判断条件; then
    statement1
    statement2
    ......
else
    statement3
    statement4
    ......
fi
```

#### 1.7.3 多分支if语句

```
if 判断条件1; then
    statement1
    statement2
    ......
elif 判断条件2; then
    statement3
    statement4
    ......
else
    statement5
    statement6
    ......
fi
```

# 2. 分支选择

```
case $变量名 in            
value1)                
    statement                
    ...                
    ;;            
value2)                
    statement                
    ...                
    ;;            
*)                
    statement                
    ...                
    ;;        
esac

case支持glob风格的通配符：
    *            任意长度任意字符
    ?            任意单个字符
    []           指字范围内的任意单个字符
    abc|bcd      abc或bcd
```

# 3. 循环语句

**循环语句通常需要有一个进入条件和一个退出条件。**

## 3.1 for循环

**for循环当列表不为空时进入循环，否则退出循环**

```
for 变量 in 列表; do
    循环体
done

for ((expr1;expr2;expr3))
{
    循环体
}

for (( expr1 ; expr2 ; expr3 ));do
    循环体
done

expr1    用于指定初始条件，给控制变量一个初始值
expr2    判定什么时候退出循环
expr3    修正expr1指定的变量的值

如何生成列表：
    {1..100}
    seq [起始数] [步进长度] 结束数
```

## 3.2 while循环

**while循环适用于循环次数未知的场景，注意要有退出条件。
条件满足时进入循环，条件不满足了退出循环。**

#### 3.2.1 while循环正常用法

```
while 条件; do
    statement
    ...
done
```

#### 3.2.2 while循环特殊用法

```
while循环特殊用法一：死循环
while :;do
    statement
    ...
done

这里的冒号可以改成true或者永远成立的条件,不能为false
所以,可以定义一个flag=false,让它终止循环

while循环特殊用法二：逐行读取某文件，将值存入line变量中
while read line;do
    statement
    ...
done < /path/to/somefile
```

## 3.3 until循环

**条件不满足时进入循环，条件满足了退出循环。**

```
until 条件; do
    statement
    ...
done
```

## 3.4 循环语句特殊情况

> 在循环语句中，有几种特别情况：
> 
> break [num]：提前退出循环。当循环语句中出现break时，将提前退出循环，不再执行循环后面的语句
> 
> continue [num]：提前结束本轮循环而进入下一轮循环。当循环语句执行到continue时，continue后面的语句将不再执行，提前进入下一轮循环

# 4. 定义脚本退出状态码

```
exit命令用于定义执行状态结果

exit #       此处的#号是一个数字，其范围可以是0-255

如果脚本没有明确定义退出状态码，那么，最后执行的一条命令的退出码即为脚本的退出状态码

注意：脚本中一旦遇到exit命令，脚本会立即终止
```

**示例:**

1.猜100以内数字

```
#!bin/bash
num=$[RANDOM%100]
read -p "Please enter a number: " user_num
until [ $user_num -eq $num ];do
        while [ $user_num -gt $num ];do
                echo "a bit big"
                read -p "Please enter a number: " user_num
        done
        while [ $user_num -lt $num ];do
                echo "a little bit small"
                read -p "Please enter a number: " user_num
        done
done
        echo "Congratulations, you got it"
```

2.让用户输入自己的年龄，计算他还能活多少年，假定每个人能活100岁。

```
#!bin/bash
AGEMIX=100
read -p "Please enter your age: " AGE
if [ $AGE -le $AGEMIX ];then
	echo "You can still live for $[$AGEMIX-$AGE] years."
else
	echo "Old monster, you should die $[$AGE-$AGEMIX] years ago"
fi
```

3.脚本后接入n个数字，输出最大值和最小值。

```
#!/bin/bash
max=$1
min=$2
[ $# -lt 2 ] && echo "请至少输入2个数字: " && exit
for i in $*;do
	echo "$i" |egrep '^[0-9]+$' &> /dev/null
	[ $? -ne 0 ] && echo "请输入数字,不是字母或特殊字符" && exit
	[ $max -le $i ] && max=$i
	[ $min -ge $i ] && min=$i
done
echo "The max number is "$max
echo "The min number is "$min
```

4,写一个登录接口,输入用户名和密码,认证成功后显示欢迎信息,输错3次后警告

```
#!/bin/bash
username=wenhs
passwd=jbgsn
for ((i=1;i>=1;i++));do
read -p "please enter your name: " user
read -p "please entsr your passwd: " pass
[ $i -gt 3 ]&& echo "Enter your account or password too many failures, account has been locked, please contact the administrator to unlock" && exit
if [ $user != $username ] ||[ $pass != $passwd ];then
	echo "You entered an account or password incorrectly. Please re-enter it."
	continue
else
	echo "Hellow $user , Welcome to home."
	break
fi
done
```