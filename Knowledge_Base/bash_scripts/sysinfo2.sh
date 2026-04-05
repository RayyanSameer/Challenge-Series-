#WHAT am i doing ?

#Checking for system info 

#WHAT specifically fo i need ?
#Basic Usage 
#Hostname 
#Disk
#RAM Stats 
#Time 


#Where is it
# Hostname 
# df -g
# 

#!/ bin/bash
echo "Wellcome to the system info script"
echo "Hostname: $(hostname)"
echo "++=============================="

echo "Disk $(df -h)"

echo "================================"
echo "RAM Stats: $(free -h)"

echo "================================"
echo "Time: $(date)"

echo "================================"
echo "CPU Info: "
lscpu

echo "================================"
echo "System at a glance: "
hostnamectl


