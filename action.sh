#!/system/bin/sh
MODDIR=${0%/*}
BIN="$MODDIR/system/bin/Abdullah"
PIDFILE="$MODDIR/proxy.pid"
LOGFILE="$MODDIR/proxy.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"
}

is_running() {
  [ -f "$PIDFILE" ] || return 1
  PID=$(cat "$PIDFILE" 2>/dev/null)
  [ -n "$PID" ] || return 1
  kill -0 "$PID" 2>/dev/null
}

stop_proxy() {
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      log "Stopping PID $PID"
      kill -TERM "$PID" 2>/dev/null
      # Wait up to 5s for graceful shutdown
      i=0
      while [ $i -lt 5 ] && kill -0 "$PID" 2>/dev/null; do
        sleep 1
        i=$((i + 1))
      done
      # Force kill if still alive
      if kill -0 "$PID" 2>/dev/null; then
        log "Force killing PID $PID"
        kill -9 "$PID" 2>/dev/null
      fi
    fi
    rm -f "$PIDFILE"
  fi
  # Cleanup any stray processes
  pkill -f "$BIN" 2>/dev/null
  sleep 1
}

start_proxy() {
  if [ ! -f "$BIN" ]; then
    log "ERROR: Binary not found at $BIN"
    echo "Failed: binary missing"
    return 1
  fi

  if [ ! -x "$BIN" ]; then
    chmod 755 "$BIN" 2>/dev/null || {
      log "ERROR: Cannot make binary executable"
      echo "Failed: chmod failed"
      return 1
    }
  fi

  log "Starting $BIN"
  nohup "$BIN" >> "$LOGFILE" 2>&1 &
  NEW_PID=$!
  echo "$NEW_PID" > "$PIDFILE"
  log "Started with PID $NEW_PID"

  # Give it time to initialize
  sleep 2

  if is_running; then
    return 0
  else
    log "ERROR: Process died shortly after start"
    rm -f "$PIDFILE"
    return 1
  fi
}

echo "Action"
log "--- Action triggered ---"

# Always stop first (handles both running and stale PID files)
stop_proxy

if start_proxy; then
  echo "OK"
  log "Result: OK"
  exit 0
else
  echo "Failed"
  log "Result: Failed"
  exit 1
fi