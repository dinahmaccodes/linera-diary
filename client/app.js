// ==========================================
// Linera Diary - Main Application
// ==========================================

import { config } from "./config.js";

// ==========================================
// STATE MANAGEMENT
// ==========================================

const state = {
  isInitialized: false,
  isUnlocked: false,
  owner: null,
  entries: [],
  currentEntry: null,
  loading: false,
};

// ==========================================
// GRAPHQL CLIENT
// ==========================================

class GraphQLClient {
  constructor(url) {
    this.url = url;
  }

  async query(query, variables = {}) {
    try {
      const response = await fetch(this.url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          query,
          variables,
        }),
      });

      const result = await response.json();

      if (result.errors) {
        throw new Error(result.errors[0].message);
      }

      return result.data;
    } catch (error) {
      console.error("GraphQL Error:", error);
      throw error;
    }
  }

  async mutate(mutation, variables = {}) {
    return this.query(mutation, variables);
  }
}

// Initialize GraphQL client
const client = new GraphQLClient(config.graphqlUrl);

// ==========================================
// UTILITY FUNCTIONS
// ==========================================

function hashSecretPhrase(phrase) {
  // Simple hash function - in production, use proper crypto
  return btoa(phrase);
}

function formatDate(timestamp) {
  const date = new Date(parseInt(timestamp));
  const now = new Date();
  const diffMs = now - date;
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (diffDays === 0) {
    const hours = date.getHours().toString().padStart(2, "0");
    const minutes = date.getMinutes().toString().padStart(2, "0");
    return `Today at ${hours}:${minutes}`;
  } else if (diffDays === 1) {
    return "Yesterday";
  } else if (diffDays < 7) {
    return `${diffDays} days ago`;
  } else {
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  }
}

function truncateText(text, maxLength = 150) {
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength) + "...";
}

function showStatus(message, type = "info") {
  const statusEl = document.getElementById("status");
  statusEl.textContent = message;
  statusEl.className = `status status-${type}`;
  statusEl.classList.remove("hidden");

  // Auto-hide after 5 seconds
  setTimeout(() => {
    statusEl.classList.add("hidden");
  }, 5000);
}

function setLoading(isLoading) {
  state.loading = isLoading;
  const loadingEls = document.querySelectorAll(".loading");
  loadingEls.forEach((el) => {
    el.classList.toggle("hidden", !isLoading);
  });
}

// ==========================================
// DIARY API FUNCTIONS
// ==========================================

async function checkInitialization() {
  const query = `
        query {
            isInitialized
        }
    `;

  try {
    const data = await client.query(query);
    state.isInitialized = data.isInitialized;
    return data.isInitialized;
  } catch (error) {
    console.error("Error checking initialization:", error);
    showStatus("Error connecting to the blockchain", "error");
    return false;
  }
}

async function initializeDiary(secretPhrase) {
  const mutation = `
        mutation($secretPhrase: String!) {
            initialize(secretPhrase: $secretPhrase) {
                success
                message
            }
        }
    `;

  try {
    setLoading(true);
    const data = await client.mutate(mutation, { secretPhrase });

    if (data.initialize.success) {
      state.isInitialized = true;
      // Don't show status here - let handleInitialize show it
      return true;
    } else {
      showStatus(data.initialize.message, "error");
      return false;
    }
  } catch (error) {
    console.error("Error initializing diary:", error);
    showStatus("Failed to create diary: " + error.message, "error");
    return false;
  } finally {
    setLoading(false);
  }
}

async function unlockDiary(secretPhrase) {
  const mutation = `
        mutation($secretPhrase: String!) {
            unlock(secretPhrase: $secretPhrase) {
                success
                message
            }
        }
    `;

  try {
    setLoading(true);
    const data = await client.mutate(mutation, { secretPhrase });

    if (data.unlock.success) {
      state.isUnlocked = true;
      // Store hashed phrase for session (not the actual phrase)
      sessionStorage.setItem("diaryUnlocked", "true");
      showStatus("Diary unlocked! 🔓", "success");
      await loadEntries();
      return true;
    } else {
      showStatus("Incorrect secret phrase", "error");
      return false;
    }
  } catch (error) {
    console.error("Error unlocking diary:", error);
    showStatus("Failed to unlock diary: " + error.message, "error");
    return false;
  } finally {
    setLoading(false);
  }
}

