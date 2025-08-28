import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// Service for communicating with the Qwen Image Edit service (local or remote)
class QwenImageService {
  static const String _defaultBaseUrl = 'http://localhost:8000';
  static const Duration _defaultTimeout = Duration(seconds: 300);
  static const int _defaultMaxRetries = 3;

  final String baseUrl;
  final Duration timeout;
  final int maxRetries;
  final String healthCheckPath;
  final http.Client _httpClient;

  QwenImageService({
    String? baseUrl,
    Duration? timeout,
    int? maxRetries,
    String? healthCheckPath,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl,
        timeout = timeout ?? _defaultTimeout,
        maxRetries = maxRetries ?? _defaultMaxRetries,
        healthCheckPath = healthCheckPath ?? '/health',
        _httpClient = http.Client();

  /// Factory constructor that creates service from environment variables and defaults
  factory QwenImageService.fromConfig(Session session) {
    // Get AI service configuration from environment variables with sensible defaults
    final host = Platform.environment['AI_SERVICE_HOST'] ?? 'localhost';
    final port = int.tryParse(Platform.environment['AI_SERVICE_PORT'] ?? '') ?? 8000;
    final scheme = Platform.environment['AI_SERVICE_SCHEME'] ?? 'http';
    final timeoutMs = int.tryParse(Platform.environment['AI_SERVICE_TIMEOUT'] ?? '') ?? 30000;
    final retries = int.tryParse(Platform.environment['AI_SERVICE_MAX_RETRIES'] ?? '') ?? 3;
    final healthPath = Platform.environment['AI_SERVICE_HEALTH_PATH'] ?? '/health';
    
    final baseUrl = '$scheme://$host:$port';
    
    session.log('Configuring AI service: $baseUrl (timeout: ${timeoutMs}ms, retries: $retries)', level: LogLevel.info);
    
    return QwenImageService(
      baseUrl: baseUrl,
      timeout: Duration(milliseconds: timeoutMs),
      maxRetries: retries,
      healthCheckPath: healthPath,
    );
  }

  /// Check if the Qwen Image Edit service is healthy and ready
  Future<bool> isHealthy() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('$baseUrl$healthCheckPath'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final healthData = json.decode(response.body);
        return healthData['status'] == 'healthy' &&
            healthData['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get available models and capabilities
  Future<Map<String, dynamic>?> getModels() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('$baseUrl/models'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Process an image with the given prompt
  Future<QwenImageProcessResult> processImage({
    required String imageBase64,
    required String prompt,
    String model = 'qwen-image-edit',
    Map<String, dynamic>? options,
  }) async {
    int retries = 0;
    Exception? lastException;

    while (retries < maxRetries) {
      try {
        final requestBody = {
          'image_base64': imageBase64,
          'prompt': prompt,
          'model': model,
          'options': options ?? {},
        };

        final response = await _httpClient
            .post(
              Uri.parse('$baseUrl/process'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode(requestBody),
            )
            .timeout(timeout);

        final responseData = json.decode(response.body) as Map<String, dynamic>;

        if (response.statusCode == 200) {
          return QwenImageProcessResult(
            success: responseData['success'] ?? false,
            processedImageBase64: responseData['processed_image_base64'],
            processingTime: responseData['processing_time']?.toDouble(),
            modelUsed: responseData['model_used'],
            message: responseData['message'],
          );
        } else {
          throw QwenImageServiceException(
            'Processing failed: ${responseData['detail'] ?? response.body}',
            statusCode: response.statusCode,
          );
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        retries++;

        if (retries < maxRetries) {
          // Wait before retrying with exponential backoff
          await Future.delayed(Duration(seconds: retries * 2));
        }
      }
    }

    throw QwenImageServiceException(
      'Failed to process image after $maxRetries retries: ${lastException?.toString()}',
    );
  }

  /// Process an image by sending the image file directly
  Future<QwenImageProcessResult> processImageFile({
    required File imageFile,
    required String prompt,
    String model = 'qwen-image-edit',
  }) async {
    try {
      // Read image file and convert to base64
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      return await processImage(
        imageBase64: imageBase64,
        prompt: prompt,
        model: model,
      );
    } catch (e) {
      throw QwenImageServiceException(
        'Failed to process image file: ${e.toString()}',
      );
    }
  }

  /// Dispose of resources
  void dispose() {
    _httpClient.close();
  }
}

/// Result of image processing operation
class QwenImageProcessResult {
  final bool success;
  final String? processedImageBase64;
  final double? processingTime;
  final String? modelUsed;
  final String? message;

  QwenImageProcessResult({
    required this.success,
    this.processedImageBase64,
    this.processingTime,
    this.modelUsed,
    this.message,
  });

  @override
  String toString() {
    return 'QwenImageProcessResult(success: $success, '
        'processingTime: $processingTime, '
        'modelUsed: $modelUsed, '
        'message: $message)';
  }
}

/// Exception thrown by QwenImageService
class QwenImageServiceException implements Exception {
  final String message;
  final int? statusCode;

  QwenImageServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'QwenImageServiceException: $message'
      '${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}
