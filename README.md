# Montager

A Flutter-based AI-powered video editing application that automatically creates professional videos from your existing footage using artificial intelligence.

## 🚀 Features

- **AI-Powered Editing**: Uses advanced AI models to understand video content and create intelligent edits
- **Privacy-First**: Local processing options available (Ollama, on-device LLMs)
- **Multiple AI Providers**: Support for OpenAI, Google Gemini, Anthropic Claude, Grok, Hugging Face, and more
- **Professional Quality**: Broadcast-grade video output with cinematic techniques
- **Cross-Platform**: Web, Android, iOS (from single Flutter codebase)
- **Simple Workflow**: Select folder → Describe video → Get professional result

## 📱 Supported Platforms

- **Web**: Progressive Web App (PWA)
- **Android**: Native ARM64/ARMv7/x86_64
- **iOS**: Native ARM64
- **Desktop**: Windows, macOS, Linux (via Flutter desktop support)

## 🔧 Local Development Setup

### Prerequisites
- Flutter SDK 3.19+ 
- Dart SDK 3.3+
- Android Studio / Xcode (for mobile builds)
- VS Code or Android Studio/IntelliJ

### Setup Steps
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Connect your device or start an emulator/simulator
4. Run `flutter run` to start the application

### Web Development
```bash
flutter run -d chrome
```

### Android Development
```bash
flutter run -d android
```

### iOS Development
```bash
flutter run -d ios
```

## 🌐 Deployment Options

### Vercel (Recommended for Web)
1. Install Vercel CLI: `npm i -g vercel`
2. Run `vercel` in the project directory
3. Follow the prompts to deploy

### Netlify
1. Push to GitHub/GitLab/Bitbucket
2. Connect repository to Netlify
3. Set build command: `flutter build web --release --web-renderer canvaskit`
4. Set publish directory: `build/web`

### Docker
```bash
# Build the image
docker build -t montager .

# Run the container
docker run -p 8080:80 montager

# Access at http://localhost:8080
```

## 📝 Note on API Keys

For security reasons, API keys for AI services should be configured as environment variables in your deployment environment, not hardcoded in the application.

For local development, you can create a `.env` file or configure your IDE to provide these values.