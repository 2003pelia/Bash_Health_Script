#!/bin/bash
# ==========================================
# System Health Monitoring Script - Version 3
# Author: Preston Elia
# ==========================================

# ---------- CONFIGURATION ----------
LOG_DIR="/var/log"
LOGFILE="$LOG_DIR/system_health.log"
ARCHIVE_DIR="$LOG_DIR/system_health_archive"
EMAIL_ALERT="you@example.com"    # Optional email for alerts

CPU_THRESHOLD=85
MEM_THRESHOLD=85
DISK_THRESHOLD=90
NET_INTERFACE="eth0"             # Change to your network interface (use: ip a)
KEEP_DAYS=7                     # Number of days to keep old logs
# -----------------------------------

# ANSI Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ---------- SETUP ----------
sudo mkdir -p "$ARCHIVE_DIR"

# ---------- LOG ROTATION ----------
find "$ARCHIVE_DIR" -type f -mtime +$KEEP_DAYS -exec rm -f {} \; 2>/dev/null
if [ -f "$LOGFILE" ]; then
    mv "$LOGFILE" "$ARCHIVE_DIR/system_health_$(date +%Y-%m-%d_%H-%M-%S).log"
fi

# ---------- DATA COLLECTION ----------
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
CPU_INT=${CPU_LOAD%.*}

MEM_USED=$(free | awk '/Mem/{printf("%.0f"), $3/$2*100}')

DISK_USED=$(df / | grep / | awk '{print $5}' | sed 's/%//')

UPTIME_INFO=$(uptime -p)

# Network stats: RX/TX bytes
NET_STATS=$(cat /proc/net/dev | grep "$NET_INTERFACE" | awk '{print $2, $10}')
RX=$(echo $NET_STATS | awk '{print $1}')
TX=$(echo $NET_STATS | awk '{print $2}')
RX_MB=$(awk "BEGIN {printf \"%.2f\", $RX/1024/1024}")
TX_MB=$(awk "BEGIN {printf \"%.2f\", $TX/1024/1024}")

# ---------- ALERT LOGIC ----------
ALERT=0

colorize() {
    local val=$1
    local threshold=$2
    if [ "$val" -ge "$threshold" ]; then echo -e "${RED}${val}%${NC}"
    elif [ "$val" -ge 70 ]; then echo -e "${YELLOW}${val}%${NC}"
    else echo -e "${GREEN}${val}%${NC}"
    fi
}

CPU_COLOR=$(colorize $CPU_INT $CPU_THRESHOLD)
MEM_COLOR=$(colorize $MEM_USED $MEM_THRESHOLD)
DISK_COLOR=$(colorize $DISK_USED $DISK_THRESHOLD)

# ---------- DASHBOARD OUTPUT ----------
{
    echo -e "${BOLD}${CYAN}"
    echo "==========================================="
    echo "         SYSTEM HEALTH DASHBOARD"
    echo "===========================================${NC}"
    echo
    printf "%-20s %-15s\n" "Metric" "Value"
    echo "-------------------------------------------"
    printf "%-20s %-15b\n" "CPU Usage:" "$CPU_COLOR"
    printf "%-20s %-15b\n" "Memory Usage:" "$MEM_COLOR"
    printf "%-20s %-15b\n" "Disk Usage:" "$DISK_COLOR"
    printf "%-20s %-15s\n" "Uptime:" "$UPTIME_INFO"
    printf "%-20s %-15s\n" "Network RX:" "$RX_MB MB"
    printf "%-20s %-15s\n" "Network TX:" "$TX_MB MB"
    echo "-------------------------------------------"
} | tee "$LOGFILE"

# ---------- ALERT CONDITIONS ----------
if [ "$CPU_INT" -ge "$CPU_THRESHOLD" ] || [ "$MEM_USED" -ge "$MEM_THRESHOLD" ] || [ "$DISK_USED" -ge "$DISK_THRESHOLD" ]; then
    ALERT=1
    echo -e "${RED}[ALERT] One or more system metrics exceeded thresholds.${NC}" | tee -a "$LOGFILE"
fi

if [ "$ALERT" -eq 1 ] && [ -n "$EMAIL_ALERT" ]; then
    mail -s "⚠️ System Health Alert on $(hostname)" "$EMAIL_ALERT" <<< "One or more metrics exceeded limits. Check $LOGFILE for details."
fi

echo -e "\n${GREEN}Report saved to: $LOGFILE${NC}"
echo -e "${CYAN}Old logs archived in: $ARCHIVE_DIR${NC}"

