import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/video/video_processing_service.dart';
import 'video_preview_screen.dart';

class AIProcessingScreen extends ConsumerStatefulWidget {
  final String folderPath;
  final String prompt;
  final String provider;
  final double videoLength;

  const AIProcessingScreen({
    super.key,
    required this.folderPath,
    required this.prompt,
    required this.provider,
    required this.videoLength,
  });

  @override
  ConsumerState<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends ConsumerState<AIProcessingScreen> {
  bool _isProcessing = false;
  double _progress = 0.0;
  String _currentStep = 'Initializing...';
  List<String> _steps = [];
  String? _errorMessage;
  String? _outputPath;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    setState(() {
      _isProcessing = true;
      _steps = [
        'Scanning video files...',
        'Analyzing video content with AI...',
        'Generating editing plan...',
        'Rendering video...',
        'Finalizing output...'
      ];
    });

    try {
      // Get the video processing service
      final videoService = ref.read(videoProcessingServiceProvider);
      
      // Update progress as we go through steps
      await _updateProgress(0.1, 'Scanning video files...');
      
      // In a real implementation, we would call the video processing service
      // For demo purposes, we'll simulate the process
      
      await _updateProgress(0.3, 'Analyzing video content with AI...');
      await _updateProgress(0.5, 'Generating editing plan...');
      await _updateProgress(0.7, 'Rendering video...');
      await _updateProgress(0.9, 'Finalizing output...');
      
      // Simulate completion
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      setState(() {
        _isProcessing = false;
        _progress = 1.0;
        _currentStep = 'Processing complete!';
        // In a real app, this would be the actual output path
        _outputPath = '/storage/emulated/0/Download/AI_Video_Editor/output.mp4';
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video processing completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Processing failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProgress(double progress, String step) async {
    if (!mounted) return;
    
    setState(() {
      _progress = progress;
      _currentStep = step;
      
      // Update step completion status
      final stepIndex = _steps.indexWhere((s) => s.startsWith(step.split('...')[0]));
      if (stepIndex != -1 && !_steps[stepIndex].endsWith('✓')) {
        _steps[stepIndex] = '$step✓';
      }
    });
    
    // Small delay to make progress visible
    await Future.delayed(const Duration(milliseconds: 800));
  }

  void _viewOutput() {
    if (_outputPath != null) {
      // TODO: Implement video playback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video playback coming soon!')),
      );
    }
  }

  void _reprocess() {
    if (!mounted) return;
    
    Navigator.of(context).pop();
  }

  void _exportVideo() {
    if (_outputPath != null) {
      // TODO: Implement sharing/export functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export functionality coming soon!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Processing'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
        ),
        actions: _isProcessing
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: _reprocess,
                  tooltip: 'Reprocess with same settings',
                ),
              ],
      ),
      body: _isProcessing
          ? _buildProcessingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _outputPath != null
                  ? _buildSuccessState()
                  : _buildIdleState(),
    );
  }

  Widget _buildProcessingState() {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              FractionallySizedBox(
                widthFactor: _progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Current step
        Text(
          _currentStep,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.Center,
        ),
        const SizedBox(height: 24),
        // Steps list
        Expanded(
          child: ListView.builder(
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final isCompleted = _steps[index].endsWith('✓');
              final stepText = _steps[index].replaceAll('✓', '');
              
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        stepText,
                        style: TextStyle(
                          color: isCompleted
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Failed',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.Center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _reprocess,
            icon: const Icon(Icons.replay),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.success,
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your video has been successfully processed and is ready for viewing.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.Center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _viewOutput,
                icon: const Icon(Icons.play_circle),
                label: const Text('View Video'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: _reprocess,
                child: const Text('Create Another'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Ready to process',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}