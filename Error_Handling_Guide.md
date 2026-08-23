# Error Handling in Montager's Together AI Provider

This guide explains how the Together AI provider handles errors and how to properly handle them in the Montager application UI.

## 🎯 Exception Types

The Together AI provider uses a custom `TogetherException` for all user-visible failures. This makes it easy to catch and handle all provider-related errors in a consistent way.

### TogetherException Definition
```dart
/// Exception thrown by [TogetherProvider] for any user-visible failure
/// (bad API key, network error, non-JSON response, etc.).
class TogetherException implements Exception {
  final String message;
  TogetherException(this.message);

  @override
  String toString() => 'TogetherException: $message';
}
```

## 🔧 Error Categories and Handling

### 1. Input Validation Errors
These occur before any API calls are made.

**Examples:**
- Video file not found
- Invalid API key format
- Missing required parameters

**UI Handling:**
```dart
try {
  final analysis = await togetherProvider.analyzeVideo(videoPath);
  // Process successful result
} on TogetherException catch (e) {
  if (e.message.contains('Video file not found')) {
    // Show file picker error or suggest checking file path
    showErrorDialog('Video file not found. Please check the file path and try again.');
  } else if (e.message.contains('API key')) {
    // Show API key configuration error
    showErrorDialog('Invalid API key. Please check your Together AI API key in settings.');
  } else {
    // Generic input validation error
    showErrorDialog('Input validation failed: ${e.message}');
  }
}
```

### 2. FFmpeg/Processing Errors
These occur during video frame extraction.

**Examples:**
- FFmpeg not installed or not in PATH
- Video codec not supported
- Insufficient system resources
- Timeout during frame extraction

**UI Handling:**
```dart
try {
  final analysis = await togetherProvider.analyzeVideo(videoPath);
  // Process successful result
} on TogetherException catch (e) {
  if (e.message.contains('FFmpeg') || 
      e.message.contains('timeout') ||
      e.message.contains('extract frame')) {
    // Show processing error with helpful suggestions
    showErrorDialog('''
    Video processing failed. This could be due to:
    • FFmpeg not installed or not accessible
    • Video file corrupted or unsupported format
    • Insufficient system resources
    
    Please ensure FFmpeg is installed and try with a different video file.
    ''');
  } else {
    showErrorDialog('Video processing error: ${e.message}');
  }
}
```

### 3. Network and API Errors
These occur during communication with the Together AI API.

**Examples:**
- Network connectivity issues
- API rate limiting
- Invalid API key (detected by API)
- Server-side errors at Together AI
- Request timeouts
- Non-JSON responses from API

**UI Handling:**
```dart
try {
  final analysis = await togetherProvider.analyzeVideo(videoPath);
  // Process successful result
} on TogetherException catch (e) {
  if (e.message.contains('Network error') || 
      e.message.contains('SocketException')) {
    showErrorDialog('''
    Network connection error. Please check your internet connection and try again.
    ''');
  } else if (e.message.contains('API error 401') || 
              e.message.contains('Unauthorized')) {
    showErrorDialog('''
    Authentication failed. Your Together AI API key may be invalid or expired.
    Please check your API key in the settings and try again.
    ''');
  } else if (e.message.contains('API error 429') || 
              e.message.contains('rate limit')) {
    showErrorDialog('''
    Rate limit exceeded. Please wait a moment before trying again.
    Consider upgrading your Together AI plan for higher limits.
    ''');
  } else if (e.message.contains('timed out') || 
              e.message.contains('TimeoutException')) {
    showErrorDialog('''
    Request timed out. The Together AI API may be experiencing high load.
    Please try again in a few moments.
    ''');
  } else if (e.message.contains('non-JSON') || 
              e.message.contains('extractable content')) {
    showErrorDialog('''
    Unexpected response from Together AI API. This is usually temporary.
    Please try again. If the problem persists, check the Together AI status page.
    ''');
  } else {
    // Generic API error
    showErrorDialog('Together AI API error: ${e.message}');
  }
}
```

