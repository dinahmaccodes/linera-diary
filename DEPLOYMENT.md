# 📔 Linera Diary - Deployment Guide

Complete guide to build, deploy, and run the Linera Diary application.

## 🚀 Quick Start (Local Development)

The fastest way to get started:

```bash
# 1. Build the application
./build.sh

# 2. Deploy to local network
./deploy-local.sh

# 3. Start the GraphQL service (in a new terminal)
./start-service.sh

# 4. Test the deployment
./test-deployment.sh

# 5. Open the web interface
open client/index.html
# Or serve with Python: python3 -m http.server 3000 -d client
```

That's it! Your diary is ready to use. 🎉

---

## 📋 Prerequisites

Ensure you have the following installed:

- ✅ **Linera CLI** (v0.15.4 or later)
  ```bash
  linera --version
  ```
  
- ✅ **Rust toolchain** (1.79.0+)
  ```bash
  rustc --version
  ```
  
- ✅ **wasm32-unknown-unknown target**
  ```bash
  rustup target add wasm32-unknown-unknown
  ```

- ✅ **Build tools**
  - macOS: `xcode-select --install`
  - Linux: `sudo apt install build-essential`

---

## 🛠️ Deployment Scripts

We provide several scripts to streamline the deployment process:

### `build.sh`
Builds the WASM binaries with automatic checks and verification.

```bash
./build.sh
```

**What it does:**
- Checks for Rust and WASM target
- Builds the contract and service to WASM
- Verifies output files
- Shows build size and location

### `deploy-local.sh`
Complete automated deployment to local development network.

```bash
./deploy-local.sh
```

**What it does:**
- Runs build.sh automatically
- Starts/checks local Linera network
- Publishes and creates the application
- Extracts Application ID and Chain ID
- Generates frontend configuration
- Creates DEPLOYMENT_INFO.md with all details

### `start-service.sh`
Starts the Linera GraphQL service on port 8080.

```bash
./start-service.sh
```

**What it does:**
- Checks if port 8080 is available
- Reads deployment info
- Starts the GraphQL service
- Shows the endpoint URLs

### `test-deployment.sh`
Tests that your deployment is working correctly.

```bash
./test-deployment.sh
```

**What it does:**
- Checks if service is running
- Tests GraphQL queries
- Verifies diary endpoints
- Shows deployment status

---

## 📖 Step-by-Step Manual Deployment

If you prefer to understand each step or need to customize the deployment:

### Step 1: Build the Application

```bash
cd backend
cargo build --release --target wasm32-unknown-unknown
cd ..
```

**Output location:**
- `backend/target/wasm32-unknown-unknown/release/diary_backend.wasm`

### Step 2: Start Local Network

```bash
linera net up --testing-prng-seed 37
```

**This command:**
- Starts a local Linera validator
- Creates test wallets
- Sets up development environment
- Uses consistent seed for reproducibility

**Check network status:**

```bash
linera wallet show
```

### Step 3: Deploy the Application

```bash
linera project publish-and-create \
  backend/target/wasm32-unknown-unknown/release/diary_backend.wasm \
  backend/target/wasm32-unknown-unknown/release/diary_backend.wasm
```

**Note:** We use the same WASM file for both contract and service since Linera v0.15+ uses a unified binary approach.

**Save the Application ID** from the output - it looks like:
```text
e476187f6ddfeb9d588c7b45d3df334d5501d6499b3f9ad5595cae86cce16a65:0
```

### Step 4: Get Your Chain ID

```bash
linera wallet show
```

Look for "Default chain" or "Chain ID" in the output.

Look for "Default chain" or "Chain ID" in the output.

### Step 5: Configure the Frontend

Create or update `client/config.js`:

```javascript
export const CONFIG = {
  APPLICATION_ID: 'YOUR_APPLICATION_ID_HERE',
  CHAIN_ID: 'YOUR_CHAIN_ID_HERE',
  SERVICE_URL: 'http://localhost:8080',
  GRAPHQL_ENDPOINT: `http://localhost:8080/chains/YOUR_CHAIN_ID/applications/YOUR_APP_ID`,
  MAX_TITLE_LENGTH: 100,
  MAX_CONTENT_LENGTH: 5000,
  TOAST_DURATION: 3000,
};
```

Replace `YOUR_APPLICATION_ID_HERE` and `YOUR_CHAIN_ID_HERE` with actual values.

### Step 6: Start the GraphQL Service

```bash
linera service --port 8080
```

Keep this running in a terminal.

### Step 7: Open the Frontend

In a new terminal or browser:

```bash
# Option 1: Direct file open
open client/index.html

