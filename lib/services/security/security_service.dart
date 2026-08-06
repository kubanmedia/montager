import 'dart:io';
import 'package:path/path.dart' as path;

/// Security service for Montager that provides threat detection and protection
/// capabilities by integrating with the Secura security framework.
class SecurityService {
  final String _securaAgentPath;

  SecurityService({String? securaAgentPath})
      : _securaAgentPath = securaAgentPath ??
            '/home/kubanmedia/.openclaw/workspace/multi_agent_crew/secura';

  /// Scans a file for security threats using Secura principles
  /// Returns true if the file is safe, false if threats are detected
  Future<bool> scanFileForThreats(String filePath) async {
    try {
      if (!await File(filePath).exists()) {
        return false;
      }

      // Basic file validation
      final file = File(filePath);
      final stats = await file.stat();
      
      // Check for suspiciously large files (potential DoS)
      const maxFileSize = 500 * 1024 * 1024; // 500MB
      if (stats.size > maxFileSize) {
        await _logSecurityEvent(
            'FILE_SIZE_VIOLATION', 
            'File too large: ${stats.size} bytes', 
            filePath);
        return false;
      }

      // Check file extension for video files
      final extension = path.extension(filePath).toLowerCase();
      const videoExtensions = {
        '.mp4', '.mov', '.avi', '.mkv', '.webm', '.mpeg', '.hevc', '.h264'
      };
      
      if (!videoExtensions.contains(extension)) {
        await _logSecurityEvent(
            'INVALID_FILE_TYPE', 
            'Non-video file extension: $extension', 
            filePath);
        return false;
      }

      // In a full implementation, this would call the Secura agent
      // For now, we'll implement basic security checks locally
      final isSafe = await _performLocalSecurityChecks(filePath);
      
      if (!isSafe) {
        await _logSecurityEvent(
            'THREAT_DETECTED', 
            'Security threats found in file', 
            filePath);
      }
      
      return isSafe;
    } catch (e) {
      await _logSecurityEvent(
          'SCAN_ERROR', 
          'Error scanning file: $e', 
          filePath);
      return false; // Fail closed - if we can't scan, treat as unsafe
    }
  }

  /// Scans user prompt for prompt injection attempts
  /// Returns true if prompt is safe, false if injection detected
  Future<bool> scanPromptForInjection(String prompt) async {
    try {
      if (prompt.trim().isEmpty) {
        return true; // Empty prompt is safe
      }

      // Check for common prompt injection patterns
      final lowerPrompt = prompt.toLowerCase();
      
      // System override attempts
      final systemPatterns = [
        'system:', 'ignore previous', 'forget everything', 
        'you are now', 'disregard instructions', 
        'override security', 'bypass safety', 'jailbreak'
      ];
      
      for (final pattern in systemPatterns) {
        if (lowerPrompt.contains(pattern)) {
          await _logSecurityEvent(
              'PROMPT_INJECTION_ATTEMPT', 
              'Prompt injection pattern detected: $pattern', 
              prompt);
          return false;
        }
      }

      // Check for attempts to extract system information
      const infoPatterns = [
        'reveal', 'show me', 'what are', 'tell me about',
        'system prompt', 'internal instructions', 'configuration'
      ];
      
      for (final pattern in infoPatterns) {
        if (lowerPrompt.contains(pattern) && 
            lowerPrompt.contains('your') && 
            lowerPrompt.contains('settings')) {
          await _logSecurityEvent(
              'INFO_EXTRACTION_ATTEMPT', 
              'Potential information extraction: $pattern', 
              prompt);
          // Don't block, but log for monitoring
        }
      }

      // Check for data exfiltration attempts
      const exfilPatterns = [
        'send to', 'email to', 'upload to', 'transmit to',
        'share with', 'give to', 'provide to'
      ];
      
      for (final pattern in exfilPatterns) {
        if (lowerPrompt.contains(pattern)) {
          await _logSecurityEvent(
              'EXFILTRATION_ATTEMPT', 
              'Potential data exfiltration: $pattern', 
              prompt);
          // Don't block immediately, but flag for review
        }
      }

      // Check for requests to generate harmful content
      const harmfulPatterns = [
        'violence', 'gore', 'explicit', 'nsfw', 'pornographic',
        'hate speech', 'harassment', 'illegal activities'
      ];
      
      for (final pattern in harmfulPatterns) {
        if (lowerPrompt.contains(pattern)) {
          await _logSecurityEvent(
              'HARMFUL_CONTENT_REQUEST', 
              'Request for potentially harmful content: $pattern', 
              prompt);
          // In production, might want to block or require confirmation
        }
      }

      await _logSecurityEvent(
          'PROMPT_SCAN_COMPLETE', 
          'Prompt scanned successfully', 
          prompt.length.toString());
      return true;
    } catch (e) {
      await _logSecurityEvent(
          'PROMPT_SCAN_ERROR', 
          'Error scanning prompt: $e', 
          prompt);
      return false;
    }
  }

