---
title: "shell脚本示例"
date: 2018-10-27T16:15:57+08:00
description: ""
draft: false
tags: ["shell"]
categories: ["Linux运维"]
---

<!--more-->

使用for循环在/wenhs目录下通过随机10个字符加固定字符串wenhs批量创建10个html文件，结果类似qnvuxvicni_wenhs.html

```
#!/bin/bash
dir=/wenhs/
for ((i=1;i<=10;i++));do
	filename=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 10 |xargs)_wenhs.html
	if [ -d $dir ];then
		cd $dir && touch $filename
	else
	mkdir $dir && cd $dir && touch $filename
	fi
done

效果:
[root@wenhs5479 ~]# ls /wenhs/
7Ocr2n4FNh_wenhs.html  eWOxCCySgE_wenhs.html  wzmqqJ8vS8_wenhs.html
BFRXrBMn6N_wenhs.html  NEAof8Y8dN_wenhs.html  xLEbyL6ZDs_wenhs.html
E2VgHE1rwc_wenhs.html  Ulq9EZSxLX_wenhs.html
EcFzJip34y_wenhs.html  UMbdC4pusC_wenhs.html

```

将以上文件名中的wenhs全部改成weixinghao(用for循环实现),并且html改成大写

```
#!/bin/bash
dir=/wenhs
file=$(ls $dir)
for i in $file;do
	j=$(echo $i|cut -c 1-10)
	mv $dir/$j* $dir/${j}_weixinghao.HTML
done

效果:
[root@wenhs5479 ~]# ls /wenhs/
7Ocr2n4FNh_weixinghao.HTML  eWOxCCySgE_weixinghao.HTML  wzmqqJ8vS8_weixinghao.HTML
BFRXrBMn6N_weixinghao.HTML  NEAof8Y8dN_weixinghao.HTML  xLEbyL6ZDs_weixinghao.HTML
E2VgHE1rwc_weixinghao.HTML  Ulq9EZSxLX_weixinghao.HTML
EcFzJip34y_weixinghao.HTML  UMbdC4pusC_weixinghao.HTML
```

批量创建10个系统帐号wenhs01-wenhs10并设置密码（密码为随机8位字符串）

```
#!/bin/bash
for i in $(seq -w 10);do
useradd -r wenhs$i
echo "password$i" | md5sum |cut -c-8 | tee -a passwd.txt | passwd --stdin wenhs$i &>/dev/null
done
```

写一个脚本，实现判断实验主机当前网段中当前在线的IP有哪些

```
#!/bin/bash
subnet=192.168.42.0/24
netaddr=`echo $subnet|cut -d. -f1-3`
for i in {1..254};do
{
ping -c 1 -t 1 $netaddr.$i > /dev/null
if [ $? == 0 ];then
 echo $netaddr.$i
fi
} &
done
wait

效果:
[root@wenhs5479 ~]# bash nmap
192.168.42.129
192.168.42.87
192.168.42.81

```

打印My WeChat is wenhs5479, welcome to discuss together.中字母长度不大于6的单词

```
#!/bin/bash
len=6
words='My WeChat is wenhs5479, welcome to discuss together.'
for word in ${words[@]};do
l=$(echo $word|wc -c)
if [ $l -gt $len ];then echo $word;fi
done

效果:
[root@wenhs5479 ~]# bash print.sh
WeChat
wenhs5479,
welcome
discuss
together.
```

实现以脚本传参的方式比较2个整数大小，以屏幕输出的方式提醒用户比较结果

```
#!/bin/bash
max=$1
min=$2
[ $# -lt 2 ] && echo "请至少输入2个数字: " && exit
for i in $*;do
	echo "$i" |egrep '^[0-9]+$' &> /dev/null
	[ $? -ne 0 ] && echo "请输入2个整数,不是字母或特殊字符" && exit
	[ $max -le $i ] && max=$i
	[ $min -ge $i ] && min=$i
done
echo "$max > $min"

效果:
[root@wenhs5479 ~]# bash wenhs.sh 13123 53453
53453 > 13123
```

实现以read读入的方式比较2个整数大小，以屏幕输出的方式提醒用户比较结果

```
#!/bin/bash
flag=true
while $flag;do
    read -p "请输入一个数字：" A
    echo $A |egrep '^[0-9]+$' &>/dev/null
    if [ $? -ne 0 ];then
        echo "请输入一个整数"
        continue
	else
		while $flag;do
			read -p "请输入一个数字：" B
			echo $B |egrep '^[0-9]+$' &>/dev/null
			if [ $? -ne 0 ];then
				echo "请输入一个整数"
				continue
			else
				flag=false
			fi
		done
	fi
done
if [ $A -gt $B ];then
	echo "$A > $B"
elif [ $A -eq $B ];then
	echo "$A = $B"
else
	echo "$A < $B"
fi

效果:
[root@wenhs5479 ~]# bash wenhs.sh
请输入一个数字：a
请输入一个整数
请输入一个数字：b
请输入一个整数
请输入一个数字：123
请输入一个数字：321
123 < 321
[root@wenhs5479 ~]# bash wenhs.sh
请输入一个数字：123  
请输入一个数字：123
123 = 123
[root@wenhs5479 ~]# bash wenhs.sh
请输入一个数字：321
请输入一个数字：123
321 > 123
[root@wenhs5479 ~]# 
```