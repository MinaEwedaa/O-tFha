/// Application configuration constants
class AppConfig {
  // App Info
  static const String appName = 'Otfha';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'http://10.0.2.2:5000/v1';
  static const String weatherApiKey = 'b379950557f94a44ade90852252911';
  static const String weatherApiBaseUrl = 'http://api.weatherapi.com/v1';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String schedulesCollection = 'schedules';
  static const String resourcesCollection = 'resources';
  static const String cropsCollection = 'crops';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String cartCollection = 'cart';
  static const String expensesCollection = 'expenses';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String resourceImagesPath = 'resources';
  static const String cropImagesPath = 'crops';
  static const String productImagesPath = 'products';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = true;
  
  // Business Rules
  static const double minOrderAmount = 10.0;
  static const int maxCartItems = 50;
  static const int taskReminderMinutes = 30;
}


















