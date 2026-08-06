#!/system/bin/sh
MODDIR=${0%/*}
LOG="/data/local/tmp/bluewhale/service.log"

log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

# Wait for full boot
log "Waiting for boot..."
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 3
done
sleep 5

log "Boot complete. Starting Blue Whale..."

# Kill any existing instances
pkill -9 -f bluewhale_d 2>/dev/null
sleep 1

# Apply system bypass (hosts + iptables)
log "Applying system bypass..."
mount -o rw,remount / 2>/dev/null

# DNS spoof
sed -i '/catchmeifyoucan/d' /etc/hosts
echo '127.0.0.1 catchmeifyoucan.xyz' >> /etc/hosts

# iptables redirect
iptables -t nat -F OUTPUT 2>/dev/null
iptables -t nat -A OUTPUT -d 172.67.135.103 -p tcp --dport 80 \
    -j DNAT --to-destination 127.0.0.1:80 2>/dev/null

# Block external WebUI access
iptables -A INPUT -p tcp --dport 8080 ! -s 127.0.0.1 -j DROP 2>/dev/null

log "System bypass applied ✓"

# Start daemon
if [ -f "/system/bin/bluewhale_d" ]; then
    log "Starting bluewhale_d..."
    /system/bin/bluewhale_d >> "$LOG" 2>&1 &
    log "Daemon started ✓"
else
    log "⚠ bluewhale_d not found. Skipping."
fi

log "Service complete."