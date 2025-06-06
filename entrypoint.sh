#!/bin/bash

# Clear screen and scrollback buffer
clear
printf "\033[3J"

# Reset terminal colors
tput reset

echo -e "\033[1;32m[Rust Container] Starting up...\033[0m"

cd /home/container || exit 1

echo "ENTRYPOINT: FRAMEWORK=${FRAMEWORK} FRAMEWORK_UPDATE=${FRAMEWORK_UPDATE}"

# Get public IP
PUBLIC_IP=$(curl -s https://icanhazip.com)

# Display sleek intro
echo "
==========================================
         Rust Server Manager v1.0
==========================================

  Framework: ${FRAMEWORK:-none}
  Auto-Update: ${FRAMEWORK_UPDATE:-disabled}
  Public IP: ${PUBLIC_IP}

  [✓] Container initialized
  [✓] Environment ready
==========================================

"

export INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2); exit}')

# Create logs folder and log file
DATE=$(date +%Y-%m-%d_%H-%M-%S)
LOGFILE="logs/ServerLog-${DATE}.log"
mkdir -p "$(dirname "$LOGFILE")"

# --- Step 1: Always update game first ---
echo ">>> Auto-updating Rust..."
./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit

echo "
"

# --- Step 2: Framework handling (AFTER game install to avoid overwriting mods) ---

if [[ "${FRAMEWORK}" == "oxide" && "${FRAMEWORK_UPDATE}" == "1" ]]; then
    echo "
==========================================
            Oxide Framework
=========================================="

    if ls RustDedicated_Data/Managed 2>/dev/null | grep -qi "Carbon"; then
        echo "  [1/3] Removing Carbon integration files..."
        # Remove Carbon integration files but preserve the carbon folder
        rm -f ./libdoorstop.so ./doorstop_config.ini ./Carbon.targets ./carbon.sh
        rm -rf ./HarmonyMods
        rm -f ./harmony_log.txt
        find ./RustDedicated_Data/Managed -type f -iname "*Carbon*" -exec rm -f {} \;
        echo "  [✓] Carbon integration files removed"
        echo "  [i] Note: The 'carbon' folder has been preserved. You can manually remove it"
        echo "      if you no longer need it, but it's safe to keep for future use."
    else
        echo "  [1/3] No Carbon installation detected"
    fi

    echo "  [2/3] Downloading Oxide/uMod..."
    OXIDE_URL="https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip"
    OXIDE_ZIP="umod.zip"
    curl -sSL "$OXIDE_URL" -o "$OXIDE_ZIP"

    if [ ! -s "$OXIDE_ZIP" ]; then
        echo "  [✗] Failed to download Oxide ZIP"
        exit 1
    fi

    echo "  [3/3] Installing Oxide/uMod..."
    unzip -o "$OXIDE_ZIP" -d /home/container >/dev/null
    sync
    rm -f "$OXIDE_ZIP"

    if [ -f "RustDedicated_Data/Managed/Oxide.Core.dll" ] && [ -d "oxide" ]; then
        echo "  [✓] Oxide installation completed successfully"
    else
        echo "  [✗] Oxide installation failed"
        exit 1
    fi

    echo ""

elif [[ "${FRAMEWORK}" == "carbon" && "${FRAMEWORK_UPDATE}" == "1" ]]; then
    echo "
==========================================
            Carbon Framework
==========================================

"

    if [ -f "./carbon/managed/Carbon.Preloader.dll" ]; then
        echo "  [✓] Carbon already installed"
    else
        if [ -d "oxide" ]; then
            echo "  [1/3] Removing Oxide integration files..."
            # Remove Oxide integration files but preserve the oxide folder
            find ./RustDedicated_Data/Managed -type f -iname "*Oxide*" -exec rm -f {} \;
            echo "  [✓] Oxide integration files removed"
            echo "  [i] Note: The 'oxide' folder has been preserved. You can manually remove it"
            echo "      if you no longer need it, but it's safe to keep for future use."
        fi

        echo "  [2/3] Downloading Carbon..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar -xz
        
        if [ ! -f "./carbon/managed/Carbon.Preloader.dll" ]; then
            echo "  [✗] Carbon installation failed"
            exit 1
        fi
        
        export DOORSTOP_ENABLED=1
        export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/carbon/managed/Carbon.Preloader.dll"
        echo "  [3/3] Carbon installation completed"
    fi
