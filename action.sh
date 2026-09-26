#!/system/bin/sh
MODDIR=${0%/*}
BIN="$MODDIR/system/bin/Abdullah"
PIDFILE="$MODDIR/proxy.pid"
LOGFILE="$MODDIR/proxy.log"

# ---------- UI helpers ----------
# Use $'...' so the escape is stored as a real ESC byte, not literal "\033"
R=$'\033[0;31m'; G=$'\033[0;32m'; Y=$'\033[1;33m'
B=$'\033[0;34m'; C=$'\033[0;36m'; M=$'\033[0;35m'
W=$'\033[1;37m'; D=$'\033[0;90m'; N=$'\033[0m'

line()  { printf "%s────────────────────────────────────────%s\n" "$D" "$N"; }
title() { printf "\n%s%s  %s%s\n" "$C" "$W" "$1" "$N"; line; }
ok()    { printf "  %s✔%s  %s\n" "$G" "$N" "$1"; }
warn()  { printf "  %s⚠%s  %s\n" "$Y" "$N" "$1"; }
fail()  { printf "  %s✘%s  %s\n" "$R" "$N" "$1"; }
info()  { printf "  %s•%s  %s\n" "$B" "$N" "$1"; }
dim()   { printf "  %s%s%s\n" "$D" "$1" "$N"; }

banner() {
  printf "%s" "$M"
  printf "  ╔═══════════════════════════════════════════╗\n"
  printf "  ║      %s Blue Whale System Controls%s        ║\n" "$W" "$M"
  printf "  ╚═══════════════════════════════════════════╝\n"
  printf "%s" "$N"
}

spinner() {
  local pid=$1
  local chars='|/-\'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i + 1) % 4 ))
    printf "\r  %s%s%s  %s" "$C" "$(printf '%s' "$chars" | cut -c$((i+1)))" "$N" "$2"
    sleep 0.15
  done
  printf "\r\033[K"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"
}

# ---------- Logic ----------
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
      printf "  %s•%s  Stopping running instance %s(PID %s)%s\n" "$B" "$N" "$D" "$PID" "$N"
      kill -TERM "$PID" 2>/dev/null
      log "Sent SIGTERM to PID $PID"

      ( for i in 1 2 3 4 5; do sleep 1; kill -0 "$PID" 2>/dev/null || break; done ) &
      spinner $! "Waiting for graceful shutdown..."
      wait $! 2>/dev/null

      if kill -0 "$PID" 2>/dev/null; then
        warn "Graceful shutdown timed out, forcing kill"
        kill -9 "$PID" 2>/dev/null
        log "Sent SIGKILL to PID $PID"
      else
        ok "Stopped cleanly"
      fi
    else
      dim "Stale PID file removed"
    fi
    rm -f "$PIDFILE"
  fi
  pkill -f "$BIN" 2>/dev/null
  sleep 1
}

start_proxy() {
  if [ ! -f "$BIN" ]; then
    fail "Binary not found"
    dim "$BIN"
    log "ERROR: Binary not found at $BIN"
    return 1
  fi

  if [ ! -x "$BIN" ]; then
    chmod 755 "$BIN" 2>/dev/null || {
      fail "Cannot make binary executable"
      log "ERROR: chmod failed on $BIN"
      return 1
    }
    ok "Set executable permission"
  fi

  info "Launching service..."
  log "Starting $BIN"
  nohup "$BIN" >> "$LOGFILE" 2>&1 &
  NEW_PID=$!
  echo "$NEW_PID" > "$PIDFILE"

  ( sleep 2 ) &
  spinner $! "Initializing..."
  wait $! 2>/dev/null

  if is_running; then
    printf "  %s✔%s  Running %s(PID %s)%s\n" "$G" "$N" "$D" "$NEW_PID" "$N"
    log "Started with PID $NEW_PID"
    return 0
  else
    fail "Process died shortly after start"
    dim "Check log: $LOGFILE"
    log "ERROR: Process died shortly after start"
    rm -f "$PIDFILE"
    return 1
  fi
}

# ---------- Main ----------
banner
log "--- Action triggered ---"

title "Status"
if is_running; then
  dim "Previous instance detected"
else
  dim "No instance running"
fi

title "Shutdown"
stop_proxy

title "Startup"
if start_proxy; then
  line
  printf "  %s%s● BLUE WHALE IS RUNNING%s\n" "$G" "$W" "$N"
  line
  log "Result: OK"
  exit 0
else
  line
  printf "  %s%s● BLUE WHALE FAILED TO START%s\n" "$R" "$W" "$N"
  line
  log "Result: Failed"
  exit 1
fi