# Option 2: Use a local server (recommended)
python3 -m http.server 3000 -d client
# Then visit: http://localhost:3000
```

---

## 🧪 Testing Your Deployment

### Test 1: Check GraphQL Endpoint

```bash
# Replace <CHAIN_ID> and <APP_ID> with your values
curl -X POST http://localhost:8080/chains/<CHAIN_ID>/applications/<APP_ID> \
  -H "Content-Type: application/json" \
  -d '{"query": "{ isInitialized }"}'
```

**Expected response:**
```json
{
  "data": {
    "isInitialized": false
  }
}
```

### Test 2: Initialize the Diary

Use the web interface or GraphQL:

```bash
curl -X POST http://localhost:8080/chains/<CHAIN_ID>/applications/<APP_ID> \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { initialize(secretPhrase: \"my-secret-phrase-123\") { success message } }"
  }'
```

### Test 3: Add an Entry

```bash
curl -X POST http://localhost:8080/chains/<CHAIN_ID>/applications/<APP_ID> \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { addEntry(secretPhrase: \"my-secret-phrase-123\", title: \"My First Entry\", content: \"Hello Linera!\") { success message } }"
  }'
```

### Test 4: Query All Entries

```bash
curl -X POST http://localhost:8080/chains/<CHAIN_ID>/applications/<APP_ID> \
  -H "Content-Type: application/json" \
  -d '{"query": "{ entries { id title content timestamp } }"}'
```

---

## 🌐 Production Deployment (Testnet)

### Prerequisites for Testnet

1. **Find an active testnet faucet URL**
   - Check Linera Discord/community for current testnet info
   - Testnet URLs change periodically

2. **Initialize wallet with testnet**

```bash
# Example (URL will vary)
linera wallet init --faucet https://faucet.testnet-XXX.linera.net
```

### Build for Production

```bash
./build.sh
```

### Deploy to Testnet

```bash
# Build is same, but network is different
# Make sure your wallet is connected to testnet
linera project publish-and-create \
  backend/target/wasm32-unknown-unknown/release/diary_backend.wasm \
  backend/target/wasm32-unknown-unknown/release/diary_backend.wasm
```

### Start Service for Testnet

```bash
# Service connects to your configured network
linera service --port 8080
```

### Update Frontend for Testnet

Update `client/config.js` with testnet values:

```javascript
export const CONFIG = {
  APPLICATION_ID: 'YOUR_TESTNET_APP_ID',
  CHAIN_ID: 'YOUR_TESTNET_CHAIN_ID',
  SERVICE_URL: 'https://your-testnet-service-url.com',  // Update this
  GRAPHQL_ENDPOINT: `https://your-testnet-service-url.com/chains/...`,
  // ... rest of config
};
```

---

## 🔧 Troubleshooting

### Build Errors

**Error: `linker 'cc' not found`**

```bash
# Ubuntu/Debian
sudo apt install build-essential

# macOS
xcode-select --install
```

**Error: `could not find wasm32-unknown-unknown`**

```bash
rustup target add wasm32-unknown-unknown
```

**Error: `no such file or directory: diary_contract.wasm`**

The correct filename is `diary_backend.wasm`. Our build scripts use the correct name.

### Deployment Errors

**Error: `wallet doesn't exist`**

```bash
# For local development
linera net up

# For testnet (need active faucet URL)
linera wallet init --faucet <TESTNET_FAUCET_URL>
```

**Error: `No default chain`**

```bash
# Check wallet status
linera wallet show

# If no chains, create one (local development)
linera net up
```

### Runtime Errors

**Service not responding**

```bash
# Check if service is running
ps aux | grep linera

# Restart service
pkill linera
./start-service.sh
```

**GraphQL errors**

- Verify Application ID and Chain ID are correct
- Check service is running: `curl http://localhost:8080`
- Review service logs for errors

**Frontend not connecting**

- Check browser console for errors
- Verify `client/config.js` has correct IDs
- Ensure service is running on port 8080
- Try clearing browser cache

