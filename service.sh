#!/system/bin/sh
MODDIR=${0%/*}
BIN="$MODDIR/system/bin/BlueWhale"
PIDFILE="$MODDIR/proxy.pid"
sleep 25
start() {
  if [ -f "$PIDFILE" ]; then
    old=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$old" ] && kill -0 "$old" 2>/dev/null; then return 0; fi
  fi
  pkill -f "BlueWhale" 2>/dev/null
  sleep 1
  chmod 755 "$BIN" 2>/dev/null
  nohup "$BIN" >/dev/null 2>&1 &
  echo $! > "$PIDFILE"
}
start
while true; do
  sleep 15
  if [ -f "$PIDFILE" ]; then
    pid=$(cat "$PIDFILE" 2>/dev/null)
    if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then start; fi
  else start; fi
done
