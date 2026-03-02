#!/bin/bash
bot_token=
chat_id=
cpu_limit=80
mem_limit=85
host_limit=90
while true; do
HOSTNAME=$(hostname)
UPTIME=$(uptime -p)
MEM=$(free -h | awk '/Mem:/{print $3 "/" $2}')
DISK=$(df -h / |awk 'NR==2 {print $3 "/" $2}')
cpu1=$(grep 'cpu ' /proc/stat | awk '{print $2+$4}')
idle1=$(grep 'cpu ' /proc/stat | awk '{print $5}')
sleep 1
cpu2=$(grep 'cpu ' /proc/stat | awk '{print $2+$4}')
idle2=$(grep 'cpu ' /proc/stat | awk '{print $5}')
HOST_CPU=$(awk -v cpu1="$cpu1" -v cpu2="$cpu2" -v idle1="$idle1" -v idle2="$idle2" 'BEGIN {printf "%.0f", ((cpu2-cpu1)*100)/((cpu2-cpu1)+(idle2-idle1))}')
stats=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemPerc}}")
cpu_raw=$(echo "$stats" | cut -d',' -f1 | sed 's/%//')
mem_raw=$(echo "$stats" | cut -d',' -f2 | sed 's/%//')
cpu_init=$(printf "%.0f" "$cpu_raw" 2>/dev/null || echo 0)
mem_init=$(printf "%.0f" "$mem_raw" 2>/dev/null || echo 0)
container_status=$(docker ps)
stats_report=$(docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}")
MESSAGE="homelab status
host: $HOSTNAME
UPTIME: $UPTIME
memory: $MEM
Disk: $DISK   
cpu : $cpu_init%
container status
$container_status
container stat
$stats_report"
hardwaremessage="homelab status high cpu usage
host:$HOST_CPU%
DOCKERCPUUSAGE:$cpu_init
memory:$MEM"
if [ "$cpu_init" -gt "$cpu_limit" ] || [ "$mem_init" -gt "$mem_limit" ]; then 
curl -s -o /dev/null -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
-d chat_id="$chat_id" \
-d text="$MESSAGE"
fi
if [ "$HOST_CPU" -gt "$host_limit" ]; then
curl -s -o /dev/null -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
-d chat_id="$chat_id" \
-d text="$hardwaremessage"
fi
sleep 2
done
