import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import '../services/language_service.dart';
import '../services/schedule_service.dart';
import '../models/schedule_task.dart';
import '../core/theme/app_colors.dart';
import 'camera_screen.dart';
import 'crops_screen.dart';
import 'market_screen.dart';
import 'schedule_screen.dart';
import 'resources_screen.dart';
import 'expenses_screen.dart';
import 'profile_screen.dart';
import 'community_screen.dart';
import 'chat_screen.dart';
import 'seed_inventory_screen.dart';
import 'robot_control_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final ScheduleService _scheduleService = ScheduleService();
  final NotificationService _notificationService = NotificationService();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Single animation controller for initial fade-in only
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadWeather();
  }

  void _initAnimations() {
    // Single fade animation for entrance - runs once
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weatherData = await _weatherService.getCurrentWeather();
      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _isLoading = false;
          if (weatherData == null) {
            _errorMessage = 'Unable to fetch weather data';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    HapticFeedback.mediumImpact();
    bool hasPermission = await _weatherService.checkLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text('Location Permission'),
              ],
            ),
            content: const Text(
              'This app needs location permission to provide accurate weather information. Would you like to enable it in settings?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _weatherService.openLocationSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    } else {
      _loadWeather();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingArabic() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 6) return Icons.nights_stay_rounded;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_cloudy_rounded;
    if (hour < 20) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_rounded;
  }

  Color _getGreetingIconColor() {
    final hour = DateTime.now().hour;
    if (hour < 6) return Colors.indigo.shade400;
    if (hour < 12) return Colors.orange.shade400;
    if (hour < 17) return Colors.amber.shade500;
    if (hour < 20) return Colors.deepOrange.shade400;
    return Colors.indigo.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final languageService = Provider.of<LanguageService>(context);

    return Directionality(
      textDirection: languageService.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9F5),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Simple App Bar
                SliverToBoxAdapter(
                  child: _buildSimpleAppBar(context, user, languageService),
                ),
                
                // Greeting Section
                SliverToBoxAdapter(
                  child: _buildGreetingSection(user, languageService),
                ),
                
                // Weather Card
                SliverToBoxAdapter(
                  child: _buildModernWeatherCard(languageService),
                ),
                
                // Diagnose Card
                SliverToBoxAdapter(
                  child: _buildDiagnoseCard(context),
                ),
                
                // Quick Actions
                SliverToBoxAdapter(
                  child: _buildModernQuickActions(context, languageService),
                ),
                
                // Task Section
                SliverToBoxAdapter(
                  child: _buildModernTaskSection(context, languageService),
                ),
                
                // Bottom padding for nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(context, languageService),
      ),
    );
  }

  Widget _buildSimpleAppBar(BuildContext context, user, LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF5F9F5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.png',
              width: 52,
              height: 52,
              fit: BoxFit.contain,
            ),
          ),
          
          // Right side actions
          Row(
            children: [
              // Language toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  languageService.toggleLanguage();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        languageService.languageSwitch,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 10),
              
              // Notification bell with badge
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: StreamBuilder<int>(
                  stream: _notificationService.getUnreadCount(),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;
                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_rounded,
                            color: unreadCount > 0 
                                ? AppColors.primary 
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(user, LanguageService languageService) {
    final userName = user?.displayName ?? 
        (languageService.isArabic ? 'مزارع' : 'Farmer');
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: languageService.crossAxisAlignment,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getGreetingIcon(),
                      color: _getGreetingIconColor(),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      languageService.isArabic 
                          ? _getGreetingArabic()
                          : _getGreeting(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  languageService.isArabic 
                      ? 'لنجعل اليوم منتجاً! 🌱'
                      : "Let's make today productive! 🌱",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernWeatherCard(LanguageService languageService) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(24),
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00897B),
              const Color(0xFF00695C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_errorMessage != null || _weatherData == null) {
      return _buildWeatherPermissionCard(languageService);
    }

    return _buildWeatherDataCard(languageService);
  }

  Widget _buildWeatherPermissionCard(LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            languageService.locationPermissionRequired,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            languageService.enableLocationDescription,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _requestLocationPermission,
            icon: const Icon(Icons.location_on_rounded, size: 18),
            label: Text(
              languageService.enableLocation,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDataCard(LanguageService languageService) {
    final weather = _weatherData!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    languageService.weather,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _loadWeather();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          weather.locationName,
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Main weather content
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Weather icon
              Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Image.asset('assets/images/sun.png', fit: BoxFit.contain),
              ),
              
              const SizedBox(width: 16),
              
              // Temperature and condition
              Expanded(
                child: Column(
                  crossAxisAlignment: languageService.crossAxisAlignment,
                  children: [
                    Text(
                      '${languageService.today} • ${languageService.getDayOfWeek(weather.getDayOfWeek())}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: languageService.mainAxisAlignmentStart,
                      children: [
                        Text(
                          weather.temperatureC.toStringAsFixed(0),
                          style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, height: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('°C', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70)),
                        ),
                      ],
                    ),
                    Text(
                      languageService.getWeatherCondition(weather.condition),
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Weather details row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetailItem(Icons.wb_sunny_outlined, weather.sunrise, languageService.sunrise),
                _buildWeatherDetailDivider(),
                _buildWeatherDetailItem(Icons.nights_stay_outlined, weather.sunset, languageService.sunset),
                _buildWeatherDetailDivider(),
                _buildWeatherDetailItem(Icons.air_rounded, '${weather.windKph.toStringAsFixed(0)} km/h', languageService.wind),
                _buildWeatherDetailDivider(),
                _buildWeatherDetailItem(Icons.water_drop_outlined, '${weather.humidity}%', languageService.humidity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetailDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildDiagnoseCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        },
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Main image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/Diagnose_in_one.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160,
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
              // Tap indicator
              Positioned(
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_rounded, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Scan Now',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                      ),
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

  Widget _buildModernQuickActions(BuildContext context, LanguageService languageService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  languageService.isArabic ? 'الوصول السريع' : 'Quick Access',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '6 ${languageService.isArabic ? 'خدمات' : 'services'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons grid - First row (4 items)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildModernActionButton(
                languageService.myCrops,
                Icons.eco_rounded,
                const Color(0xFF4CAF50),
                const Color(0xFF388E3C),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CropsScreen()),
                ),
              ),
              _buildModernActionButton(
                languageService.market,
                Icons.storefront_rounded,
                const Color(0xFFE53935),
                const Color(0xFFC62828),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MarketScreen()),
                ),
              ),
              _buildModernActionButton(
                languageService.expenses,
                Icons.account_balance_wallet_rounded,
                const Color(0xFF42A5F5),
                const Color(0xFF1976D2),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpensesScreen()),
                ),
              ),
              _buildModernActionButton(
                languageService.resources,
                Icons.agriculture_rounded,
                const Color(0xFFFF9800),
                const Color(0xFFF57C00),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResourcesScreen()),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Community Services Card
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.people_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: languageService.crossAxisAlignment,
                      children: [
                        Text(languageService.community, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(languageService.connectWithFarmers, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(
                    languageService.isArabic ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Seed Inventory Card
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SeedInventoryScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF795548), Color(0xFF5D4037)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🌱', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: languageService.crossAxisAlignment,
                      children: [
                        Text(languageService.isArabic ? 'مخزون البذور' : 'Seed Inventory', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(languageService.isArabic ? 'تتبع البذور والصلاحية' : 'Track seeds & expiry', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(
                    languageService.isArabic ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton(
    String label,
    IconData icon,
    Color color1,
    Color color2,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTaskSection(BuildContext context, LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F9F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.task_alt_rounded,
                        color: AppColors.info,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: languageService.crossAxisAlignment,
                      children: [
                        Text(
                          languageService.yourTaskToday,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScheduleScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    languageService.schedule,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks list
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: StreamBuilder<List<ScheduleTask>>(
              stream: _scheduleService.getTodaysTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildTaskError(languageService);
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return _buildEmptyTasks(languageService);
                }

                return Column(
                  children: tasks.take(3).map((task) {
                    return _buildModernTaskItem(task, languageService);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskError(LanguageService languageService) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            languageService.isArabic
                ? 'خطأ في تحميل المهام'
                : 'Error loading tasks',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            languageService.isArabic
                ? 'يرجى المحاولة لاحقاً'
                : 'Please try again later',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {});
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              languageService.isArabic ? 'إعادة المحاولة' : 'Retry',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasks(LanguageService languageService) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            languageService.isArabic 
                ? 'لا توجد مهام لهذا اليوم'
                : 'No tasks for today',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            languageService.isArabic 
                ? 'استمتع بيومك! 🌾'
                : 'Enjoy your day! 🌾',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTaskItem(ScheduleTask task, LanguageService languageService) {
    final timeFormat = DateFormat('hh:mm a');
    final startTime = timeFormat.format(task.startDateTime);
    final endTime = timeFormat.format(task.endDateTime);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        _scheduleService.toggleTaskCompletion(task.id, !task.isCompleted);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: task.isCompleted 
              ? AppColors.success.withOpacity(0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted 
                ? AppColors.success.withOpacity(0.3)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Animated checkbox
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _scheduleService.toggleTaskCompletion(task.id, !task.isCompleted);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: task.isCompleted 
                      ? AppColors.success 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.isCompleted 
                        ? AppColors.success 
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
            ),
            
            const SizedBox(width: 14),
            
            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: languageService.crossAxisAlignment,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted 
                          ? AppColors.textTertiary 
                          : AppColors.textPrimary,
                      decoration: task.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$startTime - $endTime',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.agriculture_rounded,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  task.farmName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Swipe hint icon
            Icon(
              Icons.chevron_left_rounded,
              color: Colors.grey.shade300,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, LanguageService languageService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Community Button
                _buildNavItem(
                  context: context,
                  icon: Icons.people_rounded,
                  label: languageService.isArabic ? 'المجتمع' : 'Community',
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CommunityScreen()),
                    );
                  },
                ),
                
                // Robot Control Button
                _buildNavItem(
                  context: context,
                  icon: Icons.agriculture_rounded,
                  label: languageService.isArabic ? 'الروبوت' : 'Robot',
                  color: const Color(0xFF009688),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RobotControlScreen()),
                    );
                  },
                ),
                
                // Camera Button (Center)
                _buildCenterCameraButton(context, languageService),
                
                // Chatbot Button
                _buildNavItem(
                  context: context,
                  icon: Icons.psychology_alt_rounded,
                  label: '3bdo',
                  color: const Color(0xFF00897B),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                ),
                
                // Profile Button
                _buildNavItem(
                  context: context,
                  icon: Icons.person_rounded,
                  label: languageService.isArabic ? 'الملف' : 'Profile',
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCameraButton(BuildContext context, LanguageService languageService) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        );
      },
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF00695C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 2),
            Text(
              languageService.isArabic ? 'كاميرا' : 'Scan',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
