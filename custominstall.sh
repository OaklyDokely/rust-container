#!/bin/bash

cd /home/container || exit 1

echo "=== [Rust Installer] Installing base Rust server files ==="
mkdir -p ./steamcmd
curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C ./steamcmd
./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit

echo "FRAMEWORK selected: $FRAMEWORK"
echo "FRAMEWORK_UPDATE: $FRAMEWORK_UPDATE"

if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
    if [[ "$FRAMEWORK" == oxide* ]]; then
        echo "🧹 Removing Carbon files..."
        rm -rf /home/container/carbon
        find /home/container -type f -name 'Carbon.*' -delete
        echo "✅ Carbon files removed."

        echo "⬇️  Installing Oxide/uMod..."
        curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" -o umod.zip
        unzip -o -q umod.zip -d /home/container && rm umod.zip
        curl -sSL "https://assets.umod.org/compiler/Compiler.x86_x64" -o Compiler.x86_x64
        chmod +x Compiler.x86_x64
        echo "✅ Oxide installed."

    elif [[ "$FRAMEWORK" == carbon* ]]; then
        echo "🧹 Removing Oxide files..."
        find /home/container -type f -name 'Oxide.*' -delete
        find /home/container -type f -name 'Compiler.x86_x64' -delete
        echo "✅ Oxide files removed."

        echo "⬇️  Installing Carbon..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar -xz
        echo "✅ Carbon installed."

    else
        echo "⚠️ Unknown framework: $FRAMEWORK — skipping framework setup."
    fi
else
    echo "ℹ️ Framework updates disabled. Skipping modding framework installation."
fi

