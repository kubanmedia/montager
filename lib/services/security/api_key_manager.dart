import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:montager/services/database/video_database.dart';

/// Secure API key manager using flutter_secure_storage
/// Provides encrypted storage for API keys using platform-specific secure storage:
/// - Android: Keystore
/// - iOS: Keychain
/// This satisfies the PRD requirement for secure credential management.
class ApiKeyManager {
  static const String _apiKeyPrefix = 'montager_api_key_';
  static const String _OllamaCloudKey = '${_apiKeyPrefix}ollama_cloud';
  static const String _TogetherAIKey = '${_apiKeyPrefix}together_ai';
  static const String _LastUsedProvider = '${_apiKeyPrefix}last_provider';
  
  final FlutterSecureStorage _storage;
  
  ApiKeyManager() : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

  /// Stores an API key for the specified provider
  /// Uses platform-specific secure storage (Keystore/Keychain)
  Future<void> storeApiKey(String provider, String apiKey) async {
    // Validate the API key before storing
    final isValid = await _validateApiKeyFormat(provider, apiKey);
    if (!isValid) {
      throw ArgumentError('Invalid API key format for provider: $provider');
    }
    
    final key = _getStorageKey(provider);
    await _storage.write(key: key, value: apiKey);
    
    // Also track which provider was last used
    await _storage.write(key: _LastUsedProvider, value: provider);
  }

  /// Retrieves the API key for the specified provider
  /// Returns null if no key is stored
  Future<String?> getApiKey(String provider) async {
    final key = _getStorageKey(provider);
    return await _storage.read(key: key);
  }

  /// Gets the most recently used provider
  /// Returns null if no provider has been used yet
  Future<String?> getLastUsedProvider() async {
    return await _storage.read(key: _LastUsedProvider);
  }

  /// Removes the API key for the specified provider
  Future<void> deleteApiKey(String provider) async {
    final key = _getStorageKey(provider);
    await _storage.delete(key: key);
  }

  /// Checks if an API key exists for the given provider
  Future<bool> hasApiKey(String provider) async {
    final key = _getStorageKey(provider);
    final value = await _storage.read(key: key);
    return value != null && value.isNotEmpty;
  }

  /// Clears all stored API keys
  Future<void> clearAllApiKeys() async {
    await _storage.deleteAll();
  }

  /// Gets all stored provider names
  Future<List<String>> getStoredProviders() async {
    // Since we don't have a way to list all keys in flutter_secure_storage,
    // we'll check our known providers
    final List<String> knownProviders = ['ollama_cloud', 'together_ai'];
    final List<String> storedProviders = [];
    
    for (final provider in knownProviders) {
      if (await hasApiKey(provider)) {
        storedProviders.add(provider);
      }
    }
    
    return storedProviders;
  }

  /// Validates API key format for the given provider
  /// Returns true if the key appears to be valid
  Future<bool> _validateApiKeyFormat(String provider, String apiKey) async {
    if (apiKey.isEmpty) return false;
    
    // Remove whitespace
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) return false;
    
