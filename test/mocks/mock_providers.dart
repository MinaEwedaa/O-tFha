import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Test wrapper that provides all necessary providers for widget testing
/// 
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   TestWrapper(
///     child: LoginScreen(),
///   ),
/// );
/// ```
class TestWrapper extends StatelessWidget {
  final Widget child;
  final List<NavigatorObserver>? navigatorObservers;
  final String? initialRoute;
  final Map<String, WidgetBuilder>? routes;
  final ThemeData? theme;
  
  const TestWrapper({
    super.key,
    required this.child,
    this.navigatorObservers,
    this.initialRoute,
    this.routes,
    this.theme,
  });
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockLanguageService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: child,
        initialRoute: initialRoute,
        routes: routes ?? {},
        navigatorObservers: navigatorObservers ?? [],
      ),
    );
  }
}

/// Mock LanguageService for testing
class MockLanguageService extends ChangeNotifier {
  String _currentLanguage = 'en';
  bool _isArabic = false;
  
  String get currentLanguage => _currentLanguage;
  bool get isArabic => _isArabic;
  
  void setLanguage(String language) {
    _currentLanguage = language;
    _isArabic = language == 'ar';
    notifyListeners();
  }
  
  void toggleLanguage() {
    _isArabic = !_isArabic;
    _currentLanguage = _isArabic ? 'ar' : 'en';
    notifyListeners();
  }
  
  // Translation helper - returns key in test mode
  String translate(String key) {
    return key;
  }
}

/// Mock NavigatorObserver for tracking navigation
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];
  final List<Route<dynamic>> replacedRoutes = [];
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      replacedRoutes.add(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
  
  /// Get last pushed route name
  String? get lastPushedRouteName {
    if (pushedRoutes.isEmpty) return null;
    return pushedRoutes.last.settings.name;
  }
  
  /// Check if route was pushed
  bool wasRoutePushed(String routeName) {
    return pushedRoutes.any((route) => route.settings.name == routeName);
  }
  
  /// Reset tracking
  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
    replacedRoutes.clear();
  }
}

/// Mock scaffold messenger for testing snackbars
class MockScaffoldMessengerState {
  final List<SnackBar> shownSnackBars = [];
  
  void showSnackBar(SnackBar snackBar) {
    shownSnackBars.add(snackBar);
  }
  
  void reset() {
    shownSnackBars.clear();
  }
}

// Note: WidgetTester extensions are defined in test files that import flutter_test
// Import flutter_test in your test file to use these patterns:
//
// Example usage in test files:
// ```dart
// await tester.pumpWidget(TestWrapper(child: MyWidget()));
// await tester.enterText(find.byKey(Key('email')), 'test@example.com');
// await tester.tap(find.text('Submit'));
// await tester.pumpAndSettle();
// ```

