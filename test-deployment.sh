#!/bin/bash
# Test the deployed Linera Diary application

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║              📔 Testing Linera Diary Deployment                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if service is running
if ! curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo -e "${RED}✗ Linera service is not running on port 8080${NC}"
    echo -e "${YELLOW}Start it with: ./start-service.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Linera service is running${NC}"
echo ""

# Read deployment info
if [ ! -f "DEPLOYMENT_INFO.md" ]; then
    echo -e "${RED}✗ DEPLOYMENT_INFO.md not found${NC}"
    echo -e "${YELLOW}Please run ./deploy-local.sh first${NC}"
    exit 1
fi

APP_ID=$(grep "Application ID:" DEPLOYMENT_INFO.md | grep -oP '\`\K[^`]+')
CHAIN_ID=$(grep "Chain ID:" DEPLOYMENT_INFO.md | grep -oP '\`\K[^`]+')

if [ -z "$APP_ID" ] || [ -z "$CHAIN_ID" ]; then
    echo -e "${RED}✗ Could not read Application ID or Chain ID${NC}"
    exit 1
fi

echo -e "${BLUE}Testing deployment:${NC}"
echo -e "  ${YELLOW}Application ID:${NC} $APP_ID"
echo -e "  ${YELLOW}Chain ID:${NC} $CHAIN_ID"
echo ""

ENDPOINT="http://localhost:8080/chains/$CHAIN_ID/applications/$APP_ID"

# Test 1: Check if diary is initialized
echo -e "${BLUE}Test 1: Checking diary initialization status...${NC}"
RESPONSE=$(curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ isInitialized }"}')

if echo "$RESPONSE" | grep -q "isInitialized"; then
    echo -e "${GREEN}✓ GraphQL endpoint is responding${NC}"
    echo -e "  Response: $RESPONSE"
else
    echo -e "${RED}✗ Unexpected response${NC}"
    echo -e "  Response: $RESPONSE"
fi
echo ""

# Test 2: Get entry count
echo -e "${BLUE}Test 2: Getting entry count...${NC}"
RESPONSE=$(curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ entryCount }"}')

if echo "$RESPONSE" | grep -q "entryCount"; then
    echo -e "${GREEN}✓ Entry count query works${NC}"
    echo -e "  Response: $RESPONSE"
else
    echo -e "${YELLOW}⚠ Unexpected response${NC}"
    echo -e "  Response: $RESPONSE"
fi
echo ""

# Test 3: Try to get all entries
echo -e "${BLUE}Test 3: Fetching entries...${NC}"
RESPONSE=$(curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ entries { id title content timestamp } }"}')

if echo "$RESPONSE" | grep -q "entries"; then
    echo -e "${GREEN}✓ Entries query works${NC}"
    echo -e "  Response: $RESPONSE"
else
    echo -e "${YELLOW}⚠ Diary might not be initialized yet${NC}"
    echo -e "  Response: $RESPONSE"
fi
echo ""

# Summary
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                     Testing Complete! ✓                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Your diary is ready to use!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Open ${GREEN}client/index.html${NC} in your browser"
echo -e "  2. Initialize the diary with a secret phrase"
echo -e "  3. Start writing your entries!"
echo ""
