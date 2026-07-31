import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/video/video_processing_service.dart';
import '../services/ai/providers/ai_provider.dart';
import '../services/ai/providers/ai_provider.dart' show AIProviderFactory;

// Provider for the AI provider - this would typically be configured based on user settings
final aiProviderProvider = Provider<AIProvider>((ref) {
  // In a real app, this would come from user preferences
  // For now, we'll return a mock provider or throw if not configured
  throw UnimplementedError('AI provider not configured. Please set up AI provider in settings.');
});

// Provider for the video processing service
final videoProcessingServiceProvider = Provider<VideoProcessingService>((ref) {
  final aiProvider = ref.watch(aiProviderProvider);
  // In a real app, we would get the configured provider from settings
  // For now, we'll return a placeholder or handle the error gracefully
  return VideoProcessingService(
    aiProvider: aiProvider,
  );
});

// Helper provider to get a configured AI provider based on settings
final configuredAiProviderProvider = Provider.family<AIProvider, Map<String, dynamic>>(
  (ref, settings) {
    final providerType = settings['providerType'] as String;
    final config = Map<String, dynamic>.from(settings['config'] as Map);
    return AIProviderFactory.createProvider(providerType, config);
  },
);

// Helper provider to get a video processing service with specific settings
final videoProcessingServiceWithSettingsProvider = Provider.family<VideoProcessingService, Map<String, dynamic>>(
  (ref, settings) {
    final providerType = settings['providerType'] as String;
    final config = Map<String, dynamic>.from(settings['config'] as Map);
    final aiProvider = AIProviderFactory.createProvider(providerType, config);
    return VideoProcessingService(
      aiProvider: aiProvider,
    );
  },
);