    // Provider-specific validation
    switch (provider.toLowerCase()) {
      case 'ollama_cloud':
        // Ollama Cloud API keys typically don't have a specific prefix
        // but should be reasonably long
        return trimmedKey.length >= 16;
        
      case 'together_ai':
        // Together AI API keys typically start with certain patterns
        // Common formats: tkp-, tgp-, or similar
        if (trimmedKey.startsWith('tkp-') || 
            trimmedKey.startsWith('tgp-') ||
            trimmedKey.startsWith('tkr-')) {
          return trimmedKey.length >= 20;
        }
        // Also accept longer tokens that might be valid
        return trimmedKey.length >= 32;
        
      default:
        // For unknown providers, apply general validation
        return trimmedKey.length >= 16;
    }
  }

  /// Gets the storage key name for a provider
  String _getStorageKey(String provider) {
    return '${_apiKeyPrefix}${provider.toLowerCase()}';
  }

  /// Tests if the stored API key for a provider is valid
  /// Returns true if key exists and passes basic validation
  Future<bool> isApiKeyValid(String provider) async {
    final apiKey = await getApiKey(provider);
    if (apiKey == null) return false;
    
    return await _validateApiKeyFormat(provider, apiKey);
  }

  /// Gets headers for API requests with the stored key
  /// Returns null if no key is available
  Future<Map<String, String>?> getAuthHeaders(String provider) async {
    final apiKey = await getApiKey(provider);
    if (apiKey == null) return null;
    
    // Provider-specific header formats
    switch (provider.toLowerCase()) {
      case 'ollama_cloud':
        // Ollama typically uses Bearer token or no auth for local instances
        // For cloud instances, it might use API key in header
        return {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        };
        
      case 'together_ai':
        // Together API uses Bearer token authentication
        return {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        };
        
      default:
        // Generic bearer token approach
        return {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        };
    }
  }

  /// Securely updates an existing API key
  /// Returns true if update was successful
  Future<bool> updateApiKey(String provider, String newApiKey) async {
    try {
      // Validate before storing
      final isValid = await _validateApiKeyFormat(provider, newApiKey);
      if (!isValid) return false;
      
      // Store the new key
      await storeApiKey(provider, newApiKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Enum for supported AI providers in Montager
enum AiProvider {
  ollamaCloud,
  togetherAi,
  
  String get displayName {
    switch (this) {
      case AiProvider.ollamaCloud: return 'Ollama Cloud';
      case AiProvider.togetherAi: return 'Together AI';
    }
  }
  
  String get storageKey {
    switch (this) {
      case AiProvider.ollamaCloud: return 'ollama_cloud';
      case AiProvider.togetherAi: return 'together_ai';
    }
  }
  
  /// Gets the recommended model for video processing tasks
  String get recommendedModel {
    switch (this) {
      case AiProvider.ollamaCloud:
        // For Ollama, recommend a good multimodal model
        return 'llava:13b'; // Good balance of capability and size
      case AiProvider.togetherAi:
        // As specified in instructions: PrismML Ternary Bonsai 27B (free)
        return 'PrismML/Ternary-Bonsay-27B-v1';
    }
  }
  
  /// Gets the base URL for the provider's API
  String get baseUrl {
    switch (this) {
      case AiProvider.ollamaCloud:
        // Ollama Cloud endpoint
        return 'https://cloud.ollama.com/api';
      case AiProvider.togetherAi:
        // Together AI endpoint
        return 'https://api.together.xyz/v1';
    }
  }
}

/// Convenience extension for working with AiProvider
extension AiProviderExtension on AiProvider {
  /// Gets the full model identifier for API calls
  String get modelIdentifier => recommendedModel;
  
  /// Checks if this provider requires API key authentication
  bool get requiresApiKey {
    // Ollama local instances don't need API keys, but cloud ones might
    // For simplicity, we'll assume cloud usage requires keys
    return true;
  }
}

/// Utility class for managing the currently active AI provider
class ActiveProviderManager {
  static const String _activeProviderKey = 'montager_active_provider';
  final FlutterSecureStorage _storage;
  
  ActiveProviderManager() : _storage = const FlutterSecureStorage();
  
  /// Sets the active AI provider
  Future<void> setActiveProvider(AiProvider provider) async {
    await _storage.write(
      key: _activeProviderKey, 
      value: provider.storageKey
    );
  }
  
  /// Gets the currently active AI provider
  /// Returns null if no provider has been set
  Future<AiProvider?> getActiveProvider() async {
    final value = await _storage.read(key: _activeProviderKey);
    if (value == null) return null;
    
    switch (value) {
      case 'ollama_cloud': return AiProvider.ollamaCloud;
      case 'together_ai': return AiProvider.togetherAi;
      default: return null;
    }
  }
  
  /// Clears the active provider selection
  Future<void> clearActiveProvider() async {
    await _storage.delete(key: _activeProviderKey);
  }
}