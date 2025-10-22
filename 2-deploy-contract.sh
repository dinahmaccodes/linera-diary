#!/bin/bash
# Terminal 2: Deploy Contract
# Run this AFTER copying export commands from Terminal 1

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║          📔 Terminal 2: Deploy Linera Diary                         ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if environment variables are set
if [ -z "$LINERA_WALLET" ] || [ -z "$LINERA_KEYSTORE" ] || [ -z "$LINERA_STORAGE" ]; then
    echo -e "${RED}✗ ERROR: Environment variables not set!${NC}"
    echo ""
    echo -e "${YELLOW}Please run the export commands from Terminal 1 first:${NC}"
    echo -e "  ${GREEN}export LINERA_WALLET=...${NC}"
    echo -e "  ${GREEN}export LINERA_KEYSTORE=...${NC}"
    echo -e "  ${GREEN}export LINERA_STORAGE=...${NC}"
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

APP_OUTPUT=$(linera project publish-and-create "$WASM_PATH" "$WASM_PATH" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo -e "${RED}✗ Deployment failed!${NC}"
    echo "$APP_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✓ Application deployed!${NC}"
echo ""

# Step 3: Extract IDs
echo -e "${BLUE}Step 3: Extracting Application and Chain IDs...${NC}"

# Extract Application ID (format: bytecode_id:chain_id)
APP_ID=$(echo "$APP_OUTPUT" | grep -oP 'e476[a-f0-9]+:[a-f0-9]+' | head -1)

if [ -z "$APP_ID" ]; then
    echo -e "${YELLOW}⚠ Could not auto-extract Application ID from:${NC}"
    echo "$APP_OUTPUT"
    echo ""
    echo -e "${YELLOW}Please manually find the Application ID in the format: e476xxxxx:xxxxx${NC}"
    read -p "Enter Application ID: " APP_ID
fi

# Get wallet info to extract Chain ID
WALLET_OUTPUT=$(linera wallet show 2>&1)

# Extract default Chain ID
CHAIN_ID=$(echo "$WALLET_OUTPUT" | grep -oP 'Default:\s+\K[a-f0-9]+' | head -1)

if [ -z "$CHAIN_ID" ]; then
    # Try alternate pattern
    CHAIN_ID=$(echo "$WALLET_OUTPUT" | grep -oP '│\s+\K[a-f0-9]{64}' | head -1)
fi

if [ -z "$CHAIN_ID" ]; then
    echo -e "${YELLOW}⚠ Could not auto-extract Chain ID${NC}"
    echo "$WALLET_OUTPUT"
    echo ""
    read -p "Enter Chain ID: " CHAIN_ID
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    📋 Deployment Information                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Application ID:${NC} ${YELLOW}$APP_ID${NC}"
echo -e "${BLUE}Chain ID:${NC} ${YELLOW}$CHAIN_ID${NC}"
echo ""

# Step 4: Update frontend configuration
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

# Step 5: Save deployment info
cat > DEPLOYMENT_INFO.md << EOF
# Linera Diary - Deployment Information

**Deployment Date:** $(date)

## Application Details

- **Application ID:** \`${APP_ID}\`
- **Chain ID:** \`${CHAIN_ID}\`
- **Network:** Local Development (linera net up)

## GraphQL Endpoint

\`\`\`
http://localhost:8080/chains/${CHAIN_ID}/applications/${APP_ID}
\`\`\`

## Service Commands

### Start Linera Service

\`\`\`bash
# Make sure environment variables are still set:
export LINERA_WALLET="${LINERA_WALLET}"
export LINERA_KEYSTORE="${LINERA_KEYSTORE}"
export LINERA_STORAGE="${LINERA_STORAGE}"

# Start service on port 8080
linera service --port 8080
\`\`\`

### Start Frontend

\`\`\`bash
# Option 1: Simple HTTP server (Python)
python3 -m http.server 3000 -d client

# Option 2: Open directly
open client/index.html
\`\`\`

## Next Steps

1. Keep Terminal 1 (network) running
2. In a new terminal, export the environment variables above
3. Run: \`linera service --port 8080\`
4. Open frontend: \`http://localhost:3000\` (or open client/index.html)
5. Initialize your diary with a secret phrase
6. Start journaling! 📝

## Test GraphQL

\`\`\`bash
curl -X POST http://localhost:8080/chains/${CHAIN_ID}/applications/${APP_ID} \\
  -H "Content-Type: application/json" \\
  -d '{"query":"{ isInitialized }"}'
\`\`\`
EOF

echo -e "${GREEN}✓ Deployment info saved: DEPLOYMENT_INFO.md${NC}"
echo ""

# Final instructions
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                   🎉 Deployment Successful!                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo -e "1. ${BLUE}Keep Terminal 1 running${NC} (the network must stay active)"
echo ""
echo -e "2. ${BLUE}In a NEW terminal, start the service:${NC}"
echo -e "   ${GREEN}export LINERA_WALLET=\"$LINERA_WALLET\"${NC}"
echo -e "   ${GREEN}export LINERA_KEYSTORE=\"$LINERA_KEYSTORE\"${NC}"
echo -e "   ${GREEN}export LINERA_STORAGE=\"$LINERA_STORAGE\"${NC}"
echo -e "   ${GREEN}linera service --port 8080${NC}"
echo ""
echo -e "3. ${BLUE}Open the frontend:${NC}"
echo -e "   ${GREEN}python3 -m http.server 3000 -d client${NC}"
echo -e "   Then visit: ${YELLOW}http://localhost:3000${NC}"
echo ""
echo -e "4. ${BLUE}Initialize your diary and start journaling!${NC} 📝"
echo ""
echo -e "${BLUE}Full deployment details saved in:${NC} ${YELLOW}DEPLOYMENT_INFO.md${NC}"
echo ""
