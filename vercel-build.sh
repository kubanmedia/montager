#!/bin/bash
set -e

echo "🚀 Starting Flutter web build for Vercel..."

# Install Flutter if not already installed
if ! command -v flutter &> /dev/null; then
    echo "📥 Installing Flutter..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
    export PATH="$HOME/flutter/bin:$PATH"
    flutter doctor --no-color
fi

# Create a temporary directory for our work
TEMP_DIR=$(mktemp -d)
echo "📁 Working in temporary directory: $TEMP_DIR"

# Create a new Flutter web project
echo "🆕 Creating new Flutter web project..."
flutter create --platforms=web --org com.kubanmedia --project-name montager_web "$TEMP_DIR/montager_web"

# Copy our source code into the new project
echo "📋 Copying source code..."
cp -r "$TEMP_DIR/montager_web/web" "$TEMP_DIR/montager_web/lib" "$TEMP_DIR/montager_web/pubspec.yaml" "$TEMP_DIR/montager_web/assets" "$TEMP_DIR/montager_web/firebase_options.dart" . 2>/dev/null || true

# If assets directory doesn't exist in source, create it
mkdir -p assets

# Copy our actual application code
echo "📋 Copying application source..."
cp -r lib/* "$TEMP_DIR/montager_web/lib/" 2>/dev/null || true
cp -r assets/* "$TEMP_DIR/montager_web/assets/" 2>/dev/null || true

# Copy pubspec dependencies (but keep Flutter web configuration)
echo "📋 Processing dependencies..."
cp pubspec.yaml "$TEMP_DIR/montager_web/pubspec.yaml.tmp"

# Use the web-configured pubspec from the new project as base
cp "$TEMP_DIR/montager_web/pubspec.yaml" pubspec.yaml

# Get dependencies in the new project context
cd "$TEMP_DIR/montager_web"
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build web app
echo "🏗️ Building Flutter web app..."
flutter build web --release

# Verify build output
if [ ! -d "build/web" ]; then
    echo "❌ Error: Flutter web build failed - build/web directory not found"
    exit 1
fi

# Copy the built web app to where Vercel expects it
mkdir -p /vercel/workspace/build/web
cp -r build/web/* /vercel/workspace/build/web/

echo "✅ Flutter web build completed successfully!"
echo "📁 Build output: $(du -sh build/web | cut -f1)"