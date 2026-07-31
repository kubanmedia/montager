import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Service for handling FFmpeg video processing operations
class FFmpegService {
  FFmpegService();

  /// Checks if FFmpeg is available and working
  Future<bool> isFFmpegAvailable() async {
    try {
      // In a real implementation, we would run: ffmpeg -version
      // For now, we'll simulate availability
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets FFmpeg version information
  Future<String> getFFmpegVersion() async {
    try {
      // Would run: ffmpeg -version
      return 'ffmpeg version 6.0';
    } catch (e) {
      return 'FFmpeg not available: $e';
    }
  }

  /// Gets list of available codecs
  Future<List<String>> getAvailableCodecs() async {
    // Would run: ffmpeg -codecs
    return [
      'libx264',
      'libx265',
      'libvpx-vp9',
      'libaom-av1',
      'h264',
      'hevc',
      'vp9',
      'av1',
      'aac',
      'mp3',
      'opus',
    libopus',
    ];
  }

  /// Gets video metadata (duration, resolution, format, etc.)
  Future<Map<String, dynamic>> getVideoMetadata(String filePath) async {
    if (!await File(filePath).exists()) {
      throw FileSystemException('File not found: $filePath');
    }

    try {
      // In a real implementation, we would run:
      // ffprobe -v quiet -print_format json -show_format -show_streams input.mp4
      
      // Simulating FFprobe response
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'duration': 125.5, // seconds
        'durationString': '00:02:05.500000',
        'width': 1920,
        'height': 1080,
        'format': 'mp4',
        'formatName': 'mov,mp4,m4a,3gp,3g2,mj2',
        'bitRate': '5200000',
        'frameRate': '30/1',
        'avgFrameRate': '30',
        'codecName': 'h264',
        'codecLongName': 'H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10',
        'pixelFormat': 'yuv420p',
        'audioCodec': 'aac',
        'audioSampleRate': '48000',
        'audioChannels': 2,
        'size': 81920000, // bytes
        'bitrate': '5200 kb/s',
      };
    } catch (e) {
      throw Exception('Failed to get video metadata: $e');
    }
  }

  /// Extracts a single frame from video at specified time
  Future<String> extractFrame({
    required String inputPath,
    required String outputPath,
    required double timeSeconds,
    int width = 320,
    int height = 240,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would run:
      // ffmpeg -i input -ss $timeSeconds -vframes 1 -vf "scale=$width:$height" output
      
      // Simulate processing time
      await Future.delayed(Duration(milliseconds: 800 + (timeSeconds * 10).toInt()));
      
      // Create a dummy output file for simulation
      final file = File(outputPath);
      await file.writeAsBytes(List.filled(1024, 0)); // Dummy data
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to extract frame: $e');
    }
  }

  /// Extracts multiple frames from video
  Future<List<String>> extractFrames({
    required String inputPath,
    required String outputDir,
    required double intervalSeconds,
    int? maxFrames,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }

    final dir = Directory(outputDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    try {
      // Get video duration first
      final metadata = await getVideoMetadata(inputPath);
      final duration = metadata['duration'] as double;
      
      final frameTimes = <double>[];
      for (double t = 0; t < duration; t += intervalSeconds) {
        frameTimes.add(t);
        if (maxFrames != null && frameTimes.length >= maxFrames) {
          break;
        }
      }

      final extractedPaths = <String>[];
      for (int i = 0; i < frameTimes.length; i++) {
        final outputPath = path.join(
          outputDir, 
          'frame_${i.toString().padLeft(4, '0')}.jpg'
        );
        
        await extractFrame(
          inputPath: inputPath,
          outputPath: outputPath,
          timeSeconds: frameTimes[i],
        );
        extractedPaths.add(outputPath);
      }
      
      return extractedPaths;
    } catch (e) {
      throw Exception('Failed to extract frames: $e');
    }
  }

  /// Trims video to specified start and end times
  Future<String> trimVideo({
    required String inputPath,
    required String outputPath,
    required double startTime,
    required double endTime,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }

    if (startTime < 0 || endTime <= startTime) {
      throw ArgumentError('Invalid time range: $startTime to $endTime');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would run:
      // ffmpeg -i input -ss $startTime -to $endTime -c:v libx264 -c:a aac -preset medium -crf 23 output
      
      // Simulate processing time based on duration
      final duration = endTime - startTime;
      await Future.delayed(Duration(milliseconds: (duration * 100).toInt()));
      
      // Copy input to output for simulation (in real impl, this would be processed)
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to trim video: $e');
    }
  }

  /// Concatenates multiple video files
  Future<String> concatenateVideos({
    required List<String> inputPaths,
    required String outputPath,
  }) async {
    if (inputPaths.isEmpty) {
      throw ArgumentError('No input files provided');
    }

    // Verify all input files exist
    for (final inputPath in inputPaths) {
      if (!await File(inputPath).exists()) {
        throw FileSystemException('Input file not found: $inputPath');
      }
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would:
      // 1. Create a temporary file list for FFmpeg concat demuxer
      // 2. Run: ffmpeg -f concat -safe 0 -i filelist.txt -c copy output
      
      // Simulate processing time
      final totalDuration = await _estimateTotalDuration(inputPaths);
      await Future.delayed(Duration(milliseconds: (totalDuration * 50).toInt()));
      
      // For simulation, just copy first file
      final inputFile = File(inputPaths[0]);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to concatenate videos: $e');
    }
  }

  /// Adds transition between two video clips
  Future<String> addTransition({
    required String input1Path,
    required String input2Path,
    required String outputPath,
    required String transitionType,
    required double duration,
  }) async {
    if (!await File(input1Path).exists()) {
      throw FileSystemException('Input 1 not found: $input1Path');
    }
    if (!await File(input2Path).exists()) {
      throw FileSystemException('Input 2 not found: $input2Path');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would create appropriate filter based on transitionType
      // Supported transitions: fade, slide, wipe, zoom, flash, etc.
      
      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // For simulation, concatenate the two files
      final tempList = await _createTempFileList([input1Path, input2Path]);
      final tempOutput = '$outputPath.temp.mp4';
      await concatenateVideos(
        inputPaths: [input1Path, input2Path],
        outputPath: tempOutput,
      );
      
      // In real implementation, we would apply transition filter here
      // For now, just move the concatenated result to final output
      final tempFile = File(tempOutput);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await tempFile.readAsBytes());
      await tempFile.delete();
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to add transition: $e');
    }
  }

  /// Applies color correction to video
  Future<String> applyColorCorrection({
    required String inputPath,
    required String outputPath,
    required double brightness,
    required double contrast,
    required double saturation,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would use eq filter:
      // ffmpeg -i input -vf "eq=brightness=$brightness:contrast=$contrast:saturation=$saturation" output
      
      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // Copy for simulation
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to apply color correction: $e');
    }
  }

  /// Changes video speed (slow motion or fast motion)
  Future<String> changeSpeed({
    required String inputPath,
    required String outputPath,
    required double speedFactor,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }
    
    if (speedFactor <= 0) {
      throw ArgumentError('Speed factor must be positive');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would use setpts filter:
      // ffmpeg -i input -filter:v "setpts=$factor*PTS" -filter:a "atempo=$audioFactor" output
      
      // Simulate processing time (inverse relationship with speed)
      final metadata = await getVideoMetadata(inputPath);
      final duration = metadata['duration'] as double;
      final processingTime = (duration / speedFactor.abs()).clamp(0.5, 10.0);
      
      await Future.delayed(Duration(milliseconds: (processingTime * 100).toInt()));
      
      // Copy for simulation
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to change video speed: $e');
    }
  }

  /// Adds audio track to video
  Future<String> addAudio({
    required String videoPath,
    required String audioPath,
    required String outputPath,
    required double volume,
  }) async {
    if (!await File(videoPath).exists()) {
      throw FileSystemException('Video file not found: $videoPath');
    }
    if (!await File(audioPath).exists()) {
      throw FileSystemException('Audio file not found: $audioPath');
    }
    
    if (volume < 0 || volume > 2.0) {
      throw ArgumentError('Volume must be between 0.0 and 2.0');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would use:
      // ffmpeg -i video -i audio -filter_complex "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=3" -c:v copy output
      
      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Copy video for simulation (audio would be mixed in real impl)
      final videoFile = File(videoPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await videoFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to add audio: $e');
    }
  }

  /// Adds text overlay to video
  Future<String> addTextOverlay({
    required String inputPath,
    required String outputPath,
    required String text,
    required double x,
    required double y,
    required double fontSize,
    required String fontColor,
    required double opacity,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would use drawtext filter:
      // ffmpeg -i input -vf "drawtext=text='$text':x=$x:y=$y:fontsize=$fontSize:fontcolor=$fontColor@$opacity" output
      
      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Copy for simulation
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to add text overlay: $e');
    }
  }

  /// Stabilizes video (reduces camera shake)
  Future<String> stabilizeVideo({
    required String inputPath,
    required String outputPath,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would use vidstabdetect and vidstabtransform filters
      // This is a two-pass process:
      // 1. ffmpeg -i input -vf vidstabdetect=stepsize=6:shakiness=8:accuracy=9:result=transforms.trf -f null -
      // 2. ffmpeg -i input -vf vidstabtransform=input=transforms.trf:zoom=1:smoothing=30,unsharp=5:5:0.8:3:3:0.4 -c:v libx264 -preset slow -crf 18 -c:a copy output
      
      // Simulate processing (this would be quite intensive in reality)
      await Future.delayed(const Duration(seconds: 3));
      
      // Copy for simulation
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to stabilize video: $e');
    }
  }

  /// Resizes video to specified dimensions
  Future<String> resizeVideo({
    required String inputPath,
    required String outputPath,
    required int width,
    required int height,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }
    
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Width and height must be positive');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would use scale filter:
      // ffmpeg -i input -vf "scale=$width:$height" -c:a copy output
      
      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Copy for simulation
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to resize video: $e');
    }
  }

  /// Converts video to different format/codec
  Future<String> convertVideo({
    required String inputPath,
    required String outputPath,
    required String videoCodec,
    required String audioCodec,
    required String preset,
    required int crf,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // In a real implementation, we would run:
      // ffmpeg -i input -c:v $videoCodec -c:a $audioCodec -preset $preset -crf $crf output
      
      // Simulate processing time based on complexity
      final processingMs = (crf * 10).toInt().clamp(500, 3000);
      await Future.delayed(Duration(milliseconds: processingMs));
      
      // Copy for simulation
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to convert video: $e');
    }
  }

  /// Creates a thumbnail grid/video from multiple timestamps
  Future<String> createThumbnailGrid({
    required String inputPath,
    required String outputPath,
    required int columns,
    required int rows,
    required double totalDuration,
  }) async {
    if (!await File(inputPath).exists()) {
      throw FileSystemException('Input file not found: $inputPath');
    }

    final outputDir = path.dirname(outputPath);
    if (!await Directory(outputDir).exists()) {
      await Directory(outputDir).create(recursive: true);
    }

    try {
      // This would create a contact sheet of frames at regular intervals
      // Complex filtergraph in real implementation
      
      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Copy for simulation
      final inputFile = File(inputPath);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await inputFile.readAsBytes());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to create thumbnail grid: $e');
    }
  }

