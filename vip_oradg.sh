#!/bin/bash
dbstats=`echo -e 'set pagesize 0\nselect open_mode from v$database;' | sqlplus -S / as sysdba|grep "READ WRITE"|wc -l`
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
