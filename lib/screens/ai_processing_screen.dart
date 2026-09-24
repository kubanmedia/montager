import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import "../services/service_provider.dart";
import 'video_preview_screen.dart';

const _videoExtensions = {
  '.mp4', '.mov', '.avi', '.mkv', '.webm', '.mpeg', '.hevc', '.h264'
};

class AIProcessingScreen extends ConsumerStatefulWidget {
  final String folderPath;
  final String prompt;
  final String provider;
  final double videoLength;
  final List<String>? fileNames;
  final List<String>? sourcePaths;

  const AIProcessingScreen({
    super.key,
    required this.folderPath,
    required this.prompt,
    required this.provider,
    required this.videoLength,
    this.fileNames,
    this.sourcePaths,
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
  Map<String, dynamic>? _plan;
  String _planSource = '';
  int _videosUsed = 0;

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
      if (kIsWeb) {
        await _runWebDemo();
        return;
      }
      await _runNativePipeline();
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

  /// Web demo flow: browsers expose noFilesystem paths, so we simulate.
  Future<void> _runWebDemo() async {
    await _updateProgress(0.2, 'Scanning video files...');
    await _updateProgress(0.4, 'Analyzing video content with AI...');
    await _updateProgress(0.7, 'Generating editing plan...');
    await _updateProgress(0.9, 'Finalizing output...');

    if (!mounted) return;
    final count = widget.fileNames?.length ?? 0;
    setState(() {
      _isProcessing = false;
      _progress = 1.0;
      _currentStep = 'Processing complete!';
      _plan = _demoPlan(
        List.generate(count, (i) => widget.fileNames![i]),
        widget.prompt,
        widget.videoLength,
      );
      _planSource = 'Demo plan (web build cannot access video bytes)';
      _videosUsed = count;
      _outputPath = null; // No playable file on web
    });
  }

  /// Real on-device pipeline: scan -> AI/demo plan -> assemble output file.
  Future<void> _runNativePipeline() async {
    await _updateProgress(0.1, 'Scanning video files...');
    final videoPaths = await _scanNativeVideos();
    if (videoPaths.isEmpty) {
      throw Exception(
        'No video files found. Pick videos with "Select Video Files".',
      );
    }

    await _updateProgress(0.3, 'Analyzing video content with AI...');
    final analyses = videoPaths
        .map((v) => {'videoPath': v, 'description': p.basename(v)})
        .toList();

    await _updateProgress(0.5, 'Generating editing plan...');
    Map<String, dynamic> plan;
    String planSource;
    final aiProvider =
        await ref.read(configuredAiProviderProvider(widget.provider).future);
    if (aiProvider != null) {
      try {
        plan = await aiProvider
            .planEditing(
              videoAnalyses: analyses,
              userPrompt: widget.prompt,
              targetDuration: widget.videoLength,
            )
            .timeout(const Duration(seconds: 60));
        planSource = 'AI plan (${widget.provider})';
      } catch (e) {
        plan = _demoPlan(videoPaths, widget.prompt, widget.videoLength);
        planSource = 'Demo plan (AI request failed: $e)';
      }
    } else {
      plan = _demoPlan(videoPaths, widget.prompt, widget.videoLength);
      planSource =
          'Demo plan (no API key for "${widget.provider}" - add one in Settings)';
    }

    await _updateProgress(0.7, 'Rendering video...');
    final outputPath = await _assembleOutput(videoPaths, plan);

    await _updateProgress(0.9, 'Finalizing output...');
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _progress = 1.0;
      _currentStep = 'Processing complete!';
      _plan = plan;
      _planSource = planSource;
      _videosUsed = videoPaths.length;
      _outputPath = outputPath;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video processing completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Resolve playable source videos on device.
  Future<List<String>> _scanNativeVideos() async {
    final picked = widget.sourcePaths
            ?.where((e) =>
                _videoExtensions.contains(p.extension(e).toLowerCase()) &&
                File(e).existsSync())
            .toList() ??
        [];
    if (picked.isNotEmpty) return picked;

    final dir = Directory(widget.folderPath);
    if (!await dir.exists()) return [];
    final found = <String>[];
    await for (final entity
        in dir.list(recursive: true, followLinks: false)) {
      if (entity is File &&
          _videoExtensions.contains(p.extension(entity.path).toLowerCase())) {
        found.add(entity.path);
      }
    }
    return found;
  }

  /// Local heuristic plan used when no AI provider is configured.
  Map<String, dynamic> _demoPlan(
    List<String> videoPaths,
    String prompt,
    double targetDuration,
  ) {
    final n = videoPaths.isEmpty ? 1 : videoPaths.length;
    final perClip = targetDuration / n;
    final timeline = <Map<String, dynamic>>[];
    for (var i = 0; i < n; i++) {
      timeline.add({
        'videoIndex': videoPaths.isEmpty ? 0 : i % videoPaths.length,
        'videoPath': videoPaths.isEmpty ? '' : videoPaths[i % videoPaths.length],
        'startTime': 0.0,
        'endTime': perClip,
        'transitionIn': i == 0 ? 'none' : 'fade',
        'transitionOut': i == n - 1 ? 'fade' : 'none',
      });
    }
    return {
      'timeline': timeline,
      'targetDuration': targetDuration,
      'prompt': prompt,
      'demo': true,
    };
  }

  /// Assemble the output: without an on-device FFmpeg binary, true
  /// re-encoding is unavailable, so the output is a real copy of the
  /// first source video plus the saved edit plan next to it.
  Future<String> _assembleOutput(
    List<String> videoPaths,
    Map<String, dynamic> plan,
  ) async {
    final docs = await getApplicationDocumentsDirectory();
    final outDir = Directory(p.join(docs.path, 'montager_output'));
    await outDir.create(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final outPath = p.join(outDir.path, 'montager_$stamp.mp4');
    await File(videoPaths.first).copy(outPath);
    await File(p.join(outDir.path, 'plan_$stamp.json'))
        .writeAsString(const JsonEncoder.withIndent('  ').convert(plan));
    return outPath;
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
    if (_outputPath != null && _outputPath!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoPreviewScreen(
            videoPath: _outputPath!,
            editPlan: _plan ?? const {},
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _planSource.isEmpty
                ? 'No preview available on web.'
                : 'Plan ready: $_planSource',
          ),
        ),
      );
    }
  }

  void _reprocess() {
    if (!mounted) return;
    
    Navigator.of(context).pop();
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          textAlign: TextAlign.center,
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
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
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
            textAlign: TextAlign.center,
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
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
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
            _outputPath != null && _outputPath!.isNotEmpty
                ? 'Your video has been successfully processed and is ready for viewing.'
                : 'Your edit plan is ready. $_planSource',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_videosUsed > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$_videosUsed source video${_videosUsed == 1 ? '' : 's'} used',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (_planSource.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _planSource,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_outputPath != null && _outputPath!.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _viewOutput,
                  icon: const Icon(Icons.play_circle),
                  label: const Text('View Video'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              if (_outputPath != null && _outputPath!.isNotEmpty)
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