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

# Clean any potential Flutter cache issues
echo "Cleaning Flutter cache..."
flutter clean

# EXPLICITLY ENSURE WEB PLATFORM SUPPORT
echo "Ensuring web platform support is configured..."
flutter config --enable-web

# Check if web platform is configured, and if not, add it
echo "Verifying web platform configuration..."
if flutter config | grep -q "enable-web: true"; then
    echo "Web platform support is enabled"
else
    echo "Web platform support not found, enabling..."
    flutter config --enable-web
fi

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web app
echo "Building Flutter web app..."
flutter build web --release

# Verify build output
if [ ! -d "build/web" ]; then
    echo "Error: Flutter web build failed - build/web directory not found"
    exit 1
fi

echo "Flutter web build completed successfully!"
echo "Build output: $(du -sh build/web | cut -f1)"