#!/system/bin/sh
MODDIR=${0%/*}
BIN="$MODDIR/system/bin/Abdullah"
PIDFILE="$MODDIR/proxy.pid"
sleep 20
start() {
  if [ -f "$PIDFILE" ]; then
    old=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$old" ] && kill -0 "$old" 2>/dev/null; then return 0; fi
  fi
  pkill -f "/system/bin/Abdullah" 2>/dev/null
  pkill -f "system/bin/Abdullah" 2>/dev/null
  sleep 1
  chmod 755 "$BIN" 2>/dev/null
  # ensure always restart
  nohup "$BIN" >/dev/null 2>&1 &
  echo $! > "$PIDFILE"
}
start
# aggressive watchdog - never stay down
while true; do
  sleep 8
  if [ -f "$PIDFILE" ]; then
    pid=$(cat "$PIDFILE" 2>/dev/null)
    if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
      start
    fi
  else
    start
  fi
  # also check process by name
  if ! pgrep -f "system/bin/Abdullah" >/dev/null 2>&1; then
    rm -f "$PIDFILE"
    start
  fi
done
