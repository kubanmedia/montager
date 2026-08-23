import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'together_provider.dart';
import 'ollama_cloud_provider.dart';

import 'ai_provider_factory.dart';

/// Abstract base class for AI providers
abstract class AIProvider {
  /// Initializes the provider with configuration
  Future<void> initialize(Map<String, String> config);

  /// Analyzes a video file and returns metadata about its content
  Future<Map<String, dynamic>> analyzeVideo(String videoPath);

  /// Plans the video editing based on analyzed videos and user prompt
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  });

  /// Generates narration based on a prompt
  Future<String?> generateNarration(String prompt, {Duration? maxDuration});

  /// Generates title suggestions based on video analyses
  Future<List<String>> generateTitleSuggestions(List<Map<String, dynamic>> videoAnalyses);

  /// Cleans up resources
  Future<void> dispose();
}

/// Base class for cloud-based AI providers (API-based services)
abstract class CloudAIProvider implements AIProvider {
  final String _apiKey;
  final String _endpoint;

  CloudAIProvider({
    required String apiKey,
    required String endpoint,
  })  : _apiKey = apiKey,
        _endpoint = endpoint.replaceAll(RegExp(r'/+$'), ''); // Remove trailing slashes

  @override
  Future<void> initialize(Map<String, String> config) async {
    // Base implementation for cloud providers
    // Specific providers can override if needed
  }

  @protected
  Map<String, String> getAuthHeaders() {
    return {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
  }
}

/// OpenAI Provider (GPT-4V, etc.)
class OpenAIProvider extends CloudAIProvider {
  final String _modelName;

  OpenAIProvider({
    required String apiKey,
    String modelName = 'gpt-4-vision-preview',
  }) : _modelName = modelName,
       super(apiKey: apiKey, endpoint: 'https://api.openai.com/v1');

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    // In a real implementation, we would:
    // 1. Extract key frames from the video
    // 2. Encode them as base64
    // 3. Send to GPT-4V API with prompt for video analysis
    
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    return {
      'description': 'A beautiful outdoor scene with people enjoying activities',
      'objects': ['person', 'tree', 'sky', 'water'],
      'emotions': ['happy', 'peaceful', 'joyful'],
      'quality': 0.85,
      'duration': 12.5,
      'keyMoments': [
        {'time': 2.0, 'description': 'Person smiling at camera'},
        {'time': 7.5, 'description': 'Group activity in progress'},
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) async {
    await Future.delayed(const Duration(seconds: 3));
    
    return {
      'timeline': [
        {
          'videoIndex': 0,
          'startTime': 0.0,
          'endTime': 5.0,
          'transition': 'fade',
          'reason': 'Opening scene establishes setting',
        },
        {
          'videoIndex': 1,
          'startTime': 2.0,
          'endTime': 8.0,
          'transition': 'slide',
          'reason': 'Shows main action',
        },
        {
          'videoIndex': 0,
          'startTime': 6.0,
          'endTime': 12.0,
          'transition': 'crossfade',
          'reason': 'Closing shot',
        },
      ],
      'totalDuration': targetDuration.clamp(10.0, 300.0),
      'suggestedTitle': 'AI Generated Video: $userPrompt',
      'recommendedMusic': 'upbeat_background',
      'suggestedNarration': 'This video showcases beautiful moments captured in nature.',
    };
  }

  @override
  Future<String?> generateNarration(String prompt, {Duration? maxDuration}) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (prompt.toLowerCase().contains('narrate') || 
        prompt.toLowerCase().contains('voiceover')) {
      return 'This is a generated narration for the video based on your request: "$prompt"';
    }
    
    return null;
  }

  @override
  Future<List<String>> generateTitleSuggestions(List<Map<String, dynamic>> videoAnalyses) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      'Memorable Moments',
      'Adventure Highlights',
      'Beautiful Memories',
      'Special Moments Collection',
      'Video Montage',
    ];
  }

  @override
  Future<void> dispose() async {
    // Clean up resources
  }
}

/// Google Gemini Provider
class GeminiProvider extends CloudAIProvider {
  final String _modelName;

