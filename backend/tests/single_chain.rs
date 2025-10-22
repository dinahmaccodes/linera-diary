// Copyright (c) Linera.
// SPDX-License-Identifier: Apache-2.0

//! Integration tests for the diary application.
//! These tests run the full application on a simulated chain.

use diary_backend::{hash_secret_phrase, DiaryAbi, Operation, OperationResponse};
use linera_sdk::test::{ActiveChain, TestValidator};

/// Test initializing a diary
#[tokio::test]
async fn test_initialize_diary() {
    // Set up test environment
    let (validator, bytecode_id) = TestValidator::with_current_bytecode::<DiaryAbi>().await;
    let mut chain = validator.new_chain().await;

    // Create a secret phrase and hash it
    let secret_phrase = "my-super-secret-phrase";
    let secret_phrase_hash = hash_secret_phrase(secret_phrase);

    // Initialize the diary
    let response = chain
        .add_block(|block| {
            block.with_operation(Operation::Initialize {
                secret_phrase_hash: secret_phrase_hash.clone(),
            });
        })
        .await;

    // Check that initialization was successful
    assert!(
        response.is_ok(),
        "Failed to initialize diary: {:?}",
        response
    );

    // Query to verify initialization
    let query = r#"
        query {
            isInitialized
            entryCount
        }
    "#;

    let response: serde_json::Value = chain.graphql_query(query).await;
    assert_eq!(response["isInitialized"], true);
    assert_eq!(response["entryCount"], 0);
}

/// Test adding diary entries
#[tokio::test]
async fn test_add_entries() {
    let (validator, bytecode_id) = TestValidator::with_current_bytecode::<DiaryAbi>().await;
    let mut chain = validator.new_chain().await;

    let secret_phrase = "my-super-secret-phrase";
    let secret_phrase_hash = hash_secret_phrase(secret_phrase);

    // Initialize
    chain
        .add_block(|block| {
            block.with_operation(Operation::Initialize {
                secret_phrase_hash,
            });
        })
        .await
        .unwrap();

    // Add first entry
    chain
        .add_block(|block| {
            block.with_operation(Operation::AddEntry {
                secret_phrase: secret_phrase.to_string(),
                title: "My First Day".to_string(),
                content: "Today was amazing! I started my journey...".to_string(),
            });
        })
        .await
        .unwrap();

    // Add second entry
    chain
        .add_block(|block| {
            block.with_operation(Operation::AddEntry {
                secret_phrase: secret_phrase.to_string(),
                title: "Day Two".to_string(),
                content: "Continuing the adventure...".to_string(),
            });
        })
        .await
        .unwrap();

    // Query entries
    let query = r#"
        query {
            entryCount
            entries {
                id
                title
                content
            }
        }
    "#;

    let response: serde_json::Value = chain.graphql_query(query).await;
    assert_eq!(response["entryCount"], 2);
    assert_eq!(response["entries"].as_array().unwrap().len(), 2);
}

/// Test updating diary entries
#[tokio::test]
async fn test_update_entry() {
    let (validator, bytecode_id) = TestValidator::with_current_bytecode::<DiaryAbi>().await;
    let mut chain = validator.new_chain().await;

    let secret_phrase = "my-super-secret-phrase";
    let secret_phrase_hash = hash_secret_phrase(secret_phrase);

    // Initialize
    chain
        .add_block(|block| {
            block.with_operation(Operation::Initialize {
                secret_phrase_hash,
            });
        })
        .await
        .unwrap();

    // Add entry
    let add_response = chain
        .add_block(|block| {
            block.with_operation(Operation::AddEntry {
                secret_phrase: secret_phrase.to_string(),
                title: "Original Title".to_string(),
                content: "Original content".to_string(),
            });
        })
        .await
        .unwrap();

    // Get the entry ID from the response
    // In a real test, you'd need to query this or parse from response
    // For now, we'll use a timestamp approach

    // Query to get entry ID
    let query = r#"
        query {
            entries {
                id
                title
            }
        }
    "#;

    let response: serde_json::Value = chain.graphql_query(query).await;
    let entry_id = response["entries"][0]["id"].as_u64().unwrap();

    // Update the entry
    chain
        .add_block(|block| {
            block.with_operation(Operation::UpdateEntry {
                secret_phrase: secret_phrase.to_string(),
                entry_id,
                title: Some("Updated Title".to_string()),
                content: Some("Updated content".to_string()),
            });
        })
        .await
        .unwrap();

    // Verify update
    let response: serde_json::Value = chain.graphql_query(query).await;
    assert_eq!(response["entries"][0]["title"], "Updated Title");
}

