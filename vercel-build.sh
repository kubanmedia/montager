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

# ENSURE WEB PLATFORM IS SET UP (not just enabled)
echo "Ensuring web platform is properly set up..."
# This will add web platform support if it's missing
flutter create . --platforms=web --no-pub

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web app
echo("Building Flutter web app...")
flutter build web --release

# Verify build output
if [ ! -d "build/web" ]; then
    echo "Error: Flutter web build failed - build/web directory not found"
    exit 1
fi

echo "Flutter web build completed successfully!"
echo "Build output: $(du -sh build/web | cut -f1)"