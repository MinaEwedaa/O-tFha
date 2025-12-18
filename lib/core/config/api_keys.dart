/// API Keys Configuration
/// 
/// SECURITY NOTE: 
/// - Never commit real API keys to version control
/// - Consider using environment variables for production
/// - Use Firebase Remote Config for secure key management
library;

class ApiKeys {
  // Google Gemini API Key
  // TODO: Replace with your API key from https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // HuggingFace API Key - Get yours at https://huggingface.co/settings/tokens
  // TODO: Replace with your HuggingFace token
  static const String huggingFaceApiKey = 'YOUR_HUGGINGFACE_API_KEY_HERE';
  
  // Check if API key is configured
  static bool get isGeminiConfigured => 
      geminiApiKey.isNotEmpty && geminiApiKey.startsWith('AIza');
  
  static bool get isHuggingFaceConfigured =>
      huggingFaceApiKey.isNotEmpty && huggingFaceApiKey.startsWith('hf_');
}
