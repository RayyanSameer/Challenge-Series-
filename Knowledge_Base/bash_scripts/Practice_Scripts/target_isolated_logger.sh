cat > ~/pz_memlog.sh << 'EOF'
#!/bin/bash
LOGFILE=~/pz_memory_log.txt
echo "Starting memory logging. Press Ctrl+C to stop." > "$LOGFILE"
while true; do
  echo "[$(date '+%H:%M:%S.%3N')] $(free -m | grep Mem)" >> "$LOGFILE"
  sleep 0.2
done
EOF
chmod +x ~/pz_memlog.sh