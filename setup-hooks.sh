#!/bin/sh
# Install git hooks for this repository
# Run this once after cloning

set -e

if ! command -v pre-commit >/dev/null 2>&1; then
    echo "Error: pre-commit not installed."
    echo "Install with: brew install pre-commit"
    exit 1
fi

pre-commit install
echo "Git hooks installed successfully."
