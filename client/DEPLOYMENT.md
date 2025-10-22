# 🚀 Frontend Deployment Guide

This guide will help you deploy the Linera Diary frontend to Vercel or Netlify.

## 📋 Prerequisites

Before deploying, you need:
- ✅ Application ID from your Linera deployment
- ✅ Chain ID: `1259e4132844b892fe0a1f7c687462d2aa15ad73b91fc53c8c734069b176168c`
- ✅ A running Linera service endpoint (GraphQL)

## 🔧 Pre-Deployment Setup

### 1. Update Configuration

Edit `config.js` with your deployment details:

```javascript
export const config = {
    // Update this with your Application ID from deployment
    applicationId: "YOUR_APPLICATION_ID_HERE",
    
    // Chain ID (already configured)
    chainId: "1259e4132844b892fe0a1f7c687462d2aa15ad73b91fc53c8c734069b176168c",
    
    // Update this with your public Linera service URL
    serviceUrl: "https://your-linera-service.example.com",
};
```

**Important:** For production deployment, you need a publicly accessible Linera service endpoint.

## 🌐 Deploy to Vercel

### Option 1: Using Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Navigate to client directory
cd client

# Deploy
vercel
```

### Option 2: Using Vercel Dashboard

1. Go to [vercel.com](https://vercel.com)
2. Click "Import Project"
3. Select your GitHub repository
4. Set **Root Directory** to: `client`
5. Click "Deploy"

### Vercel Configuration

The `vercel.json` file is already configured with:
- Static file serving
- CORS headers
- Proper routing

## 🎨 Deploy to Netlify

### Option 1: Using Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Navigate to client directory
cd client

# Deploy
netlify deploy

# Production deployment
netlify deploy --prod
```

### Option 2: Using Netlify Dashboard

1. Go to [netlify.com](https://netlify.com)
2. Click "Add new site" → "Import an existing project"
3. Connect your GitHub repository
4. Configure build settings:
   - **Base directory:** `client`
   - **Build command:** (leave empty)
   - **Publish directory:** `.` (current directory)
5. Click "Deploy site"

### Netlify Configuration

The `netlify.toml` file is already configured with:
- SPA routing redirects
- CORS headers
- Security headers

## 🔌 Backend Service Options

For your frontend to work in production, you need one of:

### Option 1: Local Linera Service (Development)
```bash
# Start local service
linera service --port 8080

# Update config.js
serviceUrl: "http://localhost:8080"
```
⚠️ Only works for local testing

### Option 2: Deployed Linera Service (Production)
You need to deploy your Linera node and service to a cloud provider:

1. **Deploy Linera Node:**
   - AWS EC2, Google Cloud, or DigitalOcean
   - Run `linera service --port 8080`
   - Configure reverse proxy (nginx/caddy)
   - Get SSL certificate (Let's Encrypt)

2. **Update config.js:**
   ```javascript
   serviceUrl: "https://your-linera-node.example.com"
   ```

### Option 3: Linera Testnet (When Available)
```javascript
// Update config.js when testnet is available
serviceUrl: "https://testnet.linera.io"
applicationId: "YOUR_TESTNET_APP_ID"
chainId: "YOUR_TESTNET_CHAIN_ID"
```

## 🧪 Test Deployment Locally

Before deploying, test locally:

```bash
cd client

# Start local server
python3 -m http.server 3000

# Visit http://localhost:3000
```

**Test checklist:**
- [ ] Page loads without errors
- [ ] GraphQL endpoint is reachable
- [ ] Can check initialization status
- [ ] Forms and buttons work
- [ ] Console shows no errors

## 📝 Environment Configuration

### For Local Development
```javascript
// config.js
serviceUrl: "http://localhost:8080"
```

### For Production
```javascript
// config.js
serviceUrl: "https://your-production-service.com"
```

## 🔍 Troubleshooting

### CORS Errors
If you see CORS errors in production:

1. **Verify service URL** in `config.js`
2. **Check Linera service** is running and accessible
3. **Ensure CORS headers** are set on your Linera service

### Application ID Not Found
- Make sure Application ID in `config.js` matches your deployment
- Verify the application is deployed on the specified chain

### GraphQL Errors
- Check service endpoint is reachable: `curl https://your-service.com/health`
- Verify Application ID and Chain ID are correct
- Check browser console for detailed error messages

## 📊 Production Checklist

Before deploying to production:

- [ ] Application ID is updated in `config.js`
- [ ] Chain ID is correct
- [ ] Service URL points to public endpoint (not localhost)
- [ ] Linera service is publicly accessible
- [ ] CORS is properly configured
- [ ] SSL certificate is active (HTTPS)
- [ ] All GraphQL queries tested
- [ ] Frontend loads without console errors
- [ ] Mobile responsiveness tested

## 🎯 Quick Deploy Commands

### Vercel
```bash
cd client
vercel --prod
```

### Netlify
```bash
cd client
netlify deploy --prod --dir=.
```

## 🔗 Useful Links

- [Vercel Documentation](https://vercel.com/docs)
- [Netlify Documentation](https://docs.netlify.com)
- [Linera Documentation](https://docs.linera.io)
- [Project Repository](https://github.com/dinahmaccodes/linera-diary)

## 📧 Support

For issues or questions:
- Open an issue on GitHub
- Check the main README.md
- Review API.md for GraphQL queries

---

**Note:** The frontend is a static site (HTML, CSS, JS) and can be deployed anywhere. The key requirement is having a publicly accessible Linera service endpoint for the GraphQL API.
