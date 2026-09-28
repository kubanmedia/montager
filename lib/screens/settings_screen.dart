import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_provider.dart';
import 'api_keys_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _kProvider = 'default_provider';
  static const _kCloud = 'cloud_processing';
  static const _kBattery = 'battery_while_charging';
  static const _kQuality = 'default_quality';
  static const _kFps = 'default_fps';
  static const _kAudio = 'default_audio';

  static const _providerOptions = ['Together AI', 'Ollama Cloud'];
  static const _qualityOptions = ['720p HD', '1080p HD', '4K Ultra HD'];
  static const _fpsOptions = ['24 fps', '30 fps', '60 fps'];
  static const _audioOptions = ['Stereo 128kbps', 'Stereo 256kbps', 'Mono 64kbps'];

  String _provider = 'Together AI';
  bool _cloud = true;
  bool _battery = true;
  String _quality = '1080p HD';
  String _fps = '30 fps';
  String _audio = 'Stereo 128kbps';
  bool _keySaved = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _provider = prefs.getString(_kProvider) ?? _provider;
      _cloud = prefs.getBool(_kCloud) ?? _cloud;
      _battery = prefs.getBool(_kBattery) ?? _battery;
      _quality = prefs.getString(_kQuality) ?? _quality;
      _fps = prefs.getString(_kFps) ?? _fps;
      _audio = prefs.getString(_kAudio) ?? _audio;
      _loading = false;
    });
    await _refreshKeyStatus();
  }

  Future<void> _refreshKeyStatus() async {
    final storageKey =
        _provider == 'Ollama Cloud' ? 'ollama_cloud' : 'together_ai';
    bool saved = false;
    try {
      saved = await ref.read(apiKeyManagerProvider).hasApiKey(storageKey);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _keySaved = saved);
  }

  Future<void> _save(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickOption({
    required String title,
    required List<String> options,
    required String current,
    required Future<void> Function(String) onPick,
  }) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          for (final o in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(o),
              child: Row(
                children: [
                  Expanded(child: Text(o)),
                  if (o == current)
                    const Icon(Icons.check, size: 18, color: Colors.green),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked != null && picked != current) {
      await onPick(picked);
    }
  }

  void _showInfo(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<int> _cacheBytes() async {
    if (kIsWeb) return 0;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'montager_output'));
      if (!await dir.exists()) return 0;
      var total = 0;
      await for (final e in dir.list(recursive: true, followLinks: false)) {
        if (e is File) total += await e.length();
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _clearCache() async {
    if (kIsWeb) {
      _snack('Cache clearing is not available on web');
      return;
    }
    final bytes = await _cacheBytes();
    final mb = (bytes / 1048576).toStringAsFixed(1);
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cache?'),
        content: Text('This frees about $mb MB of processed outputs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'montager_output'));
      if (await dir.exists()) {
        await for (final e in dir.list(followLinks: false)) {
          await e.delete(recursive: true);
        }
      }
      _snack('Cache cleared ($mb MB freed)');
    } catch (e) {
      _snack('Clear failed: $e');
    }
  }

  Future<void> _reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset settings?'),
        content: const Text(
          'All preferences return to defaults. Stored API keys are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    setState(() {
      _provider = 'Together AI';
      _cloud = true;
      _battery = true;
      _quality = '1080p HD';
      _fps = '30 fps';
      _audio = 'Stereo 128kbps';
    });
    await _refreshKeyStatus();
    _snack('Settings reset to defaults');
  }

  String _providerSubtitle() =>
      _keySaved ? '$_provider - API key saved' : '$_provider - no API key yet';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            'AI Provider Settings',
            [
              _buildSettingsTile(
                Icons.smartphone,
                'Default AI Provider',
                _providerSubtitle(),
                onTap: () => _pickOption(
                  title: 'Default AI Provider',
                  options: _providerOptions,
                  current: _provider,
                  onPick: (v) async {
                    setState(() => _provider = v);
                    await _save(_kProvider, v);
                    await _refreshKeyStatus();
                  },
                ),
              ),
              _buildSettingsTile(
                Icons.api,
                'API Keys Management',
                _keySaved
                    ? 'Keys configured - tap to edit'
                    : 'Add your cloud API keys',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ApiKeysScreen(),
                    ),
                  );
                  await _refreshKeyStatus();
                },
              ),
              _buildSettingsTile(
                Icons.cloud,
                'Cloud Processing',
                'Allow AI processing via cloud services',
                isSwitch: true,
                value: _cloud,
                onChanged: (value) async {
                  setState(() => _cloud = value);
                  await _save(_kCloud, value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Local Processing Settings',
            [
              _buildSettingsTile(
                Icons.storage,
                'Local Model Storage',
                'On-device models are not used in this version',
                onTap: () => _showInfo(
                  'Local Model Storage',
                  'Montager currently plans edits with cloud AI or an on-device demo plan. No local models are downloaded, so nothing is stored here.',
                ),
              ),
              _buildSettingsTile(
                Icons.devices,
                'Device Processing Power',
                'Automatic',
                onTap: () => _showInfo(
                  'Device Processing Power',
                  'Montager adapts to your device automatically. Video assembly runs at full speed; AI planning quality depends on the selected provider.',
                ),
              ),
              _buildSettingsTile(
                Icons.battery_charging_full,
                'Battery Usage',
                'Allow processing while charging',
                isSwitch: true,
                value: _battery,
                onChanged: (value) async {
                  setState(() => _battery = value);
                  await _save(_kBattery, value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Output Settings',
            [
              _buildSettingsTile(
                Icons.format_size,
                'Default Video Quality',
                _quality,
                onTap: () => _pickOption(
                  title: 'Default Video Quality',
                  options: _qualityOptions,
                  current: _quality,
                  onPick: (v) async {
                    setState(() => _quality = v);
                    await _save(_kQuality, v);
                  },
                ),
              ),
              _buildSettingsTile(
                Icons.videocam,
                'Default Frame Rate',
                _fps,
                onTap: () => _pickOption(
                  title: 'Default Frame Rate',
                  options: _fpsOptions,
                  current: _fps,
                  onPick: (v) async {
                    setState(() => _fps = v);
                    await _save(_kFps, v);
                  },
                ),
              ),
              _buildSettingsTile(
                Icons.audiotrack,
                'Default Audio Quality',
                _audio,
                onTap: () => _pickOption(
                  title: 'Default Audio Quality',
                  options: _audioOptions,
                  current: _audio,
                  onPick: (v) async {
                    setState(() => _audio = v);
                    await _save(_kAudio, v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Privacy & Security',
            [
              _buildSettingsTile(
                Icons.privacy_tip,
                'Data Usage',
                'No video data is uploaded without permission',
                onTap: () => _showInfo(
                  'Data Usage',
                  'Your videos stay on this device. Only the selected AI provider receives the text prompt and clip metadata needed to build an edit plan - and only when cloud processing is enabled.',
                ),
              ),
              _buildSettingsTile(
                Icons.security,
                'API Key Storage',
                'Securely stored in device keychain',
                onTap: () => _showInfo(
                  'API Key Storage',
                  'API keys are encrypted with Android Keystore (or iOS Keychain) via flutter_secure_storage. Montager never logs or shares them.',
                ),
              ),
              _buildSettingsTile(
                Icons.delete_sweep,
                'Clear Cache',
                'Free up storage space',
                onTap: _clearCache,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _reset,
              child: const Text('Reset to Default Settings'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    bool isSwitch = false,
    bool? value,
    ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: isSwitch
          ? Switch(
              value: value ?? false,
              onChanged: onChanged,
              activeThumbColor: Theme.of(context).colorScheme.primary,
            )
          : (onTap != null
              ? Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline)
              : null),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }
}
