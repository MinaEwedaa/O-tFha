import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Voice Service for accessibility features
/// Provides speech-to-text and text-to-speech for farmers who can't read/write
class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastWords = '';
  String _currentLocale = 'ar-EG'; // Default to Egyptian Arabic
  
  // Callbacks
  Function(String)? onResult;
  Function(bool)? onListeningStateChange;
  Function(bool)? onSpeakingStateChange;
  Function(String)? onError;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;

  /// Initialize the voice service
  Future<void> initialize() async {
    await _initSpeechToText();
    await _initTextToSpeech();
  }

  /// Initialize Speech-to-Text
  Future<void> _initSpeechToText() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          _isListening = false;
          onListeningStateChange?.call(false);
          
          // Provide user-friendly error messages
          String errorMessage;
          if (error.errorMsg.contains('timeout') || error.errorMsg == 'error_speech_timeout') {
            errorMessage = 'لم يتم سماع صوتك. تأكد من التحدث بوضوح والميكروفون يعمل';
          } else if (error.errorMsg.contains('network') || error.errorMsg.contains('internet')) {
            errorMessage = 'تحقق من اتصال الإنترنت للتعرف على الصوت';
          } else if (error.errorMsg.contains('permission')) {
            errorMessage = 'يرجى السماح بالوصول للميكروفون من الإعدادات';
          } else if (error.errorMsg.contains('busy') || error.errorMsg.contains('unavailable')) {
            errorMessage = 'خدمة التعرف على الصوت مشغولة، حاول مرة أخرى';
          } else {
            errorMessage = 'خطأ في التعرف على الصوت: ${error.errorMsg}';
          }
          onError?.call(errorMessage);
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            onListeningStateChange?.call(false);
          }
        },
      );
      
      if (_speechEnabled) {
        // Get available locales and prefer Arabic
        var locales = await _speechToText.locales();
        debugPrint('Available locales: ${locales.map((l) => l.localeId).toList()}');
        
        // Try to find Arabic locale
        var arabicLocale = locales.firstWhere(
          (locale) => locale.localeId.startsWith('ar'),
          orElse: () => locales.first,
        );
        _currentLocale = arabicLocale.localeId;
        debugPrint('Selected locale: $_currentLocale');
      } else {
        debugPrint('Speech recognition not available on this device');
      }
    } catch (e) {
      debugPrint('Failed to initialize speech recognition: $e');
      _speechEnabled = false;
    }
  }

  /// Initialize Text-to-Speech
  Future<void> _initTextToSpeech() async {
    try {
      // Set up TTS
      await _flutterTts.setLanguage('ar-EG'); // Egyptian Arabic
      await _flutterTts.setSpeechRate(0.5); // Slower for clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // Get available languages
      var languages = await _flutterTts.getLanguages;
      debugPrint('Available TTS languages: $languages');
      
      // Set completion handler
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        onSpeakingStateChange?.call(false);
      });
      
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        onSpeakingStateChange?.call(true);
      });
      
      _flutterTts.setErrorHandler((error) {
        debugPrint('TTS error: $error');
        _isSpeaking = false;
        onSpeakingStateChange?.call(false);
      });
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
    }
  }

  /// Start listening to voice input
  Future<void> startListening() async {
    if (!_speechEnabled) {
      onError?.call('التعرف على الصوت غير متاح');
      return;
    }
    
    if (_isListening) {
      await stopListening();
      return;
    }

    // Stop any ongoing speech
    if (_isSpeaking) {
      await stopSpeaking();
    }

    _lastWords = '';
    _isListening = true;
    onListeningStateChange?.call(true);

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 60), // Increased from 30s
        pauseFor: const Duration(seconds: 5),   // Increased from 3s for more time between words
        localeId: _currentLocale,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false, // Don't cancel on errors, let user try to continue
          listenMode: ListenMode.dictation, // Better for continuous speech
        ),
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _isListening = false;
      onListeningStateChange?.call(false);
      onError?.call('فشل في بدء التسجيل الصوتي. تأكد من اتصال الإنترنت وصلاحيات الميكروفون');
    }
  }

  /// Handle speech recognition result
  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    debugPrint('Recognized: $_lastWords (final: ${result.finalResult})');
    
    if (result.finalResult && _lastWords.isNotEmpty) {
      _isListening = false;
      onListeningStateChange?.call(false);
      onResult?.call(_lastWords);
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      onListeningStateChange?.call(false);
    }
  }

  /// Speak text aloud (Text-to-Speech)
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    // Stop any ongoing speech
    if (_isSpeaking) {
      await stopSpeaking();
    }
    
    // Clean up text for better speech
    String cleanText = _cleanTextForSpeech(text);
    
    _isSpeaking = true;
    onSpeakingStateChange?.call(true);
    
    try {
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('TTS error: $e');
      _isSpeaking = false;
      onSpeakingStateChange?.call(false);
    }
  }

  /// Clean text for better speech output
  String _cleanTextForSpeech(String text) {
    return text
        // Remove markdown formatting
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'_'), '')
        .replaceAll(RegExp(r'`'), '')
        // Remove bullet points
        .replaceAll('•', '')
        .replaceAll('- ', '')
        // Remove emojis (basic)
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        // Remove extra whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      onSpeakingStateChange?.call(false);
    }
  }

  /// Toggle language between Arabic and English
  Future<void> toggleLanguage() async {
    if (_currentLocale.startsWith('ar')) {
      _currentLocale = 'en-US';
      await _flutterTts.setLanguage('en-US');
    } else {
      _currentLocale = 'ar-EG';
      await _flutterTts.setLanguage('ar-EG');
    }
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  /// Dispose resources
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
  }
}

