import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_keys.dart';
import '../models/chat_message.dart';

/// Chat Service for AI Crop Advisor using Google Gemini API directly
class ChatService {
  final List<Map<String, dynamic>> _conversationHistory = [];
  
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  
  /// System prompt for the AI
  static const String _systemPrompt = '''أنت "عم عبده"، مستشار زراعي مصري خبير. 
- بتتكلم باللهجة المصرية بطريقة ودية وبسيطة
- بتساعد الفلاحين في كل حاجة تخص الزراعة
- بتقدم نصائح عملية ومفيدة
- بتستخدم إيموجي بشكل معتدل''';

  ChatService();

  /// Send a message and get AI response
  Future<String> sendMessage(String userMessage) async {
    try {
      // Add user message to history
      _conversationHistory.add({
        'role': 'user',
        'parts': [{'text': userMessage}]
      });
      
      // Build the request body
      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': '$_systemPrompt\n\nالسؤال: $userMessage'}]
          },
          ..._conversationHistory.skip(1).toList(),
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      };
      
      final url = '$_baseUrl?key=${ApiKeys.geminiApiKey}';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      
      print('Gemini API Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text != null && text.isNotEmpty) {
          // Add response to history
          _conversationHistory.add({
            'role': 'model',
            'parts': [{'text': text}]
          });
          return text;
        }
      }
      
      print('Gemini API Error: ${response.body}');
      return _getOfflineResponse(userMessage);
      
    } catch (e) {
      print('ChatService Error: $e');
      return _getOfflineResponse(userMessage);
    }
  }
  
  /// Get offline response when API fails
  String _getOfflineResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Pest control
    if (lowerQuery.contains('آفة') || lowerQuery.contains('حشر') || 
        lowerQuery.contains('pest') || lowerQuery.contains('bug') ||
        lowerQuery.contains('دود')) {
      return '''🐛 **نصائح مكافحة الآفات:**

1. **زيت النيم** - رش طبيعي وآمن
2. **الزراعة المصاحبة** - ازرع نباتات طاردة للحشرات
3. **الحشرات النافعة** - استخدم الدعسوقة والمن
4. **تدوير المحاصيل** - غيّر مكان الزراعة كل موسم
5. **الحواجز المادية** - استخدم الشباك والأغطية

💡 نصيحة: الوقاية خير من العلاج! 🌿''';
    }
    
    // Watering/Irrigation
    if (lowerQuery.contains('ري') || lowerQuery.contains('مية') || 
        lowerQuery.contains('water') || lowerQuery.contains('سقي')) {
      return '''💧 **نصائح الري الصحيح:**

1. **الري الصباحي** - أفضل وقت قبل الشمس
2. **الري العميق** - اسقي بعمق مش سطحي
3. **الري بالتنقيط** - يوفر المية ويحسن النمو
4. **التغطية** - غطي التربة للحفاظ على الرطوبة
5. **فحص التربة** - اتأكد إنها محتاجة مية قبل ما تسقي

⏰ نصيحة: اسقي كل 2-3 أيام حسب الطقس! 🌱''';
    }
    
    // Fertilizer
    if (lowerQuery.contains('سماد') || lowerQuery.contains('تسميد') || 
        lowerQuery.contains('fertiliz') || lowerQuery.contains('غذاء')) {
      return '''🌿 **دليل التسميد:**

1. **NPK** - نيتروجين للنمو، فوسفور للجذور، بوتاسيوم للثمار
2. **تحليل التربة** - اعرف التربة محتاجة إيه
3. **الأسمدة العضوية** - كمبوست وسماد بلدي
4. **التوقيت المناسب** - سمّد في بداية الموسم
5. **الكمية المناسبة** - الزيادة ضارة زي النقص

⚠️ نصيحة: السماد العضوي أفضل للتربة على المدى البعيد! 🌾''';
    }
    
    // Season/Planting
    if (lowerQuery.contains('موسم') || lowerQuery.contains('زراعة') || 
        lowerQuery.contains('plant') || lowerQuery.contains('وقت')) {
      return '''📅 **دليل المواسم الزراعية:**

🌸 **الموسم الصيفي (مارس-مايو):**
طماطم، خيار، فلفل، باذنجان

🍂 **الموسم الشتوي (سبتمبر-نوفمبر):**
فول، بصل، ثوم، كرنب، خس

🌱 **نصائح عامة:**
- جهز الأرض قبل الزراعة بأسبوعين
- استخدم بذور جيدة ومضمونة
- راعي المسافات بين النباتات

🗓️ التوقيت الصح = محصول ناجح! 🌾''';
    }
    
    // Default response
    return '''🌾 **أهلاً بيك!**

أنا عم عبده، مستشارك الزراعي. أقدر أساعدك في:

🌱 زراعة المحاصيل
🐛 مكافحة الآفات
💧 نصائح الري
🌿 التسميد والتغذية
📅 المواسم الزراعية

اسألني في أي حاجة تخص الزراعة وأنا تحت أمرك! 🧑‍🌾''';
  }
  
  /// Get suggestions based on AI response
  List<String> getSuggestions(String response) {
    final lowerResponse = response.toLowerCase();
    
    if (lowerResponse.contains('محصول') || 
        lowerResponse.contains('زراعة') ||
        lowerResponse.contains('نبات')) {
      return QuickSuggestions.cropRelated;
    }
    
    if (lowerResponse.contains('آفة') || 
        lowerResponse.contains('حشر') ||
        lowerResponse.contains('مرض')) {
      return QuickSuggestions.pestControl;
    }
    
    if (lowerResponse.contains('طقس') || 
        lowerResponse.contains('جو') ||
        lowerResponse.contains('حرارة')) {
      return QuickSuggestions.weather;
    }
    
    return QuickSuggestions.initial;
  }
  
  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }
}
