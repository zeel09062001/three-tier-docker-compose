#!/usr/bin/env bash
# =============================================================================
# Deploy the latest code from GitHub. Run this ON THE SERVER, in the project folder.
# =============================================================================
set -euo pipefail

echo "==> Fetching the latest code from GitHub"
git pull --ff-only

echo "==> Rebuilding and restarting changed services"
docker compose up -d --build --wait

echo "==> Removing old, unused images (frees disk space)"
docker image prune -f

echo "==> Current status"
docker compose ps