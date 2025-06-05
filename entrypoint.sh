#!/bin/bash

cd /mnt/server

# === LOGGING ===
DATE=$(date +%Y-%m-%d_%H-%M-%S)
DEFAULT_LOGFILE="logs/ServerLog-${DATE}.log"
LOGFILE="${LOG_FILE:-$DEFAULT_LOGFILE}"

mkdir -p "$(dirname "$LOGFILE")"

echo "Logging to: $LOGFILE"

# === AUTO-UPDATE ===
if [ -z "${AUTO_UPDATE}" ] || [ "${AUTO_UPDATE}" == "1" ]; then
    echo "Auto-updating Rust server..."
    ./steamcmd/steamcmd.sh +force_install_dir /mnt/server +login anonymous +app_update 258550 validate +quit
else
    echo "Skipping update — AUTO_UPDATE=${AUTO_UPDATE}"
fi

# === STARTUP COMMAND ===
# Convert {{VAR}} to ${VAR} for eval
MODIFIED_STARTUP=$(eval echo "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")

# Append logfile if not already included
if [[ "$MODIFIED_STARTUP" != *"-logfile"* ]]; then
    MODIFIED_STARTUP="${MODIFIED_STARTUP} -logfile \"${LOGFILE}\""
fi

echo ":/mnt/server$ ${MODIFIED_STARTUP}"

# === START SERVER ===
eval ${MODIFIED_STARTUP}
