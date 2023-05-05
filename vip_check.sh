step=3
for ((i = 0; i < 60; i = (i + step))); do
    $(/etc/vip.sh)
    sleep $step
done
exit 0
