import 'package:flutter/foundation.dart';
import '../services/ai/providers/ai_provider.dart';
import '../services/video/video_processing_service.dart';

/// Example showing how to use the video processing service
class VideoProcessingExample {
  /// Example 1: Using OpenAI GPT-4V for video processing
  static Future<void> exampleOpenAIProcessing() async {
    // Initialize AI provider
    final aiProvider = AIProviderFactory.createProvider(
      'OpenAI',
      {
        'apiKey': 'your-openai-api-key-here',
        'model': 'gpt-4-vision-preview',
      },
    );

    // Create video processing service
    final videoService = VideoProcessingServiceFactory.createService(
      aiProviderType: 'OpenAI',
      aiConfig: {
        'apiKey': 'your-openai-api-key-here',
        'model': 'gpt-4-vision-preview',
      },
    );

    try {
      // Process a folder of videos
      final outputPath = await videoService.processVideoFolder(
        folderPath: '/path/to/your/videos',
        userPrompt: 'Create an exciting highlights reel of the best moments',
        outputPath: '/path/to/output/highlights.mp4',
        targetDuration: 60.0, // 60 seconds
      );

      if (kDebugMode) {
        print('Video processing completed: $outputPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Video processing failed: $e');
      }
    } finally {
      // Clean up resources
      await videoService.dispose();
      await aiProvider.dispose();
    }
  }

  /// Example 2: Using local Ollama for privacy-focused processing
  static Future<void> exampleOllamaProcessing() async {
    // Initialize Ollama provider (running locally)
    final aiProvider = AIProviderFactory.createProvider(
      'Ollama (Local)',
      {
        'baseUrl': 'http://localhost:11434',
        'modelName': 'llava', // Multimodal model for video understanding
      },
    );

    // Create video processing service
    final videoService = VideoProcessingServiceFactory.createService(
      aiProviderType: 'Ollama (Local)',
      aiConfig: {
        'baseUrl': 'http://localhost:11434',
        'modelName': 'llava',
      },
    );

    try {
      // Process videos with local AI (no data leaves device)
      final outputPath = await videoService.processVideoFolder(
        folderPath: '/path/to/your/videos',
        userPrompt: 'Make a calm, peaceful video montage',
        outputPath: '/path/to/output/peaceful_montage.mp4',
        targetDuration: 45.0,
      );

      if (kDebugMode) {
        print('Local video processing completed: $outputPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Local video processing failed: $e');
      }
    } finally {
      // Clean up resources
      await videoService.dispose();
      await aiProvider.dispose();
    }
  }

  /// Example 3: Using Hugging Face for open-source model processing
  static Future<void> exampleHuggingFaceProcessing() async {
    // Initialize Hugging Face provider
    final aiProvider = AIProviderFactory.createProvider(
      'Hugging Face',
      {
        'apiKey': 'your-huggingface-api-token',
        // Optional: specify specific model endpoint
        // 'apiUrl': 'https://api-inference.huggingface.co/models/google/vit-base-patch16-224',
      },
    );

    // Create video processing service
    final videoService = VideoProcessingServiceFactory.createService(
      aiProviderType: 'Hugging Face',
      aiConfig: {
        'apiKey': 'your-huggingface-api-token',
      },
    );

    try {
      // Process videos using open-source models
      final outputPath = await videoService.processVideoFolder(
        folderPath: '/path/to/your/videos',
        userPrompt: 'Create a professional business presentation',
        outputPath: '/path/to/output/business_presentation.mp4',
        targetDuration: 90.0,
      );

      if (kDebugMode) {
        print('HF video processing completed: $outputPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('HF video processing failed: $e');
      }
    } finally {
      // Clean up resources
      await videoService.dispose();
      await aiProvider.dispose();
    }
  }
}