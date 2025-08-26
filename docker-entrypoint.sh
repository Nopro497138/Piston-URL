#!/bin/sh
set -e

ISOLATE_DIR="${PISTON_ISOLATE_DIR:-/tmp/isolate}"
mkdir -p "$ISOLATE_DIR" || true
echo "Starting piston — trying common entrypoints. PISTON_ISOLATE_DIR=$ISOLATE_DIR"
echo "NODE_PATH=$NODE_PATH"
echo "Listing /app:"
ls -la /app || true

# show package.json briefly for debug
if [ -f /app/package.json ]; then
  echo "/app/package.json:"
  cat /app/package.json || true
fi

# Make sure node can find local workspace packages
# Expand NODE_PATH if needed (non-glob safe, but helps)
export NODE_PATH=${NODE_PATH:-/app/node_modules}
echo "Effective NODE_PATH: $NODE_PATH"

# Candidate JS entrypoints that appear in this repo
CANDIDATES="/app/api/index.js /app/index.js /app/piston/index.js /app/cli/index.js /app/packages/runner/index.js /piston/index.js"

for f in $CANDIDATES; do
  if [ -f "$f" ]; then
    echo "Found entrypoint: $f — starting node $f"
    exec node "$f"
  fi
done

# fallback to npm start if package.json has start script
if [ -f /app/package.json ]; then
  if grep -q "\"start\"" package.json 2>/dev/null; then
    echo "No direct JS entrypoint found. Attempting npm start..."
    exec npm start
  fi
fi

# Nothing found — print debugging info and keep container alive briefly
echo "ERROR: Could not find piston entrypoint or start script. Listing /app contents for debugging:"
ls -la /app || true
echo "Listing /app/packages:"
ls -la /app/packages || true
echo "Sleeping so you can inspect logs in Render (3600s)..."
exec sleep 3600
