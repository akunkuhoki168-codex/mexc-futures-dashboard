#!/usr/bin/env bash
# Idempotent: starts push.py as a detached background loop unless it is already running.
cd "$(dirname "$0")" || exit 1
if [ -z "${GH_TOKEN_NEW:-}" ]; then
  echo "start_push.sh: GH_TOKEN_NEW is not set; refusing to start" >&2
  exit 1
fi
export GH_TOKEN_NEW
PIDF=push.pid
if [ -f "$PIDF" ]; then
  P=$(cat "$PIDF" 2>/dev/null)
  if [ -n "$P" ] && kill -0 "$P" 2>/dev/null && tr '\0' ' ' < /proc/$P/cmdline | grep -q "push.py"; then
    echo "push.py already running (pid $P)"; exit 0
  fi
fi
nohup setsid python3 -u push.py >> push.log 2>&1 < /dev/null &
echo $! > "$PIDF"
sleep 1
echo "started push.py (pid $(cat $PIDF)), log: $(pwd)/push.log"
