#!/bin/bash
# 下载资源
#sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
#sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
#yum makecache
#yum update -y

yum install -y net-tools
yum install -y vim
yum install -y ntp
yum install -y wget
yum install -y unzip zip
wget https://repo.huaweicloud.com/java/jdk/8u171-b11/jdk-8u171-linux-x64.tar.gz
wget https://mirrors.huaweicloud.com/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
wget https://mirrors.huaweicloud.com/apache/hadoop/core/hadoop-2.7.6/hadoop-2.7.6.tar.gz
wget https://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.47.zip
wget https://mirrors.huaweicloud.com/apache/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz
wget https://downloads.lightbend.com/scala/2.11.11/scala-2.11.11.tgz
wget https://mirrors.huaweicloud.com/apache/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz

# 基础环境配置
# 关掉防火墙
systemctl stop firewalld
systemctl disable firewalld
# 同步时钟任务
whereis ntpdate
echo "*/30 10-17 * * * /usr/sbin/ntpdate master" >> /var/spool/cron/root
# 配置java
mkdir -p /usr/java
tar -zxvf ./jdk-8u171-linux-x64.tar.gz -C /usr/java
# 配置zookeeper
mkdir -p /usr/zookeeper/zookeeper-3.4.10/conf
tar -zxvf ./zookeeper-3.4.10.tar.gz -C /usr/zookeeper
# 配置hadoop
mkdir -p /usr/hadoop/hadoop-2.7.6/etc/hadoop
tar -zxvf ./hadoop-2.7.6.tar.gz -C /usr/hadoop
# 安装mysql
yum localinstall -y mysql57-community-release-el7-11.noarch.rpm
yum repolist enabled | grep "mysql.*-community.*"
yum repolist all | grep mysql
yum install -y mysql-community-server
systemctl daemon-reload
systemctl start mysqld
systemctl enable mysqld
mysql_password=$(grep "temporary password" /var/log/mysqld.log | awk '{print $11}')
touch ./mysql.sql
echo 'set global validate_password_policy = 0;' >> ./mysql.sql
echo 'set global validate_password_length = 4;' >> ./mysql.sql
echo "alter user 'root'@'localhost' identified by '123456';" >> ./mysql.sql
echo "create user 'root'@'%' identified by '123456';" >> ./mysql.sql
echo "grant all privileges on *.* to 'root'@'%' with grant option;" >> ./mysql.sql
echo "flush privileges;" >> ./mysql.sql
echo "create database hongyaa;" >> ./mysql.sql
mysql -uroot -p"$mysql_password" --connect-expired-password < ./mysql.sql
# 安装hive
mkdir -p /usr/hive
tar -zxvf ./apache-hive-2.1.1-bin.tar.gz -C /usr/hive
echo 'export HADOOP_HOME=/usr/hadoop/hadoop-2.7.6' >> /usr/hive/apache-hive-2.1.1-bin/conf/hive-env.sh
echo 'export HIVE_CONF_DIR=/usr/hive/apache-hive-2.1.1-bin/conf' >> /usr/hive/apache-hive-2.1.1-bin/conf/hive-env.sh
echo 'export HIVE_AUX_JARS_PATH=/usr/hive/apache-hive-2.1.1-bin/lib' >> /usr/hive/apache-hive-2.1.1-bin/conf/hive-env.sh
cp /usr/hive/apache-hive-2.1.1-bin/lib/jline-2.12.jar /usr/hadoop/hadoop-2.7.6/share/hadoop/yarn/lib/
unzip -o -d ./ mysql-connector-java-5.1.47.zip
cp ./mysql-connector-java-5.1.47/mysql-connector-java-5.1.47-bin.jar /usr/hive/apache-hive-2.1.1-bin/lib
# 安装scala
mkdir -p /usr/scala
tar -zxvf  ./scala-2.11.11.tgz -C /usr/scala
# 安装spark
mkdir -p /usr/spark/spark-2.4.3-bin-hadoop2.7/conf
tar -zxvf ./spark-2.4.3-bin-hadoop2.7.tgz -C /usr/spark