  GeminiProvider({
    required String apiKey,
    String modelName = 'gemini-pro-vision',
  }) : _modelName = modelName,
       super(apiKey: apiKey, endpoint: 'https://generativelanguage.googleapis.com/v1beta/models');

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'description': 'Sample video description from Gemini',
      'objects': ['person', 'building', 'sky'],
      'emotions': ['excited', 'peaceful'],
      'quality': 0.85,
      'duration': 12.0,
    };
  }

  @override
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) async {
    await Future.delayed(const Duration(seconds: 3));
    
    return {
      'timeline': [
        {
          'videoIndex': 0,
          'startTime': 0.0,
          'endTime': 4.0,
          'transition': 'fade',
          'reason': 'Opening shot',
        },
        {
          'videoIndex': 0,
          'startTime': 4.0,
          'endTime': 8.0,
          'transition': 'slide',
          'reason': 'Action sequence',
        },
        {
          'videoIndex': 0,
          'startTime': 8.0,
          'endTime': 12.0,
          'transition': 'fade',
          'reason': 'Closing scene',
        },
      ],
      'totalDuration': targetDuration.clamp(10.0, 300.0),
      'suggestedTitle': 'Gemini Enhanced Video',
      'recommendedMusic': 'cinematic_score',
    };
  }

  @override
  Future<String?> generateNarration(String prompt, {Duration? maxDuration}) async => null;

  @override
  Future<List<String>> generateTitleSuggestions(List<Map<String, dynamic>> videoAnalyses) async =>
      ['Gemini Masterpiece', 'AI Enhanced Memories'];

  @override
  Future<void> dispose() async {}
}

/// Anthropic Claude Provider
class ClaudeProvider extends CloudAIProvider {
  final String _modelName;

  ClaudeProvider({
    required String apiKey,
    String modelName = 'claude-3-opus-20240229',
  }) : _modelName = modelName,
       super(apiKey: apiKey, endpoint: 'https://api.anthropic.com/v1');

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'description': 'Video analyzed by Claude',
      'objects': ['people', 'nature', 'water'],
      'emotions': ['serene', 'joyful'],
      'quality': 0.9,
      'duration': 15.0,
    };
  }

  @override
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) async {
    await Future.delayed(const Duration(seconds: 3));
    
    return {
      'timeline': [
        {
          'videoIndex': 0,
          'startTime': 0.0,
          'endTime': 6.0,
          'transition': 'fade',
          'reason': 'Establishing shot',
        },
        {
          'videoIndex': 0,
          'startTime': 6.0,
          'endTime': 12.0,
          'transition': 'crossfade',
          'reason': 'Main content',
        },
        {
          'videoIndex': 0,
          'startTime': 12.0,
          'endTime': 15.0,
          'transition': 'fade',
          'reason': 'Conclusion',
        },
      ],
      'totalDuration': targetDuration.clamp(10.0, 300.0),
      'suggestedTitle': 'Claude Crafted Video',
      'recommendedMusic': 'ambient_soundtrack',
    };
  }

  @override
  Future<String?> generateNarration(String prompt, {Duration? maxDuration}) async => null;

  @override
  Future<List<String>> generateTitleSuggestions(List<Map<String, dynamic>> videoAnalyses) async =>
      ['Claude Masterpiece', 'AI Curated Memories'];

  @override
  Future<void> dispose() async {}
}

/// Grok Provider (xAI)
class GrokProvider extends CloudAIProvider {
  GrokProvider({
    required String apiKey,
    String? apiUrl,
  }) : super(apiKey: apiKey, endpoint: apiUrl ?? 'https://api.x.ai/v1');

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'description': 'Video analyzed by Grok',
      'objects': ['person', 'animal', 'vehicle', 'landscape'],
      'emotions': ['excited', 'calm', 'focused'],
      'quality': 0.88,
      'duration': 15.0,
      'keyMoments': [
        {'time': 3.0, 'description': 'Key moment detected'},
        {'time': 10.0, 'description': 'Another significant moment'},
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'timeline': [
        {
          'videoIndex': 0,
          'startTime': 0.0,
          'endTime': targetDuration.clamp(5.0, 60.0) / 3,
          'transition': 'fade',
          'reason': 'Opening act',
        },
        {
          'videoIndex': 0,
          'startTime': targetDuration.clamp(5.0, 60.0) / 3,
          'endTime': targetDuration.clamp(5.0, 60.0) * 2 / 3,
          'transition': 'slide',
          'reason': 'Main story',
        },
        {
          'videoIndex': 0,
          'startTime': targetDuration.clamp(5.0, 60.0) * 2 / 3,
          'endTime': targetDuration.clamp(5.0, 60.0),
          'transition': 'fade',
          'reason': 'Conclusion',
        },
      ],
      'totalDuration': targetDuration.clamp(10.0, 300.0),
      'suggestedTitle': 'Grok AI Enhanced Video',
      'recommendedMusic': 'electronic_orchestral',
      'suggestedNarration': 'This video was intelligently edited by Grok AI.',
    };
  }

  @override
  Future<String?> generateNarration(String prompt, {Duration? maxDuration}) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (prompt.toLowerCase().contains('narrate') || 
        prompt.toLowerCase().contains('voiceover')) {
      return 'Narration generated by Grok AI based on: "$prompt"';
    }
    
    return null;
  }

  @override
  Future<List<String>> generateTitleSuggestions(List<Map<String, dynamic>> videoAnalyses) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      'Grok Masterpiece',
      'X.AI Creation',
      'Intelligent Video Edit',
    ];
  }

  @override
  Future<void> dispose() async {}
}

