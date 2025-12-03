/// API Keys Configuration
/// 
/// IMPORTANT: Replace these placeholder values with your actual API keys.
/// 
/// For Google Gemini API:
/// 1. Go to https://makersuite.google.com/app/apikey
/// 2. Create a new API key (it's FREE!)
/// 3. Replace 'YOUR_GEMINI_API_KEY' with your actual key
/// 
/// SECURITY NOTE: 
/// - Never commit real API keys to version control
/// - Consider using environment variables for production
/// - Use Firebase Remote Config for secure key management

class ApiKeys {
  // Google Gemini API Key - Get yours free at https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyDFsD5Koq16ku1_JRm-qNlO_2vrbvBzzBE';
  
  // Check if API key is configured (returns true if key is set and not placeholder)
  static bool get isGeminiConfigured => 
      geminiApiKey != 'YOUR_GEMINI_API_KEY' && geminiApiKey.isNotEmpty;
}

