#!/system/bin/sh
MODDIR=${0%/*}
DAEMON="$MODDIR/bluewhale"

# বাইনারিকে executable বানাও
chmod +x "$DAEMON" 2>/dev/null

# OOM killer থেকে বাঁচাতে
protect_oom() {
    pid=$(pgrep -x bluewhale | head -n 1)
    [ -n "$pid" ] && echo -1000 > /proc/$pid/oom_score_adj 2>/dev/null
}

# ওয়াচডগ: মরে গেলে রিস্টার্ট
while true; do
    if ! pgrep -x bluewhale >/dev/null 2>&1; then
        # পোর্ট পরিষ্কার
        fuser -k 80/tcp 2>/dev/null
        fuser -k 8080/tcp 2>/dev/null
        
        # Daemon চালু
        nohup "$DAEMON" >/dev/null 2>&1 &
        sleep 2
        protect_oom
    fi
    sleep 10
done