### 4. JSON Parsing Errors
These occur when the API returns valid HTTP response but invalid JSON.

**Examples:**
- API temporarily returning text/html error pages
- Malformed JSON due to service issues
- Streaming responses when JSON was expected

**UI Handling:**
```dart
try {
  final analysis = await togetherProvider.analyzeVideo(videoPath);
  // Process successful result
} on TogetherException catch (e) {
  if (e.message.contains('non-JSON response') || 
      e.message.contains('non-JSON body')) {
    showErrorDialog('''
    Together AI returned an unexpected response format.
    This is usually temporary and resolves on retry.
    If the issue persists, please check:
    • Together AI service status
    • Your API key validity
    • Network connectivity
    ''');
  } else {
    showErrorDialog('Response parsing error: ${e.message}');
  }
}
```

## 📱 UI Implementation Examples

### Simple Error Display:
```dart
import 'package:flutter/material.dart';
import 'package:montager/services/ai/providers/together_provider.dart';

class VideoAnalysisButton extends StatelessWidget {
  final String videoPath;
  final VoidCallback onSuccess;
  
  const VideoAnalysisButton({
    Key? key,
    required this.videoPath,
    required this.onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AlertDialog(
              title: Text('Analyzing Video'),
              content: Text('Please wait while AI analyzes your video...'),
            ),
          );
          
          // Perform analysis
          final apiKeyManager = ApiKeyManager();
          final apiKey = await apiKeyManager.getApiKey('together_ai');
          final provider = TogetherProvider(apiKey: apiKey!);
          
          final result = await provider.analyzeVideo(videoPath);
          
          // Hide loading indicator
          if (context.mounted) Navigator.of(context).pop();
          
          // Handle success
          onSuccess();
          
          // Show results
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Analysis Complete'),
                content: Text('Description: ${result['description']}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } on TogetherException catch (e) {
          // Hide loading indicator if showing
          if (context.mounted) Navigator.of(context).pop();
          
          // Show error message
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Analysis Failed'),
                content: Text(e.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.analytics),
      label: const Text('Analyze with AI'),
    );
  }
}
```

### With Retry Mechanism:
```dart
import 'package:flutter/material.dart';
import 'package:montager/services/ai/providers/together_provider.dart';

class ResilientVideoAnalyzer extends StatefulWidget {
  final String videoPath;
  
  const ResilientVideoAnalyzer({
    Key? key,
    required this.videoPath,
  }) : super(key: key);

  @override
  State<ResilientVideoAnalyzer> createState() => _ResilientVideoAnalyzerState();
}

class _ResilientVideoAnalyzerState extends State<ResilientVideoAnalyzer> {
  bool _isAnalyzing = false;
  String? _errorMessage;
  Map<String, dynamic>? _analysisResult;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  Future<void> _analyzeVideo() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final apiKeyManager = ApiKeyManager();
      final apiKey = await apiKeyManager.getApiKey('together_ai');
      
      if (apiKey == null) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'No Together AI API key configured. Please set one in Settings.';
        });
        return;
      }

      final provider = TogetherProvider(apiKey: apiKey!);
      final result = await provider.analyzeVideo(widget.videoPath);
      
      setState(() {
        _isAnalyzing = false;
        _analysisResult = result;
        _retryCount = 0; // Reset retry count on success
      });
    } on TogetherException catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e.message;
        
        // Determine if we should retry
        final shouldRetry = _shouldRetryError(e.message);
        if (shouldRetry && _retryCount < _maxRetries) {
          _retryCount++;
          // Retry after a short delay
          Future.delayed(const Duration(seconds: 2), _analyzeVideo);
        }
      });
    }
  }

  bool _shouldRetryError(String errorMessage) {
    // Define which errors are worth retrying
    final retryableErrors = [
      'Network error',
      'timeout',
      'timed out',
      'SocketException',
      'API error 500', // Internal server error
      'API error 502', // Bad gateway
      'API error 503', // Service unavailable
      'API error 504', // Gateway timeout
    ];
    
    return retryableErrors.any((error) => errorMessage.contains(error));
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing video with AI...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryCount < _maxRetries ? _analyzeVideo : null,
              child: Text(_retryCount < _maxRetries ? 'Retry' : 'Try Again Later'),
            ),
            if (_retryCount > 0)
              Text(
                'Attempt $_retryCount/${_maxRetries + 1}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      );
    }

    if (_analysisResult != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              'Analysis Complete!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Description: ${_analysisResult!['description']}',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to next step or show detailed results
              },
              child: const Text('Continue to Editing'),
            ),
          ],
        ),
      );
    }

    // Initial state - show analyze button
    return ElevatedButton.icon(
      onPressed: _analyzeVideo,
      icon: const Icon(Icons.analytics),
      label: const Text('Analyze Video with AI'),
    );
  }
}
```

