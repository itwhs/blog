---
title: "xtrabackup"
date: 2018-12-01T16:15:57+08:00
description: ""
draft: false
tags: ["sql"]
categories: ["Linux运维"]
---

<!--more-->

## xtrabackup的安装(centos/rhel系列)

[想要支持5.7版本的备份至少得2.4的，然后8.0的只支持mysql8](https://www.percona.com/doc/percona-xtrabackup/2.4/installation/yum_repo.html)

```
yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
yum -y list | grep percona
yum -y install percona-xtrabackup-24
```

**xtrabackup的特性：**

使用innobakupex备份时，其会调用xtrabackup备份所有的InnoDB表，复制所有关于表结构定义的相关文件(.frm)、以及MyISAM、MERGE、CSV和ARCHIVE表的相关文件，同时还会备份触发器和数据库配置信息相关的文件。这些文件会被保存至一个以时间命名的目录中,在备份时，innobackupex还会在备份目录中创建如下文件：

1. xtrabackup_checkpoints：备份类型（如完全或增量）、备份状态（如是否已经为prepared状态）和LSN(日志序列号)范围信息,每个InnoDB页(通常为16k大小)都会包含一个日志序列号，即LSN。LSN是整个数据库系统的系统版本号，每个页面相关的LSN能够表明此页面最近是如何发生改变的
2. xtrabackup_binlog_info：mysql服务器当前正在使用的二进制日志文件及至备份这一刻为止二进制日志事件的位置
3. xtrabackup_binlog_pos_innodb：二进制日志文件及用于InnoDB或XtraDB表的二进制日志文件的当position
4. xtrabackup_binary：备份中用到的xtrabackup的可执行文件
5. backup-my.cnf：备份命令用到的配置选项信息在使用innobackupex进行备份时，还可以使用--no-timestamp选项来阻止命令自动创建一个以时间命名的目录；innobackupex命令将会创建一个BACKUP-DIR目录来存储备份数据

### 该**xtrabackup2.4**选项参考

此页面记录了**xtrabackup**二进制文件的所有命令行选项 。

### 选项

--apply-log-only

此选项仅在准备备份时执行重做阶段。这对增量备份非常重要。

--backup

进行备份并将其放入。

请参阅 [创建备份](https://www.percona.com/doc/percona-xtrabackup/2.4/backup_scenarios/full_backup.html#creating-a-backup)。[`xtrabackup --target-dir`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-target-dir)

--binlog-info

此选项控制*Percona XtraBackup*应如何检索与备份对应的服务器二进制日志坐标。可能的值是 `OFF`，`ON`，`LOCKLESS`和`AUTO`。

有关 详细信息，请参阅*Percona XtraBackup无* [锁二进制日志信息](https://www.percona.com/doc/percona-xtrabackup/2.4/advanced/lockless_bin-log.html#lockless-bin-log)手册页。

--check-privileges

此选项检查*Percona XtraBackup*是否具有所有必需的权限。如果当前操作需要缺少权限，它将终止并打印出错误消息。如果当前操作不需要缺少权限，但某些其他XtraBackup操作可能需要该权限，则不会中止该过程并打印警告。`xtrabackup：错误：*。*上缺少必需的权限LOCK TABLES xtrabackup：警告：在*。*上缺少必需的权限复制客户端 `

--close-files

不要保持文件打开。当**xtrabackup**打开表空间时，它通常不会关闭其文件句柄以正确处理DDL操作。但是，如果表空间的数量非常大并且不能满足任何限制，则可以选择在不再访问文件句柄时关闭它们。*Percona XtraBackup*可以在启用此选项的情况下生成不一致的备份。使用风险由您自己承担。

--compact

通过跳过辅助索引页来创建压缩备份。

--compress

此选项告诉**xtrabackup**使用指定的压缩算法压缩所有输出数据，包括事务日志文件和元数据文件。目前唯一支持的算法是`quicklz`。生成的文件具有qpress存档格式，即`*.qp`xtrabackup生成的每个文件本质上都是一个文件的qpress存档，可以通过[qpress](http://www.quicklz.com/) 文件存档提取[和解](http://www.quicklz.com/)压缩。

--compress-chunk-size=#

压缩线程的工作缓冲区大小（以字节为单位）。默认值为64K。

--compress-threads=#

此选项指定**xtrabackup**用于并行数据压缩的工作线程数。此选项默认为`1`。并行压缩（：选项：`xtrabackup -compress-threads`）可以与并行文件复制（）一起使用。

例如， 将创建4个I / O线程，这些线程将读取数据并将其传递给2个压缩线程。[`xtrabackup --parallel`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-parallel)`--parallel=4 --compress --compress-threads=2`

--copy-back

将先前制作的备份中的所有文件从备份目录复制到其原始位置。除非指定了选项，否则此选项不会复制现有文件。[`xtrabackup --force-non-empty-directories`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-force-non-empty-directories)

--create-ib-logfile

此选项目前尚未实施。要创建InnoDB日志文件，您必须准备两次备份。

--databases=#

此选项指定应备份的数据库和表的列表。该选项接受表单列表。`"databasename1[.table_name1] databasename2[.table_name2] . . ."`

--databases-exclude=name

根据名称排除数据库，操作方式与备份相同，但匹配的名称将从备份中排除。请注意，此选项的优先级高于 。[`xtrabackup --databases`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-databases)[`xtrabackup --databases`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-databases)

--databases-file=#

此选项指定包含应备份的数据库和表列表的文件的路径。该文件可以包含表单的列表元素，`databasename1[.table_name1]`每行一个元素。

--datadir=DIRECTORY

备份的源目录。这应该与*MySQL*服务器的datadir相同，因此`my.cnf`如果存在则应该从中读取; 否则你必须在命令行上指定它。

--decompress

使用`.qp`以前使用该选项进行的备份中的扩展名解压缩所有文件。该 选项将允许同时解密多个文件。为了解压缩，必须在路径中安装和访问qpress实用程序。*Percona XtraBackup*不会自动删除压缩文件。为了清理备份目录，用户应该使用选项。[`xtrabackup --compress`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-compress)[`xtrabackup --parallel`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-parallel)[`xtrabackup --remove-original`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-remove-original)

--decrypt=ENCRYPTION-ALGORITHM

`.xbcrypt`在先前使用选项进行的备份中解密具有扩展名的所有文件。该 选项将允许同时解密多个文件。*Percona XtraBackup*不会自动删除加密文件。为了清理备份目录，用户应该使用选项。[`xtrabackup --encrypt`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-encrypt)[`xtrabackup --parallel`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-parallel)[`xtrabackup --remove-original`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-remove-original)`

--defaults-extra-file=[MY.CNF]

读取全局文件后读取此文件。必须作为命令行上的第一个选项。

--defaults-file=[MY.CNF]

仅读取给定文件中的默认选项。必须作为命令行上的第一个选项。必须是真实的文件; 它不能成为一种象征性的联系。

--defaults-group=GROUP-NAME

此选项用于设置应从配置文件中读取的组。如果您使用该选项，**innobackupex**将使用此 选项。部署需要它 。[`xtrabackup --defaults-group`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-defaults-group)`mysqld_multi`

--dump-innodb-buffer-pool

此选项控制是否应该执行缓冲池内容的新转储。使用`--dump-innodb-buffer-pool`，**xtrabackup** 向服务器发出请求以在**备份**开始时启动缓冲池转储（需要一些时间才能完成并在后台完成），前提是状态变量 `innodb_buffer_pool_dump_status`报告转储已完成。`$ xtrabackup --backup --dump-innodb-buffer-pool --target-dir = / home / user / backup `默认情况下，此选项设置为OFF。如果`innodb_buffer_pool_dump_status`报告存在正在运行的缓冲池转储，则**xtrabackup**将使用值等待转储完成[`--dump-innodb-buffer-pool-timeout`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-dump-innodb-buffer-pool-timeout)该文件`ib_buffer_pool`存储用于更快地预热缓冲池的表空间ID和页面ID数据。也可以看看*MySQL*文档：保存和恢复缓冲池状态<https://dev.mysql.com/doc/refman/5.7/en/innodb-preload-buffer-pool.html>

--dump-innodb-buffer-pool-timeout

此选项包含**xtrabackup**应监视其值`innodb_buffer_pool_dump_status`以确定缓冲池转储是否已完成的秒数。此选项与[`--dump-innodb-buffer-pool`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-dump-innodb-buffer-pool)。结合使用 。默认情况下，它设置为10 秒。

--dump-innodb-buffer-pool-pct

此选项包含要转储的最近使用的缓冲池页面的百分比。如果[`--dump-innodb-buffer-pool`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-dump-innodb-buffer-pool)选项设置为ON，则此选项有效。如果此选项包含值，则**xtrabackup会**设置*MySQL* 系统变量`innodb_buffer_pool_dump_pct`。缓冲池转储完成或停止（请参阅 [`--dump-innodb-buffer-pool-timeout`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-dump-innodb-buffer-pool-timeout)）后，将恢复*MySQL*系统变量的值。也可以看看更改缓冲池转储的超时[`--dump-innodb-buffer-pool-timeout`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-dump-innodb-buffer-pool-timeout)*MySQL*文档：innodb_buffer_pool_dump_pct系统变量<https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_buffer_pool_dump_pct>

--encrypt=ENCRYPTION_ALGORITHM

此选项指示xtrabackup使用ENCRYPTION_ALGORITHM中指定的算法加密InnoDB数据文件的备份副本。它直接传递给xtrabackup子进程。有关更多详细信息，请参阅 **xtrabackup** [文档](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xtrabackup_binary.html)。

--encrypt-key=ENCRYPTION_KEY

此选项指示xtrabackup `ENCRYPTION_KEY`在使用该选项时使用给定的。它直接传递给xtrabackup子进程。有关更多详细信息，请参阅**xtrabackup** [文档](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xtrabackup_binary.html)。[`xtrabackup --encrypt`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-encrypt)

--encrypt-key-file=ENCRYPTION_KEY_FILE

此选项指示xtrabackup `ENCRYPTION_KEY_FILE`在使用该 选项时使用存储在给定中的加密密钥。它直接传递给xtrabackup子进程。有关更多详细信息，请参阅 **xtrabackup** [文档](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xtrabackup_binary.html)。[`xtrabackup --encrypt`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-encrypt)

--encrypt-threads=#

此选项指定将用于并行加密/解密的工作线程数。有关更多详细信息，请参阅**xtrabackup** [文档](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xtrabackup_binary.html)。

--encrypt-chunk-size=#

此选项指定每个加密线程的内部工作缓冲区的大小（以字节为单位）。它直接传递给xtrabackup子进程。有关更多详细信息，请参阅**xtrabackup** [文档](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xtrabackup_binary.html)。

--export

创建导出表所需的文件。请参阅[恢复单个表](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/restoring_individual_tables.html)。

--extra-lsndir=DIRECTORY

（for -backup）：在此目录中保存`xtrabackup_checkpoints` 和`xtrabackup_info`文件的额外副本。

--force-non-empty-directories

如果指定，它会：选项`xtrabackup -copy-back`和 选项将文件传输到非空目录。不会覆盖现有文件。如果需要从备份目录中复制/移动的文件已存在于目标目录中，则它仍将失败并显示错误。[`xtrabackup --move-back`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-move-back)

--ftwrl-wait-timeout=SECONDS

此选项指定xtrabackup应等待在运行之前阻塞的查询的时间（以秒为单位）。如果超时到期时仍有此类查询，则xtrabackup将终止并显示错误。默认是，在这种情况下，它不会等待查询完成并 立即启动。如果支持（Percona Server 5.6+），则xtrabackup将自动使用[备份锁](https://www.percona.com/doc/percona-server/5.6/management/backup_locks.html#backup-locks) 作为复制非InnoDB数据的轻量级替代方法，以避免阻止修改InnoDB表的DML查询。`FLUSH TABLES WITH READ LOCK``0``FLUSH TABLESWITH READ LOCK``FLUSH TABLES WITH READ LOCK`

--ftwrl-wait-threshold=SECONDS

此选项指定查询运行时阈值，该阈值由xtrabackup用于检测具有非零值的长时间运行的查询 。 在存在长时间运行的查询之前不会启动。如果是，则此选项无效。默认值为秒。如果支持（Percona Server 5.6+），则xtrabackup将自动使用[备份锁](https://www.percona.com/doc/percona-server/5.6/management/backup_locks.html#backup-locks) 作为复制非InnoDB数据的轻量级替代方法，以避免阻止修改InnoDB表的DML查询。[`xtrabackup --ftwrl-wait-timeout`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-ftwrl-wait-timeout)`FLUSH TABLES WITH READLOCK`[`xtrabackup --ftwrl-wait-timeout`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-ftwrl-wait-timeout)`0``60``FLUSH TABLES WITH READ LOCK`

--ftwrl-wait-query-type=all|update

此选项指定在xtrabackup发出全局锁之前允许完成哪些类型的查询。默认是`all`。

--galera-info

此选项创建`xtrabackup_galera_info`包含备份时本地节点状态的文件。在执行*Percona XtraDB Cluster*的备份时应使用选项。使用备份锁创建备份时，它不起作用。

--incremental-basedir=DIRECTORY

创建增量备份时，这是包含完整备份的目录，该备份是增量备份的基础数据集。

--incremental-dir=DIRECTORY

准备增量备份时，这是增量备份与完整备份组合的目录，以进行新的完整备份。

--incremental-force-scan

创建增量备份时，即使完整更改的页面位图数据可用，也强制对正在备份的实例中的数据页进行完全扫描。

--incremental-lsn=LSN

创建增量备份时，可以指定日志序列号（[LSN](https://www.percona.com/doc/percona-xtrabackup/2.4/glossary.html#term-lsn)）而不是指定 。对于在5.1及更高版本中创建的数据库，请将[LSN](https://www.percona.com/doc/percona-xtrabackup/2.4/glossary.html#term-lsn)指定为单个64位整数。**注意**：如果指定了错误的LSN值（*Percona XtraBackup*无法检测到的用户错误），则备份将无法使用。小心！[`xtrabackup --incremental-basedir`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-incremental-basedir)

--innodb-log-arch-dir=DIRECTORY

此选项用于指定包含存档日志的目录。它只能与选项一起使用。[`xtrabackup --prepare`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-prepare)

--innodb-miscellaneous

有一大组InnoDB选项通常从`my.cnf`配置文件中读取 ，因此**xtrabackup**以与当前服务器相同的配置启动其嵌入式InnoDB。您通常不需要明确指定这些。这些选项与InnoDB或XtraDB中的选项具有相同的行为。

它们如下：

```
-innodb-adaptive-hash-index 
-innodb-additional-mem-pool-size  
-innodb-autoextend-increment 
-innodb-buffer-pool-size  
-innodb-checksums  
-innodb-data-file-path
-innodb-数据-主页-目录
-innodb-doublewrite-file
-innodb-doublewrite
-innodb-extra-undoslots
-innodb-fast-checksum
-innodb-file-io-threads
-innodb-file-per-table
-innodb-flush-log-at-trx-commit
-innodb-flush-method
-innodb-force-recovery
-innodb-io-capacity
-innodb-lock-wait-timeout
-innodb-log-buffer-size
-innodb-log- files-in-group
-innodb-日志-文件-大小
-innodb-log-group-home-dir
-innodb-max-dirty-pages- pct
-innodb-open-files
-innodb-page-size
-innodb-read-io-threads
-innodb-write-io-threads 
```

--keyring-file-data=FILENAME

密钥环文件的路径。

--lock-ddl

如果备份开始时服务器支持阻止所有DDL操作，则发出问题。`LOCK TABLES FOR BACKUP`

--lock-ddl-per-table

在xtrabackup开始复制之前锁定每个表的DDL，直到备份完成。

--lock-ddl-timeout

如果在给定的超时内没有返回，则中止备份。`LOCK TABLES FOR BACKUP`

--log-copy-interval=#

此选项指定日志复制线程执行的检查之间的时间间隔（以毫秒为单位）（默认值为1秒）。

--move-back

将先前制作的备份中的所有文件从备份目录移动到其原始位置。由于此选项会删除备份文件，因此必须谨慎使用。

--no-defaults

不要从任何选项文件中读取默认选项。必须作为命令行上的第一个选项。

--no-version-check

此选项禁用版本检查。如果未通过此选项，则在模式下运行**xtrabackup**时**会**隐式启用自动版本检查`--backup`。要禁用版本检查，应`--no-version-check`在envoking **xtrabackup**时显式传递该选项。启用自动版本检查后，**xtrabackup**会在创建服务器连接后对备份阶段的服务器执行版本检查。**xtrabackup**将以下信息发送到服务器：MySQL的味道和版本操作系统名称Percona Toolkit版本Perl版本每条信息都有唯一的标识符。这是一个MD5哈希值，Percona Toolkit用它来获取有关如何使用它的统计信息。这是一个随机的UUID; 没有收集或存储客户信息。

--parallel=#

此选项指定在创建备份时用于同时复制多个数据文件的线程数。默认值为1（即没有并发传输）。在*Percona XtraBackup* 2.3.10及更高版本中，此选项可与选项一起使用以并行复制用户数据文件（重做日志和系统表空间在主线程中复制）。[`xtrabackup --copy-back`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-copy-back)

--password=PASSWORD

此选项指定连接到数据库时要使用的密码。它接受一个字符串参数。有关详细信息，请参阅mysql -help。

--prepare

使**xtrabackup**对使用创建的备份执行恢复 ，以便可以使用它。请参阅 [准备备份](https://www.percona.com/doc/percona-xtrabackup/2.4/backup_scenarios/full_backup.html#preparing-a-backup)。[`xtrabackup --backup`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-backup)

--print-defaults

打印程序参数列表并退出。必须作为命令行上的第一个选项。

--print-param

使**xtrabackup**打印出可用于将数据文件复制回原始位置以恢复它们的参数。请参阅 [使用xtrabackup编写备份脚本](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/scripting_backups_xbk.html#scripting-xtrabackup)。

--reencrypt-for-server-id=<new_server_id>

使用此选项可以使用与从中获取加密备份的server_id不同的server_id启动服务器实例，例如复制从属节点或galera节点。使用此选项时，作为准备步骤，xtrabackup将根据新的server_id生成具有ID的新主密钥，将其存储到密钥环文件中并重新加密表空间标头内的表空间密钥。选项应该通过[`--prepare`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-prepare)（最后一步）。

--remove-original

在*Percona XtraBackup* 2.4.6中实现，指定时将删除此选项`.qp`，`.xbcrypt`并`.qp.xbcrypt`在解密和解压缩后删除文件。

--safe-slave-backup

指定后，xtrabackup将在运行之前停止从属SQL线程，并等待启动备份直到 in 为零。如果没有打开的临时表，则会进行备份，否则将启动并停止SQL线程，直到没有打开的临时表为止。如果在几秒钟后没有变为零， 则备份将失败。备份完成后，将重新启动从属SQL线程。实现此选项是为了处理[复制临时表](https://dev.mysql.com/doc/refman/5.7/en/replication-features-temptables.html) ，而不是基于行的复制。`FLUSH TABLES WITH READ LOCK``Slave_open_temp_tables``SHOWSTATUS``Slave_open_temp_tables`[`xtrabackup --safe-slave-backup-timeout`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-safe-slave-backup-timeout)

--safe-slave-backup-timeout=SECONDS

应该等待 多少秒才能变为零。默认为300秒。[`xtrabackup --safe-slave-backup`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-safe-slave-backup)`Slave_open_temp_tables`

--secure-auth

如果客户端使用旧的（4.1.1之前的）协议，则拒绝客户端连接到服务器。（默认情况下启用;使用-skip-secure-auth禁用。）

--server-id=#

正在备份的服务器实例。

--slave-info

备份复制从属服务器时，此选项很有用。它打印主服务器的二进制日志位置。它还将此信息`xtrabackup_slave_info`作为 命令写入文件。可以通过在此备份上启动从属服务器并发出保存在文件中的二进制日志位置的命令来设置此主站的新从站。`CHANGE MASTER``CHANGEMASTER``xtrabackup_slave_info`

--ssl

 启用安全连接。更多信息可以在[-ssl](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl) MySQL服务器文档中找到。

--ssl-ca

包含受信任SSL CA列表的文件路径。更多信息可以在[-ssl-ca](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl-ca) MySQL服务器文档中找到。

--ssl-capath

包含PEM格式的受信任SSL CA证书的目录路径。更多信息可以在[-ssl-capath](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl-capath) MySQL服务器文档中找到。

--ssl-cert

包含PEM格式的X509证书的文件的路径。更多信息可以在[-ssl-cert](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl-cert) MySQL服务器文档中找到。

--ssl-cipher

用于连接加密的允许密码列表。更多信息可以在[-ssl-cipher](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl-cipher) MySQL服务器文档中找到。

--ssl-crl

包含证书吊销列表的文件的路径。更多信息可以在[-ssl-crl](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl-crl) MySQL服务器文档中找到。

--ssl-crlpath

 包含证书吊销列表文件的目录路径。更多信息可以在[-ssl-crlpath](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl-crlpath) MySQL服务器文档中找到。

--ssl-key

包含PEM格式的X509密钥的文件路径。更多信息可以在[-ssl-key](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl-key) MySQL服务器文档中找到。

--ssl-mode

与服务器连接的安全状态。更多信息可以在 [-ssl-mode](https://dev.mysql.com/doc/refman/5.7/en/secure-connection-options.html#option_general_ssl-mode) MySQL服务器文档中找到。

--ssl-verify-server-cert

验证服务器证书Common Name值与连接到服务器时使用的主机名。更多信息可以在 [-ssl-verify-server-cert](https://dev.mysql.com/doc/refman/5.6/en/secure-connection-options.html#option_general_ssl-verify-server-cert) MySQL服务器文档中找到。

--stats

使**xtrabackup**扫描指定的数据文件并打印出索引统计信息。

--stream=name

将所有备份文件以指定格式流式传输到标准输出。目前支持的格式是`xbstream`和`tar`。

--tables=name

正则表达式，与`databasename.tablename`格式的完整表名 匹配。如果名称匹配，则备份表。查看[部分备份](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/partial_backups.html)。

--tables-exclude=name

通过regexp过滤表名。操作方式与备份相同，但匹配的名称不在备份中。请注意，此选项的优先级高于 。[`xtrabackup --tables`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-tables)[`xtrabackup --tables`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-tables)

--tables-file=name

每行包含一个表名的文件，格式为databasename.tablename。备份将仅限于指定的表。请参阅 [使用xtrabackup编写备份脚本](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/scripting_backups_xbk.html#scripting-xtrabackup)。

--target-dir=DIRECTORY

此选项指定备份的目标目录。如果目录不存在，则**xtrabackup**会创建它。如果该目录确实存在且为空，则**xtrabackup**将成功。 但是，**xtrabackup**不会覆盖现有文件; 它将因操作系统错误17而失败。`file exists`如果此选项是相对路径，则将其解释为相对于执行**xtrabackup**的当前工作目录。

--throttle=#

此选项限制每秒复制的块数。块大小为 *10 MB*。要将带宽限制为*10 MB / s*，请将选项设置为*1*： -throttle = 1。也可以看看有关如何限制备份的详细信息[限制备份](https://www.percona.com/doc/percona-xtrabackup/2.4/advanced/throttling_backups.html#throttling-backups)

--tmpdir=name

除了在使用时打印出正确的tmpdir参数，此选项当前不用于任何内容。[`xtrabackup --print-param`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-print-param)

--to-archived-lsn=LSN

此选项用于指定在准备备份时应将日志应用到的LSN。它只能与选项一起使用 。[`xtrabackup --prepare`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-prepare)

--transition-key

此选项用于在不访问密钥环保管库服务器的情况下启用备份处理。在这种情况下，**xtrabackup**从指定的密码短语中派生AES加密密钥，并使用它来加密正在备份的表空间的表空间密钥。如果[`--transition-key`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-transition-key)没有任何价值，**xtrabackup**会要求它。应为该命令指定相同的密码。[`xtrabackup --prepare`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-prepare)

--use-memory=#

此选项会影响为备份或使用分析统计分配的内存 量 。其目的与[innodb_buffer_pool_size](https://www.percona.com/doc/percona-xtrabackup/2.4/glossary.html#term-innodb-buffer-pool-size)类似。它与Oracle的InnoDB热备份工具中的类似命名选项不同。默认值为100MB，如果您有足够的可用内存，1GB到2GB是一个很好的推荐值。提供单元支持倍数（例如1MB，1M，1GB，1G）。[`xtrabackup --prepare`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-prepare)[`xtrabackup --stats`](https://www.percona.com/doc/percona-xtrabackup/2.4/xtrabackup_bin/xbk_option_reference.html#cmdoption-xtrabackup-stats)

--user=USERNAME

此选项指定连接到服务器时使用的MySQL用户名（如果不是当前用户）。该选项接受字符串参数。有关详细信息，请参阅mysql -help。

--version

此选项打印**xtrabackup**版本并退出

**xtrabackup用法**

```
备份：innobackupex [option] BACKUP-ROOT-DIR
选项说明：
--user：该选项表示备份账号
--password：该选项表示备份的密码
--host：该选项表示备份数据库的地址
--databases：该选项接受的参数为数据名，如果要指定多个数据库，彼此间需要以空格隔开；如："xtra_test dba_test"，同时，在指定某数据库时，也可以只指定其中的某张表。如："mydatabase.mytable"。该选项对innodb引擎表无效，还是会备份所有innodb表
--defaults-file：该选项指定了从哪个文件读取MySQL配置，必须放在命令行第一个选项的位置
--incremental：该选项表示创建一个增量备份，需要指定--incremental-
basedir
--incremental-basedir：该选项表示接受了一个字符串参数指定含有full backup的目录为增量备份的base目录，与--incremental同时使用
--incremental-dir：该选项表示增量备份的目录
--include=name：指定表名，格式：databasename.tablename
Prepare：innobackupex --apply-log [option] BACKUP-DIR
选项说明：
--apply-log：一般情况下,在备份完成后，数据尚且不能用于恢复操作，因为备份的数据中可能会包含尚未提交的事务或已经提交但尚未同步至数据文件中的事务。因此，此时数据文件仍处理不一致状态。此选项作用是通过回滚未提交的事务及同步已经提交的事务至数据文件使数据文件处于一致性状态
--use-memory：该选项表示和--apply-log选项一起使用，prepare 备份的时候，xtrabackup做crash recovery分配的内存大小，单位字节。也可(1MB,1M,1G,1GB)，推荐1G
--defaults-file：该选项指定了从哪个文件读取MySQL配置，必须放在命令行第一个选项的位置
-export：表示开启可导出单独的表之后再导入其他Mysql中
--redo-only：这个选项在prepare base full backup，往其中merge增量备份时候使用
还原：innobackupex --copy-back [选项] BACKUP-DIR
innobackupex --move-back [选项] [--defaults-group=GROUP-NAME] BACKUP-DIR
选项说明：
--copy-back：做数据恢复时将备份数据文件拷贝到MySQL服务器的datadir
--move-back：这个选项与--copy-back相似，唯一的区别是它不拷贝文件，而是移动文件到目的地。这个选项移除backup文件，用时候必须小心。使用场景：没有足够的磁盘空间同事保留数据文件和Backup副本
```

```
cat xtrabackup.sh
#!/bin/bash
[ -d /root/increment/ ] || mkdir -p /root/increment/
mysql_path=/opt/data
mysql_increment_path=/root/increment/
#mysql全备
mysql_backup() {
innobackupex --defaults-file=/etc/my.cnf --user=root --password='jbgsn123!' --backup $mysql_path/mysql-`date +%Y%m%d`/  --no-timestamp
exit 0
}

#恢复
mysql_recovery() {
systemctl stop mysqld
mv /var/lib/mysql  /var/lib/mysql2
innobackupex --apply-log $mysql_path/mysql-`date +%Y%m%d`/
innobackupex --defaults-file=/etc/my.cnf --copy-back $mysql_path/mysql-`date +%Y%m%d`/
chown -R mysql.mysql /var/lib/mysql
systemctl start mysqld
exit 0
}

#增量备份
mysql_increment() {
innobackupex --defaults-file=/etc/my.cnf --user=root --password='jbgsn123!' --incremental $mysql_increment_path/mysql-`date +%Y%m%d`/ --incremental-basedir=$mysql_path/mysql-`date +%Y%m%d`/ --no-timestamp
exit 0
}

#增量恢复
mysql_increment_recovery() {
innobackupex --apply-log --redo-only $mysql_path/mysql-`date +%Y%m%d`/
innobackupex --apply-log --redo-only $mysql_path/mysql-`date +%Y%m%d`/  --incremental-dir=$mysql_path/mysql-`date +%Y%m%d`/
systemctl stop mysqld
mv /var/lib/mysql  /var/lib/mysql2
innobackupex --defaults-file=/etc/my.cnf --copy-back $mysql_path/mysql-`date +%Y%m%d`/
chown -R mysql.mysql /var/lib/mysql
systemctl start mysqld
exit 0
}

man() {
mysql_backup
#mysql_recovery
mysql_increment
#mysql_increment_recovery
}

man
```