import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../core/config/api_keys.dart';

/// AI Crop Advisor Chat Service
/// Uses Google Gemini API for intelligent farming assistance
class ChatService {
  // Google Gemini API Configuration
  static String get _apiKey => ApiKeys.geminiApiKey;
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // System prompt for agricultural context
  static const String _systemPrompt = '''
You are an expert AI Crop Advisor assistant for farmers. Your name is "A'm Abdo" (عم عبده) - a friendly, wise Egyptian farmer character. You specialize in:

1. **Crop Management**: Planting schedules, crop rotation, companion planting, harvest timing
2. **Pest & Disease Control**: Identification, organic solutions, prevention strategies, IPM
3. **Soil Health**: Soil testing, amendments, fertilization, composting
4. **Irrigation**: Water management, drip irrigation, scheduling, conservation
5. **Weather & Climate**: Seasonal planning, frost protection, drought management
6. **Organic Farming**: Certification, practices, natural pest control
7. **Market & Economics**: Pricing, market trends, crop selection for profit
8. **Equipment & Technology**: Modern farming tools, precision agriculture

Guidelines:
- Give practical, actionable advice
- Consider local/regional farming conditions
- Recommend sustainable and eco-friendly practices when possible
- Keep responses concise but informative (2-4 paragraphs max)
- Use bullet points for lists
- Include relevant emojis to make responses engaging
- If asked about something outside agriculture, politely redirect to farming topics
- Always be encouraging and supportive to farmers

Respond in a friendly, warm tone like a wise village elder sharing knowledge. You can mix Arabic expressions occasionally. Format your responses with proper spacing and structure.
''';

  final List<Map<String, dynamic>> _conversationHistory = [];

  /// Send a message and get AI response
  Future<String> sendMessage(String userMessage) async {
    // Check if API key is configured
    if (!ApiKeys.isGeminiConfigured) {
      throw Exception('API key not configured. Please set your Gemini API key in api_keys.dart');
    }

    // Add user message to history
    _conversationHistory.add({
      'role': 'user',
      'parts': [{'text': userMessage}]
    });

    try {
      final response = await _callGeminiAPI(userMessage);
      
      // Add assistant response to history
      _conversationHistory.add({
        'role': 'model',
        'parts': [{'text': response}]
      });

      return response;
    } catch (e) {
      // Remove failed user message from history
      _conversationHistory.removeLast();
      rethrow;
    }
  }

  /// Call Google Gemini API
  Future<String> _callGeminiAPI(String userMessage) async {
    final url = Uri.parse('$_baseUrl?key=$_apiKey');

    // Build conversation with system prompt
    final contents = [
      {
        'role': 'user',
        'parts': [{'text': _systemPrompt}]
      },
      {
        'role': 'model',
        'parts': [{'text': 'أهلاً وسهلاً! أنا عم عبده، مستشارك الزراعي. I\'m here to help with all your farming questions - from crop management and pest control to irrigation and organic practices. يلا نبدأ! 🌾'}]
      },
      ..._conversationHistory,
    ];

    final body = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text != null) {
          return text;
        } else {
          throw Exception('Empty response from AI');
        }
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['error']?['message'] ?? 'Invalid request');
      } else if (response.statusCode == 403) {
        throw Exception('API key invalid or quota exceeded. Please check your Gemini API key.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      rethrow;
    }
  }

  /// Get offline response for common questions (fallback)
  String getOfflineResponse(String query) {
    final lowerQuery = query.toLowerCase();

    // Pest control
    if (lowerQuery.contains('pest') || lowerQuery.contains('insect') || lowerQuery.contains('bug')) {
      return '''🐛 **Natural Pest Control Tips**

Here are some organic methods to manage pests:

• **Neem Oil Spray**: Mix 2 tbsp neem oil with 1 gallon water. Spray on affected plants.
• **Companion Planting**: Plant marigolds, basil, or garlic near crops to repel pests.
• **Beneficial Insects**: Introduce ladybugs or lacewings to eat aphids.
• **Crop Rotation**: Rotate crops yearly to break pest cycles.
• **Physical Barriers**: Use row covers or netting for protection.

Would you like more specific advice for a particular pest?''';
    }

    // Watering/Irrigation
    if (lowerQuery.contains('water') || lowerQuery.contains('irrigat')) {
      return '''💧 **Irrigation Best Practices**

Efficient watering is crucial for healthy crops:

• **Morning Watering**: Water early (6-10 AM) to reduce evaporation.
• **Deep Watering**: Water deeply but less frequently to encourage deep roots.
• **Drip Irrigation**: Most efficient method - delivers water directly to roots.
• **Mulching**: Apply 2-4 inches of mulch to retain soil moisture.
• **Check Soil**: Insert finger 2 inches deep - water if dry.

💡 **Tip**: Most vegetables need 1-2 inches of water per week.''';
    }

    // Fertilizer
    if (lowerQuery.contains('fertiliz') || lowerQuery.contains('nutrient')) {
      return '''🌿 **Fertilization Guide**

Balanced nutrition keeps plants healthy:

• **NPK Basics**: Nitrogen (leaves), Phosphorus (roots/flowers), Potassium (overall health)
• **Soil Testing**: Test soil before fertilizing to know what's needed.
• **Organic Options**: Compost, manure, bone meal, fish emulsion.
• **Application Timing**: Apply at planting, then during active growth.
• **Don't Over-Fertilize**: More is not better - can burn plants!

🌱 **Tip**: Compost is the best all-around soil amendment.''';
    }

    // Season/Planting
    if (lowerQuery.contains('season') || lowerQuery.contains('plant') || lowerQuery.contains('when')) {
      return '''📅 **Seasonal Planting Guide**

**Cool Season Crops** (Spring/Fall):
• Lettuce, spinach, peas, broccoli, carrots

**Warm Season Crops** (Summer):
• Tomatoes, peppers, cucumbers, beans, corn

**Tips**:
• Check your local frost dates before planting
• Start seeds indoors 6-8 weeks before transplanting
• Harden off seedlings before moving outdoors

Would you like specific planting dates for your region?''';
    }

    // Default response
    return '''🌾 **عم عبده - مستشارك الزراعي**

أنا هنا عشان أساعدك في كل أسئلتك الزراعية! أقدر أساعدك في:

• 🌱 اختيار وإدارة المحاصيل
• 🐛 مكافحة الآفات والأمراض
• 💧 الري وإدارة المياه
• 🌿 ممارسات الزراعة العضوية
• 📅 التخطيط الموسمي
• 🧪 صحة التربة والتسميد

إيه اللي عايز تعرفه؟''';
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// Get contextual suggestions based on last response
  List<String> getSuggestions(String lastResponse) {
    final lower = lastResponse.toLowerCase();

    if (lower.contains('pest') || lower.contains('insect')) {
      return QuickSuggestions.pestControl;
    }
    if (lower.contains('weather') || lower.contains('rain') || lower.contains('frost')) {
      return QuickSuggestions.weather;
    }
    if (lower.contains('crop') || lower.contains('plant') || lower.contains('grow')) {
      return QuickSuggestions.cropRelated;
    }

    return QuickSuggestions.initial;
  }
}

