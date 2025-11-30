import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Prediction result model classes
class PredictionResult {
  final bool success;
  final String disease;
  final double confidence;
  final List<TopPrediction> topPredictions;
  final String predictionId;
  final String? plantScientificName;
  final String? plantCommonName;

  PredictionResult({
    required this.success,
    required this.disease,
    required this.confidence,
    required this.topPredictions,
    required this.predictionId,
    this.plantScientificName,
    this.plantCommonName,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    // Handle results array from PlantVillage model
    var disease = data['disease'] ?? data['plant'] ?? 'Unknown';
    var confidence = 0.0;
    var topPredictions = <TopPrediction>[];
    
    // Check if we have results array (PlantVillage format)
    if (data['results'] != null && data['results'] is List && (data['results'] as List).isNotEmpty) {
      final results = data['results'] as List;
      final topResult = results[0];
      disease = topResult['name'] ?? topResult['disease'] ?? 'Unknown';
      confidence = (topResult['confidence'] as num?)?.toDouble() ?? 0.0;
      
      // Convert all results to top predictions
      topPredictions = results.map((r) => TopPrediction(
        className: r['name'] ?? r['disease'] ?? 'Unknown',
        confidence: (r['confidence'] as num?)?.toDouble() ?? 0.0,
      )).toList();
    } else {
      // Handle standard format
      if (data['confidence'] != null) {
        if (data['confidence'] is List) {
          confidence = ((data['confidence'] as List).isNotEmpty)
              ? ((data['confidence'][0] as num?)?.toDouble() ?? 0.0)
              : 0.0;
        } else {
          confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
        }
      }
      
      // Handle top_predictions array
      if (data['top_predictions'] != null && data['top_predictions'] is List) {
        topPredictions = (data['top_predictions'] as List)
            .map((p) => TopPrediction.fromJson(p))
            .toList();
      }
    }
    
    return PredictionResult(
      success: json['success'] ?? true,
      disease: disease,
      confidence: confidence,
      topPredictions: topPredictions,
      predictionId: data['prediction_id'] ?? '',
      plantScientificName: data['plant_scientific_name'],
      plantCommonName: data['plant_common_name'],
    );
  }

  // Check if plant is healthy
  bool get isHealthy => disease.toLowerCase().contains('healthy');

  // Get severity level
  String get severityLevel {
    if (isHealthy) return 'Healthy';
    if (confidence > 0.9) return 'High Confidence';
    if (confidence > 0.7) return 'Medium Confidence';
    return 'Low Confidence';
  }

  // Get color for severity
  String get severityColor {
    if (isHealthy) return 'green';
    if (confidence > 0.9) return 'red';
    if (confidence > 0.7) return 'orange';
    return 'yellow';
  }
}

// Top prediction model
class TopPrediction {
  final String className;
  final double confidence;

  TopPrediction({
    required this.className,
    required this.confidence,
  });

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      className: json['class'] ?? json['class_name'] ?? json['name'] ?? json['disease'] ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Local HTTP ML Service - connects to local Python server
class TFLiteMLService {
  bool _isInitialized = false;
  static const String serverUrl = 'http://10.0.2.2:5000'; // Android emulator localhost
  
  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if server is running
      final response = await http.get(Uri.parse('$serverUrl/health')).timeout(
        const Duration(seconds: 3),
      );
      
      if (response.statusCode == 200) {
        _isInitialized = true;
        print('✅ Local model server connected');
      } else {
        throw Exception('Server not responding');
      }
    } catch (e) {
      print('❌ Cannot connect to local server: $e');
      print('Make sure to run: python local_model_server.py');
      throw Exception('Local model server not running. Start it with: python local_model_server.py');
    }
  }

  /// Run inference on an image file
  Future<PredictionResult> detectDisease(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$serverUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      // Send request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PredictionResult.fromJson(json);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error during inference: $e');
      throw Exception('Failed to analyze image: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
  }
}