  /// Validates API key format and checks for common leakage patterns
  Future<bool> validateApiKey(String apiKey, String providerName) async {
    try {
      if (apiKey.isEmpty) {
        await _logSecurityEvent(
            'MISSING_API_KEY', 
            'API key is empty for provider: $providerName', 
            '');
        return false;
      }

      // Basic format validation
      if (apiKey.length < 10) {
        await _logSecurityEvent(
            'INVALID_API_KEY_FORMAT', 
            'API key too short for provider: $providerName', 
            apiKey.substring(0, 5));
        return false;
      }

      // Check for common placeholder patterns
      final lowerKey = apiKey.toLowerCase();
      const placeholderPatterns = [
        'your_key_here', 'insert_key', 'api_key', 
        'placeholder', 'example', 'test', 'demo'
      ];
      
      for (final pattern in placeholderPatterns) {
        if (lowerKey.contains(pattern)) {
          await _logSecurityEvent(
              'PLACEHOLDER_API_KEY', 
              'Placeholder API key detected for provider: $providerName', 
              apiKey.substring(0, Math.min(10, apiKey.length)));
          return false;
        }
      }

      // Provider-specific validation
      switch (providerName.toLowerCase()) {
        case 'openai':
          if (!apiKey.startsWith('sk-')) {
            await _logSecurityEvent(
                'INVALID_OPENAI_KEY_FORMAT', 
                'OpenAI API key should start with sk-', 
                apiKey.substring(0, Math.min(10, apiKey.length)));
            return false;
          }
          break;
        case 'anthropic':
          if (!apiKey.startsWith('sk-ant-')) {
            await _logSecurityEvent(
                'INVALID_ANTHROPIC_KEY_FORMAT', 
                'Anthropic API key should start with sk-ant-', 
                apiKey.substring(0, Math.min(10, apiKey.length)));
            return false;
          }
          break;
        case 'together':
          // Together API keys typically don't have a specific prefix
          // but should be reasonably long
          if (apiKey.length < 20) {
            await _logSecurityEvent(
                'INVALID_TOGETHER_KEY_FORMAT', 
                'Together API key seems too short', 
                apiKey.substring(0, Math.min(10, apiKey.length)));
            return false;
          }
          break;
        default:
          // Generic validation for unknown providers
          break;
      }

      await _logSecurityEvent(
          'API_KEY_VALIDATION_PASSED', 
          'API key validation passed for provider: $providerName', 
          apiKey.substring(0, Math.min(10, apiKey.length)));
      return true;
    } catch (e) {
      await _logSecurityEvent(
          'API_KEY_VALIDATION_ERROR', 
          'Error validating API key: $e', 
          providerName);
      return false;
    }
  }

