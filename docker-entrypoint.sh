#!/bin/sh
set -e

# ensure the isolate dir exists and is writable
ISOLATE_DIR="${PISTON_ISOLATE_DIR:-/tmp/isolate}"
mkdir -p "$ISOLATE_DIR"

# Useful debug info (shows up in Render logs)
echo "Starting piston — trying common entrypoints. PISTON_ISOLATE_DIR=$ISOLATE_DIR"
echo "Listing /app:"
ls -la /app || true
echo "Listing /app root files:"
[ -f /app/package.json ] && cat /app/package.json || true

# Candidate entrypoints (adjustable)
CANDIDATES="/app/api/index.js /app/index.js /app/piston/index.js /app/cli/index.js /piston/index.js"

for f in $CANDIDATES; do
  if [ -f "$f" ]; then
    echo "Found entrypoint: $f — starting node $f"
    exec node "$f"
  fi
done

# fallback to npm start if package.json exists
if [ -f /app/package.json ]; then
  echo "No direct JS entrypoint found. Attempting npm start..."
  exec npm start
fi

# Nothing found — print debugging info and sleep to keep container alive for inspection
echo "ERROR: Could not find piston entrypoint. Listing /app contents:"
ls -la /app || true
echo "Listing /:"
ls -la / || true
echo "Sleeping so you can inspect logs in Render..."
exec sleep 3600
