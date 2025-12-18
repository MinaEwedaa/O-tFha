import 'package:intl/intl.dart';

/// Formatting utilities for dates, numbers, currency, etc.
class Formatters {
  /// Formats a DateTime to a readable date string (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  /// Formats a DateTime to a short date string (e.g., "15/01/2024")
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Formats a DateTime to a time string (e.g., "02:30 PM")
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
  
  /// Formats a DateTime to a full date-time string (e.g., "Jan 15, 2024 at 02:30 PM")
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(date);
  }
  
  /// Formats a DateTime to a relative time string (e.g., "2 hours ago", "just now")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
  
  /// Formats a number to a currency string (e.g., "$1,234.56")
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  /// Formats a number to a compact currency string (e.g., "$1.2K", "$1.5M")
  static String formatCompactCurrency(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatCurrency(amount, symbol: symbol);
    }
  }
  
  /// Formats a number with thousand separators (e.g., "1,234,567")
  static String formatNumber(num number, {int decimals = 0}) {
    final formatter = NumberFormat('#,###${decimals > 0 ? '.${'0' * decimals}' : ''}');
    return formatter.format(number);
  }
  
  /// Formats a percentage (e.g., "75.5%")
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }
  
  /// Formats a file size (e.g., "1.5 MB", "256 KB")
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// Formats a duration (e.g., "2 hours 30 minutes", "45 seconds")
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      }
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else {
      final seconds = duration.inSeconds;
      return '$seconds ${seconds == 1 ? 'second' : 'seconds'}';
    }
  }
  
  /// Formats a phone number (e.g., "+1 (555) 123-4567")
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleaned.startsWith('+')) {
      // International format
      if (cleaned.length >= 10) {
        final countryCode = cleaned.substring(0, cleaned.length - 10);
        final areaCode = cleaned.substring(cleaned.length - 10, cleaned.length - 7);
        final firstPart = cleaned.substring(cleaned.length - 7, cleaned.length - 4);
        final secondPart = cleaned.substring(cleaned.length - 4);
        return '$countryCode ($areaCode) $firstPart-$secondPart';
      }
    } else if (cleaned.length == 10) {
      // US format
      final areaCode = cleaned.substring(0, 3);
      final firstPart = cleaned.substring(3, 6);
      final secondPart = cleaned.substring(6);
      return '($areaCode) $firstPart-$secondPart';
    }
    
    return phoneNumber; // Return original if format not recognized
  }
  
  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Capitalizes the first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  /// Truncates text with ellipsis
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
  
  /// Formats a list of strings into a comma-separated string
  static String formatList(List<String> items, {String separator = ', ', String? lastSeparator}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    
    if (lastSeparator != null && items.length > 1) {
      final allButLast = items.sublist(0, items.length - 1);
      final last = items.last;
      return '${allButLast.join(separator)}$lastSeparator$last';
    }
    
    return items.join(separator);
  }
}


















