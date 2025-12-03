import 'package:flutter/material.dart';
// Import existing screens from old structure (to be migrated)
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/forgot_password_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/crops_screen.dart';
import '../../screens/crop_detail_screen.dart';
import '../../screens/new_crop_screen.dart';
import '../../screens/market_screen.dart';
import '../../screens/product_detail_screen.dart';
import '../../screens/cart_screen.dart';
import '../../screens/checkout_screen.dart';
import '../../screens/schedule_screen.dart';
import '../../screens/new_schedule_screen.dart';
import '../../screens/resources_screen.dart';
import '../../screens/resource_detail_screen.dart';
import '../../screens/add_resource_screen.dart';
import '../../screens/expenses_screen.dart';
import '../../screens/camera_screen.dart';
import '../../screens/result_screen.dart' as result_screen;
import '../../screens/loan_application_screen.dart';

/// App route names
class Routes {
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  // Main routes
  static const String home = '/home';
  
  // Crops routes
  static const String crops = '/crops';
  static const String cropDetail = '/crop-detail';
  static const String newCrop = '/new-crop';
  
  // Market routes
  static const String market = '/market';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  
  // Schedule routes
  static const String schedule = '/schedule';
  static const String newSchedule = '/new-schedule';
  
  // Resources routes
  static const String resources = '/resources';
  static const String resourceDetail = '/resource-detail';
  static const String addResource = '/add-resource';
  
  // Expenses routes
  static const String expenses = '/expenses';
  
  // Diagnosis routes
  static const String camera = '/camera';
  static const String diagnosisResult = '/diagnosis-result';
  
  // Loans routes
  static const String loanApplication = '/loan-application';
}

/// Route generator for named routes
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      // Main routes
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      // Crops routes
      case Routes.crops:
        return MaterialPageRoute(builder: (_) => const CropsScreen());
      case Routes.cropDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CropDetailScreen(
            crop: args?['crop'],
          ),
        );
      case Routes.newCrop:
        return MaterialPageRoute(builder: (_) => const NewCropScreen());
      
      // Market routes
      case Routes.market:
        return MaterialPageRoute(builder: (_) => const MarketScreen());
      case Routes.productDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: args?['product'],
          ),
        );
      case Routes.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case Routes.checkout:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            cartItems: args?['cartItems'] ?? [],
            deliveryFees: args?['deliveryFees'] ?? 0.0,
            taxes: args?['taxes'] ?? 0.0,
            discount: args?['discount'] ?? 0.0,
            total: args?['total'] ?? 0.0,
          ),
        );
      
      // Schedule routes
      case Routes.schedule:
        return MaterialPageRoute(builder: (_) => const ScheduleScreen());
      case Routes.newSchedule:
        return MaterialPageRoute(builder: (_) => const NewScheduleScreen());
      
      // Resources routes
      case Routes.resources:
        return MaterialPageRoute(builder: (_) => const ResourcesScreen());
      case Routes.resourceDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResourceDetailScreen(
            resource: args?['resource'],
          ),
        );
      case Routes.addResource:
        return MaterialPageRoute(builder: (_) => const AddResourceScreen());
      
      // Expenses routes
      case Routes.expenses:
        return MaterialPageRoute(builder: (_) => const ExpensesScreen());
      
      // Diagnosis routes
      case Routes.camera:
        return MaterialPageRoute(builder: (_) => const CameraScreen());
      case Routes.diagnosisResult:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => result_screen.ResultScreen(
            result: args?['result'],
            imageFile: args?['imageFile'],
          ),
        );
      
      // Loans routes
      case Routes.loanApplication:
        return MaterialPageRoute(builder: (_) => const LoanApplicationScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}

