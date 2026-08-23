# Using Together AI with Montager

This guide shows how to configure and use the Together AI provider in the Montager application.

## 🔑 Getting a Together AI API Key

1. Sign up at [Together AI](https://api.together.xyz/)
2. Navigate to your account settings
3. Generate a new API key
4. Copy the API key (it will look like `tkp_...` or `tgp_...`)

## 📱 Configuring in Montager

### Via the App UI:
1. Open Montager application
2. Go to Settings → AI Provider Selection
3. Choose "Together AI" from the Cloud LLM Options
4. Enter your API key when prompted
5. The key is securely stored using platform-specific encryption:
   - Android: Keystore
   - iOS: Keychain

### Programmatically (for testing/development):
```dart
import 'package:montager/services/security/api_key_manager.dart';

// Store your Together AI API key securely
final apiKeyManager = ApiKeyManager();
await apiKeyManager.storeApiKey(
  'together_ai', 
  'your_together_ai_api_key_here'
);

// Verify the key is stored
final hasKey = await apiKeyManager.hasApiKey('together_ai');
// Returns true if stored successfully
```

## 🧠 How It Works

### Video Analysis Process:
1. **Frame Extraction**: Uses FFmpeg to extract 8 evenly-spaced frames from your video
2. **Image Encoding**: Converts frames to base64 JPEG
3. **AI Processing**: Sends frames to Together AI's vision model (Llama 3.2 90B Vision)
4. **Result Parsing**: Returns structured analysis including:
   - Overall description
   - Detected objects
   - Scene classification
   - Emotional tone
   - Quality score (0.0-1.0)
   - Key moments with timestamps

### Video Planning Process:
1. **Context Assembly**: Combines video analyses with your user prompt
2. **AI Reasoning**: Uses Together AI's text model (Llama 3.3 70B) to:
   - Create an editing timeline
   - Select appropriate transitions
   - Suggest titles and music
   - Generate narration (if requested)
3. **Plan Validation**: Ensures the plan meets timing and technical requirements

### Supported Models:
- **Vision**: `meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo` (default)
- **Text**: `meta-llama/Llama-3.3-70B-Instruct-Turbo` (default)
- **Alternatives**: Various Llama and Qwen models available

## 🎯 Example Usage in Code

```dart
import 'package:montager/services/ai/providers/together_provider.dart';
import 'package:montager/services/security/api_key_manager.dart';

// Initialize the provider
final apiKeyManager = ApiKeyManager();
final apiKey = await apiKeyManager.getApiKey('together_ai');

final togetherProvider = TogetherProvider(
  apiKey: apiKey!,
  // Optional: specify custom models
  // textModel: 'meta-llama/Llama-3.1-8B-Instruct',
  // visionModel: 'meta-llama/Llama-3.2-11B-Vision-Instruct-Turbo',
);

// Analyze a video
final analysis = await togetherProvider.analyzeVideo('/path/to/video.mp4');
print('Description: ${analysis['description']}');
print('Objects: ${analysis['objects']}');
print('Quality: ${analysis['quality']}');

// Create an editing plan
final editPlan = await togetherProvider.planEditing(
  videoAnalyses: [analysis],
  userPrompt: 'Create a 60-second highlight reel with upbeat music',
  targetDuration: 60.0,
);

print('Suggested Title: ${editPlan['suggestedTitle']}');
print('Timeline has ${editPlan['timeline'].length} segments');

// Generate narration if requested
final narration = await togetherProvider.generateNarration(
  'Please narrate this video highlighting the key moments',
  maxDuration: Duration(seconds: 30),
);
if (narration != null) {
  print('Narration: $narration');
}

// Get title suggestions
final titles = await togetherProvider.generateTitleSuggestions([analysis]);
print('Title suggestions: $titles');
```

## ⚙️ Configuration Options

### Timeout Settings:
The provider uses a 2-minute timeout for API calls, which can be adjusted:
```dart
final provider = TogetherProvider(
  apiKey: 'your_key',
  timeout: Duration(seconds: 180), // 3 minutes
);
```

### Model Selection:
You can override the default models:
```dart
final provider = TogetherProvider(
  apiKey: 'your_key',
  textModel: 'Qwen/Qwen2.5-72B-Instruct-Turbo',    // Faster, cheaper
  visionModel: 'meta-llama/Llama-3.2-11B-Vision-Instruct-Turbo', // More efficient
);
```

## 🛡️ Security & Privacy

- **API Keys**: Stored securely using platform-specific encrypted storage
- **Data Processing**: Video frames are processed in memory and never stored permanently
- **API Calls**: All communication happens over HTTPS to Together AI's servers
- **Local Processing**: Frame extraction happens on-device using FFmpeg

## 📊 Cost Considerations

Together AI offers competitive pricing for open-source models:
- Llama 3.2 90B Vision: ~$0.90 per million tokens
- Llama 3.3 70B Text: ~$0.60 per million tokens
- Actual costs depend on video length and complexity

## 🔧 Troubleshooting

### Common Issues:

1. **"Together API error 401"**
   - Cause: Invalid or missing API key
   - Solution: Verify your API key is correctly entered and active

2. **"Together API request timed out"**
   - Cause: Network issues or high API load
   - Solution: Check internet connection, try again later

3. **"Failed to extract frame" or FFmpeg errors**
   - Cause: FFmpeg not installed or video codec issues
   - Solution: Ensure FFmpeg is installed and accessible in PATH

4. **"Non-JSON response"**
   - Cause: API temporarily returning unexpected format
   - Solution: Usually resolved on retry; the provider includes robust error handling

### Debugging:
Enable verbose logging by adding print statements or using a logging package in the `_chatCompletions` method of `TogetherProvider`.