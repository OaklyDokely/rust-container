#!/bin/bash

cd /home/container || exit 1

echo "
==========================================
         Rust Server Installation
==========================================

  [1/2] Setting up SteamCMD...
"

# Create steamcmd directory and download SteamCMD
if ! mkdir -p ./steamcmd; then
    echo "  [✗] Failed to create steamcmd directory"
    exit 1
fi

if ! curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C ./steamcmd; then
    echo "  [✗] Failed to download or extract SteamCMD"
    exit 1
fi

echo "  [✓] SteamCMD installed successfully

  [2/2] Downloading Rust server files...
"

# Install Rust server files
if ! ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit; then
    echo "  [✗] Failed to install Rust server files"
    exit 1
fi

echo "  [✓] Rust server files installed successfully

  [3/3] Verifying installation...
"

# Verify critical files exist
if [ ! -f "RustDedicated" ]; then
    echo "  [✗] RustDedicated executable not found"
    exit 1
fi

if [ ! -d "RustDedicated_Data" ]; then
    echo "  [✗] RustDedicated_Data directory not found"
    exit 1
fi

echo "
==========================================
  [✓] Rust server installation complete
==========================================
"

