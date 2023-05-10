###该脚本以mysql mgr为例，实际应参考vip_mgr.sh/vip_oradg.sh等
#!/bin/bash
dbpri=`/usr/bin/mysql --defaults-extra-file=/etc/my.password -s -P 33062 -e "select MEMBER_HOST,MEMBER_STATE,MEMBER_ROLE from performance_schema.replication_group_members;"|grep ONLINE|grep "192.168.207.131"|awk '{print $2}'|grep "PRIMARY"|wc -l` #注意修改此处的IP地址为本机的IP#for mysql mgr
ip1=`/usr/sbin/ip a|grep eth0:1|wc -l`
if [[ "${dbpri}" -eq 1 ]] ; then
    if [[ "${ip1}" -eq 0 ]]; then
    /usr/sbin/ifconfig eth0:1 192.168.207.134 netmask 255.255.255.0 up ##注意修改网卡名称和浮动IP地址
    /usr/sbin/arping -I eth0 -b -s 192.168.207.134 192.168.207.1 -c 4 ##解决了vip切换后5秒内可联通的问题，不加arping可能需要耗时5分钟左右
    fi
else
    if [[ "${ip1}" -gt 0 ]]; then
    /usr/sbin/ifconfig eth0:1 down
    fi
fi

##主库和备库都增加浮动IP，只适合2个节点集群；注意不适用3个节点以上备库浮动IP，因为备库会有2个以上节点。

dbstb=`/usr/bin/mysql --defaults-extra-file=/etc/my.password -s -P 33062 -e "select MEMBER_HOST,MEMBER_STATE,MEMBER_ROLE from performance_schema.replication_group_members;"|grep ONLINE|grep "192.168.207.131"|awk '{print $2}'|grep "SECONDARY"|wc -l` #注意修改此处的IP地址为本机的IP#for mysql mgr
ip2=`/usr/sbin/ip a|grep eth0:2|wc -l`

if [[ "${dbstb}" -eq 1 ]] ; then
    if [[ "${ip2}" -eq 0 ]]; then
    /usr/sbin/ifconfig eth0:2 192.168.207.135 netmask 255.255.255.0 up
    /usr/sbin/arping -I eth0 -b -s 192.168.207.135 192.168.207.1 -c 4
    fi
else
    if [[ "${ip2}" -gt 0 ]]; then
    /usr/sbin/ifconfig eth0:2 down
    fi
fi
