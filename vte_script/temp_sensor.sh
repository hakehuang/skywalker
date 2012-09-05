#!/bin/sh
mac=$(cat /sys/class/net/eth0/address | sed 's/:/_/g')
echo "------------------------------------------------------------"
while true
do
 sleep 30
 echo "<<<MEASUER_START>>>" >> /root/${mac}
 if [ -e /sys/devices/virtual/thermal/thermal_zone0/temp ]; then
	cat /sys/devices/virtual/thermal/thermal_zone0/temp >> /root/${mac}
 fi
 top -n 1  | head -n 10 >> /root/${mac}
 date -u >> /root/${mac}
 echo "<<<MEASUER_END>>>" >> /root/${mac}
done

