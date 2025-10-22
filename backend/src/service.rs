// Copyright (c) Linera.
// SPDX-License-Identifier: Apache-2.0

#![cfg_attr(target_arch = "wasm32", no_main)]

mod state;

use std::sync::Arc;
use async_graphql::{EmptySubscription, Object, Schema};
use linera_sdk::{
    linera_base_types::WithServiceAbi,
    views::View,
    Service, ServiceRuntime,
};

use diary_backend::{hash_secret_phrase, Operation, OperationResponse};
use self::state::{DiaryEntry, DiaryState};

/// The GraphQL service for the diary application.
/// This provides read-only queries and schedules operations through mutations.
pub struct DiaryService {
    state: Arc<DiaryState>,
    runtime: Arc<ServiceRuntime<Self>>,
}

linera_sdk::service!(DiaryService);

impl WithServiceAbi for DiaryService {
    type Abi = diary_backend::DiaryAbi;
}

impl Service for DiaryService {
    type Parameters = ();

    async fn new(runtime: ServiceRuntime<Self>) -> Self {
        let state = DiaryState::load(runtime.root_view_storage_context())
            .await
            .expect("Failed to load state");
        DiaryService {
            state: Arc::new(state),
            runtime: Arc::new(runtime),
        }
    }

    async fn handle_query(&self, request: async_graphql::Request) -> async_graphql::Response {
        let schema = Schema::build(
            QueryRoot {
                state: self.state.clone(),
            },
            MutationRoot {
                runtime: self.runtime.clone(),
            },
            EmptySubscription,
        )
        .finish();

        schema.execute(request).await
    }
}

/// GraphQL query root for reading diary data.
struct QueryRoot {
    state: Arc<DiaryState>,
}

#[Object]
impl QueryRoot {
    /// Check if the diary has been initialized
    async fn is_initialized(&self) -> bool {
        self.state.is_initialized()
    }

    /// Get the diary owner
    async fn owner(&self) -> String {
        self.state.get_owner()
    }

    /// Get the total number of entries
    async fn entry_count(&self) -> u64 {
        self.state.get_entry_count()
    }

    /// Get all diary entries (sorted by newest first)
    async fn entries(&self) -> Result<Vec<DiaryEntry>, async_graphql::Error> {
        self.state
            .get_all_entries()
            .await
            .map_err(|e| async_graphql::Error::new(format!("Failed to get entries: {}", e)))
    }

    /// Get a specific diary entry by ID
    async fn entry(&self, id: u64) -> Result<Option<DiaryEntry>, async_graphql::Error> {
        self.state
            .get_entry(id)
            .await
            .map_err(|e| async_graphql::Error::new(format!("Failed to get entry: {}", e)))
    }

    /// Get the latest N entries
    async fn latest_entries(&self, limit: i32) -> Result<Vec<DiaryEntry>, async_graphql::Error> {
        if limit <= 0 {
            return Err(async_graphql::Error::new("Limit must be positive"));
        }

        self.state
            .get_latest_entries(limit as usize)
            .await
            .map_err(|e| async_graphql::Error::new(format!("Failed to get latest entries: {}", e)))
    }

    /// Get entries within a specific time range
    async fn entries_in_range(
        &self,
        start_timestamp: u64,
        end_timestamp: u64,
    ) -> Result<Vec<DiaryEntry>, async_graphql::Error> {
        if start_timestamp > end_timestamp {
            return Err(async_graphql::Error::new(
                "Start timestamp must be before end timestamp",
            ));
        }

        self.state
            .get_entries_in_range(start_timestamp, end_timestamp)
            .await
            .map_err(|e| {
                async_graphql::Error::new(format!("Failed to get entries in range: {}", e))
            })
    }

    /// Search entries by title (case-insensitive)
    async fn search_by_title(&self, query: String) -> Result<Vec<DiaryEntry>, async_graphql::Error> {
        let all_entries = self.state.get_all_entries().await.map_err(|e| {
            async_graphql::Error::new(format!("Failed to search entries: {}", e))
        })?;

        let query_lower = query.to_lowercase();
        let filtered: Vec<DiaryEntry> = all_entries
            .into_iter()
            .filter(|entry| entry.title.to_lowercase().contains(&query_lower))
            .collect();

        Ok(filtered)
    }

    /// Search entries by content (case-insensitive)
    async fn search_by_content(
        &self,
        query: String,
    ) -> Result<Vec<DiaryEntry>, async_graphql::Error> {
        let all_entries = self.state.get_all_entries().await.map_err(|e| {
            async_graphql::Error::new(format!("Failed to search entries: {}", e))
        })?;

        let query_lower = query.to_lowercase();
        let filtered: Vec<DiaryEntry> = all_entries
            .into_iter()
            .filter(|entry| entry.content.to_lowercase().contains(&query_lower))
            .collect();

        Ok(filtered)
    }
}

