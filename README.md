# ha-vip
不想用keepalived，自己写了方便灵活的HA主备浮动VIP自动切换脚本，适合各种主备环境，比如mysql mgr,oracle dataguard,postgresql ha

文件说明：
vip.sh为mgr参考例子

vip_mgr.sh为mgr vip例子

vip_oradg.sh 为oracle dataguard vip例子

vip_check.sh 放在crontab定时任务中，每分钟运行一次（脚本内每3秒检测一次）

--------------------------------------------------------


以下以mysql mgr为例：

应用连接到vip，主库宕机将自动切换到从库（3秒内vip可正常）

mysql mgr集群中所有节点都需要检查部署：

1）vip打算挂在哪个网卡上? 记录网卡名称eth0和网关 192.168.207.1：

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



2）避免连接密码警告提示（mysql环境下需要这步）：

[root@mgr01 ~]# cat /etc/my.password

[client]

user=root

password=1qazXSW@


3）检测脚本：参看脚本,每个节点都要部署。

[root@mgr01 ~]# cat /etc/vip_check.sh 

[root@mgr01 ~]# cat /etc/vip.sh或/etc/vip_mgr.sh

注意：判断脚本可根据实际主节点的判断方法处理

4）设置定时任务：

[root@mgr01 ~]# crontab -l

* * * * * /etc/vip_check.sh > /dev/null 2>&1

5）测试主从切换，检查VIP是否预期正常：

ip a|grep 192.168.207.134

ping 192.168.207.134

