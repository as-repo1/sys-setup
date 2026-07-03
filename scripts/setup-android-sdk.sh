#!/usr/bin/env bash
# setup-android-sdk.sh — Configure Android SDK environment variables

set -euo pipefail

echo "→ Configuring Android SDK..."

ANDROID_HOME="/opt/android-sdk"
SDK_CMDLINE="$ANDROID_HOME/cmdline-tools/latest/bin"

# Add env vars to fish config if not present
FISH_ENV="$HOME/.config/fish/conf.d/android.fish"
mkdir -p "$(dirname "$FISH_ENV")"

if [[ ! -f "$FISH_ENV" ]]; then
cat > "$FISH_ENV" <<EOF
# Android SDK
set -x ANDROID_HOME $ANDROID_HOME
set -x PATH \$PATH $SDK_CMDLINE $ANDROID_HOME/platform-tools
EOF
    echo "  ✓ Android env vars written to $FISH_ENV"
else
    echo "  Android config already exists, skipping."
fi

echo "  ✓ Android SDK configured. Run 'sdkmanager --list' after re-login."
