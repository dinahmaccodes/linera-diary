#![cfg_attr(target_arch = "wasm32", no_main)]

mod state;

use linera_sdk::{
    linera_base_types::WithContractAbi,
    views::{RootView, View},
    Contract, ContractRuntime,
};

use diary_backend::Operation;
use self::state::{DiaryEntry, DiaryState};

pub struct DiaryContract {
    state: DiaryState,
    runtime: ContractRuntime<Self>,
}

linera_sdk::contract!(DiaryContract);

impl WithContractAbi for DiaryContract {
    type Abi = diary_backend::DiaryAbi;
}

impl Contract for DiaryContract {
    type Message = ();
    type Parameters = ();
    type InstantiationArgument = ();
    type EventValue = ();

    async fn load(runtime: ContractRuntime<Self>) -> Self {
        let state = DiaryState::load(runtime.root_view_storage_context())
            .await
            .expect("Failed to load state");
        DiaryContract { state, runtime }
    }

    async fn instantiate(&mut self, _argument: Self::InstantiationArgument) {
        // Validate that the application parameters were configured correctly
        self.runtime.application_parameters();
    }

    async fn execute_operation(&mut self, operation: Self::Operation) -> Self::Response {
        match operation {
            Operation::Initialize { secret_phrase } => {
                // Check if already initialized
                assert!(!self.state.is_initialized(), "Diary already initialized");
                
                // Hash and store the secret phrase
                let hash = diary_backend::hash_secret_phrase(&secret_phrase);
                self.state.secret_phrase_hash.set(hash);
                
                // Set the owner
                let owner = self.runtime.authenticated_signer()
                    .expect("Owner must be authenticated")
                    .to_string();
                self.state.owner.set(owner);
                
                // Initialize entry count
                self.state.entry_count.set(0);
            }
            
            Operation::AddEntry { secret_phrase, title, content } => {
                // Verify diary is initialized
                assert!(self.state.is_initialized(), "Diary not initialized");
                
                // Verify secret phrase
                let provided_hash = diary_backend::hash_secret_phrase(&secret_phrase);
                let stored_hash = self.state.secret_phrase_hash.get();
                assert_eq!(&provided_hash, stored_hash, "Invalid secret phrase");
                
                // Verify caller is the owner
                let owner = self.state.owner.get();
                let caller = self.runtime.authenticated_signer()
                    .expect("Caller must be authenticated")
                    .to_string();
                assert_eq!(owner, &caller, "Only the owner can add entries");
                
                // Get next entry ID
                let entry_id = *self.state.entry_count.get();
                
                // Create new entry
                let entry = DiaryEntry {
                    id: entry_id,
                    title,
                    content,
                    timestamp: self.runtime.system_time().micros(),
                };
                
                // Store entry
                self.state.entries.insert(&entry_id, entry)
                    .expect("Failed to insert entry");
                
                // Increment counter
                self.state.entry_count.set(entry_id + 1);
            }
            
            Operation::UpdateEntry { secret_phrase, entry_id, title, content } => {
                // Verify diary is initialized
                assert!(self.state.is_initialized(), "Diary not initialized");
                
                // Verify secret phrase
                let provided_hash = diary_backend::hash_secret_phrase(&secret_phrase);
                let stored_hash = self.state.secret_phrase_hash.get();
                assert_eq!(&provided_hash, stored_hash, "Invalid secret phrase");
                
                // Verify caller is the owner
                let owner = self.state.owner.get();
                let caller = self.runtime.authenticated_signer()
                    .expect("Caller must be authenticated")
                    .to_string();
                assert_eq!(owner, &caller, "Only the owner can update entries");
                
                // Get existing entry
                let mut entry = self.state.entries.get(&entry_id)
                    .await
                    .expect("Failed to read entry")
                    .expect("Entry not found");
                
                // Update fields if provided
                if let Some(new_title) = title {
                    entry.title = new_title;
                }
                if let Some(new_content) = content {
                    entry.content = new_content;
                }
                
                // Update timestamp
                entry.timestamp = self.runtime.system_time().micros();
                
                // Store updated entry
                self.state.entries.insert(&entry_id, entry)
                    .expect("Failed to update entry");
            }
            
            Operation::DeleteEntry { secret_phrase, entry_id } => {
                // Verify diary is initialized
                assert!(self.state.is_initialized(), "Diary not initialized");
                
                // Verify secret phrase
                let provided_hash = diary_backend::hash_secret_phrase(&secret_phrase);
                let stored_hash = self.state.secret_phrase_hash.get();
                assert_eq!(&provided_hash, stored_hash, "Invalid secret phrase");
                
                // Verify caller is the owner
                let owner = self.state.owner.get();
                let caller = self.runtime.authenticated_signer()
                    .expect("Caller must be authenticated")
                    .to_string();
                assert_eq!(owner, &caller, "Only the owner can delete entries");
                
                // Remove the entry
                self.state.entries.remove(&entry_id)
                    .expect("Failed to delete entry");
            }
        }
    }

    async fn execute_message(&mut self, _message: Self::Message) {}

    async fn store(mut self) {
        self.state.save().await.expect("Failed to save state");
    }
}
