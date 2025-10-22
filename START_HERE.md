# ✅ READY TO DEPLOY - Read This First

## 🎯 Quick Answer: Why Scripts Were Hanging

Your `deploy.sh` and `deploy-complete.sh` scripts hang because they try to run `linera net up` in the background, but:

1. **`linera net up` is blocking** - it must stay running in the foreground
2. **Creates temp wallet paths** - must be copied and exported manually
3. **Can't capture background env vars** - automation doesn't work for this step

## ✅ The Solution: Two Scripts, Two Terminals

I've created **the working approach** used by all successful Linera projects:

### 📂 New Files Created

1. **`1-start-network.sh`** - Starts network in Terminal 1 (keep it open!)
2. **`2-deploy-contract.sh`** - Deploys in Terminal 2 (after copying exports)
3. **`DEPLOY_INSTRUCTIONS.md`** - Full step-by-step guide

## 🚀 Deploy in 3 Minutes

### Terminal 1: Start Network
```bash
./1-start-network.sh
```
- Network starts and shows export commands
- **COPY the export commands** (look like: `export LINERA_WALLET=...`)
- **KEEP THIS TERMINAL OPEN**

### Terminal 2: Deploy
```bash
# Paste the export commands here
export LINERA_WALLET="..."
export LINERA_KEYSTORE="..."
export LINERA_STORAGE="..."

# Run deployment
./2-deploy-contract.sh
```

**✨ That's it!** The script will:
- Build WASM ✅
- Deploy contract ✅
- Extract Application ID ✅
- Extract Chain ID ✅
- Update `client/config.js` ✅
- Create `DEPLOYMENT_INFO.md` ✅

### Terminal 3: Start Service
```bash
# Paste the export commands again
export LINERA_WALLET="..."
export LINERA_KEYSTORE="..."
export LINERA_STORAGE="..."

linera service --port 8080
```

### Open Frontend
```bash
python3 -m http.server 3000 -d client
# Visit: http://localhost:3000
```

## 📋 What You'll Get

After deployment:
- ✅ **Application ID** (format: `e476abc...def:123...456`)
- ✅ **Chain ID** (format: `abc123def456...`)
- ✅ **Working frontend** with auto-configured GraphQL endpoint
- ✅ **DEPLOYMENT_INFO.md** with all details for GitHub

## 💡 About Local vs Testnet

**For Getting Application ID and Chain ID:**

### Local Deployment ✅ (What we're doing)
- Fast and easy
- Gives you valid Application ID and Chain ID
- Fully functional Linera blockchain deployment
- Perfect for development and submissions

### Testnet Deployment (Optional)
- Requires community Discord for faucet URL
- Publicly accessible (not just localhost)
- Data persists longer
- Takes more setup time

**Bottom line:** Local deployment gives you everything you need! Both are real Linera deployments.

## 🔧 Why This Works

**Successful Projects Use This Pattern:**
- [Goodnessukaigwe/saving_pot](https://github.com/Goodnessukaigwe/saving_pot)
- [manoahLinks/LineraGreeter](https://github.com/manoahLinks/LineraGreeter)

Both use: Terminal 1 (network) → Terminal 2 (export vars + deploy)

**Key Insight:** You can't automate `linera net up` + deployment in one script because the network must stay running as a foreground process.

## 📝 Full Documentation

For detailed instructions, troubleshooting, and explanations:
- **Quick start:** Read above (you're ready!)
- **Detailed guide:** See `DEPLOY_INSTRUCTIONS.md`
- **After deployment:** See `DEPLOYMENT_INFO.md` (auto-generated)

## 🎉 Ready to Deploy?

Run this command to start:
```bash
./1-start-network.sh
```

Then follow the prompts! The script tells you exactly what to do next.

---

**Questions?**
- Local deployment gives you Application ID ✅
- Local deployment gives you Chain ID ✅
- Both IDs are valid for your submission ✅
- Frontend will work with these IDs ✅

**Let's deploy! 🚀**
