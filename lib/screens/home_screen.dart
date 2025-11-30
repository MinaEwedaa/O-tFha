import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import '../services/language_service.dart';
import '../services/schedule_service.dart';
import '../models/schedule_task.dart';
import 'camera_screen.dart';
import 'crops_screen.dart';
import 'market_screen.dart';
import 'schedule_screen.dart';
import 'resources_screen.dart';
import 'expenses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final ScheduleService _scheduleService = ScheduleService();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWeather();
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
    bool hasPermission = await _weatherService.checkLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'This app needs location permission to provide accurate weather information. Would you like to enable it in settings?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _weatherService.openLocationSettings();
                },
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

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final languageService = Provider.of<LanguageService>(context);

    return Directionality(
      textDirection: languageService.textDirection,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Custom App Bar
                  _buildAppBar(context, user, languageService),
                  
                  const SizedBox(height: 16),
                  
                  // Weather Card
                  _buildWeatherCard(languageService),
                  
                  const SizedBox(height: 16),
                  
                  // Diagnose Card
                  _buildDiagnoseCard(context),
                  
                  const SizedBox(height: 16),
                  
                  // Four Icon Buttons
                  _buildQuickActions(context, languageService),
                  
                  const SizedBox(height: 16),
                  
                  // Task Section
                  _buildTaskSection(context, languageService),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, user, LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // O'tfha Logo
          Image.asset(
            'assets/images/logo.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          
          // Right side icons
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  languageService.toggleLanguage();
                },
                child: Text(
                  languageService.languageSwitch,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.teal.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.language, color: Colors.teal.shade600, size: 20),
              const SizedBox(width: 12),
              Icon(Icons.notifications_outlined, color: Colors.teal.shade600, size: 24),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  final authService = AuthService();
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.teal.shade700,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(LanguageService languageService) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_errorMessage != null || _weatherData == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              languageService.locationPermissionRequired,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              languageService.enableLocationDescription,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestLocationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                languageService.enableLocation,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Display weather data
    final weather = _weatherData!;
    IconData weatherIcon = Icons.wb_sunny;
    
    final iconType = weather.getWeatherIcon();
    switch (iconType) {
      case 'sunny':
        weatherIcon = Icons.wb_sunny;
        break;
      case 'cloudy':
        weatherIcon = Icons.cloud;
        break;
      case 'rainy':
        weatherIcon = Icons.umbrella;
        break;
      case 'snowy':
        weatherIcon = Icons.ac_unit;
        break;
      case 'thunderstorm':
        weatherIcon = Icons.thunderstorm;
        break;
      case 'foggy':
        weatherIcon = Icons.foggy;
        break;
      default:
        weatherIcon = Icons.wb_cloudy;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageService.weather,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadWeather,
                    iconSize: 20,
                  ),
                  Text(
                    weather.locationName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Weather Content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Weather icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  weatherIcon,
                  color: Colors.yellow.shade300,
                  size: 48,
                ),
              ),
              
              // Right side - Weather info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: languageService.isArabic ? 0 : 16,
                    right: languageService.isArabic ? 16 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: languageService.crossAxisAlignment,
                    children: [
                      Text(
                        '${languageService.today} - ${languageService.getDayOfWeek(weather.getDayOfWeek())}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: languageService.mainAxisAlignmentStart,
                        children: [
                          Text(
                            '${weather.temperatureC.toStringAsFixed(1)} °C',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                languageService.getWeatherCondition(weather.condition),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: languageService.textAlign,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Weather details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail('${languageService.sunrise}: ${weather.sunrise}'),
              _buildWeatherDetail('${languageService.sunset}: ${weather.sunset}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail('${languageService.wind}: ${weather.windKph.toStringAsFixed(1)} km/h'),
              _buildWeatherDetail('${languageService.humidity}: ${weather.humidity}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 11,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildDiagnoseCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CameraScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/Diagnose_in_one.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, LanguageService languageService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            languageService.myCrops,
            Icons.eco,
            Colors.green.shade400,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CropsScreen(),
                ),
              );
            },
          ),
          _buildActionButton(
            languageService.market,
            Icons.shopping_basket,
            Colors.red.shade400,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarketScreen(),
                ),
              );
            },
          ),
          _buildActionButton(
            languageService.expenses,
            Icons.description,
            Colors.blue.shade300,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpensesScreen(),
                ),
              );
            },
          ),
          _buildActionButton(
            languageService.resources,
            Icons.agriculture,
            Colors.orange.shade400,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResourcesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context, LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyan.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.shade100),
      ),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageService.yourTaskToday,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleScreen(),
                    ),
                  );
                },
                child: Text(
                  languageService.schedule,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Tasks list
          StreamBuilder<List<ScheduleTask>>(
            stream: _scheduleService.getTodaysTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                print('Error in task stream: ${snapshot.error}');
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.orange.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageService.isArabic
                            ? 'خطأ في تحميل المهام'
                            : 'Error loading tasks',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        languageService.isArabic
                            ? 'يرجى المحاولة لاحقاً'
                            : 'Please try again later',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            // Trigger rebuild to retry
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text(
                          languageService.isArabic ? 'إعادة المحاولة' : 'Retry',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final tasks = snapshot.data ?? [];

              if (tasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageService.isArabic 
                            ? 'لا توجد مهام لهذا اليوم'
                            : 'No tasks for today',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: tasks.take(3).map((task) {
                  return _buildTaskItem(task, languageService);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(ScheduleTask task, LanguageService languageService) {
    final timeFormat = DateFormat('hh:mm a');
    final startTime = timeFormat.format(task.startDateTime);
    final endTime = timeFormat.format(task.endDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              _scheduleService.toggleTaskCompletion(task.id, !task.isCompleted);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.teal.shade400 : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? Colors.teal.shade400 : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: languageService.crossAxisAlignment,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '$startTime - $endTime',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.agriculture, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.farmName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


