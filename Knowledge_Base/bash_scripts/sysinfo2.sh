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

echo "What info would you like to see ?"
echo "1. Hostname"
echo "2. Disk Usage"
echo "3. RAM Stats"
echo "4. Time"
echo "5. CPU Info"
echo "6. System at a glance"

read -p "Enter choice: " CHOICE

if [ "$CHOICE" == "1"]
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