/// GraphQL mutation root for scheduling operations.
struct MutationRoot {
    runtime: Arc<ServiceRuntime<DiaryService>>,
}

#[Object]
impl MutationRoot {
    /// Initialize the diary with a secret phrase
    async fn initialize(
        &self,
        secret_phrase: String,
    ) -> Result<OperationResponse, async_graphql::Error> {
        if secret_phrase.is_empty() {
            return Err(async_graphql::Error::new("Secret phrase cannot be empty"));
        }

        if secret_phrase.len() < 8 {
            return Err(async_graphql::Error::new(
                "Secret phrase must be at least 8 characters",
            ));
        }

        // Hash the secret phrase
        let secret_phrase_hash = hash_secret_phrase(&secret_phrase);

        // Schedule the Initialize operation
        self.runtime
            .schedule_operation(Operation::Initialize { secret_phrase_hash })
            .await;

        Ok(OperationResponse::ok(
            "Diary initialization scheduled. Please wait for the operation to be executed.",
        ))
    }

    /// Add a new diary entry
    async fn add_entry(
        &self,
        secret_phrase: String,
        title: String,
        content: String,
    ) -> Result<OperationResponse, async_graphql::Error> {
        if secret_phrase.is_empty() {
            return Err(async_graphql::Error::new("Secret phrase cannot be empty"));
        }

        if title.is_empty() {
            return Err(async_graphql::Error::new("Title cannot be empty"));
        }

        if content.is_empty() {
            return Err(async_graphql::Error::new("Content cannot be empty"));
        }

        // Schedule the AddEntry operation
        self.runtime
            .schedule_operation(Operation::AddEntry {
                secret_phrase,
                title: title.clone(),
                content,
            })
            .await;

        Ok(OperationResponse::ok(format!(
            "Entry '{}' creation scheduled. Please wait for the operation to be executed.",
            title
        )))
    }

    /// Update an existing diary entry
    async fn update_entry(
        &self,
        secret_phrase: String,
        entry_id: u64,
        title: Option<String>,
        content: Option<String>,
    ) -> Result<OperationResponse, async_graphql::Error> {
        if secret_phrase.is_empty() {
            return Err(async_graphql::Error::new("Secret phrase cannot be empty"));
        }

        if title.is_none() && content.is_none() {
            return Err(async_graphql::Error::new(
                "Must provide at least title or content to update",
            ));
        }

        // Validate provided values
        if let Some(ref t) = title {
            if t.is_empty() {
                return Err(async_graphql::Error::new("Title cannot be empty"));
            }
        }

        if let Some(ref c) = content {
            if c.is_empty() {
                return Err(async_graphql::Error::new("Content cannot be empty"));
            }
        }

        // Schedule the UpdateEntry operation
        self.runtime
            .schedule_operation(Operation::UpdateEntry {
                secret_phrase,
                entry_id,
                title,
                content,
            })
            .await;

        Ok(OperationResponse::ok(format!(
            "Entry {} update scheduled. Please wait for the operation to be executed.",
            entry_id
        )))
    }

    /// Delete a diary entry
    async fn delete_entry(
        &self,
        secret_phrase: String,
        entry_id: u64,
    ) -> Result<OperationResponse, async_graphql::Error> {
        if secret_phrase.is_empty() {
            return Err(async_graphql::Error::new("Secret phrase cannot be empty"));
        }

        // Schedule the DeleteEntry operation
        self.runtime
            .schedule_operation(Operation::DeleteEntry {
                secret_phrase,
                entry_id,
            })
            .await;

        Ok(OperationResponse::ok(format!(
            "Entry {} deletion scheduled. Please wait for the operation to be executed.",
            entry_id
        )))
    }

    /// Batch add multiple entries (convenience method)
    async fn add_entries(
        &self,
        secret_phrase: String,
        entries: Vec<BatchEntryInput>,
    ) -> Result<Vec<OperationResponse>, async_graphql::Error> {
        if secret_phrase.is_empty() {
            return Err(async_graphql::Error::new("Secret phrase cannot be empty"));
        }

        if entries.is_empty() {
            return Err(async_graphql::Error::new("No entries provided"));
        }

        let mut responses = Vec::new();

        for entry in entries {
            if entry.title.is_empty() || entry.content.is_empty() {
                responses.push(OperationResponse::err(
                    "Title and content cannot be empty",
                ));
                continue;
            }

            // Schedule each operation
            self.runtime
                .schedule_operation(Operation::AddEntry {
                    secret_phrase: secret_phrase.clone(),
                    title: entry.title.clone(),
                    content: entry.content,
                })
                .await;

            responses.push(OperationResponse::ok(format!(
                "Entry '{}' scheduled",
                entry.title
            )));
        }

        Ok(responses)
    }
}

/// Input type for batch entry creation
#[derive(async_graphql::InputObject)]
struct BatchEntryInput {
    title: String,
    content: String,
}
