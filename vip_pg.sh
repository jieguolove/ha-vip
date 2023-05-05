#!/bin/bash
dbstats=`su - postgres -c "/home/pgsql/bin/repmgr -f /home/pgsql/repmgr.conf cluster show"|grep 本机主机名|grep primary|grep running|wc -l` ###repmgr管理的情况下
#dbstats=`PGPASSWORD="Abcd1234" /opt/pgsql/bin/psql -U postgres -d postgres -p 5432 --host 10.1.1.53 -c "select pg_is_in_recovery();"|grep f|wc -l` ###非repmgr情况下，根据实际情况修改密码和IP信息等
ip=`/usr/sbin/ip a|grep bond0:1|wc -l`
 
if [[ "${dbstats}" -eq 1 ]] ; then
    if [[ "${ip}" -eq 0 ]]; then
    /usr/sbin/ifconfig bond0:1 10.1.1.53 netmask 255.255.255.0 up
    /usr/sbin/arping -b -s 10.1.1.53 10.1.1.1 -c 3 #保证了3秒内IP可联通
    fi
else
    if [[ "${ip}" -gt 0 ]]; then
    /usr/sbin/ifconfig bond0:1 down
    fi
fi
