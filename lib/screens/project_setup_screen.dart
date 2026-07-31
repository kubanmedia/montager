import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ai_provider_selector.dart';
import '../widgets/output_settings.dart';
import 'ai_processing_screen.dart';

class ProjectSetupScreen extends ConsumerStatefulWidget {
  final String folderPath;
  final int videoCount;
  final Duration totalDuration;

  const ProjectSetupScreen({
    super.key,
    required this.folderPath,
    required this.videoCount,
    required this.totalDuration,
  });

  @override
  ConsumerState<ProjectSetupScreen> createState() => _ProjectSetupScreenState();
}

class _ProjectSetupScreenState extends ConsumerState<ProjectSetupScreen> {
  final _promptController = TextEditingController();
  String _selectedProvider = 'Cloud AI';
  double _videoLength = 60.0; // seconds
  bool _isProcessing = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _startProcessing() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description of your desired video')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      // In a real implementation, we would:
      // 1. Save project settings to temporary storage
      // 2. Initialize the video processing service with selected provider
      // 3. Start the processing pipeline
      
      // For now, we'll simulate navigation to processing screen
      if (!mounted) return;
      
      // TODO: Uncomment when AI processing screen is fully implemented
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (_) => AIProcessingScreen(
      //       folderPath: widget.folderPath,
      //       prompt: _promptController.text,
      //       provider: _selectedProvider,
      //       videoLength: _videoLength,
      //     ),
      //   ),
      // );
      
      // For now, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing started! (Feature coming soon)')),
      );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting processing: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              Icons.folder,
              'Source Folder',
              widget.folderPath.length > 40
                  ? '...${widget.folderPath.substring(widget.folderPath.length - 40)}'
                  : widget.folderPath,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.video_collection,
              'Video Count',
              '${widget.videoCount} videos',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.timer,
              'Total Duration',
              '${widget.totalDuration.inMinutes} minutes',
            ),
            const SizedBox(height: 24),
            
            Text(
              'Describe your video',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What kind of video would you like to create?',
                hintText: 'e.g., "Create an exciting sports highlights reel"',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'AI Provider',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const AIProviderSelector(),
            
            const SizedBox(height: 24),
            
            Text(
              'Output Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const OutputSettings(),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _startProcessing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Start AI Processing'),
              ),
            ),
            
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Folder Selection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}