import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/service_provider.dart';

/// Screen for entering, viewing and deleting cloud AI API keys.
/// Keys are stored encrypted via flutter_secure_storage (Keystore/Keychain).
class ApiKeysScreen extends ConsumerStatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  ConsumerState<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends ConsumerState<ApiKeysScreen> {
  static const _providers = [
    ('ollama_cloud', 'Ollama Cloud', 'Ollama models hosted in the cloud'),
    ('together_ai', 'Together AI', 'Llama 3.3, Qwen and more via Together'),
  ];

  final Map<String, bool> _hasKey = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _busy = {};
  final Map<String, bool> _obscured = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    for (final p in _providers) {
      _controllers[p.$1] = TextEditingController();
      _hasKey[p.$1] = false;
      _busy[p.$1] = false;
      _obscured[p.$1] = true;
    }
    _refresh();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    final manager = ref.read(apiKeyManagerProvider);
    final status = <String, bool>{};
    for (final p in _providers) {
      try {
        status[p.$1] = await manager.hasApiKey(p.$1);
      } catch (_) {
        status[p.$1] = false;
      }
    }
    if (!mounted) return;
    setState(() {
      _hasKey.addAll(status);
      _loading = false;
    });
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  Future<void> _save(String id) async {
    final key = _controllers[id]!.text.trim();
    if (key.isEmpty) {
      _snack('Enter an API key first', error: true);
      return;
    }
    setState(() => _busy[id] = true);
    try {
      await ref.read(apiKeyManagerProvider).storeApiKey(id, key);
      _controllers[id]!.clear();
      if (mounted) FocusScope.of(context).unfocus();
      _snack('API key saved');
    } catch (e) {
      _snack('Key rejected: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy[id] = false);
      await _refresh();
    }
  }

  Future<void> _delete(String id, String label) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $label key?'),
        content: const Text('The stored key will be removed from secure storage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busy[id] = true);
    try {
      await ref.read(apiKeyManagerProvider).deleteApiKey(id);
      _snack('API key deleted');
    } catch (e) {
      _snack('Delete failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy[id] = false);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Keys'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Keys are stored encrypted in your device keystore and never leave the device except in API calls.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                for (final p in _providers) _buildProviderCard(p.$1, p.$2, p.$3),
              ],
            ),
    );
  }

  Widget _buildProviderCard(String id, String label, String hint) {
    final configured = _hasKey[id] ?? false;
    final busy = _busy[id] ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    configured ? 'Configured' : 'Not set',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: configured ? Colors.green.shade100 : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(hint, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: _controllers[id],
              obscureText: _obscured[id] ?? true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: configured ? 'Replace key' : 'Enter API key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon((_obscured[id] ?? true)
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => setState(
                    () => _obscured[id] = !(_obscured[id] ?? true),
                  ),
                ),
              ),
              onSubmitted: (_) => _save(id),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: busy ? null : () => _save(id),
                    child: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        (busy || !configured) ? null : () => _delete(id, label),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
