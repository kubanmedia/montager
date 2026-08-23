# Using Ollama with Montager

This guide shows how to configure and use both local and cloud Ollama providers in the Montager application.

## 🦙 Understanding Ollama Options

Montager supports two Ollama options:

### 1. **Ollama (Local Server)** - Connect to your own Ollama instance
- Runs on your local machine or network
- No data leaves your environment (maximum privacy)
- Requires Ollama to be installed and running
- Uses: `http://localhost:11434` (default) or custom URL

### 2. **Ollama Cloud** - Use Ollama's hosted cloud service
- Models hosted and managed by Ollama in the cloud
- Requires internet connection
- API key authentication
- No local setup required
- Uses: `https://cloud.ollama.com/api`

## 🔧 Setting Up Ollama (Local Server)

### Option A: Install Ollama Locally
1. Download Ollama from https://ollama.com/
2. Install and start the service
3. Pull a multimodal model for video analysis:
   ```bash
   ollama pull llava:13b
   ```
   Other good options: `llava:7b`, `bakllava`, `llama-vision`

### Option B: Use Existing Ollama Instance
If you already have Ollama running on another machine:
- Note the IP address and port (e.g., `http://192.168.1.100:11434`)
- Ensure it's accessible from your device
- Pull the required models on that machine

## ☁️ Setting Up Ollama Cloud

### Get an API Key:
1. Sign up at https://cloud.ollama.com/
2. Create an account and verify your email
3. Navigate to API Keys section
4. Generate a new API key
5. Copy the API key (starts with `olc-` or similar)

## 📱 Configuring in Montager

### Via the App UI:
1. Open Montager application
2. Go to Settings → AI Provider Selection
3. Choose either:
   - **"Ollama (Local Server)"** under Local LLM Options
   - **"Ollama Cloud"** under Cloud LLM Options
4. For Ollama Cloud: Enter your API key when prompted
5. For Ollama Local: The URL is pre-configured to `http://localhost:11434` but can be customized in code

### Programmatically (for testing/development):
```dart
import 'package:montager/services/security/api_key_manager.dart';
import 'package:montager/services/ai/providers/ai_provider_factory.dart';

// For Ollama Cloud:
final apiKeyManager = ApiKeyManager();
await apiKeyManager.storeApiKey(
  'ollama_cloud', 
  'your_ollama_cloud_api_key_here'
);

// For Ollama Local (no API key needed for local instance):
// Just ensure Ollama is running and accessible
```

## 🧠 How It Works

### Video Analysis Process (Both Local & Cloud):
1. **Frame Extraction**: Uses FFmpeg to extract 6 evenly-spaced frames from your video
2. **Image Encoding**: Converts frames to base64 JPEG
3. **AI Processing**: Sends frames to Ollama's multimodal model (LlamaVision)
4. **Result Parsing**: Returns structured analysis including:
   - Overall description
   - Detected objects
   - Scene classification
   - Emotional tone
   - Quality score (0.0-1.0)
   - Key moments with timestamps

### Video Planning Process:
1. **Context Assembly**: Combines video analyses with your user prompt
2. **AI Reasoning**: Uses Ollama's language model to:
   - Create an editing timeline
   - Select appropriate transitions
   - Suggest titles and music
   - Generate narration (if requested)
3. **Plan Validation**: Ensures the plan meets timing and technical requirements

### Supported Models:
- **For Video Analysis**: Llava family (llava:13b, llava:7b, bakllava, etc.)
- **For Planning/Narration**: Any competent language model (llama3, phi3, mistral, etc.)
- **Recommended**: `llava:13b` for analysis, `llama3:8b` for planning (good balance)

## 🎯 Example Usage in Code