  /// Performs local security checks on a file
  Future<bool> _performLocalSecurityChecks(String filePath) async {
    try {
      // Check for embedded scripts or executable content in video files
      final file = File(filePath);
      final randomAccess = file.openRead();
      
      // Read first and last few KB to check for suspicious content
      const sampleSize = 8192; // 8KB samples
      final List<int> headBytes = [];
      final List<int> tailBytes = [];
      
      // Read head
      await for (final byte in randomAccess.take(sampleSize)) {
        headBytes.add(byte);
      }
      await randomAccess.close();
      
      // Read tail (seek to end - sampleSize)
      final fileLength = await file.length();
      if (fileLength > sampleSize * 2) {
        final tailReader = file.openRead(fileLength - sampleSize);
        await for (final byte in tailReader.take(sampleSize)) {
          tailBytes.add(byte);
        }
        await tailReader.close();
      }

      // Check for suspicious patterns
      final allBytes = [...headBytes, ...tailBytes];
      final suspiciousPatterns = [
        // Script tags
        [60, 115, 99, 114, 105, 112, 116, 62], // <script>
        // PHP tags
        [60, 63, 112, 104, 112], // <?
        // JavaScript
        [101, 118, 97, 108, 40], // eval(
        [101, 120, 101, 99, 40], // exec(
        // Shell commands
        [99, 109, 100, 32], // cmd
        [98, 97, 115, 104, 32], // bash
        [102, 111, 114, 109, 32], // format
        // Network activity
        [104, 116, 116, 112], // http
        [102, 116, 112], // ftp
        // Suspicious strings
        [118, 105, 114, 117, 115], // virus
        [109, 97, 108, 109, 97, 108], // malware
        [115, 112, 121, 119, 97, 114, 101], // spyware
      ];

      for (final pattern in suspiciousPatterns) {
        final headMatch = _bytesContains(allBytes.sublist(0, 
            math.min(allBytes.length, pattern.length + 100)), pattern);
        final tailMatch = _bytesContains(allBytes.sublist(
            math.max(0, allBytes.length - pattern.length - 100)), pattern);
        
        if (headMatch || tailMatch) {
          return false;
        }
      }

      return true;
    } catch (e) {
      // If we can't perform local checks, assume unsafe
      return false;
    }
  }

  /// Helper method to check if bytes contain a pattern
  bool _bytesContains(List<int> bytes, List<int> pattern) {
    if (bytes.length < pattern.length) return false;
    
    for (var i = 0; i <= bytes.length - pattern.length; i++) {
      bool match = true;
      for (var j = 0; j < pattern.length; j++) {
        if (bytes[i + j] != pattern[j]) {
          match = false;
          break;
        }
      }
      if (match) return true;
    }
    return false;
  }

  /// Logs security events for audit trail
  Future<void> _logSecurityEvent(
      String eventType, 
      String description, 
      String detail) async {
    try {
      final logDir = Directory('${_securaAgentPath}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String();
      final logEntry = 
          '$timestamp - $eventType - $description - $detail\n';

      final logFile = File('${logDir.path}/montager_security_${DateTime.now().toIso8601String().split('T')[0]}.log');
      await logFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      // Don't let logging errors break security functionality
      // In production, this should go to a more robust logging system
    }
  }

  /// Gets the current security status/logs
  Future<String> getSecurityStatus() async {
    try {
      final logDir = Directory('${_securaAgentPath}/logs');
      if (!await logDir.exists()) {
        return 'No security logs available';
      }

      final todayLogs = logDir.listSync()
          .where((entity) => 
              entity is File && 
              entity.path.contains('montager_security_') && 
              entity.path.contains(DateTime.now().toIso8601String().split('T')[0]))
          .toList();

      if (todayLogs.isEmpty) {
        return 'No security events logged today';
      }

      final latestLog = todayLogs.reduce((a, b) => 
          a.stat().modified > b.stat().modified ? a : b);
      
      final content = await latestLog.readAsString();
      return content.trim().isEmpty 
          ? 'No security events recorded' 
          : content.trim();
    } catch (e) {
      return 'Error retrieving security status: $e';
    }
  }
}