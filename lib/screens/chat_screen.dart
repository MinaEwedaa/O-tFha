import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/voice_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _showSuggestions = true;
  List<String> _currentSuggestions = QuickSuggestions.initial;
  
  // Voice states
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _currentlySpeakingMessageId;
  
  // Animation controllers
  late AnimationController _welcomeController;
  late AnimationController _typingController;
  late AnimationController _micPulseController;
  late Animation<double> _welcomeAnimation;
  late Animation<double> _typingAnimation;
  late Animation<double> _micPulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initVoiceService();
    _addWelcomeMessage();
  }

  void _initAnimations() {
    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _welcomeAnimation = CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.easeOutBack,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _typingAnimation = Tween<double>(begin: 0, end: 1).animate(_typingController);

    // Mic pulse animation for listening state
    _micPulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _micPulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );

    _welcomeController.forward();
  }

  Future<void> _initVoiceService() async {
    await _voiceService.initialize();
    
    // Set up callbacks
    _voiceService.onResult = (String text) {
      if (text.isNotEmpty) {
        _sendMessage(text);
      }
    };
    
    _voiceService.onListeningStateChange = (bool isListening) {
      setState(() {
        _isListening = isListening;
      });
      if (isListening) {
        _micPulseController.repeat(reverse: true);
      } else {
        _micPulseController.stop();
        _micPulseController.reset();
      }
    };
    
    _voiceService.onSpeakingStateChange = (bool isSpeaking) {
      setState(() {
        _isSpeaking = isSpeaking;
        if (!isSpeaking) {
          _currentlySpeakingMessageId = null;
        }
      });
    };
    
    _voiceService.onError = (String error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    };
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    _typingController.dispose();
    _micPulseController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      id: 'welcome',
      content: '''👋 **أهلاً يا فلاح!**

أنا **عم عبده**، مستشارك الزراعي بالذكاء الاصطناعي. أنا هنا عشان أساعدك في:

🌱 إدارة المحاصيل والتخطيط
🐛 مكافحة الآفات والأمراض  
💧 تحسين الري
🌿 نصائح الزراعة العضوية
📅 إرشادات موسمية

إزاي أقدر أساعدك النهارده؟''',
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: QuickSuggestions.initial,
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    HapticFeedback.lightImpact();
    _messageController.clear();
    _focusNode.unfocus();

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _showSuggestions = false;
    });

    _scrollToBottom();

    // Get response from chat service
    final response = await _chatService.sendMessage(text);

    // Add AI response
    final aiMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: _chatService.getSuggestions(response),
    );

    setState(() {
      _messages.add(aiMessage);
      _isTyping = false;
      _currentSuggestions = aiMessage.suggestions ?? QuickSuggestions.initial;
      _showSuggestions = true;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('Clear Chat'),
          ],
        ),
        content: const Text('Are you sure you want to clear the conversation? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _chatService.clearHistory();
                _addWelcomeMessage();
                _showSuggestions = true;
                _currentSuggestions = QuickSuggestions.initial;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PatternPainter(),
                      ),
                    ),
                    // Chat messages
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageBubble(_messages[index], index);
                      },
                    ),
                  ],
                ),
              ),
              // Suggestions
              if (_showSuggestions && !_isTyping) _buildSuggestions(),
              // Input field
              _buildInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          // Bot avatar with animation
          ScaleTransition(
            scale: _welcomeAnimation,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "A'm Abdo",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isSpeaking 
                            ? AppColors.accent 
                            : _isListening 
                                ? AppColors.error 
                                : AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isSpeaking 
                                ? AppColors.accent 
                                : _isListening 
                                    ? AppColors.error 
                                    : AppColors.success).withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isSpeaking 
                          ? 'بيتكلم... 🔊' 
                          : _isListening 
                              ? 'بيسمعك... 🎤' 
                              : 'مستشار زراعي • متاح',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Clear chat button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.grey.shade600, size: 22),
              onPressed: _clearChat,
              tooltip: 'Clear chat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isUser;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 200)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // Clamp value to ensure opacity stays within valid range
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(isUser ? 30 * (1 - clampedValue) : -30 * (1 - clampedValue), 0),
          child: Opacity(opacity: clampedValue, child: child),
        );
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: isUser ? 50 : 0,
            right: isUser ? 0 : 50,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _buildBotAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser ? AppColors.primary : Colors.black).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormattedText(
                        message.content,
                        isUser ? Colors.white : AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: isUser ? Colors.white70 : AppColors.textTertiary,
                            ),
                          ),
                          // Speaker button for AI messages (accessibility)
                          if (!isUser) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _speakMessage(message),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _currentlySpeakingMessageId == message.id
                                      ? AppColors.primary
                                      : AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _currentlySpeakingMessageId == message.id
                                          ? Icons.stop_rounded
                                          : Icons.volume_up_rounded,
                                      size: 14,
                                      color: _currentlySpeakingMessageId == message.id
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _currentlySpeakingMessageId == message.id
                                          ? 'إيقاف'
                                          : 'استمع',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _currentlySpeakingMessageId == message.id
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                _buildUserAvatar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text, Color baseColor) {
    // Simple markdown-like formatting
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      if (line.startsWith('**') && line.endsWith('**')) {
        // Bold text
        widgets.add(Text(
          line.replaceAll('**', ''),
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: baseColor,
          ),
        ));
      } else if (line.startsWith('• ')) {
        // Bullet point
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(color: baseColor, fontSize: 14)),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: GoogleFonts.poppins(fontSize: 14, color: baseColor, height: 1.4),
                ),
              ),
            ],
          ),
        ));
      } else if (line.contains('**')) {
        // Inline bold
        widgets.add(_buildInlineBold(line, baseColor));
      } else {
        widgets.add(Text(
          line,
          style: GoogleFonts.poppins(fontSize: 14, color: baseColor, height: 1.5),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildInlineBold(String text, Color baseColor) {
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];
    var lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: GoogleFonts.poppins(fontSize: 14, color: baseColor),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: baseColor),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: GoogleFonts.poppins(fontSize: 14, color: baseColor),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 18),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 8, bottom: 8),
      child: Row(
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final progress = (_typingAnimation.value + delay) % 1.0;
                    final bounce = math.sin(progress * math.pi);
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      child: Transform.translate(
                        offset: Offset(0, -4 * bounce),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.4 + 0.6 * bounce),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _currentSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _currentSuggestions[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value.clamp(0.0, 1.2), // Allow slight overshoot for scale but not too much
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => _sendMessage(suggestion),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    suggestion,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice mode indicator
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _micPulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _micPulseAnimation.value,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'جاري الاستماع... اتكلم دلوقتي',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // Microphone button
              _buildVoiceButton(),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.poppins(fontSize: 15),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'اكتب أو اضغط على المايك للتحدث...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _sendMessage(_messageController.text),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (_isListening) {
          _voiceService.stopListening();
        } else {
          _voiceService.startListening();
        }
      },
      child: AnimatedBuilder(
        animation: _micPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _micPulseAnimation.value : 1.0,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isListening
                      ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                      : [AppColors.accent, AppColors.accentDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? AppColors.error : AppColors.accent)
                        .withOpacity(0.4),
                    blurRadius: _isListening ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Speak a message aloud
  void _speakMessage(ChatMessage message) {
    HapticFeedback.lightImpact();
    if (_isSpeaking && _currentlySpeakingMessageId == message.id) {
      _voiceService.stopSpeaking();
    } else {
      setState(() {
        _currentlySpeakingMessageId = message.id;
      });
      _voiceService.speak(message.content);
    }
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Background pattern painter
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    const radius = 3.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