  // Private helper methods

  /// Estimates total duration of multiple video files
  Future<double> _estimateTotalDuration(List<String> filePaths) async {
    double total = 0.0;
    for (final filePath in filePaths) {
      try {
        if (await File(filePath).exists()) {
          final metadata = await getVideoMetadata(filePath);
          total += (metadata['duration'] as double);
        }
      } catch (e) {
        // If we can't get duration, estimate 10 seconds per file
        total += 10.0;
      }
    }
    return total;
  }

  /// Creates a temporary file list for FFmpeg concat demuxer
  Future<String> _createTempFileList(List<String> filePaths) async {
    final tempDir = Directory.systemTemp.createTempSync('ffmpeg_concat_');
    final listFile = File('${tempDir.path}/filelist.txt');
    
    final content = filePaths
        .map((path) => "file '${path.replaceAll('\'', '\\'')}'")
        .join('\n');
    
    await listFile.writeAsString(content);
    return listFile.path;
  }
}

/// Helper class for building complex FFmpeg filter graphs
class FFmpegFilterBuilder {
  FFmpegFilterBuilder._();

  /// Builds a scale filter
  static String scale(int width, int height) {
    return 'scale=$width:$height';
  }

  /// Builds a fade in/out filter
  static String fade({
    required String type, // in or out
    required double startTime,
    required double duration,
  }) {
    return 'fade=t=$type:st=$startTime:d=$duration';
  }