/// Hugging Face Provider
class HuggingFaceProvider extends CloudAIProvider {
  HuggingFaceProvider({
    required String apiToken,
    String? apiUrl,
  }) : super(apiKey: apiToken, endpoint: apiUrl ?? 'https://api-inference.huggingface.co/models');

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    await Future.delayed(const Duration(seconds: 3));
    
    return {
      'description': 'Scene analysis via Hugging Face model',
      'objects': ['human', 'nature', 'technology', 'food'],
      'emotions': ['joy', 'serenity', 'energy'],
      'quality': 0.82,
      'duration': 12.0,
      'modelUsed': 'google/vit-base-patch16-224 or similar',
    };
  }

  @override
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'timeline': [
        {
          'videoIndex': 0,
          'startTime': 0.0,
          'endTime': targetDuration.clamp(10.0, 120.0) * 0.4,
          'transition': 'fade',
          'reason': 'Introduction segment',
        },
        {
          'videoIndex': 0,
          'startTime': targetDuration.clamp(10.0, 120.0) * 0.4,
          'endTime': targetDuration.clamp(10.0, 120.0) * 0.7,
          'transition': 'slide',
          'reason': 'Main content',
        },
        {
          'videoIndex': 0,
          'startTime': targetDuration.clamp(10.0, 120.0) * 0.7,
          'endTime': targetDuration.clamp(10.0, 120.0),
          'transition': 'fade',
          'reason': 'Closing segment',
        },
      ],
      'totalDuration': targetDuration.clamp(10.0, 300.0),
      'suggestedTitle': 'HF AI Video Montage',
      'recommendedMusic': 'ambient_orchestral',
      'suggestedNarration': 'This video was processed using Hugging Face AI models.',
    };
  }

  @override
  Future<String?> generateNarration(String prompt, {Duration? maxDuration}) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Hugging Face has TTS models we could use
    if (prompt.toLowerCase().contains('narrate') || 
        prompt.toLowerCase().contains('voiceover')) {
      return 'Narration generated via Hugging Face TTS model based on your input.';
    }
    
    return null;
  }

  @override
  Future<List<String>> generateTitleSuggestions(List<Map<String, dynamic>> videoAnalyses) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      'Hugging Face AI Video',
      'Open Source AI Creation',
      'Community Model Montage',
    ];
  }

  @override
  Future<void> dispose() async {}
}

/// Abstract base class for Local LLM providers (on-device inference)
abstract class LocalLLMProvider implements AIProvider {
  @override
  Future<void> initialize(Map<String, String> config) async {
    // Base initialization for local LLMs
  }

  @override
  Future<void> dispose() async {
    _client.close();
    // Clean up local resources
  }
}

/// Exception thrown by [OllamaLocalProvider] for any user-visible failure
/// (connection error, non-JSON response, etc.).
class OllamaLocalException implements Exception {
  final String message;
  OllamaLocalException(this.message);

  @override
  String toString() => 'OllamaLocalException: $message';
}

/// Ollama-based Local LLM Provider
class OllamaLocalProvider extends LocalLLMProvider {
  final String _baseUrl;
  final String _modelName;
  final http.Client _client;