async function loadEntries() {
  const query = `
        query {
            entries {
                id
                title
                content
                timestamp
            }
        }
    `;

  try {
    setLoading(true);
    const data = await client.query(query);
    state.entries = data.entries || [];
    renderEntries();
  } catch (error) {
    console.error("Error loading entries:", error);
    showStatus("Failed to load entries", "error");
  } finally {
    setLoading(false);
  }
}

async function addEntry(title, content, secretPhrase) {
  const mutation = `
        mutation($title: String!, $content: String!, $secretPhrase: String!) {
            addEntry(title: $title, content: $content, secretPhrase: $secretPhrase) {
                success
                message
                entryId
            }
        }
    `;

  try {
    setLoading(true);
    const data = await client.mutate(mutation, {
      title,
      content,
      secretPhrase,
    });

    if (data.addEntry.success) {
      showStatus("Entry saved! 📝", "success");
      await loadEntries();
      return true;
    } else {
      showStatus(data.addEntry.message, "error");
      return false;
    }
  } catch (error) {
    console.error("Error adding entry:", error);
    showStatus("Failed to save entry: " + error.message, "error");
    return false;
  } finally {
    setLoading(false);
  }
}

async function updateEntry(id, title, content, secretPhrase) {
  const mutation = `
        mutation($id: Int!, $title: String!, $content: String!, $secretPhrase: String!) {
            updateEntry(id: $id, title: $title, content: $content, secretPhrase: $secretPhrase) {
                success
                message
            }
        }
    `;

  try {
    setLoading(true);
    const data = await client.mutate(mutation, {
      id: parseInt(id),
      title,
      content,
      secretPhrase,
    });

    if (data.updateEntry.success) {
      showStatus("Entry updated! ✏️", "success");
      await loadEntries();
      return true;
    } else {
      showStatus(data.updateEntry.message, "error");
      return false;
    }
  } catch (error) {
    console.error("Error updating entry:", error);
    showStatus("Failed to update entry: " + error.message, "error");
    return false;
  } finally {
    setLoading(false);
  }
}

async function deleteEntry(id, secretPhrase) {
  const mutation = `
        mutation($id: Int!, $secretPhrase: String!) {
            deleteEntry(id: $id, secretPhrase: $secretPhrase) {
                success
                message
            }
        }
    `;

  try {
    setLoading(true);
    const data = await client.mutate(mutation, {
      id: parseInt(id),
      secretPhrase,
    });

    if (data.deleteEntry.success) {
      showStatus("Entry deleted", "success");
      await loadEntries();
      return true;
    } else {
      showStatus(data.deleteEntry.message, "error");
      return false;
    }
  } catch (error) {
    console.error("Error deleting entry:", error);
    showStatus("Failed to delete entry: " + error.message, "error");
    return false;
  } finally {
    setLoading(false);
  }
}

async function searchEntries(query) {
  const searchQuery = `
        query($query: String!) {
            searchByTitle(query: $query) {
                id
                title
                content
                timestamp
            }
        }
    `;

  try {
    setLoading(true);
    const data = await client.query(searchQuery, { query });
    state.entries = data.searchByTitle || [];
    renderEntries();
  } catch (error) {
    console.error("Error searching entries:", error);
    showStatus("Search failed", "error");
  } finally {
    setLoading(false);
  }
}

// ==========================================
// UI RENDERING
// ==========================================

function renderEntries() {
  const grid = document.getElementById("entriesGrid");
  const emptyState = document.getElementById("emptyState");

  if (!state.entries || state.entries.length === 0) {
    grid.classList.add("hidden");
    emptyState.classList.remove("hidden");
    return;
  }

  grid.classList.remove("hidden");
  emptyState.classList.add("hidden");

  grid.innerHTML = state.entries
    .sort((a, b) => b.timestamp - a.timestamp)
    .map(
      (entry) => `
            <div class="entry-card fade-in" data-entry-id="${entry.id}">
                <div class="entry-header">
                    <h3 class="entry-title">${escapeHtml(entry.title)}</h3>
                    <p class="entry-date">${formatDate(entry.timestamp)}</p>
                </div>
                <p class="entry-preview">${escapeHtml(
                  truncateText(entry.content)
                )}</p>
                <div class="entry-actions">
                    <button class="btn btn-sm btn-outline" onclick="viewEntry('${
                      entry.id
                    }')">
                        📖 Read
                    </button>
                    <button class="btn btn-sm btn-ghost" onclick="editEntry('${
                      entry.id
                    }')">
                        ✏️ Edit
                    </button>
                    <button class="btn btn-sm btn-ghost text-error" onclick="confirmDeleteEntry('${
                      entry.id
                    }')">
                        🗑️ Delete
                    </button>
                </div>
            </div>
        `
    )
    .join("");
}

