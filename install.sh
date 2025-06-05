#!/bin/bash

cd /mnt/server

if [[ "$FRAMEWORK" == carbon* && "$FRAMEWORK_UPDATE" == 1 ]]; then
    echo "Installing Carbon framework..."
    curl -sSL https://downloads.carbonmod.gg/Carbon/latest/download -o carbon.zip
    unzip carbon.zip -d carbon && rm carbon.zip
elif [[ "$FRAMEWORK" == oxide* && "$FRAMEWORK_UPDATE" == 1 ]]; then
    echo "Installing Oxide/uMod..."
    curl -sSL https://umod.org/games/rust/download/develop -o oxide.zip
    unzip oxide.zip && rm oxide.zip
else
    echo "No framework installation requested."
fi
