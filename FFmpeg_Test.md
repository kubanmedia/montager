# FFmpeg Integration Testing Guide

This document outlines how to test and verify the FFmpeg integration used by the Together AI provider in Montager.

## 🔧 FFmpeg Dependencies

The Together AI provider relies on two FFmpeg tools:
1. **ffmpeg** - For video processing and frame extraction
2. **ffprobe** - For querying video metadata (duration, resolution, etc.)

Both tools must be installed and accessible in the system PATH.

## ✅ Verifying FFmpeg Installation

Run these commands to verify FFmpeg is properly installed:

```bash
# Check FFmpeg version
ffmpeg -version
# Should output something like:
# ffmpeg version 6.0 Copyright (c) 2000-2023 the FFmpeg developers
# built with gcc 11.2.0 (Ubuntu 11.2.0-19ubuntu1)

# Check ffprobe version
ffprobe -version
# Should output version information

# Verify both are in PATH
which ffmpeg
# Should return: /usr/bin/ffmpeg (or similar path)
which ffprobe
# Should return: /usr/bin/ffprobe (or similar path)
```

## 🧪 Testing Frame Extraction

The `_extractFrames` method in `TogetherProvider` uses FFmpeg to extract frames. Here's how to test it manually:

### Basic Frame Extraction Test:
```bash
# Extract a single frame at 5 seconds into the video
ffmpeg -i input.mp4 -ss 00:00:05 -vframes 1 -q:v 2 output_frame.jpg

# Extract multiple frames every 3 seconds
ffmpeg -i input.mp4 -vf fps=1/3 -q:v 2 frame_%03d.jpg

# Extract frames at specific timestamps
ffmpeg -i input.mp4 -ss 00:00:05 -vframes 1 frame_at_5s.jpg
ffmpeg -i input.mp4 -ss 00:00:10 -vframes 1 frame_at_10s.jpg
ffmpeg -i input.mp4 -ss 00:00:15 -vframes 1 frame_at_15s.jpg
```

### Parameters Used by Montager:
The Together AI provider uses these FFmpeg parameters for frame extraction:
```bash
# For duration probing
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4

# For frame extraction (per frame)
ffmpeg -y -ss [timestamp] -i input.mp4 -frames:v 1 -q:v 4 -vf "scale=720:-1" output.jpg
```

Where:
- `-y` : Overwrite output files without asking
- `-ss [timestamp]` : Seek to position (in seconds)
- `-i input.mp4` : Input video file
- `-frames:v 1` : Extract 1 video frame
- `-q:v 4` : Quality setting (2-31, lower=better quality)
- `-vf "scale=720:-1"` : Scale width to 720px, maintain aspect ratio
- `output.jpg` : Output file

## 📱 Testing Within Montager Context

To test the FFmpeg integration as used by Montager:

1. **Ensure a test video file is available** (MP4 format recommended)
2. **Verify FFmpeg tools are accessible** (as shown above)
3. **Test the duration probing function**:
   ```dart
   // This is what _probeDurationSeconds does:
   final result = await Process.run('ffprobe', [
     '-v', 'error',
     '-show_entries', 'format=duration',
     '-of', 'default=noprint_wrappers=1:nokey=1',
     'test_video.mp4',
   ]);
   // result.stdout should contain the duration in seconds
   ```

4. **Test single frame extraction** (fallback method):
   ```dart
   // This is what _fallbackSingleFrame does:
   final ok = await Process.run('ffmpeg', [
     '-y',
     '-i', 'test_video.mp4',
     '-vf', 'select=eq(n\\,0),scale=720:-1',
     '-frames:v', '1',
     '-q:v', '4',
     'output_frame.jpg',
   ]).timeout(const Duration(seconds: 30));
   // ok should be true if successful
   ```

5. **Test multi-frame extraction** (primary method):
   ```dart
   // This simulates what _extractFrames does:
   // 1. Get duration
   // 2. Calculate frame intervals (every 5 seconds, max 8 frames)
   // 3. Extract frames at those intervals
   
   final duration = 25.0; // example: 25 second video
   final frameCount = (duration / 5).floor().clamp(1, 8); // 5 frames
   final step = duration / (frameCount + 1); // ~4.16 seconds between frames
   
   // Extract frames at: 4.16s, 8.32s, 12.48s, 16.64s, 20.80s
   for (var i = 1; i <= frameCount; i++) {
     final t = step * i;
     await Process.run('ffmpeg', [
       '-y',
       '-ss', t.toStringAsFixed(2),
       '-i', 'test_video.mp4',
       '-frames:v', '1',
       '-q:v', '4',
       '-vf', 'scale=720:-1',
       'frame_$i.jpg',
     ]);
   }
   ```

