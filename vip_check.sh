###vip_check.sh应放在crontab -l任务中，* * * * * /etc/vip_check.sh > /dev/null 2>&1
step=3 ##每3秒一次检查，可根据情况修改
for ((i = 0; i < 60; i = (i + step))); do ##1分钟内每3秒一次，可根据情况修改
    $(/etc/vip.sh) ###此处的vip.sh应根据实际情况改成vip_mgr.sh/vip_oradg.sh
    sleep $step
done
exit 0
