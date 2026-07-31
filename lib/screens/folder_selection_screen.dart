import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../services/video/video_processing_service.dart';
import '../widgets/ai_provider_selector.dart';
import 'project_setup_screen.dart';

class FolderSelectionScreen extends ConsumerStatefulWidget {
  const FolderSelectionScreen({super.key});

  @override
  ConsumerState<FolderSelectionScreen> createState() => _FolderSelectionScreenState();
}

class _FolderSelectionScreenState extends ConsumerState<FolderSelectionScreen> {
  String? _selectedFolderPath;
  int _videoCount = 0;
  Duration _totalDuration = Duration.zero;
  bool _isScanning = false;

  Future<void> _selectFolder() async {
    setState(() => _isScanning = true);
    
    try {
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      
      if (directoryPath != null && directoryPath.isNotEmpty) {
        setState(() {
          _selectedFolderPath = directoryPath;
          _isScanning = false;
        });
        
        // Scan for videos and count them
        await _scanVideos(directoryPath);
      } else {
        setState(() => _isScanning = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No folder selected')),
          );
        }
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting folder: $e')),
        );
      }
    }
  }

  Future<void> _scanVideos(String directoryPath) async {
    try {
      final videoExtensions = {
        '.mp4', '.mov', '.avi', '.mkv', '.webm', '.mpeg', '.hevc', '.h264'
      };

      int count = 0;
      Duration totalDuration = Duration.zero;
      
      // In a real implementation, we would get actual durations
      // For now, we'll estimate based on file count
      await for (final entity 
          in Directory(directoryPath).listRecursively(followLinks: false)) {
        if (entity is File) {
          final extension = 
              extension(entity.path.toLowerCase()).toLowerCase();
          if (videoExtensions.contains(extension)) {
            count++;
            // Estimate duration - in reality we'd get this from metadata
            // For demo purposes, assume average 30 seconds per video
            totalDuration += const Duration(seconds: 30);
          }
        }
      }

      if (mounted) {
        setState(() {
          _videoCount = count;
          _totalDuration = totalDuration;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning videos: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Video Folder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _selectedFolderPath == null && !_isScanning
          ? _buildEmptyState()
          : _isScanning
              ? _buildScanningState()
              : _buildFolderSelectedState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No folder selected',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select a folder containing your videos to begin',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _selectFolder,
            icon: const Icon(Icons.folder_open),
            label: const Text('Select Video Folder'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text(
            'Scanning for videos...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSelectedState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Folder info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFolderPath!.length > 50
                              ? '...${_selectedFolderPath!.substring(_selectedFolderPath!.length - 50)}'
                              : _selectedFolderPath!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Videos Found',
                        '$_videoCount',
                        Icons.video_collection,
                      ),
                      _buildStatColumn(
                        'Est. Duration',
                        _formatDuration(_totalDuration),
                        Icons.timer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // AI Provider Selection
          const AIProviderSelector(),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _selectFolder,
                  child: const Text('Choose Different Folder'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _videoCount > 0 ? _proceedToProjectSetup : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue to Setup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _proceedToProjectSetup() async {
    if (_selectedFolderPath == null || _videoCount == 0) return;
    
    if (!mounted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectSetupScreen(
          folderPath: _selectedFolderPath!,
          videoCount: _videoCount,
          totalDuration: _totalDuration,
        ),
      ),
    );
  }
}