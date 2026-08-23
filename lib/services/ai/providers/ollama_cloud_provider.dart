import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'ai_provider.dart';

/// Ollama Cloud provider.
///
/// Uses Ollama Cloud's API for accessing models hosted in the cloud.
/// Supports both text and multimodal models for video analysis and planning.
///
/// Construction:
///   final provider = OllamaCloudProvider(apiKey: '...');
///   final provider = AIProviderFactory.createProvider('Ollama Cloud', {
///     'apiKey': '...',
///     'modelName': 'llava:13b',
///   });
class OllamaCloudProvider extends CloudAIProvider {
  /// Default model for video analysis and planning.
  /// Llava 13b is a good multimodal model for video understanding.
  static const String defaultModel = 'llava:13b';

  final String _modelName;
  final http.Client _client;
  final Duration _timeout;

  OllamaCloudProvider({
    required String apiKey,
    String? modelName,
    http.Client? client,
    Duration timeout = const Duration(seconds: 120),
  })  : _modelName = modelName ?? defaultModel,
        _client = client ?? http.Client(),
        _timeout = timeout,
        super(
          apiKey: apiKey,
          endpoint: 'https://cloud.ollama.com/api',
        );

  /// Model used for both text and vision tasks.
  String get modelName => _modelName;

  @override
  Future<void> dispose() async {
    _client.close();
  }

  // ---------------------------------------------------------------------------
  // Video analysis
  // ---------------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    final file = File(videoPath);
    if (!await file.exists()) {
      throw OllamaCloudException('Video file not found: $videoPath');
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
      throw OllamaCloudException(
        'Ollama Cloud returned non-JSON response: ${e.message}\n'
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

  // ---------------------------------------------------------------------------
  // Editing plan
  // ---------------------------------------------------------------------------

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
      throw OllamaCloudException(
        'Ollama Cloud planning model returned non-JSON response: ${e.message}\n'
        'Raw output (first 500 chars): ${text.substring(0, text.length.clamp(0, 500))}',
      );
    }
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

  // ---------------------------------------------------------------------------
  // Narration and titles
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // HTTP plumbing
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _chatCompletions(
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$endpoint/v1/chat/completions');
    final headers = getAuthHeaders();
    final encoded = jsonEncode(body);

    http.Response response;
    try {
      response = await _client
          .post(uri, headers: headers, body: encoded)
          .timeout(_timeout);
    } on TimeoutException {
      throw OllamaCloudException(
        'Ollama Cloud API request timed out after ${_timeout.inSeconds}s',
      );
    } on SocketException catch (e) {
      throw OllamaCloudException('Network error talking to Ollama Cloud: ${e.message}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaCloudException(
        'Ollama Cloud API error ${response.statusCode}: ${response.body}',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw OllamaCloudException(
        'Ollama Cloud API returned non-JSON body: ${response.body.substring(0, response.body.length.clamp(0, 500))}',
      );
    }
  }

  String _extractMessageContent(Map<String, dynamic> response) {
    // Ollama Cloud uses OpenAI-compatible API format
    final choices = response['choices'];
    if (choices is! List || choices.isEmpty) {
      throw OllamaCloudException(
        'Ollama Cloud API response had no choices. Body: $response',
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
    throw OllamaCloudException(
      'Ollama Cloud API response had no extractable content. Body: $response',
    );
  }

  // ---------------------------------------------------------------------------
  // Frame extraction (reuse from Together provider pattern)
  // ---------------------------------------------------------------------------

  /// Extracts frames from video using FFmpeg for AI analysis.
  /// Falls back to a single mid-video frame if FFmpeg fails.
  Future<List<Uint8List>> _extractFrames(
    String videoPath, {
      required int maxFrames,
    }) async {
    final tmpDir = Directory.systemTemp.createTempSync('ollama_cloud_frames_');
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
}

/// Exception thrown by [OllamaCloudProvider] for any user-visible failure
/// (bad API key, network error, non-JSON response, etc.).
class OllamaCloudException implements Exception {
  final String message;
  OllamaCloudException(this.message);

  @override
  String toString() => 'OllamaCloudException: $message';
}