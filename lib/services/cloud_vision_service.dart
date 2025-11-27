import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ml_service.dart';

class CloudVisionService {
  // Initialize with the correct region (us-central1 is default)
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Convert image file to base64 string
  Future<String> _imageToBase64(File imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Convert to base64
      final base64Image = base64Encode(bytes);
      
      return base64Image;
    } catch (e) {
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  /// Call the annotateImage Cloud Function
  /// This is a generic method that accepts any Cloud Vision features
  Future<Map<String, dynamic>> annotateImage({
    required File imageFile,
    List<Map<String, dynamic>>? features,
  }) async {
    // Check authentication
    if (!isAuthenticated()) {
      throw Exception('User must be authenticated to use Cloud Vision API');
    }

    try {
      // Convert image to base64
      final base64Image = await _imageToBase64(imageFile);

      // Prepare request
      final request = {
        'image': {
          'content': base64Image,
        },
        'features': features ?? [
          {
            'type': 'LABEL_DETECTION',
            'maxResults': 10,
          }
        ],
      };

      // Call Cloud Function
      final callable = _functions.httpsCallable('annotateImage');
      final result = await callable.call(request);

      return result.data as Map<String, dynamic>;
    } catch (e) {
      print('Cloud Vision API error: $e');
      throw Exception('Failed to analyze image with Cloud Vision: $e');
    }
  }

  /// Detect plant disease using specialized Cloud Function
  Future<PredictionResult> detectPlantDisease(File imageFile) async {
    // Check authentication
    if (!isAuthenticated()) {
      throw Exception('User must be authenticated to use plant disease detection');
    }

    try {
      // Convert image to base64
      final base64Image = await _imageToBase64(imageFile);

      // Prepare request
      final request = {
        'image': {
          'content': base64Image,
        },
      };

      // Call Cloud Function
      final callable = _functions.httpsCallable('detectPlantDisease');
      final result = await callable.call(request);

      // Parse response
      final data = result.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to detect plant disease');
      }

      // Convert to PredictionResult
      return _parsePredictionResult(data['data']);
    } catch (e) {
      print('Plant disease detection error: $e');
      throw Exception('Failed to detect plant disease: $e');
    }
  }

  /// Get label detection results
  Future<List<VisionLabel>> getLabelDetection(File imageFile) async {
    try {
      final response = await annotateImage(
        imageFile: imageFile,
        features: [
          {
            'type': 'LABEL_DETECTION',
            'maxResults': 10,
          }
        ],
      );

      final data = response['data'] as Map<String, dynamic>;
      final annotations = data['labelAnnotations'] as List?;

      if (annotations == null) {
        return [];
      }

      return annotations
          .map((label) => VisionLabel.fromJson(label))
          .toList();
    } catch (e) {
      throw Exception('Failed to get label detection: $e');
    }
  }

  /// Get object localization results
  Future<List<VisionObject>> getObjectLocalization(File imageFile) async {
    try {
      final response = await annotateImage(
        imageFile: imageFile,
        features: [
          {
            'type': 'OBJECT_LOCALIZATION',
            'maxResults': 10,
          }
        ],
      );

      final data = response['data'] as Map<String, dynamic>;
      final annotations = data['localizedObjectAnnotations'] as List?;

      if (annotations == null) {
        return [];
      }

      return annotations
          .map((obj) => VisionObject.fromJson(obj))
          .toList();
    } catch (e) {
      throw Exception('Failed to get object localization: $e');
    }
  }

  /// Parse Cloud Vision response to PredictionResult
  PredictionResult _parsePredictionResult(Map<String, dynamic> data) {
    return PredictionResult(
      success: true,
      disease: data['disease'] ?? 'Unknown',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      topPredictions: (data['topPredictions'] as List?)
              ?.map((p) => TopPrediction(
                    className: p['className'] ?? 'Unknown',
                    confidence: (p['confidence'] as num?)?.toDouble() ?? 0.0,
                  ))
              .toList() ??
          [],
      predictionId: data['predictionId'] ?? '',
      plantScientificName: data['plantScientificName'],
      plantCommonName: data['plantCommonName'],
    );
  }
}

/// Vision Label model
class VisionLabel {
  final String description;
  final double score;
  final String? mid; // Knowledge Graph entity ID

  VisionLabel({
    required this.description,
    required this.score,
    this.mid,
  });

  factory VisionLabel.fromJson(Map<String, dynamic> json) {
    return VisionLabel(
      description: json['description'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      mid: json['mid'],
    );
  }
}

/// Vision Object model
class VisionObject {
  final String name;
  final double score;
  final Map<String, dynamic>? boundingPoly;

  VisionObject({
    required this.name,
    required this.score,
    this.boundingPoly,
  });

  factory VisionObject.fromJson(Map<String, dynamic> json) {
    return VisionObject(
      name: json['name'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      boundingPoly: json['boundingPoly'],
    );
  }
}