  OllamaLocalProvider({
    required String baseUrl,
    required String modelName,
    http.Client? client,
  })  : _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''), // Remove trailing slashes
        _modelName = modelName,
        _client = client ?? http.Client();

  @override
  Future<void> initialize(Map<String, String> config) async {
    // Test connection to Ollama server
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tags')).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != 200) {
        throw OllamaLocalException('Failed to connect to Ollama server at $_baseUrl');
      }
    } catch (e) {
      throw OllamaLocalException('Failed to initialize Ollama provider: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    final file = File(videoPath);
    if (!await file.exists()) {
      throw OllamaLocalException('Video file not found: $videoPath');
    }

    // Extract frames from video for analysis
    final frames = await _extractFrames(videoPath, maxFrames: 6);

    // Prepare content for multimodal model
    final content = <Map<String, dynamic>>[
      {
        'type': 'text',
        'text': _analysisPrompt(frames.length),
      },
    ];
    
    for (final bytes in frames) {
      content.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:image/jpeg;base64,${base64Encode(bytes)}',
        },
      });
    }

    final body = <String, dynamic>{
      'model': _modelName,
      'messages': [
        {
          'role': 'user',
          'content': content,
        },
      ],
      'stream': false,
      'options': {
        'temperature': 0.2,
        'num_predict': 1024,
      },
    };

    final response = await _chatCompletions(body);
    final text = _extractMessageContent(response);

    try {
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      parsed['videoPath'] = videoPath;
      parsed['frameCount'] = frames.length;
      parsed['model'] = _modelName;
      return parsed;
    } on FormatException catch (e) {
      throw OllamaLocalException(
        'Ollama local returned non-JSON response: ${e.message}\n'
        'Raw output (first 500 chars): ${text.substring(0, text.length.clamp(0, 500))}',
      );
    }
  }

  String _analysisPrompt(int frameCount) {
    return '''
You are analyzing $frameCount evenly-spaced frames sampled from a single short video.
The frames are presented in chronological order.

Return STRICT JSON (no markdown, no commentary) with this exact schema:
{
  "description": string,        // 1-2 sentence overall description
  "objects": [string],          // main objects/subjects visible
  "scene": string,              // location type (e.g. "outdoor beach", "indoor kitchen")
  "emotions": [string],          // emotional tone observed
  "quality": number,            // 0.0-1.0 visual quality estimate
  "keyMoments": [               // 0-5 entries, time relative to video start
    { "time": number, "description": string }
  ]
}
''';
  }

  Future<List<Uint8List>> _extractFrames(
    String videoPath, {
      required int maxFrames,
    }) async {
    final tmpDir = Directory.systemTemp.createTempSync('ollama_local_frames_');
    try {
      // Probe duration first.
      final durationSeconds = await _probeDurationSeconds(videoPath);
      if (durationSeconds <= 0) {
        return _fallbackSingleFrame(videoPath, tmpDir);
      }

      // Calculate frame interval to get up to maxFrames evenly spaced
      final count = durationSeconds < 3
          ? 1
          : (durationSeconds / 3).floor().clamp(1, maxFrames);

      // Spread frames evenly across the video.
      final step = durationSeconds / (count + 1);
      final frames = <Uint8List>[];

      for (var i = 1; i <= count; i++) {
        final t = step * i;
        final outPath = '${tmpDir.path}/frame_$i.jpg';
        final ok = await _runFfmpeg([
          '-y',
          '-ss', t.toStringAsFixed(2),
          '-i', videoPath,
          '-frames:v', '1',
          '-q:v', '4',
          '-vf', 'scale=720:-1',
          outPath,
        ]);
        if (!ok) {
          continue;
        }
        final f = File(outPath);
        if (await f.exists()) {
          frames.add(await f.readAsBytes());
        }
      }

      if (frames.isEmpty) {
        return _fallbackSingleFrame(videoPath, tmpDir);
      }
      return frames;
    } finally {
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
    }
  }

  Future<double> _probeDurationSeconds(String videoPath) async {
    try {
      final result = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_entries', 'format=duration',
        '-of', 'default=noprint_wrappers=1:nokey=1',
        videoPath,
      ]);
      if (result.exitCode != 0) return 0;
      final raw = (result.stdout as String).trim();
      return double.tryParse(raw) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Uint8List>> _fallbackSingleFrame(
    String videoPath,
    Directory tmpDir,
  ) async {
    try {
      final outPath = '${tmpDir.path}/frame_mid.jpg';
      final ok = await _runFfmpeg([
        '-y',
        '-i', videoPath,
        '-vf', 'select=eq(n\\,0),scale=720:-1',
        '-frames:v', '1',
        '-q:v', '4',
        outPath,
      ]);
      if (!ok) return const <Uint8List>[];
      final f = File(outPath);
      if (!await f.exists()) return const <Uint8List>[];
      return [await f.readAsBytes()];
    } catch (e) {
      return const <Uint8List>[];
    }
  }

  Future<bool> _runFfmpeg(List<String> args) async {
    try {
      final result = await Process.run('ffmpeg', args).timeout(
        const Duration(seconds: 30),
      );
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  Future<Map<String, dynamic>> _chatCompletions(
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
    };
    final encoded = jsonEncode(body);

    http.Response response;
    try {
      response = await _client
          .post(uri, headers: headers, body: encoded)
          .timeout(const Duration(seconds: 120));
    } on TimeoutException {
      throw OllamaLocalException(
        'Ollama local API request timed out',
      );
    } on SocketException catch (e) {
      throw OllamaLocalException('Network error talking to Ollama local: ${e.message}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaLocalException(
        'Ollama local API error ${response.statusCode}: ${response.body}',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw OllamaLocalException(
        'Ollama local API returned non-JSON body: ${response.body.substring(0, response.body.length.clamp(0, 500))}',
      );
    }
  }

  String _extractMessageContent(Map<String, dynamic> response) {
    // Ollama uses OpenAI-compatible API format
    final choices = response['choices'];
    if (choices is! List || choices.isEmpty) {
      throw OllamaLocalException(
        'Ollama local API response had no choices. Body: $response',
      );
    }
    final first = choices.first as Map<String, dynamic>;
    final message = first['message'];
    if (message is Map<String, dynamic>) {
      final content = message['content'];
      if (content is String && content.isNotEmpty) return content;
    }
    // Fallback to text field for compatibility
    final text = first['text'];
    if (text is String && text.isNotEmpty) return text;
    throw OllamaLocalException(
      'Ollama local API response had no extractable content. Body: $response',
    );
  }

  String _planningSystemPrompt() {
    return '''
You are the planning brain of an autonomous video editing agent.

You receive pre-analyzed video metadata and a user prompt describing
the desired final movie. Your job is to produce a concrete edit plan
as strict JSON.

Rules:
- Use only the videos provided in the analyses. Reference them by
  their `videoPath` value.
- Total runtime must approximate the requested target duration in seconds.
- Each timeline entry must reference an existing videoPath and use
  startTime/endTime in seconds relative to that source video.
- Transitions must be one of: "cut", "fade", "crossfade", "slide", "dissolve".
- If the user's request implies a style (cinematic, funny, emotional,
  fast-paced, etc.), bias transitions and pacing to match.
- If the user asked for a title or narration, populate those fields.
''';
  }

  String _planningUserPrompt({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) {
    final analysesJson = const JsonEncoder.withIndent('  ')
        .convert(videoAnalyses);
    return '''
User request: $userPrompt

Target duration: ${targetDuration.toStringAsFixed(1)} seconds
Number of source videos: ${videoAnalyses.length}

Pre-analyzed video metadata (JSON):
$analysesJson

Return STRICT JSON (no markdown, no prose) with this exact schema:
{
  "timeline": [
    {
      "videoPath": string,
      "startTime": number,
      "endTime": number,
      "transition": "cut" | "fade" | "crossfade" | "slide" | "dissolve",
      "reason": string
    }
  ],
  "totalDuration": number,
  "suggestedTitle": string,
  "recommendedMusic": string,
  "suggestedNarration": string | null
}
''';
  }

  @override
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) async {
    final body = <String, dynamic>{
      'model': _modelName,
      'messages': [
        {
          'role': 'system',
          'content': _planningSystemPrompt(),
        },
        {
          'role': 'user',
          'content': _planningUserPrompt(
            videoAnalyses: videoAnalyses,
            userPrompt: userPrompt,
            targetDuration: targetDuration,
          ),
        },
      ],
      'stream': false,
      'options': {
        'temperature': 0.4,
        'num_predict': 2048,
      },
    };

    final response = await _chatCompletions(body);
    final text = _extractMessageContent(response);

    try {
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      parsed['targetDuration'] = targetDuration;
      parsed['userPrompt'] = userPrompt;
      parsed['model'] = _modelName;
      return parsed;
    } on FormatException catch (e) {
      throw OllamaLocalException(
        'Ollama local planning model returned non-JSON response: ${e.message}\n'
        'Raw output (first 500 chars): ${text.substring(0, text.length.clamp(0, 500))}',
      );
    }
  }

  @override
  Future<String?> generateNarration(
    String prompt, {
    Duration? maxDuration,
  }) async {
    final wantsNarration = prompt.toLowerCase().contains('narrat') ||
        prompt.toLowerCase().contains('voice') ||
        prompt.toLowerCase().contains('speak') ||
        prompt.toLowerCase().contains('script');

    if (!wantsNarration) return null;

    final capChars = maxDuration == null
        ? 800
        : (maxDuration.inSeconds * 14).clamp(120, 2000);

    final body = <String, dynamic>{
      'model': _modelName,
      'messages': [
        {
          'role': 'system',
          'content':
              'You write short narration scripts for short videos. Keep them tight, vivid, and under the requested character limit. No stage directions.',
        },
        {
          'role': 'user',
          'content':
              'Write narration for: $prompt\n\nHard character cap: $capChars characters. Return ONLY the narration text.',
        },
      ],
      'stream': false,
      'options': {
        'temperature': 0.7,
        'num_predict': (capChars / 3).ceil(),
      },
    };

    final response = await _chatCompletions(body);
    return _extractMessageContent(response).trim();
  }

  @override
  Future<List<String>> generateTitleSuggestions(
    List<Map<String, dynamic>> videoAnalyses,
  ) async {
    final body = <String, dynamic>{
      'model': _modelName,
      'messages': [
        {
          'role': 'system',
          'content':
              'You propose short, evocative titles for short AI-edited videos. Output strict JSON only.',
        },
        {
          'role': 'user',
          'content': '''
Video analyses (JSON):
${const JsonEncoder.withIndent('  ').convert(videoAnalyses)}

Return STRICT JSON:
{ "titles": [string, string, string, string, string] }
Each title 2-6 words. No quotes inside titles. No markdown.
''',
        },
      ],
      'stream': false,
      'options': {
        'temperature': 0.8,
        'num_predict': 256,
      },
    };

    final response = await _chatCompletions(body);
    final text = _extractMessageContent(response);
    try {
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      final list = (parsed['titles'] as List?)?.cast<String>() ?? const [];
      return list;
    } on FormatException {
      return const <String>[];
    }
  }
}

/// Generic Local LLM Provider (for MLC LLM, llama.cpp, etc.)
class GenericLocalLLMProvider extends LocalLLMProvider {
  final String _modelPath;
  final String _backendType; // e.g., 'mlc', 'llama.cpp', 'onnx'

  GenericLocalLLMProvider({
    required String modelPath,
    required String backendType,
  }) : _modelPath = modelPath,
       _backendType = backendType;

  @override
  Future<void> initialize(Map<String, String> config) async {
    // Initialize the local LLM runtime
    // Would load model from _modelPath using _backendType
  }

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    // Similar to Ollama but using local inference engine
    await Future.delayed(const Duration(seconds: 5)); // Local processing
    
    return {
      'description': 'Video analyzed by local LLM',
      'objects': ['detected_object'],
      'emotions': ['content'],
      'quality': 0.70,
      'duration': 8.0,
      'processing': 'Local device ($_backendType)',
      'modelPath': _modelPath,
    };
  }

  @override
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) async {
    await Future.delayed(const Duration(seconds: 4));
    
    return {
      'timeline': [
        {
          'videoIndex': 0,
          'startTime': 0.0,
          'endTime': targetDuration.clamp(5.0, 120.0),
          'transition': 'cut',
          'reason': 'Local LLM decision',
        },
      ],
      'totalDuration': targetDuration.clamp(10.0, 300.0),
      'suggestedTitle': 'Local LLM Video',
      'recommendedMusic': 'local_genre',
      'suggestedNarration': null,
    };
  }

  @override
  Future<String?> generateNarration(String prompt, {Duration? maxDuration}) async {
    await Future.delayed(const Duration(seconds: 4));
    
    if (prompt.toLowerCase().contains('narrate') || 
        prompt.toLowerCase().contains('voiceover')) {
      return 'Narration generated by local LLM ($_backendType).';
    }
    
    return null;
  }

  @override
  Future<List<String>> generateTitleSuggestions(List<Map<String, dynamic>> videoAnalyses) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      'Local LLM Video',
      'On-Device AI Processing',
      'Private AI Creation',
    ];
  }
}

