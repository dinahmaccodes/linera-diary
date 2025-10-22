// Copyright (c) Linera.
// SPDX-License-Identifier: Apache-2.0

use linera_sdk::views::{linera_views, MapView, RegisterView, RootView, ViewStorageContext};
use serde::{Deserialize, Serialize};

/// The application state stored on-chain.
#[derive(RootView, async_graphql::SimpleObject)]
#[view(context = ViewStorageContext)]
pub struct DiaryState {
    /// SHA-256 hash of the secret phrase
    pub secret_phrase_hash: RegisterView<String>,
    
    /// Owner identifier (stored as string)
    pub owner: RegisterView<String>,
    
    /// Map of diary entries (entry_id -> DiaryEntry)
    #[graphql(skip)]
    pub entries: MapView<u64, DiaryEntry>,
    
    /// Entry counter
    pub entry_count: RegisterView<u64>,
}

/// A single diary entry
#[derive(Debug, Clone, Serialize, Deserialize, async_graphql::SimpleObject)]
pub struct DiaryEntry {
    /// Entry ID
    pub id: u64,
    
    /// Entry title
    pub title: String,
    
    /// Entry content
    pub content: String,
    
    /// Timestamp (milliseconds)
    pub timestamp: u64,
}

impl DiaryState {
    /// Check if the diary has been initialized
    pub fn is_initialized(&self) -> bool {
        !self.secret_phrase_hash.get().is_empty()
    }

    /// Get the owner
    pub fn get_owner(&self) -> String {
        self.owner.get().clone()
    }

    /// Get the entry count
    pub fn get_entry_count(&self) -> u64 {
        *self.entry_count.get()
    }

    /// Get a specific entry by ID
    pub async fn get_entry(&self, id: u64) -> Option<DiaryEntry> {
        self.entries.get(&id).await.ok().flatten()
    }

    /// Get all entries (for GraphQL queries)
    pub async fn get_all_entries(&self) -> Vec<DiaryEntry> {
        let mut entries = Vec::new();
        let count = *self.entry_count.get();
        
        for id in 0..count {
            if let Some(entry) = self.entries.get(&id).await.ok().flatten() {
                entries.push(entry);
            }
        }
        
        // Sort by timestamp descending (newest first)
        entries.sort_by(|a, b| b.timestamp.cmp(&a.timestamp));
        entries
    }

    /// Get the latest N entries
    pub async fn get_latest_entries(&self, limit: usize) -> Vec<DiaryEntry> {
        let mut entries = self.get_all_entries().await;
        entries.truncate(limit);
        entries
    }

    /// Get entries within a time range
    pub async fn get_entries_in_range(&self, start: u64, end: u64) -> Vec<DiaryEntry> {
        let all_entries = self.get_all_entries().await;
        all_entries
            .into_iter()
            .filter(|e| e.timestamp >= start && e.timestamp <= end)
            .collect()
    }
}
