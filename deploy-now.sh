#!/bin/bash
# Complete deployment - Run this in the same terminal where you set LINERA_WALLET, etc.

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║          📔 Linera Diary - Quick Deploy                             ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if environment variables are set
if [ -z "$LINERA_WALLET" ] || [ -z "$LINERA_KEYSTORE" ] || [ -z "$LINERA_STORAGE" ]; then
    echo -e "${RED}✗ ERROR: Environment variables not set!${NC}"
    echo ""
    echo -e "${YELLOW}You need to run this script in the SAME terminal where you ran:${NC}"
    echo -e "  ${GREEN}export LINERA_WALLET=\"/tmp/.tmpSmZVNg/wallet_0.json\"${NC}"
    echo -e "  ${GREEN}export LINERA_KEYSTORE=\"/tmp/.tmpSmZVNg/keystore_0.json\"${NC}"
    echo -e "  ${GREEN}export LINERA_STORAGE=\"rocksdb:/tmp/.tmpSmZVNg/client_0.db\"${NC}"
    echo ""
    echo -e "${YELLOW}Or run all in one command:${NC}"
    echo -e "${GREEN}export LINERA_WALLET=\"/tmp/.tmpSmZVNg/wallet_0.json\" && \\${NC}"
    echo -e "${GREEN}export LINERA_KEYSTORE=\"/tmp/.tmpSmZVNg/keystore_0.json\" && \\${NC}"
    echo -e "${GREEN}export LINERA_STORAGE=\"rocksdb:/tmp/.tmpSmZVNg/client_0.db\" && \\${NC}"
    echo -e "${GREEN}./deploy-now.sh${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Environment variables detected!${NC}"
echo -e "  Wallet: ${YELLOW}$LINERA_WALLET${NC}"
echo ""

# Step 1: Build
echo -e "${BLUE}Step 1: Building WASM contract...${NC}"
cargo build --release --target wasm32-unknown-unknown

if [ ! -f "target/wasm32-unknown-unknown/release/diary_backend.wasm" ]; then
    echo -e "${RED}✗ Build failed - WASM file not found!${NC}"
    exit 1
fi

WASM_SIZE=$(ls -lh target/wasm32-unknown-unknown/release/diary_backend.wasm | awk '{print $5}')
echo -e "${GREEN}✓ Build complete! (${WASM_SIZE})${NC}"
echo ""

# Step 2: Deploy
echo -e "${BLUE}Step 2: Publishing and creating application...${NC}"
echo -e "${YELLOW}This may take a moment...${NC}"
echo ""

WASM_PATH="target/wasm32-unknown-unknown/release/diary_backend.wasm"

# Deploy using linera project publish-and-create
echo -e "${YELLOW}Running: linera project publish-and-create $WASM_PATH $WASM_PATH${NC}"
echo ""

APP_OUTPUT=$(linera project publish-and-create "$WASM_PATH" "$WASM_PATH" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo -e "${RED}✗ Deployment failed!${NC}"
    echo ""
    echo -e "${YELLOW}Output:${NC}"
    echo "$APP_OUTPUT"
    echo ""
    echo -e "${YELLOW}Possible issues:${NC}"
    echo -e "  - Network not running (is Terminal 1 still open with linera net up?)"
    echo -e "  - Wallet paths expired (temp directories cleaned up)"
    echo -e "  - Wrong WASM file path"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Application deployed!${NC}"
echo ""
echo -e "${BLUE}Deployment output:${NC}"
echo "$APP_OUTPUT"
echo ""

# Step 3: Extract IDs
echo -e "${BLUE}Step 3: Extracting Application and Chain IDs...${NC}"

# Extract Application ID - look for pattern like e476...abc:def...123
APP_ID=$(echo "$APP_OUTPUT" | grep -oP 'e476[a-f0-9]+:[a-f0-9]+' | head -1)

if [ -z "$APP_ID" ]; then
    # Try alternate pattern
    APP_ID=$(echo "$APP_OUTPUT" | grep -oP '[a-f0-9]{64}:[a-f0-9]{64}' | head -1)
fi

if [ -z "$APP_ID" ]; then
    echo -e "${YELLOW}⚠ Could not auto-extract Application ID${NC}"
    echo ""
    echo -e "${YELLOW}Please look for the Application ID in the output above.${NC}"
    echo -e "${YELLOW}It should look like: e476xxxxx:xxxxx${NC}"
    echo ""
    read -p "Enter Application ID (or press Enter to skip): " APP_ID
fi

# Get Chain ID from wallet
WALLET_OUTPUT=$(linera wallet show 2>&1)

# Extract default Chain ID
CHAIN_ID=$(echo "$WALLET_OUTPUT" | grep -oP 'Default:\s+\K[a-f0-9]+' | head -1)

if [ -z "$CHAIN_ID" ]; then
    # Try alternate pattern - look for chain ID in wallet output
    CHAIN_ID=$(echo "$WALLET_OUTPUT" | grep -oP '│\s+\K[a-f0-9]{64}' | head -1)
fi

if [ -z "$CHAIN_ID" ]; then
    echo -e "${YELLOW}⚠ Could not auto-extract Chain ID${NC}"
    echo ""
    echo "Wallet output:"
    echo "$WALLET_OUTPUT"
    echo ""
    read -p "Enter Chain ID (or press Enter to skip): " CHAIN_ID
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    📋 Deployment Information                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ ! -z "$APP_ID" ]; then
    echo -e "${BLUE}Application ID:${NC} ${YELLOW}$APP_ID${NC}"
