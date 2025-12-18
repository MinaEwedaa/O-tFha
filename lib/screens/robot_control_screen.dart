import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../services/language_service.dart';

class RobotControlScreen extends StatefulWidget {
  const RobotControlScreen({super.key});

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> with SingleTickerProviderStateMixin {
  // Mock sensor data
  double _temperature = 25.5;
  double _humidity = 65.0;
  bool _isConnected = true;
  String _status = 'Ready';
  int _batteryLevel = 85;
  
  // Control state
  String _lastCommand = '';
  
  // Timer for updating mock sensor data
  late Timer _sensorTimer;
  late Timer _batteryTimer;
  
  // Animation controller for sensor updates
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Simulate sensor data updates every 2 seconds
    _sensorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _animationController.forward(from: 0.0).then((_) {
          _animationController.reverse();
        });
        setState(() {
          // Simulate realistic temperature variations (20-30°C)
          _temperature = 20 + (Random().nextDouble() * 10);
          // Simulate realistic humidity variations (50-80%)
          _humidity = 50 + (Random().nextDouble() * 30);
        });
      }
    });
    
    // Simulate battery drain slowly
    _batteryTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _batteryLevel > 0) {
        setState(() {
          _batteryLevel = (_batteryLevel - 1).clamp(0, 100);
        });
      }
    });
  }

  @override
  void dispose() {
    _sensorTimer.cancel();
    _batteryTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDirection(String direction) {
    HapticFeedback.mediumImpact();
    setState(() {
      _lastCommand = direction;
      _status = 'Moving $direction';
    });
    
    // Reset status after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _status = 'Ready';
          _lastCommand = '';
        });
      }
    });
  }

  void _handleStop() {
    HapticFeedback.heavyImpact();
    setState(() {
      _status = 'Stopped';
      _lastCommand = '';
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _status = 'Ready';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(languageService),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildConnectionStatus(languageService),
                      const SizedBox(height: 20),
                      _buildSensorCards(languageService),
                      const SizedBox(height: 20),
                      _buildBatteryCard(languageService),
                      const SizedBox(height: 30),
                      _buildControlPanel(languageService),
                      const SizedBox(height: 20),
                      _buildStatusCard(languageService),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.defaultShadow],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageService.isArabic ? 'تحكم الروبوت' : 'Robot Control',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  languageService.isArabic ? 'مراقبة ومراقبة الروبوت الزراعي' : 'Monitor & Control Agricultural Robot',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isConnected ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.defaultShadow],
            ),
            child: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isConnected
              ? [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)]
              : [AppColors.error.withOpacity(0.1), AppColors.error.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isConnected ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isConnected ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isConnected ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageService.isArabic
                      ? (_isConnected ? 'متصل' : 'غير متصل')
                      : (_isConnected ? 'Connected' : 'Disconnected'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  languageService.isArabic
                      ? 'الروبوت متصل ويعمل بشكل طبيعي'
                      : 'Robot is connected and operational',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCards(LanguageService languageService) {
    return Row(
      children: [
        Expanded(
          child: _buildSensorCard(
            icon: Icons.thermostat,
            label: languageService.isArabic ? 'درجة الحرارة' : 'Temperature',
            value: '${_temperature.toStringAsFixed(1)}°C',
            color: AppColors.error,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFE53935)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSensorCard(
            icon: Icons.water_drop,
            label: languageService.isArabic ? 'الرطوبة' : 'Humidity',
            value: '${_humidity.toStringAsFixed(1)}%',
            color: AppColors.info,
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animationController.value * 0.05),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 + (_animationController.value * 0.2)),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatteryCard(LanguageService languageService) {
    Color batteryColor = _batteryLevel > 50
        ? AppColors.success
        : _batteryLevel > 20
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadow],
        border: Border.all(
          color: batteryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: batteryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _batteryLevel > 50
                  ? Icons.battery_full_rounded
                  : _batteryLevel > 20
                      ? Icons.battery_3_bar_rounded
                      : Icons.battery_alert_rounded,
              color: batteryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      languageService.isArabic ? 'مستوى البطارية' : 'Battery Level',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$_batteryLevel%',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: batteryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _batteryLevel / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          Text(
            languageService.isArabic ? 'أزرار التحكم' : 'Control Buttons',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          // Up button
          _buildDirectionButton(
            icon: Icons.arrow_upward_rounded,
            label: languageService.isArabic ? 'أعلى' : 'Up',
            onPressed: () => _handleDirection('Up'),
            isActive: _lastCommand == 'Up',
          ),
          const SizedBox(height: 16),
          // Left, Stop, Right row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDirectionButton(
                icon: Icons.arrow_back_rounded,
                label: languageService.isArabic ? 'يسار' : 'Left',
                onPressed: () => _handleDirection('Left'),
                isActive: _lastCommand == 'Left',
              ),
              _buildStopButton(languageService),
              _buildDirectionButton(
                icon: Icons.arrow_forward_rounded,
                label: languageService.isArabic ? 'يمين' : 'Right',
                onPressed: () => _handleDirection('Right'),
                isActive: _lastCommand == 'Right',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Down button
          _buildDirectionButton(
            icon: Icons.arrow_downward_rounded,
            label: languageService.isArabic ? 'أسفل' : 'Down',
            onPressed: () => _handleDirection('Down'),
            isActive: _lastCommand == 'Down',
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: isActive
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primaryDark.withOpacity(0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [AppColors.defaultShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isActive ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopButton(LanguageService languageService) {
    return GestureDetector(
      onTap: _handleStop,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF44336), Color(0xFFC62828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.stop_rounded,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              languageService.isArabic ? 'إيقاف' : 'Stop',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryDark.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageService.isArabic ? 'الحالة الحالية' : 'Current Status',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _status,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

