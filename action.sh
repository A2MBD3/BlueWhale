#!/system/bin/sh
MODDIR=${0%/*}
BIN="$MODDIR/system/bin/Abdullah"
PIDFILE="$MODDIR/proxy.pid"
is_running() { [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; }
echo "Action"
if is_running; then
  kill -9 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null
  pkill -f "system/bin/Abdullah" 2>/dev/null
  rm -f "$PIDFILE"
  sleep 1
fi
chmod 755 "$BIN"
nohup "$BIN" >/dev/null 2>&1 &
echo $! > "$PIDFILE"
sleep 2
is_running && echo OK || echo Failed
