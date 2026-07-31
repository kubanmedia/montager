import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends ConsumerStatefulWidget {
  final String videoPath;
  final String> final String videoPath;
>  
  const VideoPreviewScreen({
    super.key,
    required this.videoPath,
    required this.editPlan,
  });

  @override
  ConsumerState<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends ConsumerState<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(
      // In a real app, we'd use the actual file path
      // For now, we'll use a placeholder or network video for demo
      VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      )..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized
          setState(() {
            _isInitialized = true;
          });
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _controller.setVolume(_isMuted ? 0.0 : _volume);
  }

  void _setVolume(double volume) {
    setState(() => _volume = volume);
    if (!_isMuted) {
      _controller.setVolume(volume);
    }
  }

  void _reprocess() {
    // TODO: Navigate back to project setup with current settings
  }

  void _exportVideo() {
    // TODO: Implement sharing/export functionality
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options menu
            },
          ),
        ],
      ),
      body: _isInitialized
          ? Column(
              children: [
                // Video player
                Expanded(
                  flex: 4,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                
                // Video controls
                Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      Slider(
                        value: _controller.value.position.inMilliseconds.toDouble(),
                        min: 0,
                        max: _controller.value.duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          _controller.seekTo(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle,
                              size: 36,
                            ),
                            onPressed: _togglePlay,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              size: 28,
                            ),
                            onPressed: _toggleMute,
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: Slider(
                              value: _volume,
                              min: 0,
                              max: 1,
                              onChanged: _setVolume,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Video info and actions
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.editPlan['suggestedTitle'] ?? 'AI Generated Video'}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _reprocess,
                            tooltip: 'Reprocess with same settings',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_formatDuration(Duration(seconds: (double.tryParse(widget.editPlan['totalDuration']?.toString() ?? '0'))?.toInt() ?? 0))} • '
                        '${widget.editPlan['recommendedMusic'] ?? 'Default Music'} • '
                        '${widget.editPlan['suggestedNarraton']?.isNotEmpty == true ? 'With Narration' : 'No Narration'}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.Center,
                      ),
                    ],
                  ),
                ),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _reprocess,
                          child: const Text('Reprocess'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _exportVideo,
                          child: const Text('Export Video'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}