#!/bin/bash

cd /home/container || exit 1

# Manually export panel-provided variables
export FRAMEWORK="{{FRAMEWORK}}"
export FRAMEWORK_UPDATE="{{FRAMEWORK_UPDATE}}"

echo "Version 1"

echo "================= ENV DUMP START ================="
env | sort
echo "================= ENV DUMP END ==================="

echo "Installing base Rust server files..."
mkdir -p ./steamcmd
curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C ./steamcmd
./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit

FRAMEWORK_LOWER=$(echo "${FRAMEWORK}" | tr '[:upper:]' '[:lower:]')
echo "Detected FRAMEWORK: '${FRAMEWORK}' → Normalized: '${FRAMEWORK_LOWER}'"
echo "FRAMEWORK_UPDATE: '${FRAMEWORK_UPDATE}'"

if [[ "$FRAMEWORK_LOWER" == carbon* && "$FRAMEWORK_UPDATE" == "1" ]]; then
    echo "Installing Carbon..."
    echo "Removing Oxide-related files..."
    rm -f Oxide.* Compiler.x86_x64
    rm -f RustDedicated_Data/Managed/Oxide.*
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar -xz

elif [[ "$FRAMEWORK_LOWER" == oxide* && "$FRAMEWORK_UPDATE" == "1" ]]; then
    echo "Installing Oxide/uMod..."
    echo "Removing Carbon-related files..."
    rm -rf carbon
    rm -f RustDedicated_Data/Managed/Carbon.*

    curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" -o umod.zip
    unzip -o -q umod.zip -d /home/container && rm umod.zip
    curl -sSL "https://assets.umod.org/compiler/Compiler.x86_x64" -o Compiler.x86_x64
    chmod +x Compiler.x86_x64
else
    echo "⚠️ No framework installation triggered (vanilla, unknown, or disabled)."
    echo "Detected FRAMEWORK_LOWER='${FRAMEWORK_LOWER}' with FRAMEWORK_UPDATE='${FRAMEWORK_UPDATE}'"
fi
