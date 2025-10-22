# API Documentation

This document describes the GraphQL API for the Secret Diary application.

## Endpoint

```
POST http://localhost:8080/graphql
```

## Authentication

The diary is protected by a secret phrase that must be provided with each mutation (write operation). Queries (read operations) do not require authentication but can only be performed after unlocking the diary in the frontend.

## Schema Overview

### Types

#### DiaryEntry

```graphql
type DiaryEntry {
  id: String!
  title: String!
  content: String!
  createdAt: String!
  updatedAt: String
  author: String!
}
```

#### OperationResponse

```graphql
type OperationResponse {
  success: Boolean!
  message: String!
  entryId: String
}
```

## Queries

### isInitialized

Check if the diary has been initialized.

```graphql
query {
  isInitialized
}
```

**Response:**
```json
{
  "data": {
    "isInitialized": true
  }
}
```

---

### owner

Get the owner of the diary.

```graphql
query {
  owner
}
```

**Response:**
```json
{
  "data": {
    "owner": "0x1234567890abcdef..."
  }
}
```

---

### entryCount

Get the total number of entries.

```graphql
query {
  entryCount
}
```

**Response:**
```json
{
  "data": {
    "entryCount": 5
  }
}
```

---

### entries

Get all diary entries (sorted by newest first).

```graphql
query {
  entries {
    id
    title
    content
    createdAt
    updatedAt
    author
  }
}
```

**Response:**
```json
{
  "data": {
    "entries": [
      {
        "id": "1234567890000",
        "title": "My First Entry",
        "content": "Today was amazing...",
        "createdAt": "1234567890000",
        "updatedAt": null,
        "author": "0x1234..."
      }
    ]
  }
}
```

---

### entry

Get a specific entry by ID.

```graphql
query {
  entry(id: 1234567890000) {
    id
    title
    content
    createdAt
  }
}
```

**Parameters:**
- `id` (Int!): The entry ID (timestamp)

**Response:**
```json
{
  "data": {
    "entry": {
      "id": "1234567890000",
      "title": "My Entry",
      "content": "Entry content...",
      "createdAt": "1234567890000"
    }
  }
}
```

---

### latestEntries

Get the N most recent entries.

```graphql
query {
  latestEntries(limit: 10) {
    id
    title
    content
  }
}
```

**Parameters:**
- `limit` (Int!): Number of entries to return

**Response:**
```json
{
  "data": {
    "latestEntries": [
      {
        "id": "1234567890000",
        "title": "Latest Entry",
        "content": "..."
      }
    ]
  }
}
```

---

### entriesInRange

Get entries within a specific time range.

```graphql
query {
  entriesInRange(
    startTimestamp: 1234567890000
    endTimestamp: 1234567999000
  ) {
    id
    title
  }
}
```

**Parameters:**
- `startTimestamp` (Int!): Start of time range (microseconds)
- `endTimestamp` (Int!): End of time range (microseconds)

---

### searchByTitle

Search entries by title (case-insensitive).

```graphql
query {
  searchByTitle(query: "vacation") {
    id
    title
    content
  }
}
```

**Parameters:**
- `query` (String!): Search term

---

### searchByContent

Search entries by content (case-insensitive).

```graphql
query {
  searchByContent(query: "beach") {
    id
    title
    content
  }
}
```

**Parameters:**
- `query` (String!): Search term

## Mutations

### initialize

Initialize a new diary with a secret phrase.

```graphql
mutation {
  initialize(secretPhrase: "my-secret-phrase") {
    success
    message
  }
}
```

**Parameters:**
- `secretPhrase` (String!): The secret phrase to protect the diary (min 8 characters)

**Response:**
```json
{
  "data": {
    "initialize": {
      "success": true,
      "message": "Diary initialization scheduled..."
    }
  }
}
```

**Notes:**
- Can only be called once per diary
- Secret phrase is hashed using SHA-256 before storage
- Minimum 8 characters required

---

### addEntry

Add a new diary entry.

```graphql
mutation {
  addEntry(
    secretPhrase: "my-secret-phrase"
    title: "My First Day"
    content: "Today was amazing..."
  ) {
    success
    message
    entryId
  }
}
```

