#!/bin/bash

set -e

echo "🍚🔥 Installing Chaufa... 🥢🍳"
echo ""

mkdir -p ~/.local/bin
echo "🥢 Checking required dependencies..."
for cmd in playerctl chafa curl; do
    if ! command -v $cmd &> /dev/null; then
        echo "🍳 Installing dependency: $cmd"
        sudo apt-get update
        sudo apt-get install -y $cmd
    else
        echo "✅ $cmd is already installed."
    fi
done

cp music-center.sh ~/.local/bin/chaufa
chmod +x ~/.local/bin/chaufa
mkdir -p ~/.local/share/chaufa/images
cp images/default.png ~/.local/share/chaufa/images/default.png

echo ""
echo "✅ Installation complete. Chaufa is served 🍚🍳🔥"
echo ""
echo "🥢 You can now run the program with:"
echo "   chaufa"
echo ""
echo "If you see 'command not found', add ~/.local/bin to your PATH:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Enjoy your Chaufa music center 🍚🥢🍳"

