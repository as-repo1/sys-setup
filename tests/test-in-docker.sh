#!/usr/bin/env bash
# test-in-docker.sh — Run installer tests inside a custom Arch Linux Docker container

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "Building test Docker image 'sys-setup-test'..."
docker build -t sys-setup-test -f "$SCRIPT_DIR/Dockerfile" "$REPO_DIR"

echo "Running test container..."
if [ $# -eq 0 ]; then
    echo "Starting interactive bash shell in the container."
    echo "You can run: bash install.sh --dry-run"
    docker run --rm -it \
      -v "$REPO_DIR:/home/tester/sys-setup" \
      sys-setup-test \
      /bin/bash
else
    echo "Running install.sh with arguments: $*"
    docker run --rm -it \
      -v "$REPO_DIR:/home/tester/sys-setup" \
      sys-setup-test \
      bash install.sh "$@"
fi
