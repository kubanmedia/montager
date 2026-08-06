import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/video/video_processing_service.dart';
import '../services/ai/providers/ai_provider.dart';
import '../services/ai/providers/ai_provider.dart' show AIProviderFactory;
import '../services/security/api_key_manager.dart';

// Provider for the API key manager
final apiKeyManagerProvider = Provider<ApiKeyManager>((ref) {
  return ApiKeyManager();
});

// Provider for getting a configured AI provider based on stored credentials
final configuredAiProviderProvider = FutureProvider.family<AIProvider?, String>(
  (ref, providerName) async {
    final apiKeyManager = ref.watch(apiKeyManagerProvider);
    
    // Map provider names to storage keys
    String storageKey;
    switch (providerName.toLowerCase()) {
      case 'ollama cloud':
      case 'ollamcloud':
        storageKey = 'ollama_cloud';
        break;
      case 'together ai':
      case 'togetherai':
      case 'together':
        storageKey = 'together_ai';
        break;
      default:
        return null; // Unsupported provider
    }
    
    // Check if we have an API key stored
    final hasApiKey = await apiKeyManager.hasApiKey(storageKey);
    if (!hasApiKey) {
      return null; // No API key configured
    }
    
    // Get the API key
    final apiKey = await apiKeyManager.getApiKey(storageKey);
    if (apiKey == null) {
      return null;
    }
    
    try {
      // Create the AI provider using our factory
      final aiProvider = AIProviderFactory.createProvider(
        providerName,
        {
          'apiKey': apiKey,
        },
      );
      
      return aiProvider;
    } catch (e) {
      return null; // Failed to create provider
    }
  },
);

// Provider for the video processing service that uses the configured AI provider
final videoProcessingServiceProvider = FutureProvider.family<VideoProcessingService?, String>(
  (ref, providerName) async {
    final aiProvider = await ref.watch(configuredAiProviderProvider(providerName).future);
    
    if (aiProvider == null) {
      return null; // No AI provider configured or failed to create
    }
    
    return VideoProcessingService(
      aiProvider: aiProvider,
    );
  },
);

// Provider for getting all available AI providers that have credentials configured
final configuredProvidersProvider = FutureProvider<List<String>>((ref) async {
  final apiKeyManager = ref.watch(apiKeyManagerProvider);
  
  // Check which providers have API keys configured
  final configured = <String>[];
  
  // Check Ollama Cloud
  final hasOllamaKey = await apiKeyManager.hasApiKey('ollama_cloud');
  if (hasOllamaKey) {
    configured.add('Ollama Cloud');
  }
  
  // Check Together AI
  final hasTogetherKey = await apiKeyManager.hasApiKey('together_ai');
  if (hasTogetherKey) {
    configured.add('Together AI');
  }
  
  return configured;
});

// Notifier for managing API keys
class ApiKeyManagerNotifier extends StateNotifier<Map<String, bool>> {
  final ApiKeyManager _apiKeyManager;
  
  ApiKeyManagerNotifier(this._apiKeyManager) : super({}) {
    _loadInitialState();
  }
  
  Future<void> _loadInitialState() async {
    final providers = ['ollama_cloud', 'together_ai'];
    final status = <String, bool>{};
    
    for (final provider in providers) {
      final hasKey = await _apiKeyManager.hasApiKey(provider);
      status[provider] = hasKey;
    }
    
    state = status;
  }
  
  Future<void> storeApiKey(String provider, String apiKey) async {
    await _apiKeyManager.storeApiKey(provider, apiKey);
    await _loadInitialState();
  }
  
  Future<bool> updateApiKey(String provider, String apiKey) async {
    final result = await _apiKeyManager.updateApiKey(provider, apiKey);
    if (result) {
      await _loadInitialState();
    }
    return result;
  }
  
  Future<void> deleteApiKey(String provider) async {
    await _apiKeyManager.deleteApiKey(provider);
    await _loadInitialState();
  }
  
  Future<String?> getApiKey(String provider) async {
    return await _apiKeyManager.getApiKey(provider);
  }
  
  Future<bool> hasApiKey(String provider) async {
    return await _apiKeyManager.hasApiKey(provider);
  }
}

// Provider for the API key notifier
final apiKeyManagerNotifierProvider =
    StateNotifierProvider<ApiKeyManagerNotifier, Map<String, bool>>((ref) {
  final apiKeyManager = ref.watch(apiKeyManagerProvider);
  return ApiKeyManagerNotifier(apiKeyManager);
});