import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_keys.dart';
import 'ml_service.dart';

/// HuggingFace Inference API Service for Crop Disease Detection
/// Uses the wambugu71/crop_leaf_diseases_vit model
class HuggingFaceService {
  static const String _modelId = 'wambugu71/crop_leaf_diseases_vit';
  // New HuggingFace router endpoint (old api-inference.huggingface.co is deprecated)
  static const String _baseUrl = 'https://router.huggingface.co/hf-inference/models';
  
  bool _isInitialized = false;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!ApiKeys.isHuggingFaceConfigured) {
      throw Exception('HuggingFace API key is not configured');
    }

    // For HuggingFace serverless inference, we don't need to check model status
    // The API will handle model loading automatically when we make a request
    _isInitialized = true;
    print('✅ HuggingFace service initialized');
  }

  /// Classify an image for crop leaf disease detection
  Future<PredictionResult> classifyImage(File imageFile, {int retryCount = 0}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Read image as bytes
      final bytes = await imageFile.readAsBytes();
      
      print('📤 Sending image to HuggingFace API...');
      
      // Make request to HuggingFace Inference API
      final response = await http.post(
        Uri.parse('$_baseUrl/$_modelId'),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.huggingFaceApiKey}',
          'Content-Type': 'application/octet-stream',
        },
        body: bytes,
      ).timeout(const Duration(seconds: 60));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return _parseResults(decoded);
        } else if (decoded is Map && decoded.containsKey('error')) {
          throw Exception(decoded['error']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else if (response.statusCode == 503) {
        // Model is loading, wait and retry
        if (retryCount >= 3) {
          throw Exception('Model is still loading after multiple retries. Please try again later.');
        }
        
        final body = jsonDecode(response.body);
        final estimatedTime = body['estimated_time'] ?? 20;
        print('⏳ Model is loading, estimated time: ${estimatedTime}s (retry ${retryCount + 1}/3)');
        
        // Wait for model to load
        await Future.delayed(Duration(seconds: (estimatedTime as num).toInt().clamp(5, 30)));
        
        // Retry request
        return await classifyImage(imageFile, retryCount: retryCount + 1);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your HuggingFace API key.');
      } else if (response.statusCode == 404) {
        throw Exception('Model not found. The model may have been removed or renamed.');
      } else {
        final errorBody = response.body;
        print('❌ API Error: $errorBody');
        throw Exception('HuggingFace API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error during HuggingFace classification: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to classify image: $e');
    }
  }

  /// Parse HuggingFace image classification results into PredictionResult
  PredictionResult _parseResults(List<dynamic> results) {
    if (results.isEmpty) {
      return PredictionResult(
        success: false,
        disease: 'Unknown',
        confidence: 0.0,
        topPredictions: [],
        predictionId: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    // HuggingFace returns results in format: [{"label": "disease_name", "score": 0.95}, ...]
    final topPredictions = results.map((result) {
      final label = result['label'] as String? ?? 'Unknown';
      final score = (result['score'] as num?)?.toDouble() ?? 0.0;
      
      return TopPrediction(
        className: _formatLabel(label),
        confidence: score,
      );
    }).toList();

    // Sort by confidence (highest first)
    topPredictions.sort((a, b) => b.confidence.compareTo(a.confidence));

    final topResult = topPredictions.first;

    return PredictionResult(
      success: true,
      disease: topResult.className,
      confidence: topResult.confidence,
      topPredictions: topPredictions,
      predictionId: 'hf_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Format label from model output (e.g., "tomato_early_blight" -> "Tomato Early Blight")
  String _formatLabel(String label) {
    return label
        .replaceAll('_', ' ')
        .replaceAll('___', ' - ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ')
        .trim();
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
  }
}

