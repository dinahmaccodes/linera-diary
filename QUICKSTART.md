# Linera Diary - Quick Start Guide

## 📋 Prerequisites

Before you begin, make sure you have:

1. **Linera CLI installed** - Follow the [official Linera documentation](https://linera.dev)
2. **Rust toolchain** with `wasm32-unknown-unknown` target
3. **Python 3** (for the simple HTTP server)

## 🚀 Quick Start (3 Steps)

### Step 1: Build the Backend

```bash
cd backend
cargo build --release --target wasm32-unknown-unknown
```

This creates two WASM files:
- `target/wasm32-unknown-unknown/release/diary_contract.wasm`
- `target/wasm32-unknown-unknown/release/diary_service.wasm`

### Step 2: Deploy to Linera

```bash
# Make sure you have a Linera wallet set up
linera wallet show

# Publish and create the application
linera publish-and-create \
  target/wasm32-unknown-unknown/release/diary_contract.wasm \
  target/wasm32-unknown-unknown/release/diary_service.wasm
```

**Save these values:**
- Application ID (from the output above)
- Chain ID (from `linera wallet show`)

### Step 3: Configure and Run Frontend

Update `client/config.js` with your IDs:

```javascript
export const config = {
    applicationId: "YOUR_APPLICATION_ID",  // From step 2
    chainId: "YOUR_CHAIN_ID",              // From linera wallet show
    serviceUrl: "http://localhost:8082",
};
```

Start the Linera service (in a separate terminal):

```bash
linera service --port 8082
```

Start the frontend (in another terminal):

```bash
cd client
npm start
```

Open your browser to **http://localhost:8080** 🎉

## 📖 How to Use

### 1. Create Your Diary

- On first visit, you'll see "Create Your Secret Diary"
- Enter a secret phrase (minimum 8 characters)
- Click "Create Diary"
- **Remember your secret phrase!** You'll need it to access your entries

### 2. Unlock Your Diary

- Enter your secret phrase
- Click "Unlock"
- Your entries will be displayed

### 3. Add Entries

- Once unlocked, use the "New Entry" form
- Add a title and content
- Click "Save Entry"
- Your entry is stored on the blockchain!

## 🔧 Development Workflow

### Rebuild Backend

```bash
cd backend
cargo build --release --target wasm32-unknown-unknown
```

### Re-deploy

```bash
linera publish-and-create \
  target/wasm32-unknown-unknown/release/diary_contract.wasm \
  target/wasm32-unknown-unknown/release/diary_service.wasm
```

### Run Tests

```bash
cd backend
cargo test
```

## 📚 Documentation

- **README.md** - Full project overview
- **API.md** - GraphQL API reference
- **DEVELOPMENT.md** - Development guide
- **PROJECT_SUMMARY.md** - Project structure

## 🐛 Troubleshooting

### "Connection failed"

- Make sure `linera service --port 8082` is running
- Check that your `config.js` has the correct IDs

### "Failed to initialize diary"

- Verify your application is deployed: `linera wallet show`
- Check the browser console for errors
- Ensure your chain has sufficient tokens

### "Failed to save entry"

- Make sure you've unlocked the diary first
- Verify your secret phrase is correct
- Check that the Linera service is running

## 🎯 Next Steps

1. **Customize the UI** - Edit `client/styles.css`
2. **Add features** - Modify `backend/src/lib.rs` for new operations
3. **Deploy to testnet** - Use Linera testnet for public access
4. **Build more dApps** - Use this as a template!

---

**Need Help?** Check the [Linera documentation](https://linera.dev) or open an issue on GitHub.