function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

// ==========================================
// MODAL MANAGEMENT
// ==========================================

function showModal(modalId) {
  const modal = document.getElementById(modalId);
  modal.classList.remove("hidden");
  document.body.style.overflow = "hidden";
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  modal.classList.add("hidden");
  document.body.style.overflow = "";
}

function viewEntry(entryId) {
  const entry = state.entries.find(
    (e) => e.id.toString() === entryId.toString()
  );
  if (!entry) return;

  document.getElementById("viewEntryTitle").textContent = entry.title;
  document.getElementById("viewEntryDate").textContent = formatDate(
    entry.timestamp
  );
  document.getElementById("viewEntryContent").textContent = entry.content;

  showModal("viewEntryModal");
}

function editEntry(entryId) {
  const entry = state.entries.find(
    (e) => e.id.toString() === entryId.toString()
  );
  if (!entry) return;

  state.currentEntry = entry;

  document.getElementById("editEntryId").value = entry.id;
  document.getElementById("editEntryTitle").value = entry.title;
  document.getElementById("editEntryContent").value = entry.content;

  showModal("editEntryModal");
}

function confirmDeleteEntry(entryId) {
  const entry = state.entries.find(
    (e) => e.id.toString() === entryId.toString()
  );
  if (!entry) return;

  state.currentEntry = entry;
  document.getElementById("deleteEntryTitle").textContent = entry.title;

  showModal("deleteEntryModal");
}

// ==========================================
// EVENT HANDLERS
// ==========================================

async function handleInitialize(e) {
  e.preventDefault();

  const secretPhrase = document.getElementById("secretPhrase").value;

  if (secretPhrase.length < 8) {
    showStatus("Secret phrase must be at least 8 characters", "error");
    return;
  }

  const success = await initializeDiary(secretPhrase);

  if (success) {
    document.getElementById("secretPhrase").value = "";
    // Automatically unlock after initialization
    state.isUnlocked = true;
    sessionStorage.setItem("diaryUnlocked", "true");
    showStatus(
      "Diary created and unlocked! You can now write entries 🎉",
      "success"
    );
    await loadEntries();
    updateUI();
  }
}

async function handleUnlock(e) {
  e.preventDefault();

  const secretPhrase = document.getElementById("unlockPhrase").value;

  if (!secretPhrase) {
    showStatus("Please enter your secret phrase", "error");
    return;
  }

  const success = await unlockDiary(secretPhrase);

  if (success) {
    document.getElementById("unlockPhrase").value = "";
    updateUI();
  }
}

async function handleAddEntry(e) {
  e.preventDefault();

  const title = document.getElementById("newEntryTitle").value;
  const content = document.getElementById("newEntryContent").value;
  const secretPhrase = document.getElementById("newEntrySecret").value;

  if (!title || !content || !secretPhrase) {
    showStatus("Please fill in all fields", "error");
    return;
  }

  const success = await addEntry(title, content, secretPhrase);

  if (success) {
    document.getElementById("newEntryForm").reset();
    closeModal("newEntryModal");
  }
}

async function handleEditEntry(e) {
  e.preventDefault();

  const id = document.getElementById("editEntryId").value;
  const title = document.getElementById("editEntryTitle").value;
  const content = document.getElementById("editEntryContent").value;
  const secretPhrase = document.getElementById("editEntrySecret").value;

  if (!title || !content || !secretPhrase) {
    showStatus("Please fill in all fields", "error");
    return;
  }

  const success = await updateEntry(id, title, content, secretPhrase);

  if (success) {
    closeModal("editEntryModal");
  }
}

async function handleDeleteEntry(e) {
  e.preventDefault();

  const secretPhrase = document.getElementById("deleteEntrySecret").value;

  if (!secretPhrase) {
    showStatus("Please enter your secret phrase", "error");
    return;
  }

  const success = await deleteEntry(state.currentEntry.id, secretPhrase);

  if (success) {
    document.getElementById("deleteEntrySecret").value = "";
    closeModal("deleteEntryModal");
  }
}

function handleSearch(e) {
  const query = e.target.value.trim();

  if (query.length === 0) {
    loadEntries();
  } else if (query.length >= 2) {
    searchEntries(query);
  }
}

function handleLock() {
  state.isUnlocked = false;
  sessionStorage.removeItem("diaryUnlocked");
  state.entries = [];
  showStatus("Diary locked 🔒", "info");
  updateUI();
}