## ⚠️ Common Issues and Solutions

### 1. "ffmpeg: command not found" or "ffprobe: command not found"
- **Solution**: Install FFmpeg
  - Ubuntu/Debian: `sudo apt-get install ffmpeg`
  - macOS: `brew install ffmpeg`
  - Windows: Download from https://ffmpeg.org/download.html
  - Or use static builds: https://johnvansickle.com/ffmpeg/

### 2. "Unknown encoder 'libx264'" or codec errors
- **Solution**: Your FFmpeg build may be missing certain codecs
- Try installing a full FFmpeg build or using static binaries

### 3. Permission denied when accessing video files
- **Solution**: Ensure the application has read permissions to the video files
- On Android: Verify `READ_EXTERNAL_STORAGE` permission is granted
- On iOS: Verify file access permissions are properly configured

### 4. "Resource temporarily unavailable" or timeout errors
- **Solution**: 
  - Check if another process is using FFmpeg
  - Increase timeout values in the provider
  - Verify system has sufficient resources (RAM, CPU)

### 5. "No such file or directory" for input video
- **Solution**: 
  - Verify the video file path is correct
  - Check that the file actually exists at that path
  - Ensure proper file path encoding (especially for special characters)

## 📊 Performance Considerations

### Frame Extraction Speed:
- Depends on video resolution, codec, and storage speed
- Typical performance: 1-3 seconds per 720p frame on modern hardware
- The provider extracts max 8 frames, so ~8-24 seconds for analysis

### Optimization Tips:
1. **Use hardware acceleration** if available:
   ```bash
   # Add to FFmpeg args for hardware acceleration (when available)
   -hwaccel auto -hwaccel_output_format cuda
   ```

2. **Reduce frame resolution** for faster processing:
   - The provider already scales to 720px width
   - Could be made configurable for lower-end devices

3. **Cache results** for frequently analyzed videos:
   - Could store analysis results with video file hashes
   - Avoid re-analyzing unchanged videos

## 🎯 Testing Strategy for Montager Development

### Unit Tests:
1. Test `_probeDurationSeconds` with various video files
2. Test `_fallbackSingleFrame` with known good/bad inputs
3. Test `_runFfmpeg` with valid/invalid FFmpeg commands
4. Test timeout handling in `_runFfmpeg`

### Integration Tests:
1. Test full `_extractFrames` flow with sample videos
2. Test error cases (missing files, unsupported formats)
3. Test performance characteristics with different video lengths/resolutions

### Manual Testing:
1. Use known good test videos (various formats, lengths, resolutions)
2. Verify extracted frames are valid images
3. Check that frame timestamps are accurate
4. Validate that the right number of frames are extracted

## 📱 Platform-Specific Notes

### Android:
- FFmpeg must be bundled with the app or installed separately
- Consider using `flutter_ffmpeg` package for easier integration
- Ensure proper permissions for video file access

### iOS:
- FFmpeg must be bundled with the app (no system FFmpeg)
- App Store guidelines may restrict certain FFmpeg functionalities
- Consider using `mobile-ffmpeg` or similar iOS-friendly builds

### Web:
- FFmpeg not available in browsers
- Would need to use WebAssembly FFmpeg ports or server-side processing
- Currently, the web implementation would fall back to simulation

### Desktop (Windows/macOS/Linux):
- FFmpeg typically available via package managers
- Static builds work well for distribution
- Easiest platform for FFmpeg integration

## ✅ Success Criteria

When FFmpeg integration is working correctly in Montager, you should see:

1. **Video Analysis Succeeds**: 
   - No FFmpeg-related errors in logs
   - Frame extraction completes within timeout
   - Valid base64-encoded frame data is produced

2. **Accurate Timing**:
   - Extracted frames correspond to correct timestamps
   - Frame count matches expectations based on video duration

3. **Proper Error Handling**:
   - Graceful degradation when FFmpeg unavailable
   - Clear error messages for users
   - Fallback to single-frame extraction when needed

4. **Resource Cleanup**:
   - Temporary frame files are properly deleted
   - No memory leaks or file handle leaks
   - FFmpeg processes are properly terminated

With FFmpeg properly integrated and tested, the Together AI provider in Montager can perform accurate video analysis that forms the foundation for intelligent video editing.