/// Test deleting diary entries
#[tokio::test]
async fn test_delete_entry() {
    let (validator, bytecode_id) = TestValidator::with_current_bytecode::<DiaryAbi>().await;
    let mut chain = validator.new_chain().await;

    let secret_phrase = "my-super-secret-phrase";
    let secret_phrase_hash = hash_secret_phrase(secret_phrase);

    // Initialize
    chain
        .add_block(|block| {
            block.with_operation(Operation::Initialize {
                secret_phrase_hash,
            });
        })
        .await
        .unwrap();

    // Add entries
    chain
        .add_block(|block| {
            block.with_operation(Operation::AddEntry {
                secret_phrase: secret_phrase.to_string(),
                title: "Entry to Keep".to_string(),
                content: "This stays".to_string(),
            });
        })
        .await
        .unwrap();

    chain
        .add_block(|block| {
            block.with_operation(Operation::AddEntry {
                secret_phrase: secret_phrase.to_string(),
                title: "Entry to Delete".to_string(),
                content: "This goes".to_string(),
            });
        })
        .await
        .unwrap();

    // Get entry IDs
    let query = r#"
        query {
            entryCount
            entries {
                id
                title
            }
        }
    "#;

    let response: serde_json::Value = chain.graphql_query(query).await;
    assert_eq!(response["entryCount"], 2);

    let entries = response["entries"].as_array().unwrap();
    let entry_to_delete_id = entries
        .iter()
        .find(|e| e["title"] == "Entry to Delete")
        .unwrap()["id"]
        .as_u64()
        .unwrap();

    // Delete entry
    chain
        .add_block(|block| {
            block.with_operation(Operation::DeleteEntry {
                secret_phrase: secret_phrase.to_string(),
                entry_id: entry_to_delete_id,
            });
        })
        .await
        .unwrap();

    // Verify deletion
    let response: serde_json::Value = chain.graphql_query(query).await;
    assert_eq!(response["entryCount"], 1);
    assert_eq!(response["entries"][0]["title"], "Entry to Keep");
}

/// Test invalid secret phrase
#[tokio::test]
async fn test_invalid_secret_phrase() {
    let (validator, bytecode_id) = TestValidator::with_current_bytecode::<DiaryAbi>().await;
    let mut chain = validator.new_chain().await;

    let secret_phrase = "correct-phrase";
    let secret_phrase_hash = hash_secret_phrase(secret_phrase);

    // Initialize
    chain
        .add_block(|block| {
            block.with_operation(Operation::Initialize {
                secret_phrase_hash,
            });
        })
        .await
        .unwrap();

    // Try to add entry with wrong secret phrase
    let result = chain
        .add_block(|block| {
            block.with_operation(Operation::AddEntry {
                secret_phrase: "wrong-phrase".to_string(),
                title: "Unauthorized Entry".to_string(),
                content: "Should fail".to_string(),
            });
        })
        .await;

    // This should fail or return an error response
    // The exact behavior depends on how Linera handles operation failures
    // You may need to adjust this assertion based on actual behavior
    assert!(
        result.is_err() || !result.unwrap().is_success(),
        "Should not allow operations with invalid secret phrase"
    );
}

/// Test GraphQL queries
#[tokio::test]
async fn test_graphql_queries() {
    let (validator, bytecode_id) = TestValidator::with_current_bytecode::<DiaryAbi>().await;
    let mut chain = validator.new_chain().await;

    let secret_phrase = "my-super-secret-phrase";
    let secret_phrase_hash = hash_secret_phrase(secret_phrase);

    // Initialize and add entries
    chain
        .add_block(|block| {
            block.with_operation(Operation::Initialize {
                secret_phrase_hash,
            });
        })
        .await
        .unwrap();

    // Add multiple entries
    for i in 1..=5 {
        chain
            .add_block(|block| {
                block.with_operation(Operation::AddEntry {
                    secret_phrase: secret_phrase.to_string(),
                    title: format!("Entry {}", i),
                    content: format!("Content for entry {}", i),
                });
            })
            .await
            .unwrap();
    }

    // Test latest entries query
    let query = r#"
        query {
            latestEntries(limit: 3) {
                id
                title
            }
        }
    "#;

    let response: serde_json::Value = chain.graphql_query(query).await;
    let latest = response["latestEntries"].as_array().unwrap();
    assert_eq!(latest.len(), 3);

    // Test search by title
    let query = r#"
        query {
            searchByTitle(query: "Entry 3") {
                title
            }
        }
    "#;

    let response: serde_json::Value = chain.graphql_query(query).await;
    let results = response["searchByTitle"].as_array().unwrap();
    assert_eq!(results.len(), 1);
    assert_eq!(results[0]["title"], "Entry 3");
}

/// Test double initialization should fail
#[tokio::test]
async fn test_double_initialization() {
    let (validator, bytecode_id) = TestValidator::with_current_bytecode::<DiaryAbi>().await;
    let mut chain = validator.new_chain().await;

    let secret_phrase_hash = hash_secret_phrase("secret");

    // First initialization
    chain
        .add_block(|block| {
            block.with_operation(Operation::Initialize {
                secret_phrase_hash: secret_phrase_hash.clone(),
            });
        })
        .await
        .unwrap();

    // Second initialization should fail
    let result = chain
        .add_block(|block| {
            block.with_operation(Operation::Initialize {
                secret_phrase_hash,
            });
        })
        .await;

    // Should return error
    assert!(
        result.is_err() || !result.unwrap().is_success(),
        "Should not allow double initialization"
    );
}
