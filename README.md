# Linera Secret Diary

A secure, decentralized diary application built on the Linera blockchain. Store your personal thoughts and memories on-chain with secret phrase protection.

## 🎯 What This Is

A simple, educational dApp demonstrating:

- **Smart contract development** with Linera SDK
- **GraphQL API** for blockchain communication
- **Vanilla JavaScript frontend** - no complex frameworks
- **Secret phrase authentication** - your data, your keys

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

**Chain ID:** `1259e4132844b892fe0a1f7c687462d2aa15ad73b91fc53c8c734069b176168c`

**Network:** Local Development (Linera v0.15.4)

**Latest Block:**

- Timestamp: 2025-10-22 16:34:46.618443
- Next Block Height: 0

## Prerequisites

- Rust 1.75+ and Cargo
- Linera CLI tools (v0.15.4)
- Python 3 (for simple HTTP server)

## Quick Start

### 1. Build the Backend

```bash
# Build the Linera application
cargo build --release --target wasm32-unknown-unknown

# Or build in the backend directory
cd backend
cargo build --release --target wasm32-unknown-unknown
```

### 2. Publish to Linera

```bash
# Publish the application
linera publish-and-create \
  target/wasm32-unknown-unknown/release/diary_backend_{contract,service}.wasm \
  --json-parameters '{"secret_phrase_hash": "your-hashed-phrase"}'
```

### 3. Run Tests

```bash
cargo test
```

### 4. Start Frontend

```bash
cd frontend
npm install
npm run dev
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
# Start local Linera network
linera net up

# Watch mode for backend
cargo watch -x build

# Development server for frontend
cd frontend && npm run dev
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

- React + TypeScript
- Vite for fast builds
- GraphQL Client (@apollo/client)
- TailwindCSS for styling

## Deployment

### Testnet Deployment

```bash
# Set your chain ID
export CHAIN_ID="your-chain-id"

# Publish application
linera publish-and-create \
  target/wasm32-unknown-unknown/release/diary_backend_{contract,service}.wasm \
  --required-application-ids $CHAIN_ID
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
