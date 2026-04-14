#!/bin/bash
# Prints out system info 

#OS Version
#Username 
#Date 
#Disk
#CPU and GPU  info 
#Network Stats 
#RAM Stats 



DATE=$(date)
DISK=$(df -h /)
CPU=$(top -bn 2 -d 0.01 | grep '^%Cpu' | tail -n 1 | gawk '{print $2+$4+$6"%"}'
)
GPU=$(intel_gpu_top -bn 2 -d 0.01 | grep '^%Cpu' | tail -n 1 | gawk '{print $2+$4+$6"%"}')
NET=$(nstat)
MEM=$(free -h)
echo "Instance Details "  
hostnamectl
echo "================================"

echo "Date: $DATE"
echo  cmd

echo "================================"

echo "Disk Usage Stats: "
echo "$DISK"

echo "================================="
echo "Memory Usage Stats: "
echo "Memory: $MEM"

echo "================================"
echo "CPU Stats: "
echo "$CPU Usage "

echo "================================"
echo "GPU Stats: "
echo "$GPU Usage"

echo "================================"
echo "Network Stats: "
echo "$NET"


chmod +x sysinfo.sh


#Basic Version 

#TODO: Implement a menu system allowing uses to get an overview or a specific stat
#TODO: Use Interactive Commands to show libraries 
#TODO: Add CLI Dashboard