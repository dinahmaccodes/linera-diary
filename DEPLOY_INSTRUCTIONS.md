# 🚀 Quick Deployment Guide

## The Problem with Automated Scripts

Single scripts that try to do everything (like `deploy.sh` or `deploy-complete.sh`) **hang** because:
- `linera net up` is a **blocking operation** that must stay running
- It creates temporary wallet paths that must be exported
- Cannot capture environment variables from background processes

## ✅ The Working Solution: Two-Terminal Approach

This is how **all successful Linera projects deploy**.

### Step 1: Terminal 1 - Start Network (Keep Open!)

```bash
./1-start-network.sh
```

**What happens:**
- Network starts and displays export commands
- Terminal stays open (network running)
- You'll see something like:

```bash
export LINERA_WALLET="/tmp/.tmpXXXXXX/wallet.json"
export LINERA_KEYSTORE="/tmp/.tmpXXXXXX/keystore.json"  
export LINERA_STORAGE="rocksdb:/tmp/.tmpXXXXXX/client.db"
```

**📋 COPY these export commands!**

---

### Step 2: Terminal 2 - Deploy Contract

**In a NEW terminal:**

```bash
# 1. Paste the export commands from Terminal 1
export LINERA_WALLET="/tmp/.tmpXXXXXX/wallet.json"
export LINERA_KEYSTORE="/tmp/.tmpXXXXXX/keystore.json"
export LINERA_STORAGE="rocksdb:/tmp/.tmpXXXXXX/client.db"

# 2. Run deployment
./2-deploy-contract.sh
```

**What happens:**
- Builds WASM contract
- Deploys to network
- Extracts Application ID and Chain ID
- Updates `client/config.js` automatically
- Creates `DEPLOYMENT_INFO.md` with all details

---

### Step 3: Terminal 3 - Start Service

**In ANOTHER new terminal:**

```bash
# 1. Paste the same export commands again
export LINERA_WALLET="/tmp/.tmpXXXXXX/wallet.json"
export LINERA_KEYSTORE="/tmp/.tmpXXXXXX/keystore.json"
export LINERA_STORAGE="rocksdb:/tmp/.tmpXXXXXX/client.db"

# 2. Start GraphQL service
linera service --port 8080
```

Keep this running!

---

### Step 4: Open Frontend

**In ANOTHER terminal (or directly):**

```bash
# Option 1: HTTP Server
python3 -m http.server 3000 -d client
# Then visit: http://localhost:3000

# Option 2: Direct
open client/index.html
```

---

## 📋 What You'll Get

After Step 2 completes successfully, you'll have:

1. **Application ID** - Format: `e476abc123...def:1234567890abc...def`
2. **Chain ID** - Format: `abc123def456...789`
3. **Updated client/config.js** - Automatically configured
4. **DEPLOYMENT_INFO.md** - Full deployment details

## ✅ Success Checklist

- [ ] Terminal 1: Network running (don't close!)
- [ ] Terminal 2: Deployment successful, IDs extracted
- [ ] Terminal 3: Service running on port 8080
- [ ] Terminal 4: Frontend accessible
- [ ] Diary initialized with secret phrase
- [ ] Can add/edit/delete entries

## 🎯 About Testnet vs Local

### Local Deployment (What we're doing)
- ✅ Quick and easy
- ✅ Gives you Application ID and Chain ID
- ✅ Fully functional for development/testing
- ⚠️ Only accessible on your machine
- ⚠️ Data resets when network stops

### Testnet Deployment
- ❌ Requires Discord community access for faucet URL
- ✅ Publicly accessible
- ✅ Persistent data
- ⏱️ Takes longer to set up

**For your submission:** If you just need Application ID and Chain ID, local deployment is perfect! Both are valid Linera blockchain deployments.

## 📝 Common Issues

### "Filesystem error: No such file or directory"
- **Cause:** Wallet paths expired
- **Fix:** The network stopped. Restart from Step 1

### "Connection refused" on GraphQL
- **Cause:** Service not running or wrong port
- **Fix:** Make sure Terminal 3 service is running

### Scripts hang forever
- **Cause:** Trying to automate linera net up in one script
- **Fix:** Use this two-terminal approach

## 🎉 You're Ready!

Run `./1-start-network.sh` in Terminal 1 and follow the steps above!
