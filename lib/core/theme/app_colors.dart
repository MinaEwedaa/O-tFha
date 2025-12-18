import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF009688); // Teal
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00796B);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50); // Green
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFF57C00);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFFAFAFA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFBDBDBD);
  
  // Component Specific
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color chipBackground = Color(0xFFE0F2F1);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Weather/Condition Colors
  static const Color weatherSunny = Color(0xFFFFA726);
  static const Color weatherCloudy = Color(0xFF90A4AE);
  static const Color weatherRainy = Color(0xFF42A5F5);
  static const Color weatherSnowy = Color(0xFFE3F2FD);
  
  // Category Colors
  static const Color categorySeeds = Color(0xFF8BC34A);
  static const Color categoryEquipment = Color(0xFFFF9800);
  static const Color categoryTools = Color(0xFF607D8B);
  static const Color categoryFertilizers = Color(0xFF4CAF50);
  static const Color categoryPesticides = Color(0xFFF44336);
  
  // Resource Status Colors
  static const Color statusAvailable = Color(0xFF4CAF50);
  static const Color statusInUse = Color(0xFF2196F3);
  static const Color statusMaintenance = Color(0xFFFFC107);
  static const Color statusDamaged = Color(0xFFF44336);
  
  // Crop Status Colors
  static const Color cropPlanted = Color(0xFF8BC34A);
  static const Color cropGrowing = Color(0xFF4CAF50);
  static const Color cropHarvesting = Color(0xFFFF9800);
  static const Color cropHarvested = Color(0xFF795548);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient weatherGradient = LinearGradient(
    colors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static BoxShadow get defaultShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow get elevatedShadow => BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );
}


















