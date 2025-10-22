#!/bin/bash
# Start Linera GraphQL service for the diary application

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║          📔 Starting Linera Diary GraphQL Service                    ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if port 8080 is already in use
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}⚠ Port 8080 is already in use${NC}"
    echo -e "${YELLOW}Stop the existing service? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${BLUE}Stopping existing service...${NC}"
        kill $(lsof -t -i:8080) 2>/dev/null || true
        sleep 2
    else
        echo -e "${RED}Cannot start service - port 8080 is occupied${NC}"
        exit 1
    fi
fi

# Read deployment info if available
if [ -f "DEPLOYMENT_INFO.md" ]; then
    APP_ID=$(grep "Application ID:" DEPLOYMENT_INFO.md | grep -oP '\`\K[^`]+')
    CHAIN_ID=$(grep "Chain ID:" DEPLOYMENT_INFO.md | grep -oP '\`\K[^`]+')
    
    if [ ! -z "$APP_ID" ] && [ ! -z "$CHAIN_ID" ]; then
        echo -e "${GREEN}✓ Found deployment info${NC}"
        echo -e "  ${YELLOW}Application ID:${NC} $APP_ID"
        echo -e "  ${YELLOW}Chain ID:${NC} $CHAIN_ID"
        echo ""
    fi
fi

echo -e "${BLUE}Starting Linera service on port 8080...${NC}"
echo -e "${YELLOW}GraphQL endpoint will be available at:${NC}"
echo -e "  ${GREEN}http://localhost:8080${NC}"

if [ ! -z "$CHAIN_ID" ] && [ ! -z "$APP_ID" ]; then
    echo -e "${YELLOW}Your diary GraphQL endpoint:${NC}"
    echo -e "  ${GREEN}http://localhost:8080/chains/$CHAIN_ID/applications/$APP_ID${NC}"
fi

echo ""
echo -e "${BLUE}Press Ctrl+C to stop the service${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Start the service
linera service --port 8080
