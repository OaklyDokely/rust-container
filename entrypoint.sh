#!/bin/bash

cd /mnt/server

# Optional: print something on start
echo "Starting Rust server..."

# Ensure Carbon/Oxide is in place if needed (lightweight check)
if [[ "$FRAMEWORK" == "carbon"* && ! -d "/mnt/server/carbon" ]]; then
    echo "[entrypoint] Warning: Carbon directory not found."
fi

# Run the main process
exec ./RustDedicated -batchmode "$@"