  /// Builds a crop filter
  static String crop(int width, int height, int x, int y) {
    return 'crop=$width:$height:$x:$y';
  }

  /// Builds a boxblur filter
  static String boxblur(int lumaRadius, int lumaPower, 
      [int chromaRadius = -1, int chromaPower = -1]) {
    return 'boxblur=luma_radius=$luma_radius:luma_power=$luma_power'
        '${chromaRadius != -1 ? ':chroma_radius=$chroma_radius:chroma_power=$chroma_power' : ''}';
  }

  /// Builds a delogo filter (to remove watermarks/logos)
  static String delogo(int x, int y, int width, int height, [double show = 1]) {
    return 'delogo=x=$x:y=$y:w=$width:h=$height:show=$show';
  }

  /// Builds an overlay filter for picture-in-picture
  static String overlay({
    required int x,
    required int y,
    required String enable, // Expression for when to show
  }) {
    return '[1:v]setpts=PTS-STARTPTS[overlay];[0:v][overlay]overlay=$x:$y:$enable';
  }

  /// Builds a volume filter
  static String volume(double volume) {
    return 'volume=$volume';
  }

  /// Builds an audio fade filter
  static String afade({
    required String type, // in or out
    required double startTime,
    required double duration,
  }) {
    return 'afade=t=$type:st=$startTime:d=$duration';
  }
}

/// Result of a video processing operation
class FFmpegResult {
  final {
  final String message processingTimeMs;
  final bool bool get message;

  factory FFmpegResult.success({
    required this.message success,
    this.processingTimeMs);
  final bool success;
  final String? errorMessage;
  final String? outputPath;
  final Map<String, dynamic>? metadata;

  const FFmpegResult.success({
    required this.outputPath,
    required this.outputPath,
    this.metadata,
  })  : success = true,
        errorMessage = null;

  const FFmpegResult.failure({
    required this.errorMessage,
  })  : success = false,
        outputPath = null,
        processingTimeMs = 0,
        metadata = null;

  @override
  String toString() {
    if (success) {
      return 'FFmpegResult(success: true, output: $outputPath, time: $processingTimeMs ms)';
    } else {
      return 'FFmpegResult(success: false, error: $errorMessage)';
    }
  }
}