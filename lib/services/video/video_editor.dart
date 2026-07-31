import 'dart:io';
import 'package:path/path.dart' as path;
import '../ai/providers/ai_provider.dart';
import 'ffmpeg_service.dart';

/// Orchestrates the video editing process based on AI-generated plans
class VideoEditor {
  final FFmpegService _ffmpeg;
  final String _tempDir;

  VideoEditor({String? tempDir})
      : _ffmpeg = FFmpegService(),
        _tempDir = tempDir ?? Directory.systemTemp.createTempSync('video_edit_').path;

  /// Processes a list of videos according to an AI-generated editing plan
  Future<String> editVideo({
    required List<String> videoPaths,
    required Map<String, dynamic> editPlan,
    required String outputPath,
  }) async {
    // Validate inputs
    if (videoPaths.isEmpty) {
      throw ArgumentError('No input videos provided');
    }
    
    for (final videoPath in videoPaths) {
      if (!await File(videoPath).exists()) {
        throw FileSystemException('Input video not found: $videoPath');
      }
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // Step 1: Analyze all input videos
      final videoMetadatas = <String, Map<String, dynamic>>{};
      for (final videoPath in videoPaths) {
        videoMetadatas[videoPath] = await _ffmpeg.getVideoMetadata(videoPath);
      }

      // Step 2: Process according to edit plan
      final processedClips = await _processEditPlan(
        videoPaths: videoPaths,
        videoMetadatas: videoMetadatas,
        editPlan: editPlan,
      );

      // Step 3: Concatenate all processed clips
      final clipPaths = processedClips.map((clip) => clip['path'] as String).toList();
      
      if (clipPaths.isEmpty) {
        throw Exception('No clips were generated from the edit plan');
      }

      final finalPath = await _ffmpeg.concatenateVideos(
        inputPaths: clipPaths,
        outputPath: outputPath,
      );

      // Step 4: Clean up temporary files
      await _cleanupTempFiles(clipPaths);

      return finalPath;
    } catch (e) {
      // Clean up on failure
      await _cleanupTempFiles([]);
      rethrow;
    }
  }

  /// Processes the edit plan to generate individual clips
  Future<List<Map<String, dynamic>>> _processEditPlan({
    required List<String> videoPaths,
    required Map<String, Map<String, dynamic>> videoMetadatas,
    required Map<String, dynamic> editPlan,
  }) async {
    final processedClips = <Map<String, dynamic>>[];
    final timeline = editPlan['timeline'] as List<dynamic>? ?? [];

    for (final segment in timeline) {
      final clip = await _processTimelineSegment(
        videoPaths: videoPaths,
        videoMetadatas: videoMetadatas,
        segment: segment as Map<String, dynamic>,
        clipIndex: processedClips.length,
      );
      
      if (clip != null) {
        processedClips.add(clip);
      }
    }

    return processedClips;
  }

  /// Processes a single timeline segment
  Future<Map<String, dynamic>?> _processTimelineSegment({
    required List<String> videoPaths,
    required Map<String, Map<String, dynamic>> videoMetadatas,
    required Map<String, dynamic> segment,
    required int clipIndex,
  }) async {
    try {
      final videoIndex = segment['videoIndex'] as int? ?? 0;
      final startTime = (segment['startTime'] as num?)?.toDouble() ?? 0.0;
      final endTime = (segment['endTime'] as num?)?.toDouble() ?? 0.0;
      final transitionIn = segment['transitionIn'] as String? ?? 'none';
      final transitionOut = segment['transitionOut'] as String? ?? 'none';
      final duration = segment['duration'] as num? ?? (endTime - startTime);
      
      // Validate video index
      if (videoIndex < 0 || videoIndex >= videoPaths.length) {
        throw ArgumentError('Invalid video index: $videoIndex');
      }

      final inputPath = videoPaths[videoIndex];
      final metadata = videoMetadatas[inputPath]!;
      
      // Adjust times to be within video bounds
      final videoDuration = metadata['duration'] as double;
      final adjustedStart = startTime.clamp(0.0, videoDuration);
      final adjustedEnd = endTime.clamp(adjustedStart, videoDuration);
      
      if (adjustedEnd <= adjustedStart) {
        return null; // Skip invalid segments
      }

      // Create temporary file for this clip
      final tempClipPath = path.join(
        _tempDir, 
        'clip_${clipIndex.toString().padLeft(4, '0')}.mp4'
      );

      // Step 1: Extract the base clip
      await _ffmpeg.trimVideo(
        inputPath: inputPath,
        outputPath: tempClipPath,
        startTime: adjustedStart,
        endTime: adjustedEnd,
      );

      // Step 2: Apply any video effects (from segment metadata)
      final processedPath = await _applySegmentEffects(
        inputPath: tempClipPath,
        segment: segment,
        videoMetadata: metadata,
      );

      // Step 3: Apply transitions (would be handled during concatenation in real impl)
      // For now, we'll note the transitions in metadata for the concat step

      return {
        'path': processedPath,
        'metadata': {
          'videoIndex': videoIndex,
          'startTime': adjustedStart,
          'endTime': adjustedEnd,
          'duration': adjustedEnd - adjustedStart,
          'transitionIn': transitionIn,
          'transitionOut': transitionOut,
          'originalSegment': segment,
        },
      };
    } catch (e) {
      // Log error but continue with other clips
      debugPrint('Warning: Failed to process timeline segment: $e');
      return null;
    }
  }