fi

if [ ! -z "$CHAIN_ID" ]; then
    echo -e "${BLUE}Chain ID:${NC} ${YELLOW}$CHAIN_ID${NC}"
fi

echo ""

# Step 4: Update frontend configuration
if [ ! -z "$APP_ID" ] && [ ! -z "$CHAIN_ID" ]; then
    echo -e "${BLUE}Step 4: Updating frontend configuration...${NC}"
    
    cat > client/config.js << EOF
// Linera Diary Configuration
// Auto-generated on: $(date)

export const CONFIG = {
  // Application and Chain IDs
  APPLICATION_ID: '${APP_ID}',
  CHAIN_ID: '${CHAIN_ID}',
  
  // Service configuration
  SERVICE_URL: 'http://localhost:8080',
  GRAPHQL_ENDPOINT: \`http://localhost:8080/chains/${CHAIN_ID}/applications/${APP_ID}\`,
  
  // Application settings
  MAX_TITLE_LENGTH: 100,
  MAX_CONTENT_LENGTH: 5000,
  TOAST_DURATION: 3000,
};

export default CONFIG;
EOF
    
    echo -e "${GREEN}✓ Configuration updated: client/config.js${NC}"
    echo ""
    
    # Save deployment info
    cat > DEPLOYMENT_INFO.md << EOF
# Linera Diary - Deployment Information

**Deployment Date:** $(date)

## Application Details

- **Application ID:** \`${APP_ID}\`
- **Chain ID:** \`${CHAIN_ID}\`
- **Network:** Local Development

## Environment Variables (from Terminal 1)

\`\`\`bash
export LINERA_WALLET="${LINERA_WALLET}"
export LINERA_KEYSTORE="${LINERA_KEYSTORE}"
export LINERA_STORAGE="${LINERA_STORAGE}"
\`\`\`

## GraphQL Endpoint

\`\`\`
http://localhost:8080/chains/${CHAIN_ID}/applications/${APP_ID}
\`\`\`

## Start Service

In a new terminal with the same environment variables:

\`\`\`bash
# Set environment variables
export LINERA_WALLET="${LINERA_WALLET}"
export LINERA_KEYSTORE="${LINERA_KEYSTORE}"
export LINERA_STORAGE="${LINERA_STORAGE}"

# Start service
linera service --port 8080
\`\`\`

## Open Frontend

\`\`\`bash
python3 -m http.server 3000 -d client
# Visit: http://localhost:3000
\`\`\`

## Test GraphQL Query

\`\`\`bash
curl -X POST http://localhost:8080/chains/${CHAIN_ID}/applications/${APP_ID} \\
  -H "Content-Type: application/json" \\
  -d '{"query":"{ isInitialized }"}'
\`\`\`
EOF
    
    echo -e "${GREEN}✓ Deployment info saved: DEPLOYMENT_INFO.md${NC}"
    echo ""
fi

# Final instructions
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                   🎉 Deployment Successful!                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo -e "1. ${BLUE}Keep Terminal 1 running${NC} (where you ran 'linera net up')"
echo ""
echo -e "2. ${BLUE}In a NEW terminal, start the service:${NC}"
echo ""
echo -e "   ${GREEN}export LINERA_WALLET=\"$LINERA_WALLET\"${NC}"
echo -e "   ${GREEN}export LINERA_KEYSTORE=\"$LINERA_KEYSTORE\"${NC}"
echo -e "   ${GREEN}export LINERA_STORAGE=\"$LINERA_STORAGE\"${NC}"
echo -e "   ${GREEN}linera service --port 8080${NC}"
echo ""
echo -e "3. ${BLUE}In another terminal, start the frontend:${NC}"
echo ""
echo -e "   ${GREEN}python3 -m http.server 3000 -d client${NC}"
echo -e "   Then visit: ${YELLOW}http://localhost:3000${NC}"
echo ""
echo -e "4. ${BLUE}Initialize your diary and start journaling!${NC} 📝"
echo ""
echo -e "${BLUE}All details saved in:${NC} ${YELLOW}DEPLOYMENT_INFO.md${NC}"
echo ""
