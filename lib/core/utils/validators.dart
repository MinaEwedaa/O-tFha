/// Validation utilities for forms and inputs
class Validators {
  /// Validates if a string is not empty
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }
  
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  /// Validates password strength
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    return null;
  }
  
  /// Validates password confirmation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validates phone number format
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  /// Validates numeric input
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Value'} must be a valid number';
    }
    
    return null;
  }
  
  /// Validates positive number
  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final num? parsedValue = double.tryParse(value);
    
    if (parsedValue == null) {
      return '${fieldName ?? 'Value'} must be a valid number';
    }
    
    if (parsedValue <= 0) {
      return '${fieldName ?? 'Value'} must be greater than 0';
    }
    
    return null;
  }
  
  /// Validates minimum value
  static String? min(String? value, double minValue, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final num? parsedValue = double.tryParse(value);
    
    if (parsedValue == null) {
      return '${fieldName ?? 'Value'} must be a valid number';
    }
    
    if (parsedValue < minValue) {
      return '${fieldName ?? 'Value'} must be at least $minValue';
    }
    
    return null;
  }
  
  /// Validates maximum value
  static String? max(String? value, double maxValue, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final num? parsedValue = double.tryParse(value);
    
    if (parsedValue == null) {
      return '${fieldName ?? 'Value'} must be a valid number';
    }
    
    if (parsedValue > maxValue) {
      return '${fieldName ?? 'Value'} must be at most $maxValue';
    }
    
    return null;
  }
  
  /// Validates minimum length
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Value'} must be at least $minLength characters';
    }
    
    return null;
  }
  
  /// Validates maximum length
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'Value'} must be at most $maxLength characters';
    }
    
    return null;
  }
  
  /// Validates date format
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }
  
  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  /// Combines multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}



