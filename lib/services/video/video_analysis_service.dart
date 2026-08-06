import 'dart:io';
import 'package:montager/services/database/video_database.dart';
import 'package:montager/services/database/database_module.dart';
import '../video/ffmpeg_service.dart';

/// Service that combines video frame extraction with embedding generation
/// for intelligent video understanding and semantic search
class VideoAnalysisService {
  final FFmpegService _ffmpegService;
  final EmbeddingService _embeddingService;
  final AppDatabase _database;

  VideoAnalysisService()
      : _ffmpegService = FFmpegService(),
        _embeddingService = EmbeddingService(),
        _database = database;

  /// Analyzes a video file and creates a searchable index of its content
  Future<void> analyzeVideo(String videoPath) async {
    // Check if already processed to avoid redundant work
    if (await _embeddingService.isVideoProcessed(videoPath)) {
      return;
    }

    // Get video metadata first
    final metadata = await _ffmpegService.getVideoMetadata(videoPath);
    if (metadata.isEmpty) {
      throw Exception('Could not read video metadata: $videoPath');
    }

    // Store video metadata
    await _embeddingService.storeVideoMetadata(
      videoPath: videoPath,
      durationSeconds: (metadata['duration'] as double?) ?? 0.0,
      width: (metadata['width'] as int?) ?? 0,
      height: (metadata['height'] as int?) ?? 0,
      format: (metadata['format'] as String?) ?? 'unknown',
      codec: (metadata['codecName'] as String?) ?? 'unknown',
      frameRate: _parseFrameRate(metadata['avgFrameRate'] as String?),
      totalFrames: ((metadata['duration'] as double?) ?? 0.0) *
          ((_parseFrameRate(metadata['avgFrameRate'] as String?)) ?? 30.0),
    );

    // Extract frames at optimal intervals for analysis (1 per 1-3 seconds)
    final tempDir = await Directory.systemTemp.createTemp('video_analysis_');
    try {
      final frames = await _ffmpegService.extractFramesForAnalysis(
        inputPath: videoPath,
        outputDir: tempDir.path,
        minIntervalSeconds: 1.0,
        maxIntervalSeconds: 3.0,
      );

      // Process each extracted frame
      for (int i = 0; i < frames.length; i++) {
        final framePath = frames[i];
        final timestamp = _calculateTimestampForFrame(i, frames.length, 
            (metadata['duration'] as double?) ?? 0.0);

        try {
          // Read the frame image
          final frameBytes = await File(framePath).readAsBytes();
          
          // Generate embeddings for the frame (using placeholder implementation)
          final imageEmbedding = await _embeddingService.generateImageEmbedding(frameBytes);
          
          // Generate a description based on position (in real impl, use vision model)
          final description = 'Frame $i at ${timestamp.toStringAsFixed(1)}s';
          
          // Store the frame embedding with metadata
          await _embeddingService.storeFrameEmbedding(
            videoPath: videoPath,
            frameNumber: i,
            timestampSeconds: timestamp,
            embedding: imageEmbedding,
            description: description,
            objects: [], // Would come from object detection in real impl
            scene: 'unknown', // Would come from scene classification in real impl
            qualityScore: 0.8, // Would come from quality assessment in real impl
          );
        } catch (e) {
          // Continue processing other frames if one fails
          continue;
        }
      }
    } finally {
      // Clean up temporary files
      try {
        await tempDir.delete(recursive: true);
      } catch (e) {
        // Ignore cleanup errors
      }
    }

    // Mark video as processed
    await _embeddingService.markVideoAsProcessed(videoPath);
  }

  /// Calculates timestamp for a frame based on its position in the sequence
  double _calculateTimestampForFrame(int frameIndex, int totalFrames, double videoDuration) {
    if (totalFrames <= 1) return videoDuration / 2;
    return (frameIndex / (totalFrames - 1)) * videoDuration;
  }

  /// Parses frame rate string like "30/1" or "30" to double
  double _parseFrameRate(String? frameRateStr) {
    if (frameRateStr == null || frameRateStr.isEmpty) return 30.0;
    
    if (frameRateStr.contains('/')) {
      final parts = frameRateStr.split('/');
      if (parts.length == 2) {
        try {
          final num = double.tryParse(parts[0]) ?? 30.0;
          final den = double.tryParse(parts[1]) ?? 1.0;
          return den != 0 ? num / den : 30.0;
        } catch (_) {
          return 30.0;
        }
      }
    }
    
    return double.tryParse(frameRateStr) ?? 30.0;
  }

  /// Searches for video content similar to the given text query
  Future<List<Map<String, dynamic>>> searchByText(String query, 
      {int limit = 10, double threshold = 0.6}) async {
    final queryEmbedding = await _embeddingService.generateTextEmbedding(query);
    final results = await _embeddingService.searchSimilarFrames(
      queryEmbedding, 
      limit: limit, 
      similarityThreshold: threshold,
    );
    
    return results.map((r) => {
      'videoPath': r.videoPath,
      'frameNumber': r.frameNumber,
      'timestamp': r.timestampSeconds,
      'description': r.description,
      'similarity': 0.8, // Placeholder - calculate actual similarity
    }).toList();
  }

  /// Gets all analyzed frames for a video
  Future<List<Map<String, dynamic>>> getVideoAnalysis(String videoPath) async {
    final embeddings = await _embeddingService.getVideoEmbeddings(videoPath);
    return embeddings.map((e) => {
      'videoPath': e.videoPath,
      'frameNumber': e.frameNumber,
      'timestamp': e.timestampSeconds,
      'description': e.description,
      'objects': [], // Parse from JSON in real impl
      'scene': e.scene,
    }).toList();
  }
}