/// Factory for creating AI providers based on configuration
class AIProviderFactory {
  static AIProvider createProvider(String providerType, Map<String, dynamic> config) {
    switch (providerType) {
      case 'OpenAI':
        return OpenAIProvider(
          apiKey: config['apiKey'] ?? '',
          modelName: config['model'] ?? 'gpt-4-vision-preview',
        );
      case 'Google Gemini':
        return GeminiProvider(
          apiKey: config['apiKey'] ?? '',
          modelName: config['model'] ?? 'gemini-pro-vision',
        );
      case 'Anthropic Claude':
        return ClaudeProvider(
          apiKey: config['apiKey'] ?? '',
          modelName: config['model'] ?? 'claude-3-opus-20240229',
        );
      case 'Grok':
        return GrokProvider(
          apiKey: config['apiKey'] ?? '',
          apiUrl: config['apiUrl'],
        );
      case 'Hugging Face':
        return HuggingFaceProvider(
          apiKey: config['apiKey'] ?? '',
          apiUrl: config['apiUrl'],
        );
      case 'Together AI':
        return TogetherProvider(
          apiKey: config['apiKey'] ?? '',
          textModel: config['textModel'],
          visionModel: config['visionModel'],
        );
      case 'Ollama (Local)':
        return OllamaLocalProvider(
          baseUrl: config['baseUrl'] ?? 'http://localhost:11434',
          modelName: config['modelName'] ?? 'llava',
        );
      case 'Ollama Cloud':
        return OllamaCloudProvider(
          apiKey: config['apiKey'] ?? '',
          modelName: config['modelName'] ?? 'llava:13b',
        );
      case 'Local LLM':
        return GenericLocalLLMProvider(
          modelPath: config['modelPath'] ?? '',
          backendType: config['backendType'] ?? 'llama.cpp',
        );
      case 'Custom Endpoint':
        return CustomEndpointProvider(
          endpointUrl: config['endpointUrl'] ?? '',
          apiKey: config['apiKey'],
          headers: Map<String, String>.from(config['headers'] ?? {}),
        );
      default:
        throw UnsupportedError('Unsupported AI provider: $providerType');
    }
  }
}

