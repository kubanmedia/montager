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

# Create a clean build directory
BUILD_DIR="/tmp/flutter_build"
echo "Creating clean build directory at $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Copy only essential files for Flutter web build
echo "Copying project files to build directory..."
cp -r montager/{lib,assets} "$BUILD_DIR/"
cp montager/pubspec.yaml "$BUILD_DIR/"
cp montager/pubspec.lock "$BUILD_DIR/"

# Change to build directory
cd "$BUILD_DIR"

# Ensure web support is enabled
echo "Ensuring web platform support is configured..."
flutter config --enable-web

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web app
echo "Building Flutter web app..."
flutter build web --release

# Copy output to Vercel's expected location
echo "Copying build output to Vercel location..."
mkdir -p /vercel/workspace/build/web
cp -r build/web/* /vercel/workspace/build/web/

echo "Flutter web build completed successfully!"
echo "Build output copied to Vercel workspace"