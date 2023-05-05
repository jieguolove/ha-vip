# ha-vip
方便灵活的HA主备浮动VIP自动切换脚本，适合各种主备环境，比如mysql mgr,oracle dataguard,postgresql ha
以下以mysql mgr为例：
应用连接到vip，主库宕机将自动切换到从库（3秒内vip可正常）

mysql mgr集群中所有节点都需要检查部署：

vip打算挂在哪个网卡上? 记录网卡名称eth0和网关 192.168.207.1：
[root@mgr01 ~]# ip a|grep global
    inet 192.168.207.131/24 brd 192.168.207.255 scope global noprefixroute eth0
[root@mgr01 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.207.1   0.0.0.0         UG    100    0        0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
192.168.207.0   0.0.0.0         255.255.255.0   U     100    0        0 eth0
[root@mgr01 ~]# ip route
default via 192.168.207.1 dev eth0 proto static metric 100 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 
192.168.207.0/24 dev eth0 proto kernel scope link src 192.168.207.131 metric 100

避免连接密码警告提示：
[root@mgr01 ~]# cat /etc/my.password 
[client]
user=root
password=1qazXSW@
检测脚本：
[root@mgr01 ~]# cat /etc/vip_check.sh 
step=3
for ((i = 0; i < 60; i = (i + step))); do
    $(/etc/vip.sh)
    sleep $step
done
exit 0
[root@mgr01 ~]# cat /etc/vip.sh
#!/bin/bash
dbstats=`/usr/bin/mysql --defaults-extra-file=/etc/my.password -s -P 33062 -e "select MEMBER_HOST,MEMBER_ROLE from performance_schema.replication_group_members;"|grep "192.168.207.131"|awk '{print $2}'|grep "PRIMARY"|wc -l` #注意修改此处的IP地址为本机的IP
ip=`/usr/sbin/ip a|grep eth0:1|wc -l`
 
if [[ "${dbstats}" -eq 1 ]] ; then
    if [[ "${ip}" -eq 0 ]]; then
    /usr/sbin/ifconfig eth0:1 192.168.207.134 netmask 255.255.255.0 up ##注意修改网卡名称和浮动IP地址
    /usr/sbin/arping -I eth0 -b -s 192.168.207.134 192.168.207.1 -c 4 ##解决了vip切换后5秒内可联通的问题，不加arping可能需要耗时5分钟左右
    fi
else
    if [[ "${ip}" -gt 0 ]]; then
    /usr/sbin/ifconfig eth0:1 down
    fi
fi

设置定时任务：
[root@mgr01 ~]# crontab -l
* * * * * /etc/vip_check.sh > /dev/null 2>&1

检查VIP是否正常：
ip a|grep 192.168.207.134
ping 192.168.207.134
