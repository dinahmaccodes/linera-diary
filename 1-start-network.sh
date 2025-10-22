#!/bin/bash
# Terminal 1: Start Linera Network
# Keep this terminal open!

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║          📔 Terminal 1: Starting Linera Network                     ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  IMPORTANT: Keep this terminal OPEN during deployment!"
echo ""
echo "After the network starts, you'll see export commands like:"
echo "  export LINERA_WALLET=..."
echo "  export LINERA_KEYSTORE=..."
echo "  export LINERA_STORAGE=..."
echo ""
echo "📋 Copy those export commands and run them in Terminal 2"
echo ""
echo "Starting network now..."
echo ""

linera net up --testing-prng-seed 37
