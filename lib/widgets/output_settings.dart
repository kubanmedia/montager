import 'package:flutter/material.dart';

class OutputSettings extends StatefulWidget {
  final double videoLength;
  final ValueChanged<double>? onLengthChanged;
  final String resolution;
  final ValueChanged<String>? onResolutionChanged;

  const OutputSettings({
    super.key,
    this.videoLength = 60.0,
    this.onLengthChanged,
    this.resolution = '1080p',
    this.onResolutionChanged,
  });

  @override
  State<OutputSettings> createState() => _OutputSettingsState();
}

class _OutputSettingsState extends State<OutputSettings> {
  late double _length;
  late String _resolution;

  @override
  void initState() {
    super.initState();
    _length = widget.videoLength;
    _resolution = widget.resolution;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Target video length'),
                Text('${_length.toInt()}s'),
              ],
            ),
            Slider(
              value: _length,
              min: 15,
              max: 300,
              divisions: 19,
              label: '${_length.toInt()}s',
              onChanged: (value) {
                setState(() => _length = value);
                widget.onLengthChanged?.call(value);
              },
            ),
            const SizedBox(height: 8),
            const Text('Resolution'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _resolution,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '720p', child: Text('720p HD')),
                DropdownMenuItem(
                    value: '1080p', child: Text('1080p Full HD')),
                DropdownMenuItem(value: '4k', child: Text('4K Ultra HD')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _resolution = value);
                widget.onResolutionChanged?.call(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
