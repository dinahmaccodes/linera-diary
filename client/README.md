# Linera Diary Client - README

## 📋 Overview

Simple, vanilla JavaScript frontend for the Linera Diary dApp. No complex build tools, no heavy frameworks - just clean HTML, CSS, and JavaScript that connects directly to your Linera blockchain.

## 🎯 Features

- **Simple Setup** - No `npm install`, no dependencies
- **Direct GraphQL** - Communicates directly with Linera service
- **Beautiful UI** - Modern, responsive design
- **Secure** - Secret phrase protection with SHA-256 hashing
- **Real-time** - Immediate updates from blockchain

## 📁 Project Structure

```
client/
├── index.html          # Main HTML structure
├── styles.css          # All styling
├── linera-diary.js     # Main application logic
├── config.js           # Configuration (chain ID, app ID, etc.)
└── package.json        # Simple metadata
```

## 🚀 Getting Started

### 1. Prerequisites

- Linera service running on port 8082
- Your diary application deployed
- Python 3 (for simple HTTP server)

### 2. Configure

Edit `config.js` with your deployment details:

```javascript
export const config = {
    applicationId: "YOUR_APPLICATION_ID",  // From linera publish-and-create
    chainId: "YOUR_CHAIN_ID",              // From linera wallet show
    serviceUrl: "http://localhost:8082",
};
```

### 3. Run

```bash
npm start
```

Or directly:

```bash
python3 -m http.server 8080
```

### 4. Open

Visit `http://localhost:8080` in your browser.

## 🔌 How It Works

### Connection Flow

```
1. User opens page
   ↓
2. JavaScript loads config
   ↓
3. Check diary initialization status via GraphQL
   ↓
4. Display appropriate UI (init or diary view)
   ↓
5. User interacts (create diary, add entries)
   ↓
6. GraphQL mutations update blockchain
   ↓
7. UI updates with new data
```

### GraphQL Communication

The app uses standard GraphQL queries and mutations:

**Check Status:**
```graphql
query {
    isInitialized
}
```

**Initialize Diary:**
```graphql
mutation {
    initialize(secretPhraseHash: "hash...")
}
```

**Add Entry:**
```graphql
mutation {
    addEntry(
        secretPhrase: "phrase",
        title: "My Title",
        content: "My content"
    )
}
```

**Get Entries:**
```graphql
query {
    entries {
        id
        timestamp
        title
        content
        owner
    }
}
```

## 🎨 Customization

### Change Colors

Edit `styles.css`:

```css
/* Background gradient */
body {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* Button gradient */
button {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* Accent color */
.card h2 {
    color: #667eea;
}
```

### Modify Layout

Edit `index.html` - simple, semantic HTML structure.

### Add Features

Edit `linera-diary.js` - well-commented, easy to extend.

## 🐛 Troubleshooting

### "Connection failed"

**Cause:** Linera service not running or wrong configuration

**Solution:**
1. Check `linera service --port 8082` is running
2. Verify `config.js` has correct IDs
3. Check browser console for errors

### "Failed to load entries"

**Cause:** GraphQL query failed

**Solution:**
1. Ensure diary is initialized
2. Check application ID is correct
3. Verify chain has diary data

### Module import errors

**Cause:** Browser doesn't support ES6 modules or wrong server

**Solution:**
1. Use `npm start` (not just opening file:// directly)
2. Use a modern browser (Chrome 89+, Firefox 89+, Safari 15.4+)

## 🌐 Browser Requirements

- Chrome 89+
- Firefox 89+
- Safari 15.4+
- Edge 89+

Must support:
- ✅ ES6 modules
- ✅ Fetch API
- ✅ Async/await
- ✅ Web Crypto API (for SHA-256)

## 📖 API Reference

### Configuration Object

```javascript
config = {
    applicationId: string,    // Your deployed app ID
    chainId: string,          // Your chain ID
    serviceUrl: string,       // Linera service URL
    graphqlUrl: string        // Auto-generated GraphQL endpoint
}
```

### Main Functions

- `init()` - Initialize the app
- `checkDiaryStatus()` - Check if diary is initialized
- `initializeDiary()` - Create new diary
- `unlockDiary()` - Unlock existing diary
- `loadEntries()` - Fetch all entries
- `saveEntry()` - Add new entry
- `executeGraphQL(query)` - Execute GraphQL query/mutation

## 🔒 Security Notes

### Secret Phrase

- Stored in memory only (not localStorage)
- Hashed with SHA-256 before sending to blockchain
- Never logged or exposed

### Best Practices

1. **Use strong secret phrases** (min 8 characters, recommended 16+)
2. **Don't share secret phrases** - they're your only access key
3. **No password recovery** - this is blockchain, there's no "reset password"

## 🚀 Deployment

### Localhost (Development)

```bash
npm start
```

### Custom Server

Any static file server works:

```bash
# Python
python3 -m http.server 8080

# Node.js
npx serve -p 8080

# PHP
php -S localhost:8080
```

### Production

Deploy to any static hosting:
- GitHub Pages
- Netlify
- Vercel
- IPFS

Just remember to update `config.js` with your production Linera service URL.

## 📚 Learn More

- [Linera Documentation](https://linera.dev)
- [GraphQL Documentation](https://graphql.org)
- [Web Crypto API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API)

## 🎓 Next Steps

1. **Test the application** - Try creating entries, unlocking diary
2. **Customize the design** - Make it your own
3. **Add features** - Modify backend and frontend together
4. **Deploy to testnet** - Share with others

---

**Built on Linera Protocol** | Simple, Secure, Decentralized
