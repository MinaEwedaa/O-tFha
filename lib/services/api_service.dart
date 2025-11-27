import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();
  // For Android Emulator: use 'http://10.0.2.2:5000/v1'
  // For Physical Device: use 'http://192.168.137.44:5000/v1'
  // For iOS Simulator: use 'http://localhost:5000/v1'
  final String baseUrl = 'http://10.0.2.2:5000/v1'; // Currently set for Android Emulator
  String? _manualAuthToken;

  // Set manual auth token (for testing)
  void setAuthToken(String token) {
    _manualAuthToken = token;
  }

  // Clear manual auth token
  void clearAuthToken() {
    _manualAuthToken = null;
  }

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    // Use manual token if set, otherwise get from auth service
    final token = _manualAuthToken ?? await _authService.getIdToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Generic POST method
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic GET method
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT method
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Predict plant species
  Future<Map<String, dynamic>> predictPlant({
    required String imageUrl,
    Map<String, dynamic>? metadata,
    int topK = 5,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'image_url': imageUrl,
        'top_k': topK,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/predict/plant'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Prediction failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Predict plant disease
  Future<Map<String, dynamic>> predictDisease({
    required String imageUrl,
    String? plantId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'image_url': imageUrl,
        if (plantId != null) 'plant_id': plantId,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/predict/disease'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Prediction failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get plant information
  Future<Map<String, dynamic>> getPlant(String plantId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/plants/$plantId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get plant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get disease information
  Future<Map<String, dynamic>> getDisease(String diseaseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/diseases/$diseaseId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get disease: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Submit feedback
  Future<void> submitFeedback({
    required String predictionId,
    required Map<String, dynamic> feedback,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'prediction_id': predictionId,
        'user_feedback': feedback,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get prediction history
  Future<List<Map<String, dynamic>>> getPredictionHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/predictions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to get prediction history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