// ==========================================
// UI STATE MANAGEMENT
// ==========================================

function updateUI() {
  const initSection = document.getElementById("initSection");
  const unlockSection = document.getElementById("unlockSection");
  const diarySection = document.getElementById("diarySection");
  const lockBtn = document.getElementById("lockBtn");
  const hero = document.querySelector(".hero");

  if (!state.isInitialized) {
    // Show initialization form only
    initSection.classList.remove("hidden");
    unlockSection.classList.add("hidden");
    diarySection.classList.add("hidden");
    lockBtn.classList.add("hidden");
    if (hero) hero.classList.remove("hidden");
  } else if (!state.isUnlocked) {
    // Show unlock form
    initSection.classList.add("hidden");
    unlockSection.classList.remove("hidden");
    diarySection.classList.add("hidden");
    lockBtn.classList.add("hidden");
    if (hero) hero.classList.add("hidden");
  } else {
    // Show diary section (user is unlocked)
    initSection.classList.add("hidden");
    unlockSection.classList.add("hidden");
    diarySection.classList.remove("hidden");
    lockBtn.classList.remove("hidden");
    if (hero) hero.classList.add("hidden");
  }
}

// ==========================================
// THEME TOGGLE
// ==========================================

function initTheme() {
  const savedTheme = localStorage.getItem("theme") || "light";
  document.documentElement.setAttribute("data-theme", savedTheme);
  updateThemeIcon(savedTheme);
}

function toggleTheme() {
  const currentTheme = document.documentElement.getAttribute("data-theme");
  const newTheme = currentTheme === "light" ? "dark" : "light";

  document.documentElement.setAttribute("data-theme", newTheme);
  localStorage.setItem("theme", newTheme);
  updateThemeIcon(newTheme);
}

function updateThemeIcon(theme) {
  const themeIcon = document.getElementById("themeIcon");
  if (themeIcon) {
    themeIcon.textContent = theme === "light" ? "🌙" : "☀️";
  }
}

// ==========================================
// INITIALIZATION
// ==========================================

async function init() {
  console.log("🚀 Initializing Linera Diary...");
  console.log("GraphQL URL:", config.graphqlUrl);

  // Initialize theme
  initTheme();

  // Check if diary is initialized
  showStatus("Connecting to blockchain...", "info");
  const initialized = await checkInitialization();

  if (initialized) {
    showStatus("Connected to Linera blockchain ✓", "success");

    // Check if session is unlocked
    const sessionUnlocked = sessionStorage.getItem("diaryUnlocked");
    if (sessionUnlocked) {
      // Try to load entries (will fail if session expired)
      try {
        await loadEntries();
        state.isUnlocked = true;
      } catch (error) {
        sessionStorage.removeItem("diaryUnlocked");
      }
    }
  } else {
    showStatus("Ready to create your diary", "info");
  }

  updateUI();

  // Setup event listeners
  setupEventListeners();
}

function setupEventListeners() {
  // Forms
  const initForm = document.getElementById("initForm");
  if (initForm) initForm.addEventListener("submit", handleInitialize);

  const unlockForm = document.getElementById("unlockForm");
  if (unlockForm) unlockForm.addEventListener("submit", handleUnlock);

  const newEntryForm = document.getElementById("newEntryForm");
  if (newEntryForm) newEntryForm.addEventListener("submit", handleAddEntry);

  const editEntryForm = document.getElementById("editEntryForm");
  if (editEntryForm) editEntryForm.addEventListener("submit", handleEditEntry);

  const deleteEntryForm = document.getElementById("deleteEntryForm");
  if (deleteEntryForm)
    deleteEntryForm.addEventListener("submit", handleDeleteEntry);

  // Search
  const searchInput = document.getElementById("searchInput");
  if (searchInput) {
    searchInput.addEventListener("input", handleSearch);
  }

  // Theme toggle
  const themeToggle = document.getElementById("themeToggle");
  if (themeToggle) themeToggle.addEventListener("click", toggleTheme);

  // Lock button
  const lockBtn = document.getElementById("lockBtn");
  if (lockBtn) lockBtn.addEventListener("click", handleLock);
}

// Make functions available globally for onclick handlers
window.viewEntry = viewEntry;
window.editEntry = editEntry;
window.confirmDeleteEntry = confirmDeleteEntry;
window.closeModal = closeModal;
window.showModal = showModal;
window.toggleTheme = toggleTheme;

// Start the app when DOM is ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}