---

## 📊 Common Commands

### Wallet Management

```bash
# Show wallet info
linera wallet show

# Check balance
linera query-balance

# Sync chain state
linera sync
```

### Network Management

```bash
# Start local network
linera net up

# Stop local network
linera net down

# Clean wallet data (careful!)
rm -rf ~/.config/linera
```

### Application Management

```bash
# List applications
linera wallet show

# Query application
curl -X POST http://localhost:8080/chains/<CHAIN_ID>/applications/<APP_ID> \
  -H "Content-Type: application/json" \
  -d '{"query": "{ entryCount }"}'
```

---

---

## 📚 Project Structure

```text
linera-diary/
├── backend/
│   ├── src/
│   │   ├── contract.rs      # Business logic
│   │   ├── service.rs       # GraphQL queries
│   │   ├── state.rs         # State management
│   │   └── lib.rs           # ABI definitions
│   ├── Cargo.toml
│   └── tests/
│       └── single_chain.rs  # Integration tests
├── client/
│   ├── index.html          # Main UI
│   ├── styles.css          # Styling
│   ├── api.js              # GraphQL client
│   ├── app.js              # App logic
│   └── config.js           # Configuration (auto-generated)
├── build.sh                # Build WASM binaries
├── deploy-local.sh         # Deploy to local network
├── start-service.sh        # Start GraphQL service
├── test-deployment.sh      # Test deployment
├── DEPLOYMENT_INFO.md      # Generated deployment info
└── README.md               # Project documentation
```

---

## 🎯 Deployment Checklist

### For Local Development

- [ ] Install prerequisites (Rust, Linera CLI, WASM target)
- [ ] Run `./build.sh` to compile
- [ ] Run `./deploy-local.sh` to deploy
- [ ] Run `./start-service.sh` in a separate terminal
- [ ] Open `client/index.html` in browser
- [ ] Test with `./test-deployment.sh`

### For Testnet Deployment

- [ ] Get testnet faucet URL from community
- [ ] Initialize wallet: `linera wallet init --faucet <URL>`
- [ ] Run `./build.sh` to compile
- [ ] Deploy with `linera project publish-and-create ...`
- [ ] Note Application ID and Chain ID
- [ ] Update `client/config.js` with testnet values
- [ ] Start service: `linera service --port 8080`
- [ ] Host frontend (GitHub Pages, Vercel, etc.)
- [ ] Test thoroughly
- [ ] Document deployment info

---

## 🚨 Important Notes

### Security

- **Secret Phrase**: Cannot be recovered if lost - store securely!
- **On-Chain Storage**: All entries are permanent on the blockchain
- **Privacy**: Consider the public nature of blockchain data

### Performance

- **Local Network**: Fast, great for development
- **Testnet**: Slower, used for testing in production-like environment
- **Mainnet**: Production use, requires careful planning

### Best Practices

1. **Test locally first**: Always test on local network before testnet
2. **Backup wallet keys**: Keep your wallet backup safe
3. **Document deployments**: Save Application IDs and Chain IDs
4. **Version control**: Commit working code before deploying
5. **Monitor logs**: Check service logs for errors

---

## 📞 Getting Help

### Resources

- **Linera Documentation**: https://linera.dev
- **Linera Discord**: Join for community support and testnet info
- **GitHub Issues**: Report bugs or request features
- **API Documentation**: See `API.md` in this repo

### Common Issues & Solutions

**Issue**: "Wallet doesn't exist"
- **Solution**: Run `linera net up` for local or `linera wallet init --faucet <URL>` for testnet

**Issue**: "Application not found"
- **Solution**: Verify Application ID and Chain ID in config.js match deployment

**Issue**: "Connection refused"
- **Solution**: Ensure `linera service` is running on port 8080

**Issue**: "GraphQL query fails"
- **Solution**: Check diary is initialized with secret phrase first

---

## 🎉 Success!

Once deployed successfully, you'll have:

✅ A fully functional diary application on Linera blockchain  
✅ GraphQL API for querying and mutations  
✅ Beautiful web interface for easy interaction  
✅ Secure secret-phrase protection  
✅ Permanent, immutable storage of your entries  

**Happy journaling! 📝**

---

**Last Updated**: October 2025  
**Linera Version**: v0.15.4  
**Project**: Linera Diary
