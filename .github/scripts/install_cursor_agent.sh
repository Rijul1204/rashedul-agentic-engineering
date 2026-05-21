#!/bin/bash
set -euo pipefail

# Configuration
CURSOR_VERSION="${CURSOR_VERSION:-latest}"
INSTALL_DIR="$HOME/.local/bin"
CURSOR_BINARY="$INSTALL_DIR/cursor-agent"

echo "=== Cursor Agent Installation ==="
echo "Version: $CURSOR_VERSION"
echo "Install directory: $INSTALL_DIR"

# Create install directory
mkdir -p "$INSTALL_DIR"

# Check if already installed and cached
if [ -f "$CURSOR_BINARY" ]; then
    echo "✓ cursor-agent already exists (from cache or previous install)"
    if "$CURSOR_BINARY" --version 2>/dev/null; then
        echo "✓ Verified: cursor-agent is functional"
        exit 0
    else
        echo "⚠ Existing binary is not functional, re-downloading..."
        rm -f "$CURSOR_BINARY"
    fi
fi

echo "Installing cursor-agent..."

# Update CA certificates first
echo "Updating CA certificates..."
sudo apt-get update -qq
sudo apt-get install -y ca-certificates curl wget
sudo update-ca-certificates

# Retry function with exponential backoff
retry_with_backoff() {
    local max_attempts=3
    local attempt=1
    local delay=2

    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt of $max_attempts..."

        if "$@"; then
            return 0
        fi

        if [ $attempt -lt $max_attempts ]; then
            echo "Failed, retrying in ${delay}s..."
            sleep $delay
            delay=$((delay * 2))
        fi

        attempt=$((attempt + 1))
    done

    return 1
}

# Download installer with curl or wget fallback
download_installer() {
    local output_file="/tmp/cursor_install.sh"

    echo "Trying curl with TLS 1.2..."
    if curl --tlsv1.2 -fsSL https://cursor.com/install -o "$output_file"; then
        return 0
    fi

    echo "curl failed, trying wget..."
    if wget --secure-protocol=TLSv1_2 -q https://cursor.com/install -O "$output_file"; then
        return 0
    fi

    return 1
}

# Download with retries
if retry_with_backoff download_installer; then
    echo "✓ Downloaded installer successfully"
else
    echo "✗ Failed to download cursor-agent installer after 3 attempts"
    echo ""
    echo "Possible causes:"
    echo "  • cursor.com blocking GitHub Actions IPs"
    echo "  • Temporary server outage"
    echo "  • Network connectivity issues"
    echo ""
    echo "Troubleshooting:"
    echo "  • Check https://cursor.com status"
    echo "  • Re-run the workflow"
    echo "  • Contact Cursor support if issue persists"
    exit 1
fi

# Run installer
echo "Running installer..."
bash /tmp/cursor_install.sh

# Verify installation
if [ -x "$CURSOR_BINARY" ]; then
    echo "✓ cursor-agent installed successfully"

    # Display version
    if "$CURSOR_BINARY" --version 2>/dev/null; then
        echo "✓ cursor-agent is functional"
    else
        echo "⚠ cursor-agent installed but version check failed"
    fi
else
    echo "✗ cursor-agent not found at expected location: $CURSOR_BINARY"
    echo "Checking alternative locations..."
    find "$HOME/.local" -name "cursor-agent" 2>/dev/null || true
    exit 1
fi

echo "✓ Installation complete"
