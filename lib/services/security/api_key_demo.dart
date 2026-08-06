import 'dart:io';

/// Demonstration of the API key management system for Montager
class ApiKeyDemo {
  /// Shows how to use the secure API key management system
  static Future<void> demoApiKeyManagement() async {
    print('🔐 Montager API Key Management Demo');
    print('=' * 50);
    
    // Initialize the API key manager
    final apiKeyManager = ApiKeyManager();
    print('✅ API Key Manager initialized');
    
    // Show initially no keys are stored
    print('\n📋 Initial State:');
    final initialProviders = await apiKeyManager.getStoredProviders();
    print('   Stored providers: ${initialProviders.isEmpty ? 'none' : initialProviders.join(', ')}');
    
    // Demo storing API keys for our specified providers
    print('\n💾 Step 1: Storing API Keys');
    
    // Store Together AI API key (using the free PrismML Ternary Bonsai 27B)
    const String togetherApiKey = 'tkp_your_together_ai_api_key_here_example_only';
    try {
      await apiKeyManager.storeApiKey('together_ai', togetherApiKey);
      print('   ✅ Stored Together AI API key');
    } catch (e) {
      print('   ❌ Failed to store Together AI key: $e');
    }
    
    // Store Ollama Cloud API key
    const String ollamaApiKey = 'your_ollama_cloud_api_key_here_example_only';
    try {
      await apiKeyManager.storeApiKey('ollama_cloud', ollamaApiKey);
      print('   ✅ Stored Ollama Cloud API key');
    } catch (e) {
      print('   ❌ Failed to store Ollama Cloud key: $e');
    }
    
    // Show what's now stored
    print('\n📋 After Storage:');
    final storedProviders = await apiKeyManager.getStoredProviders();
    print('   Stored providers: ${storedProviders.join(', ')}');
    
    // Demo retrieving API keys
    print('\n🔍 Step 2: Retrieving API Keys (masked for security)');
    
    final togetherKey = await apiKeyManager.getApiKey('together_ai');
    if (togetherKey != null) {
      final masked = togetherKey.replaceRange(4, togetherKey.length - 4, '*' * (togetherKey.length - 8));
      print('   Together AI Key: $masked');
    }
    
    final ollamaKey = await apiKeyManager.getApiKey('ollama_cloud');
    if (ollamaKey != null) {
      final masked = ollamaKey.replaceRange(4, ollamaKey.length - 4, '*' * (ollamaKey.length - 8));
      print('   Ollama Cloud Key: $masked');
    }
    
    #ERROR
    Max turns (10) exceeded