## 🛡️ Best Practices for Error Handling

### 1. **User-Friendly Messages**
- Avoid exposing internal technical details to end users
- Translate technical errors into actionable advice
- Provide clear next steps when possible

### 2. **Consistent Error Presentation**
- Use similar UI patterns for all error types
- Consider using a centralized error handling service
- Maintain consistent tone and styling

### 3. **Logging for Debugging**
While showing user-friendly messages in UI, log detailed errors for developers:
```dart
} on TogetherException catch (e, stackTrace) {
  // Log detailed error for developers
  debugPrint('TogetherProvider error: $e');
  debugPrint('Stack trace: $stackTrace');
  
  // Show user-friendly message
  showUserFriendlyError(e.message);
}
```

### 4. **Graceful Degradation**
When possible, provide partial functionality:
- If frame extraction fails but we have the video, try fallback methods
- If API is unavailable, offer to save for later processing
- If one model fails, try alternative models if configured

### 5. **Retry Logic**
Implement smart retry logic for transient errors:
- Network timeouts
- Temporary service unavailability
- Rate limiting (with backoff)
- Avoid retrying for permanent errors (invalid API key, missing file)

## 📊 Error Monitoring and Analytics

Consider implementing error tracking to improve the application over time:

### Error Categorization:
Track which types of errors occur most frequently to prioritize fixes:
- Input validation errors (user correctable)
- Processing errors (environmental)
- Network/API errors (external/service)
- Authentication errors (credential issues)

### User Impact Analysis:
Measure how errors affect user completion rates:
- Where do users drop off when errors occur?
- Which errors cause the most frustration?
- What error messages lead to successful recovery?

## 🔧 Testing Error Handling

### Unit Tests:
1. Test each error condition throws appropriate TogetherException
2. Test error messages are descriptive and helpful
3. Test that valid inputs don't throw exceptions

### Integration Tests:
1. Test error recovery flows in UI
2. Test retry mechanisms work correctly
3. Test error state cleanup

### Manual Testing Scenarios:
1. **No API key**: Verify helpful error message guides user to settings
2. **Invalid API key**: Verify authentication error is clear
3. **Network disconnected**: Verify network error with retry option
4. **Missing video file**: Verify file error with browsing suggestion
5. **FFmpeg missing**: Verify processing error with installation guidance
6. **API rate limit**: Verify rate limit error with wait suggestion
7. **Service downtime**: Verify service error with status page link

## 🎯 Production Recommendations

### For Release Builds:
1. **Consider hiding stack traces** in release builds to avoid exposing internal details
2. **Implement error reporting** service (like Sentry or Firebase Crashlytics) for unexpected errors
3. **Add user feedback mechanism** for when errors occur
4. **Consider error rate monitoring** to detect regressions

### Error Message Guidelines:
1. **Be empathetic**: "We're having trouble..." rather than "You failed..."
2. **Be specific**: Mention what exactly went wrong when possible
3. **Be actionable**: Tell the user what they can do to fix it
4. **Be brief**: Long messages overwhelm users, especially on mobile
5. **Be consistent**: Use similar phrasing for similar error types

By implementing thoughtful error handling throughout the Montager application, you'll create a more resilient and user-friendly experience that helps users recover from issues quickly and continue enjoying the AI-powered video editing features.