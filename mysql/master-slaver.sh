mysql主从同步
注意事项：
主服务器重启后，slaver也必须restart

##mysql主从配置
主：
1、修改配置
修改auto.cnf：
如果是容器，需先修改auto.cnf中server-uuid的尾号为ip最后一段号码
修改my.cnf：
cat >>/etc/mysql/my.cnf
server-id =183
log-bin = log-bin 
innodb-file-per-table =ON
skip_name_resolve=ON
binlog_format=MIXED
innodb_flush_log_at_trx_commit=2  # 
sync_binlog=1  #开启binlog日志同步功能

2、mysql客户端中添加主数据库的slave账号
#主库
-- GRANT REPLICATION SLAVE ON *.* to 'slave138'@'172.18.196.183' identified by 'WCY7EWQBiKHDvFgHcFgeqqvA';#在主Mysql上建立slave138帐户并授权为Slave:
-- GRANT REPLICATION SLAVE ON *.* to 'slave245'@'172.18.171.245' identified by 'WCY7EWQBiKHDvFgHcFgeqqvA';#在主Mysql上建立slave245帐户并授权为Slave:
-- flush privileges;

3、锁库再导出数据
flush tables with read lock;
show master status;#查看并记下主库当前bin-log文件和操作位置，从库导入数据后从该位置同步
#导出数据
mysqldump -u账号 -p密码 --databases 要导出的数据库名 >/tmp/testA.sql
unlock tables;

4、拷贝数据到从服务器
scp /tmp/testA.sql 10.0.0.104:/tmp

从：
1、修改配置
cat >>/etc/mysql/my.cnf
server-id=245
log-bin=mysql-bin
binlog_format=MIXED
innodb_flush_log_at_trx_commit=2
sync_binlog=1
replicate-do-db=some_schema#要同步的数据库
replicate-ignore-db=sys#不想同步的数据库
replicate-ignore-db=performance_schema
replicate-ignore-db=mysql
replicate-ignore-db=lserver
#read_only = ON

2、导入主库的同步前数据
mysql>drop table 将导入的数据库名 #先删除同名数据库
mysql -uroot -pyangcan </tmp/testA.sql #导入数据
systemctl restart mysql.service #重启数据库

3、修改mysql数据目录下的auto.cnf
cat >/var/lib/mysql/auto.cn
[auto]
server-uuid=772a84e9-2e79-11e8-8548-00163e0a7独立尾号

4、mysql客户端中设置从数据库的master
#master_log_file文件为主库中 show master status 中的File，master_log_post为主库中Postion的值
-- change master to master_host='172.18.196.183',master_user='slave245',master_password='WCY7EWQBiKHDvFgHcFgeqqvA',master_log_file='log-bin.000002',master_log_pos=主库导出数据前的操作位置;
-- #change master to master_connect_retry=50;# 连接断开时，重新连接超时时间
-- start slave;#启动slave的io和sql线程
-- stop slave;
-- #set global sql_slave_skip_counter =1;#从回放日志中跳过1个event再执行（常用于跳过一些错误事件）
show slave status;#查看slave的当前状态







############其它调试命令###########
-- show global variables like '%log%';
-- Show master logs;
-- show global variables like '%server%';
-- select user,host from mysql.user;#查看所有用户
-- flush tables with read lock;#锁定主表的读
-- unlock tables;#解锁
-- #查看错误
-- show warnning;
#查看主库状态
-- show master status;
#查看从库连接状态
-- show processlist;
#查看从库状态
-- show slave status;
#重置主记录信息
-- reset master;
#重置从记录信息
-- reset slave;
#停止始从
-- stop slave;
#开始从
-- start slave;
#清空从所有连接、信息记录
-- reset slave all;
#删除从
-- change master to master_host=' ';


###########删除主从同步###########
-- #从库
-- stop slave;
-- reset slave all;
-- show slave status;
-- #清除从库配置文件的配置
--  
-- #主库
-- reset master;
-- #清除主库配置文件的配置
-- #清除mysql.user从库账号
-- show master status

