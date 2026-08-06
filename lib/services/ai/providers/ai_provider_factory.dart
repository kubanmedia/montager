import 'package:montager/services/database/video_database.dart';
import 'ai_provider.dart';
import 'together_provider.dart';

/// Factory for creating AI provider instances
class AIProviderFactory {
  /// Creates an AI provider instance based on the provider name and configuration
  static AIProvider createProvider(String providerName, Map<String, String> config) {
    switch (providerName.toLowerCase()) {
      case 'ollama cloud':
      case 'ollamcloud':
        // For Ollama, we would implement a specific OllamaProvider
        // For now, fall back to Together as placeholder or throw unsupported
        throw UnimplementedError('Ollama provider not yet implemented. Using Together as fallback.');
        
      case 'together ai':
      case 'togetherai':
      case 'together':
        return TogetherProvider(
          apiKey: config['apiKey'] ?? '',
          textModel: config['textModel'],
          visionModel: config['visionModel'],
        );
        
      default:
        throw ArgumentError('Unknown AI provider: $providerName');
    }
  }
  
  /// Gets a list of supported provider names
  static List<String> getSupportedProviders() {
    return [
      'Ollama Cloud',
      'Together AI',
    ];
  }
  
  /// Checks if a provider name is supported
  static bool isProviderSupported(String providerName) {
    return getSupportedProviders()
        .any((p) => p.toLowerCase() == providerName.toLowerCase());
  }
}