```dart
import 'package:montager/services/ai/providers/ai_provider_factory.dart';
import 'package:montager/services/security/api_key_manager.dart';

// Initialize the provider for Ollama Cloud
final apiKeyManager = ApiKeyManager();
final apiKey = await apiKeyManager.getApiKey('ollama_cloud');

final ollamaProvider = AIProviderFactory.createProvider(
  'Ollama Cloud',
  {
    'apiKey': apiKey!, 
    'modelName': 'llava:13b', // or 'llava:7b' for faster processing
  },
);

// OR for Ollama Local Server:
final ollamaLocalProvider = AIProviderFactory.createProvider(
  'Ollama (Local Server)',
  {
    'baseUrl': 'http://localhost:11434', // or custom URL
    'modelName': 'llava:13b',
  },
);

// Analyze a video
final analysis = await ollamaProvider.analyzeVideo('/path/to/video.mp4');
print('Description: ${analysis['description']}');
print('Objects: ${analysis['objects']}');
print('Quality: ${analysis['quality']}');

// Create an editing plan
final editPlan = await ollamaProvider.planEditing(
  videoAnalyses: [analysis],
  userPrompt: 'Create a 60-second highlight reel with upbeat music',
  targetDuration: 60.0,
);

print('Suggested Title: ${editPlan['suggestedTitle']}');
print('Timeline has ${editPlan['timeline'].length} segments');

// Generate narration if requested
final narration = await ollamaProvider.generateNarration(
  'Please narrate this video highlighting the key moments',
  maxDuration: Duration(seconds: 30),
);
if (narration != null) {
  print('Narration: $narration');
}

// Get title suggestions
final titles = await ollamaProvider.generateTitleSuggestions([analysis]);
print('Title suggestions: $titles');
```

## ⚙️ Configuration Options

### Base URL (for Local Server Only):
The Ollama Local Server provider accepts a custom base URL:
```dart
final provider = AIProviderFactory.createProvider(
  'Ollama (Local Server)',
  {
    'baseUrl': 'http://192.168.1.100:11434', // Custom Ollama instance
    'modelName': 'llava:13b',
  },
);
```

### Model Selection:
You can specify different models for different tasks:
```dart
// For faster analysis (lower quality)
final fastProvider = AIProviderFactory.createProvider(
  'Ollama Cloud',
  {
    'apiKey': 'your_key',
    'modelName': 'llava:7b', // Faster, less resource intensive
  },
);

// For highest quality analysis
final qualityProvider = AIProviderFactory.createProvider(
  'Ollama Cloud',
  {
    'apiKey': 'your_key',
    'modelName': 'llava:13b', // Best quality, more resources
  },
);
```

### Timeout Settings:
Both providers use a 2-minute timeout for API calls, which handles most video processing tasks.

## 🛡️ Security & Privacy

### Ollama Local Server:
- **Maximum Privacy**: All processing happens on your own hardware
- **No Data Leaves**: Video frames and prompts never leave your environment
- **Local Network Only**: If accessed from other devices, ensure your network is secure

### Ollama Cloud:
- **Encrypted Storage**: API keys stored securely using platform-specific encrypted storage
- **Data Processing**: Video frames are processed in memory and never stored permanently
- **API Calls**: All communication happens over HTTPS to Ollama Cloud's servers
- **API Key Protection**: Keys never exposed in logs or error messages

## 📊 Performance Considerations

### Local Server Performance:
- Depends on your hardware capabilities
- LLava 13b requires significant RAM (16GB+ recommended for smooth operation)
- GPU acceleration greatly improves performance if available
- First model load may take time as it loads into memory

### Cloud Performance:
- Consistent performance regardless of local hardware
- Network latency affects response time
- Ollama Cloud scales resources based on demand
- Generally faster than consumer-grade local hardware

### Optimization Tips:
1. **Use smaller models** for faster processing on limited hardware:
   - `llava:7b` instead of `llava:13b` for analysis
   - `phi3:medium` or `tinyllama` for planning tasks
2. **Warm up models** by making a simple request first
3. **Consider concurrent processing** for multiple short videos

