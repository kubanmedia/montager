#!/bin/bash
set -e

echo "Starting Flutter web build for Vercel..."

# Install Flutter if not already installed
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
    export PATH="$HOME/flutter/bin:$PATH"
    flutter doctor --no-color
fi

# Ensure we're in the repository directory
cd /vercel/workspace

# EXPLICITLY RECONFIGURE FOR WEB
echo "Reconfiguring project for web platform..."
flutter config --enable-web

# Verify web configuration is recognized
echo "Verifying web platform configuration..."
WEB_ENABLED=$(flutter config | grep "enable-web:" | awk '{print $2}')
if [ "$WEB_ENABLED" = "true" ]; then
    echo "✓ Web platform support is enabled"
else
    echo "✗ Web platform support is not enabled, attempting to enable..."
    flutter config --enable-web
    # Verify again
    WEB_ENABLED=$(flutter config | grep "enable-web:" | awk '{print $2}')
    if [ "$WEB_ENABLED" = "true" ]; then
        echo "✓ Web platform support now enabled"
    else
        echo "✗ Failed to enable web platform support"
        exit 1
    fi
fi

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web app
echo "Building Flutter web app..."
flutter build web --release

# Verify build output
if [ ! -d "build/web" ]; then
    echo "✗ Error: Flutter web build failed - build/web directory not found"
    exit 1
fi

echo "✓ Flutter web build completed successfully!"
echo "Build output: $(du -sh build/web | cut -f1)"