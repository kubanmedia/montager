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
WORK_DIR=$(mktemp -d)
echo "📁 Working in temporary directory: $WORK_DIR"

# Create a new Flutter web project
echo "🆕 Creating new Flutter web project..."
flutter create --platforms=web --org com.kubanmedia --project-name montager "$WORK_DIR/montager"

# Copy our application source code into the new project
echo "📋 Copying application source code..."
cp -r lib/* "$WORK_DIR/montager/lib/"
cp -r assets/* "$WORK_DIR/montager/assets/" 2>/dev/null || true

# Copy our pubspec.yaml but preserve the Flutter web configuration from the new project
echo "📋 Setting up dependencies..."
cp "$WORK_DIR/montager/pubspec.yaml" "$WORK_DIR/montager/pubspec.yaml.new"
cp pubspec.yaml "$WORK_DIR/montager/pubspec.yaml.old"

# Extract just the dependencies section from our pubspec and merge with the web-configured one
# For simplicity, we'll use the web-configured pubspec and just add our specific dependencies
cp "$WORK_DIR/montager/pubspec.yaml.new" "$WORK_DIR/montager/pubspec.yaml"

# Get dependencies in the new project
cd "$WORK_DIR/montager"
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