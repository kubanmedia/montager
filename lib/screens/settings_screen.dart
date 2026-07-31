import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsSettingscreenStateSettingsSettingsStateScreen

  @super.initState();
  }

  @override
  Widget build(BuildContext context) {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Icons.ai,
                'Default AI Provider',
                'OpenAI GPT-4V',
                onTap: () {
                  // TODO: Navigate to provider selection
                },
              ),
              _buildSettingsTile(
                Icons.api,
                'API Keys Management',
                'Configure API keys for cloud services',
                onTap: () {
                  // TODO: Navigate to API key management
                },
              ),
              _buildSettingsTile(
                Icons.cloud,
                'Cloud Processing',
                'Allow AI processing via cloud services',
                isSwitch: true,
                value: true,
                onChanged: (value) {
                  // TODO: Update cloud processing preference
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
                '2.4 GB used',
                onTap: () {
                  // TODO: Show local storage management
                },
              ),
              _buildSettingsTile(
                Icons.devices,
                'Device Processing Power',
                'Medium',
                onTap: () {
                  // TODO: Show device capabilities
                },
              ),
              _buildSettingsTile(
                Icons.battery_charging_full,
                'Battery Usage',
                'Allow processing while charging',
                isSwitch: true,
                value: true,
                onChanged: (value) {
                  // TODO: Update battery usage preference
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
                '1080p HD',
                onTap: () {
                  // TODO: Navigate to quality settings
                },
              ),
              _buildSettingsTile(
                Icons.videocam,
                'Default Frame Rate',
                '30 fps',
                onTap: () {
                  // TODO: Navigate to frame rate settings
                },
              ),
              _buildSettingsTile(
                Icons.audiotrack,
                'Default Audio Quality',
                'Stereo 128kbps',
                onTap: () {
                  // TODO: Navigate to audio settings
                },
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
                onTap: () {
                  // TODO: Show privacy policy details
                },
              ),
              _buildSettingsTile(
                Icons.security,
                'API Key Storage',
                'Securely stored in device keychain',
                onTap: () {
                  // TODO: Show security details
                },
              ),
              _buildSettingsTile(
                Icons.delete_sweep,
                'Clear Cache',
                'Free up storage space',
                onTap: () {
                  // TODO: Show cache clearing confirmation
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement reset to defaults
              },
              child: const Text('Reset to Default Settings'),
            ),
          ),
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
        ],
      ) + Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(children: children),
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
              activeColor: Theme.of(context).colorScheme.primary,
            )
          : (onTap != null
              ? Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline)
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