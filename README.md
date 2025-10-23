# Linera Secret Diary

A secure, decentralized diary application built on the Linera blockchain. Store your personal thoughts and memories on-chain with secret phrase protection.

## 🎯 What This Is

A simple, educational dApp demonstrating:

- **Smart contract development** with Linera SDK
- **GraphQL API** for blockchain communication
- **Vanilla JavaScript frontend** - no complex frameworks
- **Secret phrase authentication** - your data, your keys

## Live Demo:
https://linera-diary.netlify.app

## 🌟 Features

- 🔐 **Secret Phrase Protection**: Initialize your diary with a secure secret phrase
- 📝 **On-chain Storage**: Store diary entries permanently on the blockchain
- 🔍 **GraphQL API**: Query and manage entries through a modern GraphQL interface
- ⚡ **Real-time Updates**: Instant synchronization across the network
- 🎨 **Modern UI**: Clean, intuitive web interface

## 📁 Project Structure

```
linera-diary/
├── backend/                # Linera smart contract
│   ├── src/
│   │   ├── lib.rs         # ABI & Operation definitions
│   │   ├── state.rs       # State management (diary storage)
│   │   ├── contract.rs    # Contract implementation
│   │   └── service.rs     # GraphQL service
│   ├── tests/
│   │   └── single_chain.rs
│   └── Cargo.toml
│
├── client/                 # Simple web frontend
│   ├── index.html         # Main HTML structure
│   ├── styles.css         # All styling
│   ├── linera-diary.js    # Main application logic
│   ├── config.js          # Configuration (chain ID, app ID)
│   ├── package.json       # Simple metadata
│   └── README.md          # Client documentation
│
├── README.md              # This file
├── QUICKSTART.md          # Quick start guide
├── API.md                 # GraphQL API reference
├── DEVELOPMENT.md         # Development guide
└── PROJECT_SUMMARY.md     # Project overview
```

## 🔗 Deployment Information

### Testnet Configuration

**Network:** Linera Testnet Conway  
**Linera Version:** v0.15.4 (testnet_conway branch)  
**Faucet:** <https://faucet.testnet-conway.linera.net>  
**Chain ID:** `8fd4233c5d03554f87d47a711cf70619727ca3d148353446cab81fb56922c9b7`

**Status:** ⚠️ Testnet faucet provides read-only chains. Working on obtaining writable chain for deployment.

**Known Issue:** The testnet-conway faucet currently provides shared chains without write permissions. To deploy applications, you need to:

1. Generate a key pair with `linera keygen`
2. Request a dedicated chain from the faucet API
3. Configure wallet with proper ownership

For updates, check the [Linera Discord](https://discord.gg/linera)

## Prerequisites

- Rust 1.75+ and Cargo
- Linera CLI tools (v0.15.4)
- Python 3 (for simple HTTP server)

## Quick Start

### 1. Build the Contract

```bash
./build.sh
```

### 2. Deploy to Testnet (When Available)

```bash
linera publish-and-create \
  target/wasm32-unknown-unknown/release/diary_backend.wasm \
  target/wasm32-unknown-unknown/release/diary_backend.wasm
```

### 3. Start GraphQL Service

```bash
linera service --port 8080
```

### 4. Update Frontend Configuration

Edit `client/config.js` with your Application ID from step 2.

### 5. Run Tests

```bash
cargo test
```

## Usage

### Initialize Your Diary

```graphql
mutation {
  initialize(secretPhraseHash: "your-secret-hash") {
    success
  }
}
```

### Add a Diary Entry

```graphql
mutation {
  addEntry(title: "My First Entry", content: "Today was amazing...") {
    entryId
    timestamp
  }
}
```

### Query Entries

```graphql
query {
  entries(limit: 10) {
    id
    title
    content
    timestamp
  }

  entry(id: 1) {
    title
    content
  }
}
```

## Security Considerations

- Secret phrases are hashed using SHA-256 before storage
- Entries are associated with the chain owner
- Only the owner can add entries to their diary
- All operations are signed and verified on-chain

## Development

### Running Local Tests

```bash
# Run unit tests
cargo test --lib

# Run integration tests
cargo test --test single_chain
```

### Development Mode

```bash
# Build contract
./build.sh

# Deploy to testnet
linera publish-and-create \
  target/wasm32-unknown-unknown/release/diary_backend.wasm \
  target/wasm32-unknown-unknown/release/diary_backend.wasm

# Start GraphQL service
linera service --port 8080
```

## Architecture

### Backend Components

**State Management (`state.rs`)**

- Uses `linera-views` for persistent storage
- `RegisterView` for secret phrase and owner
- `MapView` for diary entries indexed by timestamp

**Contract (`contract.rs`)**

- Handles on-chain execution
- Validates secret phrases
- Manages entry creation

**Service (`service.rs`)**

- Provides GraphQL API
- Handles queries and read operations
- Schedules operations through mutations

### Frontend

Built with:

- Vanilla JavaScript (no framework)
- Modern ES6+ modules
- Native Fetch API for GraphQL
- CSS3 for styling

## Deployment

### Testnet Deployment

```bash
# Build the contract
./build.sh

# Deploy to testnet (requires writable chain)
linera publish-and-create \
  target/wasm32-unknown-unknown/release/diary_backend.wasm \
  target/wasm32-unknown-unknown/release/diary_backend.wasm

# Start service
linera service --port 8080

# Update client/config.js with your Application ID
```

### Mainnet Deployment

⚠️ Before mainnet deployment:

1. Complete thorough testing
2. Security audit
3. Review all operations
4. Ensure proper error handling

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Submit a pull request

## License

This project is open source and available for anyone to use, modify, and distribute.

## Resources

- [Linera Documentation](https://linera.dev)
- [Linera Protocol Repository](https://github.com/linera-io/linera-protocol)
- [GraphQL Documentation](https://graphql.org)

## Support

For issues and questions:

- Open an issue on GitHub
- Join the Linera Discord community

---

Built with ❤️ using Linera Protocol