**Parameters:**
- `secretPhrase` (String!): The secret phrase for verification
- `title` (String!): Entry title (max 200 characters)
- `content` (String!): Entry content (max 100,000 characters)

**Response:**
```json
{
  "data": {
    "addEntry": {
      "success": true,
      "message": "Entry creation scheduled...",
      "entryId": "1234567890000"
    }
  }
}
```

**Errors:**
- Invalid secret phrase
- Title or content too long
- Diary not initialized

---

### updateEntry

Update an existing diary entry.

```graphql
mutation {
  updateEntry(
    secretPhrase: "my-secret-phrase"
    entryId: 1234567890000
    title: "Updated Title"
    content: "Updated content..."
  ) {
    success
    message
    entryId
  }
}
```

**Parameters:**
- `secretPhrase` (String!): The secret phrase for verification
- `entryId` (Int!): The ID of the entry to update
- `title` (String): New title (optional)
- `content` (String): New content (optional)

**Notes:**
- At least one of `title` or `content` must be provided
- Only the diary owner can update entries

---

### deleteEntry

Delete a diary entry.

```graphql
mutation {
  deleteEntry(
    secretPhrase: "my-secret-phrase"
    entryId: 1234567890000
  ) {
    success
    message
  }
}
```

**Parameters:**
- `secretPhrase` (String!): The secret phrase for verification
- `entryId` (Int!): The ID of the entry to delete

**Response:**
```json
{
  "data": {
    "deleteEntry": {
      "success": true,
      "message": "Entry deletion scheduled..."
    }
  }
}
```

---

### addEntries (Batch)

Add multiple entries in one request.

```graphql
mutation {
  addEntries(
    secretPhrase: "my-secret-phrase"
    entries: [
      { title: "Entry 1", content: "Content 1" }
      { title: "Entry 2", content: "Content 2" }
    ]
  ) {
    success
    message
  }
}
```

**Parameters:**
- `secretPhrase` (String!): The secret phrase for verification
- `entries` ([BatchEntryInput!]!): Array of entries to add

## Error Handling

All mutations return an `OperationResponse` with:
- `success`: Boolean indicating if the operation was scheduled successfully
- `message`: Human-readable message describing the result
- `entryId`: Optional entry ID for operations that create/modify entries

Common errors:
- `"Invalid secret phrase"`: The provided secret phrase doesn't match
- `"Diary is not initialized"`: Must initialize the diary first
- `"Entry not found"`: The specified entry ID doesn't exist
- `"Unauthorized"`: Only the diary owner can perform this action

## Example Workflows

### Complete Setup Flow

1. **Check if diary is initialized:**
```graphql
query { isInitialized }
```

2. **Initialize diary (if needed):**
```graphql
mutation {
  initialize(secretPhrase: "my-secret") {
    success
    message
  }
}
```

3. **Add first entry:**
```graphql
mutation {
  addEntry(
    secretPhrase: "my-secret"
    title: "First Entry"
    content: "Beginning my journey..."
  ) {
    success
    entryId
  }
}
```

4. **Fetch entries:**
```graphql
query {
  entries {
    id
    title
    content
  }
}
```

### Search Workflow

```graphql
# Search by title
query {
  searchByTitle(query: "vacation") {
    id
    title
  }
}

# Search by content
query {
  searchByContent(query: "beach") {
    id
    title
  }
}
```

### Update Workflow

```graphql
# Get entry
query {
  entry(id: 1234567890000) {
    id
    title
    content
  }
}

# Update entry
mutation {
  updateEntry(
    secretPhrase: "my-secret"
    entryId: 1234567890000
    title: "Updated Title"
  ) {
    success
  }
}
```

## Rate Limiting

There are no built-in rate limits, but operations are subject to blockchain constraints:
- Each mutation schedules a blockchain operation
- Operations are executed sequentially per chain
- Large batches should be split into smaller chunks

## Best Practices

1. **Cache queries**: Use Apollo Client or similar for automatic caching
2. **Batch operations**: Use `addEntries` for multiple entries
3. **Pagination**: Use `latestEntries` with a limit instead of fetching all entries
4. **Search optimization**: Implement client-side caching for search results
5. **Error handling**: Always check the `success` field in responses