else
    echo "  [i] No framework changes required (FRAMEWORK=${FRAMEWORK})"
fi

# --- Step 3: Handle extensions ---
if [ "${FRAMEWORK}" == "oxide" ] || [ "${FRAMEWORK}" == "carbon" ]; then
    echo "
==========================================
            Extensions Setup
=========================================="

    # Create plugin directories if they don't exist
    if [ "${FRAMEWORK}" == "oxide" ]; then
        mkdir -p ./oxide/plugins
        PLUGIN_DIR="./oxide/plugins"
    elif [ "${FRAMEWORK}" == "carbon" ]; then
        mkdir -p ./carbon/plugins
        PLUGIN_DIR="./carbon/plugins"
    fi

    # Handle ChaosCode extension
    if [ "${CHAOS_EXT}" == "1" ]; then
        echo "  [i] Installing ChaosCode extension..."
        curl -sSL "https://raw.githubusercontent.com/ChaosCodeTeam/ChaosCode/master/ChaosCode.cs" -o "${PLUGIN_DIR}/ChaosCode.cs"
    else
        echo "  [i] Removing ChaosCode extension..."
        rm -f "${PLUGIN_DIR}/ChaosCode.cs"
    fi

    # Handle Discord extension
    if [ "${DISCORD_EXT}" == "1" ]; then
        echo "  [i] Installing Discord extension..."
        curl -sSL "https://raw.githubusercontent.com/ChaosCodeTeam/DiscordExtension/master/DiscordExtension.cs" -o "${PLUGIN_DIR}/DiscordExtension.cs"
    else
        echo "  [i] Removing Discord extension..."
        rm -f "${PLUGIN_DIR}/DiscordExtension.cs"
    fi

    # Handle RustEdit extension
    if [ "${RUSTEDIT_EXT}" == "1" ]; then
        echo "  [i] Installing RustEdit extension..."
        curl -sSL "https://raw.githubusercontent.com/ChaosCodeTeam/RustEdit/master/RustEdit.cs" -o "${PLUGIN_DIR}/RustEdit.cs"
    else
        echo "  [i] Removing RustEdit extension..."
        rm -f "${PLUGIN_DIR}/RustEdit.cs"
    fi

    # Verify extensions
    echo "
  [✓] Extension status:"
    if [ "${CHAOS_EXT}" == "1" ]; then
        if [ -f "${PLUGIN_DIR}/ChaosCode.cs" ]; then
            echo "      - ChaosCode: Installed"
        else
            echo "      - ChaosCode: Failed to install"
        fi
    else
        echo "      - ChaosCode: Not installed"
    fi

    if [ "${DISCORD_EXT}" == "1" ]; then
        if [ -f "${PLUGIN_DIR}/DiscordExtension.cs" ]; then
            echo "      - Discord: Installed"
        else
            echo "      - Discord: Failed to install"
        fi
    else
        echo "      - Discord: Not installed"
    fi

    if [ "${RUSTEDIT_EXT}" == "1" ]; then
        if [ -f "${PLUGIN_DIR}/RustEdit.cs" ]; then
            echo "      - RustEdit: Installed"
        else
            echo "      - RustEdit: Failed to install"
        fi
    else
        echo "      - RustEdit: Not installed"
    fi
fi

echo "
"

# --- Final startup ---
export LD_LIBRARY_PATH=$(pwd)/RustDedicated_Data/Plugins/x86_64:$(pwd)

MODIFIED_STARTUP=$(eval echo $(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g'))
MODIFIED_STARTUP="${MODIFIED_STARTUP} -logfile ${LOGFILE}"

echo ":/home/container$ ${MODIFIED_STARTUP}"
node /wrapper.js "${MODIFIED_STARTUP}"

