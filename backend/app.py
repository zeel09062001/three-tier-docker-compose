"""
Notes API: the BACKEND tier.

Receives HTTP requests (forwarded by Nginx in Step 4), applies simple rules,
and reads and writes notes in MySQL.

All settings come from environment variables, so the same code runs on a
laptop, on EC2, or in Kubernetes, without changes.
"""
import logging
import os

import pymysql
from flask import Flask, jsonify, request

# ---------------------------------------------------------------------------
# Settings, from environment variables.
# os.environ["X"] fails immediately if X is missing: we want the container to
# refuse to start with a clear error, rather than start broken.
# ---------------------------------------------------------------------------
DB_HOST = os.environ["DB_HOST"]
DB_PORT = int(os.environ.get("DB_PORT", "3306"))
DB_NAME = os.environ["DB_NAME"]
DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]

MAX_TITLE = 200
MAX_CONTENT = 5000

app = Flask(__name__)
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("notes-api")


def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        charset="utf8mb4",                     
        cursorclass=pymysql.cursors.DictCursor, 
        connect_timeout=5,                      
    )


def to_public(row):
    """Turn a database row into JSON-friendly data."""
    return {
        "id": row["id"],
        "title": row["title"],
        "content": row["content"],
        "createdAt": row["created_at"].isoformat(),
    }


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------
@app.get("/api/health")
def health():
    try:
        with get_connection() as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
        return jsonify(status="ok", database="reachable"), 200
    except pymysql.MySQLError:
        log.exception("Health check: database unreachable")
        return jsonify(status="error", database="unreachable"), 503


@app.get("/api/notes")
def list_notes():
    """All notes, newest first (at most 100)."""
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            "SELECT id, title, content, created_at FROM notes "
            "ORDER BY created_at DESC, id DESC LIMIT 100"
        )
        rows = cur.fetchall()
    return jsonify([to_public(row) for row in rows]), 200


@app.post("/api/notes")
def create_note():
    """Add a note. Expects JSON: {"title": "...", "content": "..."}."""
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return jsonify(error="Request body must be a JSON object"), 400

    title = body.get("title")
    content = body.get("content")

    if not isinstance(title, str) or not 1 <= len(title.strip()) <= MAX_TITLE:
        return jsonify(error=f"title must be 1-{MAX_TITLE} characters"), 400
    if not isinstance(content, str) or not 1 <= len(content.strip()) <= MAX_CONTENT:
        return jsonify(error=f"content must be 1-{MAX_CONTENT} characters"), 400

    with get_connection() as conn:
        with conn.cursor() as cur:
            # %s placeholders: the driver sends the values SEPARATELY from the
            # SQL, so user input can never change the SQL itself.
            cur.execute(
                "INSERT INTO notes (title, content) VALUES (%s, %s)",
                (title.strip(), content.strip()),
            )
            new_id = cur.lastrowid
            cur.execute(
                "SELECT id, title, content, created_at FROM notes WHERE id = %s",
                (new_id,),
            )
            row = cur.fetchone()
        conn.commit() 

    log.info("Created note %s", new_id)
    return jsonify(to_public(row)), 201

@app.delete("/api/notes/<int:note_id>")
def delete_note(note_id):
    with get_connection() as conn:
        with conn.cursor() as cur:
            deleted = cur.execute("DELETE FROM notes WHERE id = %s", (note_id,))
        conn.commit()

    if deleted == 0:
        return jsonify(error="Note not found"), 404

    log.info("Deleted note %s", note_id)
    return "", 204

# ---------------------------------------------------------------------------
# Errors: always JSON, never internal details
# ---------------------------------------------------------------------------
@app.errorhandler(404)
def not_found(_error):
    return jsonify(error="Not found"), 404


@app.errorhandler(Exception)
def unexpected_error(_error):
    log.exception("Unhandled error")
    return jsonify(error="Internal server error"), 500

@app.errorhandler(pymysql.MySQLError)
def database_error(_error):
    """Any database problem in any route: 503, so clients know to retry later."""
    log.exception("Database error")
    return jsonify(error="Database unavailable"), 503