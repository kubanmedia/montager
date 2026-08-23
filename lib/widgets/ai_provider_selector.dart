import 'package:flutter/material.dart';

class AIProviderSelector extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const AIProviderSelector({
    super.key,
    this.value,
    required this.onChanged,
  });

  @override
  State<AIProviderSelector> createState() => _AIProviderSelectorState();
}

class _AIProviderSelectorState extends State<AIProviderSelector> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Provider',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              _selectedValue ?? 'Select AI Provider',
              style: TextStyle(
                color: _selectedValue == null
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            children: [
              // Local LLM Options
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Local LLM Options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              _buildLocalLLMOption(
                'Ollama (Local Server)',
                'Connect to your local Ollama instance\nRequires Ollama running on device or network',
                'Ollama (Local)',
                Icons.computer,
                Colors.green,
              ),
              _buildLocalLLMOption(
                'Local LLM (On-Device)',
                'Run models directly on device\nMLC LLM, llama.cpp, etc.',
                'Local LLM',
                Icons.phone_android,
                Colors.green,
              ),
              
              const Divider(height: 32),
              
              // Cloud LLM Options
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Cloud LLM Options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              _buildCloudLLMOption(
                'Together AI',
                'Open-source models hosted on Together\nLlama 3.3, Llama 3.2 Vision, Qwen, etc.',
                'Together AI',
                Icons.cloud,
                Colors.indigo,
              ),
              _buildCloudLLMOption(
                'OpenAI GPT-4V',
                'Most capable vision model\nRequires OpenAI API key',
                'OpenAI',
                Icons.cloud,
                Colors.blue,
              ),
              _buildCloudLLMOption(
                'Google Gemini Pro',
                'Google\\\'s latest multimodal model',
                'Google Gemini',
                Icons.cloud,
                Colors.blue,
              ),
              _buildCloudLLMOption(
                'Anthropic Claude 3',
                'Advanced reasoning and vision',
                'Anthropic Claude',
                Icons.cloud,
                Colors.blue,
              ),
              _buildCloudLLMOption(
                'xAI Grok',
                'Elon Musk\\\'s AI model',
                'Grok (xAI)',
                Icons.cloud,
                Colors.blue,
              ),
              _buildCloudLLMOption(
                'Hugging Face',
                'Access to thousands of open-source models',
                'Hugging Face',
                Icons.cloud,
                Colors.blue,
              ),
              _buildCloudLLMOption(
                'Ollama Cloud',
                'Ollama models hosted in the cloud\nLlama 3, Llava, Phi-3, Mistral, etc.',
                'Ollama Cloud',
                Icons.cloud,
                Colors.green,
              ),
              
              const Divider(height: 32),
              
              // Custom Option
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Custom Integration',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              _buildCustomOption(
                'Custom Endpoint',
                'Connect to your own AI service',
                'Custom Endpoint',
                Icons.api,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocalLLMOption(String title, String subtitle, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      selected: _selectedValue == value,
      onTap: () {
        setState(() => _selectedValue = value);
        widget.onChanged(value);
      },
    );
  }

  Widget _buildCloudLLMOption(String title, String subtitle, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      selected: _selectedValue == value,
      onTap: () {
        setState(() => _selectedValue = value);
        widget.onChanged(value);
      },
    );
  }

  Widget _buildCustomOption(String title, String subtitle, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      selected: _selectedValue == value,
      onTap: () {
        setState(() => _selectedValue = value);
        widget.onChanged(value);
      },
    );
  }
}