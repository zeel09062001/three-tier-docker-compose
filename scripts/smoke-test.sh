#!/usr/bin/env bash
# =============================================================================
# Smoke test: proves Frontend -> Backend -> Database works end to end.
#
# Usage:
#   ./scripts/smoke-test.sh                      
#   ./scripts/smoke-test.sh http://<server-ip>   
#
# Exits with code 0 if every check passes, 1 if any check fails.
# =============================================================================
set -uo pipefail

BASE_URL="${1:-http://127.0.0.1}"
PASSED=0
FAILED=0

pass() { echo "  ✅ PASS  $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  ❌ FAIL  $1"; FAILED=$((FAILED + 1)); }

# Returns just the HTTP status code of a request (000 = no answer at all)
status_of() { curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$@" || echo "000"; }

echo "Smoke testing $BASE_URL"
echo

# --- 1. Frontend: does Nginx serve the web page? ------------------------------
page=$(curl -s --max-time 5 "$BASE_URL/" || true)
if echo "$page" | grep -q "<title>Notes</title>"; then
  pass "Frontend serves the Notes web page"
else
  fail "Frontend serves the Notes web page"
fi

# --- 2. Frontend: Nginx's own health check ------------------------------------
if [ "$(status_of "$BASE_URL/nginx-health")" = "200" ]; then
  pass "Nginx health check returns 200"
else
  fail "Nginx health check returns 200"
fi

# --- 3. Frontend -> Backend -> Database: the health check through the proxy ---
health=$(curl -s --max-time 5 "$BASE_URL/api/health" || true)
if echo "$health" | grep -q '"database":"reachable"'; then
  pass "API health through Nginx: database reachable"
else
  fail "API health through Nginx: database reachable (got: $health)"
fi

# --- 4. Create a note (a real write to the database) --------------------------
response=$(curl -s --max-time 5 -w '\n%{http_code}' -X POST "$BASE_URL/api/notes" \
  -H "Content-Type: application/json" \
  -d '{"title": "Smoke test", "content": "Created by smoke-test.sh"}' || true)
code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
note_id=$(echo "$body" | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])' 2>/dev/null || true)

if [ "$code" = "201" ] && [ -n "$note_id" ]; then
  pass "Create a note returns 201 (id $note_id)"
else
  fail "Create a note returns 201 (got $code)"
fi

# --- 5. The new note appears in the list (a real read from the database) ------
if [ -n "$note_id" ] && curl -s --max-time 5 "$BASE_URL/api/notes" \
    | python3 -c "import json,sys; ids=[n['id'] for n in json.load(sys.stdin)]; sys.exit(0 if $note_id in ids else 1)" 2>/dev/null; then
  pass "The new note appears in the list"
else
  fail "The new note appears in the list"
fi

# --- 6. Delete the note, then confirm it's gone -------------------------------
if [ -n "$note_id" ] && [ "$(status_of -X DELETE "$BASE_URL/api/notes/$note_id")" = "204" ]; then
  pass "Delete the note returns 204"
else
  fail "Delete the note returns 204"
fi

if [ -n "$note_id" ] && [ "$(status_of -X DELETE "$BASE_URL/api/notes/$note_id")" = "404" ]; then
  pass "Deleting it again returns 404"
else
  fail "Deleting it again returns 404"
fi

# --- 7. Bad input is rejected -------------------------------------------------
bad=$(status_of -X POST "$BASE_URL/api/notes" -H "Content-Type: application/json" \
  -d '{"title": "", "content": "x"}')
if [ "$bad" = "400" ]; then
  pass "Invalid note returns 400"
else
  fail "Invalid note returns 400 (got $bad)"
fi

# --- 8. Security headers are present ------------------------------------------
headers=$(curl -sI --max-time 5 "$BASE_URL/" || true)
if echo "$headers" | grep -qi "content-security-policy" \
   && echo "$headers" | grep -qi "x-frame-options"; then
  pass "Security headers present"
else
  fail "Security headers present"
fi

# --- Summary ------------------------------------------------------------------
echo
echo "Result: $PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]