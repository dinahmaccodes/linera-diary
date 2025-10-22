// Copyright (c) Linera.
// SPDX-License-Identifier: Apache-2.0

use async_graphql::{Request, Response};
use linera_sdk::{
    graphql::GraphQLMutationRoot,
    linera_base_types::{ContractAbi, ServiceAbi},
};
use serde::{Deserialize, Serialize};

pub struct DiaryAbi;

impl ContractAbi for DiaryAbi {
    type Operation = Operation;
    type Response = ();
}

impl ServiceAbi for DiaryAbi {
    type Query = Request;
    type QueryResponse = Response;
}

/// Operations that can be performed on the diary
#[derive(Debug, Deserialize, Serialize, GraphQLMutationRoot)]
pub enum Operation {
    /// Initialize the diary with a secret phrase
    Initialize { secret_phrase: String },

    /// Add a new diary entry
    AddEntry { secret_phrase: String, title: String, content: String },

    /// Update an entry
    UpdateEntry {
        secret_phrase: String,
        entry_id: u64,
        title: Option<String>,
        content: Option<String>,
    },

    /// Delete an entry
    DeleteEntry { secret_phrase: String, entry_id: u64 },
}

/// A simple response type returned by GraphQL mutations to indicate success or error.
#[derive(Debug, Serialize, Deserialize, Clone, async_graphql::SimpleObject)]
pub struct OperationResponse {
    pub success: bool,
    pub message: String,
}

impl OperationResponse {
    pub fn ok<T: Into<String>>(message: T) -> Self {
        OperationResponse {
            success: true,
            message: message.into(),
        }
    }

    pub fn err<T: Into<String>>(message: T) -> Self {
        OperationResponse {
            success: false,
            message: message.into(),
        }
    }
}

/// Helper to hash the secret phrase (SHA-256 hex)
pub fn hash_secret_phrase(phrase: &str) -> String {
    use sha2::{Digest, Sha256};
    let mut hasher = Sha256::new();
    hasher.update(phrase.as_bytes());
    format!("{:x}", hasher.finalize())
}
