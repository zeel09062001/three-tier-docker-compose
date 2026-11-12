#!/bin/bash
# =============================================================================
# Runs ONCE, as root, the first time the server boots (via cloud-init).
# Installs Docker and the Compose plugin.
# Network operations are RETRIED, because brand-new servers sometimes have
# temporary network or package-mirror problems in their first seconds.
# =============================================================================
set -euxo pipefail

# retry <attempts> <command...>: run a command until it succeeds, waiting
# 15 seconds between attempts; give up (and fail) after the last attempt
retry() {
  local attempts="$1"; shift
  for i in $(seq 1 "$attempts"); do
    if "$@"; then
      return 0
    fi
    echo "Attempt $i/$attempts failed: $*. Retrying in 15 seconds..."
    sleep 15
  done
  echo "Giving up after $attempts attempts: $*"
  return 1
}

# Refresh the list of available software packages (retried)
retry 5 apt-get update -y

# Download Docker's official installation script (retried), then run it
retry 5 curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
retry 3 sh /tmp/get-docker.sh

# Let the "ubuntu" user run docker commands without sudo
usermod -aG docker ubuntu

# Start Docker now, AND every time the server boots
systemctl enable --now docker

echo "user-data finished successfully"