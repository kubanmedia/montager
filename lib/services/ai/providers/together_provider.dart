import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'ai_provider.dart';

/// Together AI provider.
///
/// Uses Together's OpenAI-compatible chat completions API. Defaults to
/// open-weight models hosted by Together (Llama 3.2 Vision for frame
/// analysis, Llama 3.3 for text planning). All requests go to:
///   POST https://api.together.xyz/v1/chat/completions
///
/// Construction:
///   final provider = TogetherProvider(apiKey: '...');
///   final provider = AIProviderFactory.createProvider('Together AI', {
///     'apiKey': '...',
///     'textModel': 'meta-llama/Llama-3.3-70B-Instruct-Turbo',
///     'visionModel': 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo',
///   });
class TogetherProvider extends CloudAIProvider {
  /// Default text model. Strong general reasoning at reasonable cost.
  static const String defaultTextModel = 'meta-llama/Llama-3.3-70B-Instruct-Turbo';

  /// Default vision model. 90B vision flagship on Together as of writing.
  static const String defaultVisionModel =
      'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo';

  /// Cost-effective alternatives if the defaults are too expensive:
  ///   text:    'meta-llama/Llama-3.1-8B-Instruct'
  ///   text:    'Qwen/Qwen2.5-72B-Instruct-Turbo'
  ///   vision:  'meta-llama/Llama-3.2-11B-Vision-Instruct-Turbo'
  ///   vision:  'Qwen/Qwen2.5-VL-72B-Instruct'

  final String _textModel;
  final String _visionModel;
  final http.Client _client;
  final Duration _timeout;

  TogetherProvider({
    required String apiKey,
    String? textModel,
    String? visionModel,
    http.Client? client,
    Duration timeout = const Duration(seconds: 120),
  })  : _textModel = textModel ?? defaultTextModel,
        _visionModel = visionModel ?? defaultVisionModel,
        _client = client ?? http.Client(),
        _timeout = timeout,
        super(
          apiKey: apiKey,
          endpoint: 'https://api.together.xyz/v1',
        );

  /// Text model used for planning, narration, and title generation.
  String get textModel => _textModel;

  /// Vision model used for frame-based video analysis.
  String get visionModel => _visionModel;

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
      throw TogetherException('Video file not found: $videoPath');
    }

    // Extract a small set of representative frames. We use ffmpeg if
    // available; otherwise we fall back to a single mid-video frame so
    // the call still returns something useful.
    final frames = await _extractFrames(videoPath, maxFrames: 8);

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
      'model': _visionModel,
      'messages': [
        {
          'role': 'user',
          'content': content,
        },
      ],
      'temperature': 0.2,
      'max_tokens': 1024,
      'response_format': {'type': 'json_object'},
    };

    final response = await _chatCompletions(body);
    final text = _extractMessageContent(response);

    try {
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      parsed['videoPath'] = videoPath;
      parsed['frameCount'] = frames.length;
      parsed['model'] = _visionModel;
      return parsed;
    } on FormatException catch (e) {
      throw TogetherException(
        'Vision model returned non-JSON response: ${e.message}\n'
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

  /// Extract frames using ffmpeg if it is on PATH. Returns JPEG bytes.
  /// Falls back to a single mid-video still via dart:io if ffmpeg is
  /// missing — in that case the analysis will be much weaker, but the
  /// call still completes.
  Future<List<Uint8List>> _extractFrames(
    String videoPath, {
    required int maxFrames,
  }) async {
    final tmpDir = Directory.systemTemp.createTempSync('montager_frames_');
    try {
      // Probe duration first.
      final durationSeconds = await _probeDurationSeconds(videoPath);
      if (durationSeconds <= 0) {
        return _fallbackSingleFrame(videoPath, tmpDir);
      }

      final count = durationSeconds < 5
          ? 1
          : (durationSeconds / 5).floor().clamp(1, maxFrames);

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
    final result = await Process.run('ffprobe', [
      '-v', 'error',
      '-show_entries', 'format=duration',
      '-of', 'default=noprint_wrappers=1:nokey=1',
      videoPath,
    ]);
    if (result.exitCode != 0) return 0;
    final raw = (result.stdout as String).trim();
    return double.tryParse(raw) ?? 0;
  }

  Future<List<Uint8List>> _fallbackSingleFrame(
    String videoPath,
    Directory tmpDir,
  ) async {
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
      'model': _textModel,
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
      'temperature': 0.4,
      'max_tokens': 2048,
      'response_format': {'type': 'json_object'},
    };

    final response = await _chatCompletions(body);
    final text = _extractMessageContent(response);

    try {
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      parsed['targetDuration'] = targetDuration;
      parsed['userPrompt'] = userPrompt;
      parsed['model'] = _textModel;
      return parsed;
    } on FormatException catch (e) {
      throw TogetherException(
        'Planning model returned non-JSON response: ${e.message}\n'
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
      'model': _textModel,
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
      'temperature': 0.7,
      'max_tokens': (capChars / 3).ceil(),
    };

    final response = await _chatCompletions(body);
    return _extractMessageContent(response).trim();
  }

  @override
  Future<List<String>> generateTitleSuggestions(
    List<Map<String, dynamic>> videoAnalyses,
  ) async {
    final body = <String, dynamic>{
      'model': _textModel,
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
      'temperature': 0.8,
      'max_tokens': 256,
      'response_format': {'type': 'json_object'},
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
    final uri = Uri.parse('$endpoint/chat/completions');
    final headers = getAuthHeaders();
    final encoded = jsonEncode(body);

    http.Response response;
    try {
      response = await _client
          .post(uri, headers: headers, body: encoded)
          .timeout(_timeout);
    } on TimeoutException {
      throw TogetherException(
        'Together API request timed out after ${_timeout.inSeconds}s',
      );
    } on SocketException catch (e) {
      throw TogetherException('Network error talking to Together: ${e.message}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TogetherException(
        'Together API error ${response.statusCode}: ${response.body}',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw TogetherException(
        'Together API returned non-JSON body: ${response.body.substring(0, response.body.length.clamp(0, 500))}',
      );
    }
  }

  String _extractMessageContent(Map<String, dynamic> response) {
    final choices = response['choices'];
    if (choices is! List || choices.isEmpty) {
      throw TogetherException(
        'Together API response had no choices. Body: $response',
      );
    }
    final first = choices.first as Map<String, dynamic>;
    final message = first['message'];
    if (message is Map<String, dynamic>) {
      final content = message['content'];
      if (content is String && content.isNotEmpty) return content;
    }
    // Some Together models stream text directly into a top-level "text"
    // field on the choice (legacy completions compatibility).
    final text = first['text'];
    if (text is String && text.isNotEmpty) return text;
    throw TogetherException(
      'Together API response had no extractable content. Body: $response',
    );
  }
}

/// Exception thrown by [TogetherProvider] for any user-visible failure
/// (bad API key, network error, non-JSON response, etc.).
class TogetherException implements Exception {
  final String message;
  TogetherException(this.message);

  @override
  String toString() => 'TogetherException: $message';
}
