import 'dart:io';
import 'package:path/path.dart' as path;
import '../ai/providers/ai_provider.dart';
import 'ffmpeg_service.dart';
import 'video_editor.dart';

/// Service that orchestrates the complete video processing pipeline:
// AI Analysis -> Planning -> Editing -> Export
class VideoProcessingService {
  final AIProvider _aiProvider;
  final FFmpegService _ffmpegService;
  final VideoEditor _videoEditor;
  final String _tempDir;

  VideoProcessingService({
    required AIProvider aiProvider,
    String? tempDir,
  })  : _aiProvider = aiProvider,
        _ffmpegService = FFmpegService(),
        _videoEditor = VideoEditor(tempDir: tempDir),
        _tempDir = tempDir ?? Directory.systemTemp.createTempSync('video_proc_').path;

  /// Processes a folder of videos according to user prompt
  Future<String> processVideoFolder({
    required String folderPath,
    required String userPrompt,
    required String outputPath,
    double targetDuration = 60.0, // seconds
  }) async {
    // Validate inputs
    if (!await Directory(folderPath).exists()) {
      throw FileSystemException('Folder not found: $folderPath');
    }

    if (userPrompt.trim().isEmpty) {
      throw ArgumentError('User prompt cannot be empty');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // Step 1: Scan for video files
      final videoFiles = await _scanVideoFiles(folderPath);
      
      if (videoFiles.isEmpty) {
        throw Exception('No video files found in folder: $folderPath');
      }

      // Step 2: Analyze videos with AI
      final videoAnalyses = await _analyzeVideos(videoFiles);
      
      // Step 3: Generate editing plan with AI
      final editPlan = await _aiProvider.planEditing(
        videoAnalyses: videoAnalyses,
        userPrompt: userPrompt,
        targetDuration: targetDuration,
      );

      // Step 4: Execute the edit plan using FFmpeg
      final finalPath = await _videoEditor.editVideo(
        videoPaths: videoFiles,
        editPlan: editPlan,
        outputPath: outputPath,
      );

      // Step 5: Return result with metadata
      return finalPath;
    } catch (e) {
      await _videoEditor.dispose();
      rethrow;
    }
  }

  /// Scans a folder for video files
  Future<List<String>> _scanVideoFiles(String folderPath) async {
    final videoExtensions = {
      '.mp4', '.mov', '.avi', '.mkv', '.webm', '.mpeg', '.hevc', '.h264'
    };

    final videoFiles = <String>[];
    final directory = Directory(folderPath);

    try {
      await for (final entity in directory.listRecursively(
        followLinks: false,
      )) {
        if (entity is File) {
          final extension = path.extension(entity.path).toLowerCase();
          if (videoExtensions.contains(extension)) {
            videoFiles.add(entity.path);
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to scan folder: $e');
    }

    return videoFiles;
  }

  /// Analyzes videos using the AI provider
  Future<List<Map<String, dynamic>>> _analyzeVideos(List<String> videoPaths) async {
    final analyses = <Map<String, dynamic>>[];
    
    for (final videoPath in videoPaths) {
      try {
        final analysis = await _aiProvider.analyzeVideo(videoPath);
        analyses.add({
          'videoPath': videoPath,
          ...analysis,
        });
      } catch (e) {
        // If AI analysis fails for a video, we still continue with others
        // but log the issue
        debugPrint('Warning: Failed to analyze video $videoPath: $e');
        analyses.add({
          'videoPath': videoPath,
          'description': 'Analysis failed',
          'objects': [],
          'emotions': [],
          'quality': 0.0,
          'duration': 0.0,
          'error': e.toString(),
        });
      }
    }
    
    return analyses;
  }

  /// Gets the temporary directory path
  String getTempDir() => _tempDir;

  /// Cleans up resources
  Future<void> dispose() async {
    await _videoEditor.dispose();
  }
}

/// Factory for creating video processing services
class VideoProcessingServiceFactory {
  static VideoProcessingService createService({
    required String aiProviderType,
    required Map<String, dynamic> aiConfig,
    String? tempDir,
  }) {
    final aiProvider = AIProviderFactory.createProvider(
      aiProviderType,
      aiConfig,
    );
    
    return VideoProcessingService(
      aiProvider: aiProvider,
      tempDir: tempDir,
    );
  }
}