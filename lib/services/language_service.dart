import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  String _currentLanguage = 'en'; // 'en' for English, 'ar' for Arabic

  String get currentLanguage => _currentLanguage;
  bool get isArabic => _currentLanguage == 'ar';
  bool get isEnglish => _currentLanguage == 'en';

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'ar' : 'en';
    notifyListeners();
  }

  void setLanguage(String language) {
    if (language == 'en' || language == 'ar') {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  // Home Screen Translations
  String get weather => isArabic ? 'الطقس' : 'Weather';
  String get today => isArabic ? 'اليوم' : 'Today';
  String get sunrise => isArabic ? 'شروق الشمس' : 'Sunrise';
  String get sunset => isArabic ? 'غروب الشمس' : 'Sunset';
  String get wind => isArabic ? 'الرياح' : 'Wind';
  String get humidity => isArabic ? 'الرطوبة' : 'Humidity';
  
  String get locationPermissionRequired => 
      isArabic ? 'مطلوب إذن الموقع' : 'Location Permission Required';
  String get enableLocationDescription => 
      isArabic ? 'قم بتمكين الموقع للحصول على تحديثات الطقس' : 'Enable location to get weather updates';
  String get enableLocation => 
      isArabic ? 'تمكين الموقع' : 'Enable Location';
  
  String get myCrops => isArabic ? 'محاصيلي' : 'My Crops';
  String get market => isArabic ? 'السوق' : 'Market';
  String get expenses => isArabic ? 'المصروفات' : 'Expenses';
  String get resources => isArabic ? 'الموارد' : 'Resources';
  
  String get yourTaskToday => isArabic ? 'مهامك اليوم' : 'Your task today';
  String get schedule => isArabic ? 'الجدول' : 'Schedule';
  
  String get languageSwitch => isArabic ? 'English' : 'العربية';

  // Days of the week
  String getDayOfWeek(String englishDay) {
    if (!isArabic) return englishDay;
    
    final Map<String, String> arabicDays = {
      'Monday': 'الإثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };
    
    return arabicDays[englishDay] ?? englishDay;
  }

  // Weather conditions
  String getWeatherCondition(String englishCondition) {
    if (!isArabic) return englishCondition;
    
    final Map<String, String> arabicConditions = {
      'Sunny': 'مشمس',
      'Clear': 'صافي',
      'Partly cloudy': 'غائم جزئياً',
      'Cloudy': 'غائم',
      'Overcast': 'ملبد بالغيوم',
      'Mist': 'ضباب خفيف',
      'Patchy rain possible': 'احتمال أمطار متفرقة',
      'Patchy snow possible': 'احتمال ثلوج متفرقة',
      'Patchy sleet possible': 'احتمال صقيع متفرق',
      'Patchy freezing drizzle possible': 'احتمال رذاذ متجمد متفرق',
      'Thundery outbreaks possible': 'احتمال عواصف رعدية',
      'Blowing snow': 'ثلوج متطايرة',
      'Blizzard': 'عاصفة ثلجية',
      'Fog': 'ضباب',
      'Freezing fog': 'ضباب متجمد',
      'Patchy light drizzle': 'رذاذ خفيف متفرق',
      'Light drizzle': 'رذاذ خفيف',
      'Freezing drizzle': 'رذاذ متجمد',
      'Heavy freezing drizzle': 'رذاذ متجمد كثيف',
      'Patchy light rain': 'مطر خفيف متفرق',
      'Light rain': 'مطر خفيف',
      'Moderate rain at times': 'مطر معتدل في بعض الأحيان',
      'Moderate rain': 'مطر معتدل',
      'Heavy rain at times': 'مطر غزير في بعض الأحيان',
      'Heavy rain': 'مطر غزير',
      'Light freezing rain': 'مطر متجمد خفيف',
      'Moderate or heavy freezing rain': 'مطر متجمد معتدل أو كثيف',
      'Light sleet': 'صقيع خفيف',
      'Moderate or heavy sleet': 'صقيع معتدل أو كثيف',
      'Patchy light snow': 'ثلوج خفيفة متفرقة',
      'Light snow': 'ثلوج خفيفة',
      'Patchy moderate snow': 'ثلوج معتدلة متفرقة',
      'Moderate snow': 'ثلوج معتدلة',
      'Patchy heavy snow': 'ثلوج كثيفة متفرقة',
      'Heavy snow': 'ثلوج كثيفة',
      'Ice pellets': 'كريات ثلجية',
      'Light rain shower': 'زخات مطر خفيفة',
      'Moderate or heavy rain shower': 'زخات مطر معتدلة أو كثيفة',
      'Torrential rain shower': 'زخات مطر غزيرة',
      'Light sleet showers': 'زخات صقيع خفيفة',
      'Moderate or heavy sleet showers': 'زخات صقيع معتدلة أو كثيفة',
      'Light snow showers': 'زخات ثلوج خفيفة',
      'Moderate or heavy snow showers': 'زخات ثلوج معتدلة أو كثيفة',
      'Light showers of ice pellets': 'زخات خفيفة من الكريات الثلجية',
      'Moderate or heavy showers of ice pellets': 'زخات معتدلة أو كثيفة من الكريات الثلجية',
      'Patchy light rain with thunder': 'مطر خفيف متفرق مع رعد',
      'Moderate or heavy rain with thunder': 'مطر معتدل أو كثيف مع رعد',
      'Patchy light snow with thunder': 'ثلوج خفيفة متفرقة مع رعد',
      'Moderate or heavy snow with thunder': 'ثلوج معتدلة أو كثيفة مع رعد',
    };
    
    return arabicConditions[englishCondition] ?? englishCondition;
  }

  // Text direction
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
  
  // Alignment
  Alignment get alignment => isArabic ? Alignment.centerRight : Alignment.centerLeft;
  
  // Text alignment
  TextAlign get textAlign => isArabic ? TextAlign.right : TextAlign.left;
  
  // Cross axis alignment
  CrossAxisAlignment get crossAxisAlignment => 
      isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  
  // Main axis alignment for start
  MainAxisAlignment get mainAxisAlignmentStart =>
      isArabic ? MainAxisAlignment.end : MainAxisAlignment.start;
}



