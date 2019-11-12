sudo rm -f 导出文件名.sql #删除已经存在的文件
sudo mysql -uroot -p数据库密码 -Bse "FLUSH TABLES WITH READ LOCK;show master status;"
sudo mysqldump -uroot -p数据库密码 --databases 导出数据库名 >导出文件名.sql
sudo mysql -uroot -p数据库密码 -Bse "show master status;UNLOCK TABLES;"