  /// Applies effects specified in a timeline segment
  Future<String> _applySegmentEffects({
    required String inputPath,
    required Map<String, dynamic> segment,
    required Map<String, dynamic> videoMetadata,
  }) async {
    String currentPath = inputPath;
    
    try {
      // Apply color correction if specified
      if (segment.containsKey('colorCorrection')) {
        final colorCorrection = segment['colorCorrection'] as Map<String, dynamic>?;
        if (colorCorrection != null) {
          final tempPath = path.join(
            _tempDir,
            'color_${DateTime.now().millisecondsSinceEpoch}.mp4'
          );
          
          await _ffmpeg.applyColorCorrection(
            inputPath: currentPath,
            outputPath: tempPath,
            brightness: (colorCorrection['brightness'] as num?)?.toDouble() ?? 0.0,
            contrast: (colorCorrection['contrast'] as num?)?.toDouble() => 1.0,
            saturation: (colorCorrection['saturation'] as num?)?.toDouble() => 1.0,
          );
          
          currentPath = tempPath;
        }
      }

      // Apply speed change if specified
      if (segment.containsKey('speed')) {
        final speed = segment['speed'] as num?;
        if (speed != null && speed > 0) {
          final tempPath = path.join(
            _tempDir,
            'speed_${DateTime.now().millisecondsSinceEpoch}.mp4'
          );
          
          await _ffmpeg.changeSpeed(
            inputPath: currentPath,
            outputPath: tempPath,
            speedFactor: speed.toDouble(),
          );
          
          currentPath = tempPath;
        }
      }

      // Apply resize if specified
      if (segment.containsKey('resize')) {
        final resize = segment['resize'] as Map<String, dynamic>?;
        if (resize != null) {
          final tempPath = path.join(
            _tempDir,
            'resize_${DateTime.now().millisecondsSinceEpoch}.mp4'
          );
          
          await _ffmpeg.resizeVideo(
            inputPath: currentPath,
            outputPath: tempPath,
            width: (resize['width'] as int?) ?? 1920,
            height: (resize['height'] as int?) ?? 1080,
          );
          
          currentPath = tempPath;
        }
      }

      // Apply stabilization if specified
      if (segment['stabilize'] == true) {
        final tempPath = path.join(
          _tempDir,
          'stable_${DateTime.now().millisecondsSinceEpoch}.mp4'
        );
        
        await _ffmpeg.stabilizeVideo(
          inputPath: currentPath,
          outputPath: tempPath,
        );
        
        currentPath = tempPath;
      }

      return currentPath;
    } catch (e) {
      debugPrint('Warning: Failed to apply segment effects: $e');
      return currentPath; // Return original if effects fail
    }
  }

  /// Creates the final video with transitions between clips
  Future<String> _applyTransitions({
    required List<String> clipPaths,
    required List<Map<String, dynamic>> clipMetadata,
    required String outputPath,
  }) async {
    if (clipPaths.isEmpty) {
      throw ArgumentError('No clips to process');
    }

    if (clipPaths.length == 1) {
      // Single clip - just copy it
      final inputFile = File(clipPaths[0]);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      return outputPath;
    }

    // For multiple clips, we need to handle transitions
    // In a full implementation, this would create complex filtergraphs
    // For now, we'll do simple concatenation and note that transitions
    // would be handled by a more sophisticated implementation
    
    return await _ffmpeg.concatenateVideos(
      inputPaths: clipPaths,
      outputPath: outputPath,
    );
  }

  /// Cleans up temporary files
  Future<void> _cleanupTempFiles(List<String> filesToKeep) async {
    try {
      final tempDir = Directory(_tempDir);
      if await tempDir.exists() {
        final files = tempDir.listSync();
        
        for (final file in files) {
          if (file is File) {
            final shouldKeep = filesToKeep.any(
              (path) => path == file.path
            );
            
            if (!shouldKeep) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Warning: Failed to clean up temp files: $e');
    }
  }

  /// Gets the temporary directory path
  String getTempDir() => _tempDir;

  /// Cleans up all temporary files and directory
  Future<void> dispose() async {
    await _cleanupTempFiles([]);
    try {
      final tempDir = Directory(_tempDir);
      if await tempDir.exists() {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Warning: Failed to delete temp directory: $e');
    }
  }
}

/// Result of a video editing operation
class VideoEditResult {
  final bool success;
  final String? outputPath;
  final String? errorMessage;
  final Map<String, dynamic>? editInfo;
  final int processingTimeMs;

  const VideoEditResult.success({
    required this.outputPath,
    required this.editInfo,
    required this.processingTimeMs,
  })  : success = true,
        errorMessage = null;

  const VideoEditResult.failure({
    required this.errorMessage,
  })  : success = false,
        outputPath = null,
        editInfo = null,
        processingTimeMs = 0;

  @override
  String toString() {
    if (success) {
      return 'VideoEditResult(success: true, output: $outputPath, time: $processingTimeMs ms)';
    } else {
      return 'VideoEditResult(failure: true, error: $errorMessage)';
    }
  }
}