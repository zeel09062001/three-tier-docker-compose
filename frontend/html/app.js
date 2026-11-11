// =============================================================================
// Notes page: talks to the API, and shows friendly messages to the user.
// All API calls use RELATIVE paths ("/api/..."), so they go to the same
// address as the page, through Nginx. No CORS needed.
// =============================================================================

const form = document.getElementById("note-form");
const list = document.getElementById("notes");
const emptyText = document.getElementById("empty");
const messageBox = document.getElementById("message");

const CANNOT_CONNECT = "Can't reach the server. Please check your internet connection and try again.";

// -----------------------------------------------------------------------------
// Translate technical HTTP responses into language anyone can understand
// -----------------------------------------------------------------------------
async function friendlyError(response) {
    switch (response.status) {
        case 400: {
            const data = await response.json().catch(() => ({}));
            return data.error
                ? `Please check your note: ${data.error}.`
                : "Please check your note and try again.";
        }
        case 404:
            return "That note no longer exists. It may have already been deleted.";
        case 503:
            return "The database is temporarily unavailable. Please try again in a moment.";
        case 502:
        case 504:
            return "The server isn't responding right now. Please try again shortly.";
        default:
            return "Something went wrong. Please try again.";
    }
}

function showMessage(text, type = "error") {
    messageBox.textContent = text;
    messageBox.className = `message ${type}`;
    messageBox.hidden = false;
}

function clearMessage() {
    messageBox.hidden = true;
}

// MySQL stores times in UTC without saying so. Add "Z" (= UTC), so the browser
// converts it to the user's own local time correctly.
function formatDate(isoText) {
    const utc = isoText.endsWith("Z") ? isoText : `${isoText}Z`;
    return new Date(utc).toLocaleString();
}

// -----------------------------------------------------------------------------
// Show the notes. ALWAYS textContent, never innerHTML: user text is never code.
// -----------------------------------------------------------------------------
function renderNotes(notes) {
    list.replaceChildren();
    emptyText.hidden = notes.length > 0;

    for (const note of notes) {
        const item = document.createElement("li");
        item.className = "note";

        const title = document.createElement("h3");
        title.textContent = note.title;

        const content = document.createElement("p");
        content.textContent = note.content;

        const date = document.createElement("small");
        date.className = "muted";
        date.textContent = formatDate(note.createdAt);

        const deleteButton = document.createElement("button");
        deleteButton.type = "button";
        deleteButton.className = "danger";
        deleteButton.textContent = "Delete";
        deleteButton.addEventListener("click", () => deleteNote(note));

        item.append(title, content, date, deleteButton);
        list.appendChild(item);
    }
}

// -----------------------------------------------------------------------------
// API calls
// -----------------------------------------------------------------------------
async function loadNotes() {
    try {
        const response = await fetch("/api/notes");
        if (!response.ok) {
            showMessage(await friendlyError(response));
            return;
        }
        renderNotes(await response.json());
    } catch {
        showMessage(CANNOT_CONNECT);
    }
}

form.addEventListener("submit", async (event) => {
    event.preventDefault();              
    clearMessage();
    const button = form.querySelector('button[type="submit"]');
    button.disabled = true;               

    try {
        const response = await fetch("/api/notes", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                title: form.elements.title.value,
                content: form.elements.content.value,
            }),
        });

        if (response.status === 201) {
            form.reset();
            showMessage("Note added.", "success");
            await loadNotes();
        } else {
            showMessage(await friendlyError(response));
        }
    } catch {
        showMessage(CANNOT_CONNECT);
    } finally {
        button.disabled = false;
    }
});

async function deleteNote(note) {
    if (!window.confirm(`Delete the note "${note.title}"?`)) {
        return;
    }
    clearMessage();

    try {
        const response = await fetch(`/api/notes/${note.id}`, { method: "DELETE" });

        if (response.status === 204) {
            showMessage("Note deleted.", "success");
        } else {
            showMessage(await friendlyError(response));
        }
        await loadNotes();                  
    } catch {
        showMessage(CANNOT_CONNECT);
    }
}

// Start: load the notes as soon as the page opens
loadNotes();