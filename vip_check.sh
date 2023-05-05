step=3
for ((i = 0; i < 60; i = (i + step))); do
    $(/etc/vip.sh) ###此处的vip.sh应根据实际情况改成vip_mgr.sh/vip_oradg.sh
    sleep $step
done
exit 0
