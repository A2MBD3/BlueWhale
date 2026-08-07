#!/system/bin/sh
MODDIR=${0%/*}
DAEMON="$MODDIR/bluewhale"
chmod +x "$DAEMON" 2>/dev/null

notify() {
    su -c "cmd notification post -S bigtext -t '🐋 Blue Whale' 'bw_action' '$1'" >/dev/null 2>&1 || true
}

PID=$(pgrep -x bluewhale | head -n 1)

if [ -n "$PID" ]; then
    # চালু আছে → প্রথমে Soft restart (WebUI API) ট্রাই করো
    # এতে শুধু প্রক্সি রিস্টার্ট হয়, WebUI বন্ধ হয় না
    curl -s -X POST --max-time 3 http://127.0.0.1:8080/api/restart >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        notify "✅ Proxy soft-restarted (WebUI alive)"
    else
        # API কাজ না করলে Hard restart (পুরো বাইনারি কিল)
        kill -9 $PID 2>/dev/null
        sleep 1
        nohup "$DAEMON" >/dev/null 2>&1 &
        sleep 1
        NEWPID=$(pgrep -x bluewhale | head -n 1)
        [ -n "$NEWPID" ] && notify "✅ Hard-restarted (PID: $NEWPID)" || notify "❌ Failed"
    fi
else
    # বন্ধ আছে → চালু করো
    nohup "$DAEMON" >/dev/null 2>&1 &
    sleep 1
    NEWPID=$(pgrep -x bluewhale | head -n 1)
    [ -n "$NEWPID" ] && notify "✅ Started (PID: $NEWPID)" || notify "❌ Failed to start"
fi
