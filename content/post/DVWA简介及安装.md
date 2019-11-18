---
title: "DVWA 简介及安装"
date: 2019-04-07T16:15:57+08:00
description: ""
draft: false
tags: ["dvwa"]
categories: ["网络安全"]
---

<!--more-->



# 4. DVWA 简介及安装

> 学习渗透测试，特别是 Web 渗透，最头疼的无疑就是寻找靶机环境，通常是不同的漏洞需要找不同的靶机源码，而不同的源码通常 Web 架构又不一样，所以要找到一套能够练习所有 Web 渗透技巧的靶机环境，经常需要搭建 N 个 Web站点，无疑大大提高了学习的入门门槛。

#### 4.1 DVWA 简介

　　DVWA（Damn Vulnerable Web Application）是一个用来进行安全脆弱性鉴定的PHP/MySQL Web 应用，旨在为安全专业人员测试自己的专业技能和工具提供合法的环境，帮助web开发者更好的理解web应用安全防范的过程。


　　DVWA 一共包含了十个攻击模块，分别是：Brute Force（暴力（破解））、Command Injection（命令行注入）、CSRF（跨站请求伪造）、- File Inclusion（文件包含）、File Upload（文件上传）、Insecure CAPTCHA （不安全的验证码）、SQL Injection（SQL注入）、SQL Injection（Blind）（SQL盲注）、XSS（Reflected）（反射型跨站脚本）、XSS（Stored）（存储型跨站脚本）。包含了 OWASP TOP10 的所有攻击漏洞的练习环境，一站式解决所有 Web 渗透的学习环境。

　　另外，DVWA 还可以手动调整靶机源码的安全级别，分别为 Low，Medium，High，Impossible，级别越高，安全防护越严格，渗透难度越大。一般 Low 级别基本没有做防护或者只是最简单的防护，很容易就能够渗透成功；而 Medium 会使用到一些非常粗糙的防护，需要使用者懂得如何去绕过防护措施；High 级别的防护则会大大提高防护级别，一般 High 级别的防护需要经验非常丰富才能成功渗透；最后 Impossible 基本是不可能渗透成功的，所以 Impossible 的源码一般可以被参考作为生产环境 Web 防护的最佳手段

## 　　　　

#### 4.2 DVWA 安装

[GitHub](https://github.com/ethicalhack3r/DVWA)

[官网](http://www.dvwa.co.uk/)