/// Custom endpoint provider for user-defined AI services
class CustomEndpointProvider implements AIProvider {
  final String _endpointUrl;
  final String? _apiKey;
  final Map<String, String> _headers;

  CustomEndpointProvider({
    required String endpointUrl,
    String? apiKey,
    Map<String, String>? headers,
  })  : _endpointUrl = endpointUrl,
        _apiKey = apiKey,
        _headers = headers ?? {};

  @override
  Future<void> initialize(Map<String, String> config) async {
    // Initialize custom endpoint client
  }

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    // Call custom endpoint for video analysis
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'description': 'Custom analysis',
      'objects': ['item1'],
      'emotions': ['happy'],
      'quality': 0.8,
      'duration': 10.0,
    };
  }

  @override
  Future<Map<String, dynamic>> planEditing({
    required List<Map<String, dynamic>> videoAnalyses,
    required String userPrompt,
    required double targetDuration,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'timeline': [
        {
          'videoIndex': 0,
          'startTime': 0.0,
          'endTime': 5.0,
          'transition': 'fade',
          'reason': 'First part',
        },
        {
          'videoIndex': 0,
          'startTime': 5.0,
          'endTime': 10.0,
          'transition': 'fade',
          'reason': 'Second part',
        },
      ],
      'totalDuration': targetDuration.clamp(10.0, 300.0),
      'suggestedTitle': 'Custom Video',
      'recommendedMusic': 'custom_music',
    };
  }

  @override
  Future<String?> generateNarration(String prompt, {Duration? maxDuration}) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (prompt.toLowerCase().contains('narrate') || 
        prompt.toLowerCase().contains('voiceover')) {
      return 'Narration generated via custom endpoint.';
    }
    
    return null;
  }

  @override
  Future<List<String>> generateTitleSuggestions(List<Map<String, dynamic>> videoAnalyses) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return ['Custom Creation'];
  }

  @override
  Future<void> dispose() async {}
}