## 💰 Cost Considerations

### Ollama Local Server:
- **Free**: After initial hardware investment
- **Electricity**: Ongoing power consumption for hardware
- **Hardware**: One-time cost for capable machine (if needed)

### Ollama Cloud:
- **Subscription Based**: Various tiers available
- **Pay-as-you-go**: Some plans based on actual usage
- **Free Tier**: Limited usage available for testing
- **Enterprise**: Custom plans for high-volume usage

## 🔧 Troubleshooting

### Common Issues for Ollama Local Server:

1. **"Failed to connect to Ollama server"**
   - Cause: Ollama not running or not accessible
   - Solution: 
     - Ensure Ollama is installed and running (`ollama serve`)
     - Check firewall settings
     - Verify the base URL is correct

2. **"Model not found"**
   - Cause: Requested model not pulled/installed
   - Solution: Run `ollama pull llama_model_name`

3. **Slow response times**
   - Cause: Insufficient hardware resources
   - Solution: 
     - Use smaller models
     - Close other memory-intensive applications
     - Consider GPU acceleration

### Common Issues for Ollama Cloud:

1. **"Authentication failed" or "Invalid API key"**
   - Cause: Incorrect or expired API key
   - Solution: Verify and regenerate API key in Ollama Cloud dashboard

2. **"API error 429" or "Rate limit exceeded"**
   - Cause: Too many requests in short time
   - Solution: Wait before retrying, consider upgrading plan

3. **"Network error" or "Request timed out"**
   - Cause: Connectivity issues or high server load
   - Solution: Check internet connection, retry after delay

### Debugging:
Enable verbose logging by adding print statements or using a logging package in the `_chatCompletions` methods of both providers.

## 📱 Platform-Specific Notes

### Android:
- Ollama Local Server: Requires Ollama installed on device or accessible on network
- Ollama Cloud: Works normally with internet connection
- Consider using `http_proxy` settings if needed

### iOS:
- Ollama Local Server: Requires Ollama on network (can't install on iOS device)
- Ollama Cloud: Works normally with internet connection
- App Store connectivity requirements apply

### Web:
- Ollama Local Server: Only works if Ollama is accessible from browser (CORS considerations)
- Ollama Cloud: Works normally with internet connection
- May require proxy setup for local server access

### Desktop (Windows/macOS/Linux):
- Ollama Local Server: Install Ollama directly on machine
- Ollama Cloud: Works normally with internet connection
- Easiest platform for local server setup

## ✅ Success Criteria

When Ollama integration is working correctly in Montager, you should see:

1. **Video Analysis Succeeds**: 
   - No connection-related errors in logs
   - Frame extraction completes within timeout
   - Valid JSON analysis returned from Ollama
   - Meaningful descriptions, objects, and quality scores

2. **Accurate Planning**:
   - Edit plans match requested duration
   - Logical timeline with appropriate transitions
   - Relevant title and narration suggestions

3. **Proper Error Handling**:
   - Clear error messages for connection issues
   - Guidance for resolving common problems
   - Graceful degradation when possible

4. **Resource Management**:
   - HTTP clients properly closed
   - No memory leaks or file handle leaks
   - Temporary files cleaned up appropriately

## 🎯 Choosing Between Local and Cloud

### Choose Ollama Local Server when:
- Maximum privacy is required (sensitive or proprietary content)
- You have capable hardware (especially with GPU)
- You want to avoid ongoing subscription costs
- You need offline capability
- You want full control over model versions and updates

### Choose Ollama Cloud when:
- You want zero setup and maintenance
- You need access from multiple devices
- Your local hardware is limited or incompatible
- You prefer predictable performance
- You want to try the latest models immediately
- You have variable workloads and want scalable resources

Both options provide access to powerful open-source LLMs for AI-powered video editing, allowing you to choose the privacy/performance/convenience balance that works best for your needs.