#!/usr/bin/env bash
# setup-appimages.sh — Download and register AppImages via appimagelauncher

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/../appimages/appimages.csv"
DEST="$HOME/Appimages"

mkdir -p "$DEST"

echo "→ Installing AppImages to $DEST..."

# Skip header line
tail -n +2 "$MANIFEST" | while IFS=',' read -r name url sha256; do
    [[ -z "$name" || "$name" == \#* ]] && continue

    OUTFILE="$DEST/${name}.AppImage"

    if [[ -f "$OUTFILE" ]]; then
        echo "  ↷ $name already exists, skipping."
        continue
    fi

    echo "  ↓ Downloading $name..."
    if curl -L --progress-bar -o "$OUTFILE" "$url"; then
        chmod +x "$OUTFILE"

        # Verify sha256 if not 'auto'
        if [[ "$sha256" != "auto" ]]; then
            echo "$sha256  $OUTFILE" | sha256sum --check --quiet \
                && echo "  ✓ $name verified" \
                || { echo "  ✗ $name checksum FAILED — removing"; rm -f "$OUTFILE"; continue; }
        fi

        # Register with appimagelauncher if available
        if command -v ail-cli &>/dev/null; then
            ail-cli integrate "$OUTFILE" && echo "  ✓ $name registered"
        else
            echo "  ⚠ appimagelauncher-cli not found, skipping registration for $name"
        fi
    else
        echo "  ✗ Failed to download $name"
        rm -f "$OUTFILE"
    fi
done

echo "  ✓ AppImages done."
