#!/bin/bash
# Build script for Linera Diary application
# Compiles the backend to WASM with proper checks

set -e  # Exit on error

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║              📔 Building Linera Diary Application                    ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if we're in the right directory
if [ ! -d "backend" ]; then
    echo -e "${RED}✗ Error: backend directory not found${NC}"
    echo -e "${YELLOW}Please run this script from the project root${NC}"
    exit 1
fi

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}✗ Error: Cargo not found${NC}"
    echo -e "${YELLOW}Please install Rust: https://rustup.rs/${NC}"
    exit 1
fi

# Check if wasm32 target is installed
echo -e "${BLUE}Checking WASM target...${NC}"
if ! rustup target list --installed | grep -q "wasm32-unknown-unknown"; then
    echo -e "${YELLOW}Installing wasm32-unknown-unknown target...${NC}"
    rustup target add wasm32-unknown-unknown
    echo -e "${GREEN}✓ Target installed${NC}"
else
    echo -e "${GREEN}✓ WASM target already installed${NC}"
fi
echo ""

# Build the application
echo -e "${BLUE}Building WASM binaries...${NC}"
echo -e "${YELLOW}This may take a few minutes on first build...${NC}"
echo ""

cargo build --release --target wasm32-unknown-unknown

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Build successful!${NC}"
echo ""

# Verify output files
echo -e "${BLUE}Verifying WASM outputs...${NC}"
CONTRACT_WASM="target/wasm32-unknown-unknown/release/diary_backend.wasm"

if [ -f "$CONTRACT_WASM" ]; then
    SIZE=$(du -h "$CONTRACT_WASM" | cut -f1)
    echo -e "${GREEN}✓ Contract WASM: $CONTRACT_WASM ($SIZE)${NC}"
else
    echo -e "${RED}✗ Contract WASM not found: $CONTRACT_WASM${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Build Complete! 🎉                                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next step: Deploy to testnet${NC}"
echo -e "  linera publish-and-create \\"
echo -e "    target/wasm32-unknown-unknown/release/diary_backend.wasm \\"
echo -e "    target/wasm32-unknown-unknown/release/diary_backend.wasm"
echo ""
