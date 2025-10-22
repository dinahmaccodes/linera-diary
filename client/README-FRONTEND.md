# 🎨 Linera Diary - Frontend

A modern, responsive web interface for the Linera Diary dApp. Built with vanilla JavaScript, HTML, and CSS - no frameworks required!

## ✨ Features

- 🔐 **Secret Phrase Protection** - Secure diary initialization and unlocking
- 📝 **Rich Text Entry Management** - Create, edit, delete diary entries
- 🔍 **Search Functionality** - Search entries by title or content
- 📊 **Real-time Stats** - Track entry count and last update
- 🎨 **Modern UI** - Clean, intuitive interface with smooth animations
- 📱 **Fully Responsive** - Works on desktop, tablet, and mobile
- ⚡ **Fast & Lightweight** - Pure vanilla JS, no dependencies

## 🚀 Quick Start

### Local Development

```bash
# Start development server
python3 -m http.server 3000

# Visit http://localhost:3000
```

### Configuration

Update `config.js` with your deployment details:

```javascript
export const config = {
    applicationId: "YOUR_APPLICATION_ID",
    chainId: "1259e4132844b892fe0a1f7c687462d2aa15ad73b91fc53c8c734069b176168c",
    serviceUrl: "http://localhost:8080", // or your production URL
};
```

## 📁 File Structure

```
client/
├── index.html          # Main HTML structure
├── styles.css          # Complete styling (800+ lines)
├── app.js              # Application logic (700+ lines)
├── config.js           # Configuration
├── package.json        # Project metadata
├── vercel.json         # Vercel deployment config
├── netlify.toml        # Netlify deployment config
├── DEPLOYMENT.md       # Deployment guide
└── README.md           # This file
```

## 🎯 Deployment

### Deploy to Vercel

```bash
cd client
vercel --prod
```

### Deploy to Netlify

```bash
cd client
netlify deploy --prod --dir=.
```

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

## 🔧 Requirements

- **Backend:** Running Linera service with GraphQL endpoint
- **Browser:** Modern browser with ES6 module support
- **Configuration:** Valid Application ID and Chain ID

## 📊 Current Configuration

- **Chain ID:** `1259e4132844b892fe0a1f7c687462d2aa15ad73b91fc53c8c734069b176168c`
- **Application ID:** Update in `config.js` after deployment
- **Service URL:** `http://localhost:8080` (update for production)

## 🎨 Features Breakdown

### Initialization Screen
- Secret phrase input with validation
- SHA-256 hashing for secure storage
- One-time diary setup

### Main Diary Interface
- Entry list with search
- Add new entries
- Edit existing entries
- Delete entries
- View entry statistics

### Security
- Secret phrase never stored in plaintext
- SHA-256 hash verification
- Session-based unlocking
- Secure GraphQL communication

## 🧪 Testing Locally

1. **Start Linera Network:**
   ```bash
   cd ..
   ./1-start-network.sh
   ```

2. **Deploy Contract:**
   ```bash
   # In another terminal
   export LINERA_WALLET="/tmp/.tmpXXX/wallet_0.json"
   export LINERA_KEYSTORE="/tmp/.tmpXXX/keystore_0.json"
   export LINERA_STORAGE="rocksdb:/tmp/.tmpXXX/client_0.db"
   ./deploy-now.sh
   ```

3. **Start Service:**
   ```bash
   linera service --port 8080
   ```

4. **Open Frontend:**
   ```bash
   cd client
   python3 -m http.server 3000
   # Visit http://localhost:3000
   ```

## 🔍 Troubleshooting

### GraphQL Connection Failed
- Ensure Linera service is running on correct port
- Check `config.js` has correct `serviceUrl`
- Verify Application ID and Chain ID are correct

### CORS Errors
- Make sure Linera service allows CORS
- Check browser console for specific error
- Verify `vercel.json` or `netlify.toml` CORS headers

### Application Not Initialized
- Click "Initialize Diary" on first launch
- Enter a secure secret phrase
- Wait for transaction confirmation

## 📱 Browser Support

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

Requires ES6 module support.

## 🎨 Customization

### Update Theme Colors

Edit `styles.css`:

```css
:root {
    --primary: #667eea;    /* Main accent color */
    --secondary: #764ba2;  /* Secondary accent */
    --background: #0f172a; /* Dark background */
    /* ... more variables */
}
```

### Modify GraphQL Queries

Edit `app.js` to customize queries:

```javascript
// Example: Add new query
async getAllEntries() {
    const query = `
        query {
            entries {
                id
                title
                content
                timestamp
            }
        }
    `;
    return await this.client.query(query);
}
```

## 📝 API Reference

See [../API.md](../API.md) for complete GraphQL API documentation.

## 🤝 Contributing

Frontend contributions welcome! Areas for improvement:
- Additional themes
- Enhanced mobile UI
- More search filters
- Export/backup functionality
- Markdown support for entries

## 📄 License

Open source - free to use, modify, and distribute.

## 🔗 Links

- **Main Repository:** [github.com/dinahmaccodes/linera-diary](https://github.com/dinahmaccodes/linera-diary)
- **Linera Documentation:** [docs.linera.io](https://docs.linera.io)
- **Deployment Guide:** [DEPLOYMENT.md](./DEPLOYMENT.md)

---

Built with ❤️ using vanilla JavaScript
