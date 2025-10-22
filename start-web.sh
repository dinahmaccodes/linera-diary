#!/bin/bash
# 🌐 Start Web App - Quick Launch Script

set -e

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║           🌐 Starting Savings Pot Web Application                   ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if port 8000 is already in use
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port 8000 is already in use."
    echo "   The web server might already be running."
    echo ""
    echo "   Open: http://localhost:8000"
    echo ""
    exit 0
fi

# Start the web server
echo "🚀 Starting web server on port 8000..."
cd examples

# Try Python3 first
if command -v python3 &> /dev/null; then
    echo "   Using Python 3 HTTP server"
    python3 -m http.server 8000 &
    SERVER_PID=$!
# Try Python2 as fallback
elif command -v python &> /dev/null; then
    echo "   Using Python 2 HTTP server"
    python -m SimpleHTTPServer 8000 &
    SERVER_PID=$!
# Try Node.js http-server
elif command -v npx &> /dev/null; then
    echo "   Using Node.js http-server"
    npx http-server -p 8000 &
    SERVER_PID=$!
else
    echo "❌ No suitable web server found!"
    echo "   Please install Python or Node.js"
    exit 1
fi

sleep 2

echo ""
echo "✅ Web server started successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🌐 Open in browser: http://localhost:8000"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 BEFORE USING THE APP:"
echo "   1. Deploy your contract (if not already done)"
echo "   2. Start GraphQL service: linera service --port 8080"
echo "   3. Get your Chain ID: linera wallet show"
echo "   4. Get your Application ID: linera wallet show"
echo "   5. Enter IDs in the web app and click 'Connect'"
echo ""
echo "🛑 To stop the web server: kill $SERVER_PID"
echo "   Or press Ctrl+C"
echo ""

# Try to open in default browser (Linux)
if command -v xdg-open &> /dev/null; then
    echo "🌐 Opening browser..."
    xdg-open http://localhost:8000 2>/dev/null &
elif command -v firefox &> /dev/null; then
    firefox http://localhost:8000 2>/dev/null &
elif command -v google-chrome &> /dev/null; then
    google-chrome http://localhost:8000 2>/dev/null &
fi

echo "Press Ctrl+C to stop the server"
echo ""

# Wait for user to stop
wait $SERVER_PID
