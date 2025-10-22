// Copyright (c) Linera.
// SPDX-License-Identifier: Apache-2.0

//! Integration tests for the diary application.
//! These tests run the full application on a simulated chain.
//! 
//! NOTE: These tests are placeholders and will be expanded once
//! the Linera SDK test API is stable. For now, manual testing
//! via the client interface is recommended.

#[cfg(test)]
mod tests {
    use diary_backend::{Operation, hash_secret_phrase};

    #[test]
    fn test_operation_types_compile() {
        // Basic smoke test to ensure types compile
        let _init_op = Operation::Initialize {
            secret_phrase: "test-phrase".to_string(),
        };
        
        let _add_op = Operation::AddEntry {
            secret_phrase: "test-phrase".to_string(),
            title: "Test Title".to_string(),
            content: "Test Content".to_string(),
        };
        
        let _update_op = Operation::UpdateEntry {
            secret_phrase: "test-phrase".to_string(),
            entry_id: 1,
            title: Some("Updated Title".to_string()),
            content: None,
        };
        
        let _delete_op = Operation::DeleteEntry {
            secret_phrase: "test-phrase".to_string(),
            entry_id: 1,
        };
    }

    #[test]
    fn test_hash_secret_phrase() {
        let phrase = "my-secret-phrase";
        let hash1 = hash_secret_phrase(phrase);
        let hash2 = hash_secret_phrase(phrase);
        
        // Same phrase should produce same hash
        assert_eq!(hash1, hash2);
        
        // Different phrase should produce different hash
        let hash3 = hash_secret_phrase("different-phrase");
        assert_ne!(hash1, hash3);
        
        // Hash should be consistent length (SHA-256 = 64 hex chars)
        assert_eq!(hash1.len(), 64);
    }
}
