import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Holds the app's currently selected language and lets any screen change it
/// at runtime. The choice is saved ON THE PHONE so it survives app restarts.
///
/// A single shared instance ([LocaleController.instance]) is listened to by the
/// root [MaterialApp]. Calling [setLocale] (or [useSystemLanguage]) rebuilds the
/// whole app in the new language immediately.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController._() : super(null);

  /// The one shared controller used across the app.
  static final LocaleController instance = LocaleController._();

  static const String _prefsKey = 'app_locale';

  /// All languages the app ships translations for. The first entry (English)
  /// is the fallback used when a string is missing in another language.
  static List<Locale> get supportedLocales =>
      AppLocalizations.supportedLocales;

  /// Human-readable names shown in the language picker, keyed by language code.
  /// Each name is written in its OWN language so users can recognise it.
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'mr': 'मराठी',
    'gu': 'ગુજરાતી',
    'kn': 'ಕನ್ನಡ',
    'ml': 'മലയാളം',
    'pa': 'ਪੰਜਾਬੀ',
    'ur': 'اردو',
    'or': 'ଓଡ଼ିଆ',
    'as': 'অসমীয়া',
  };

  /// Display name for a locale (falls back to the raw code if unknown).
  static String displayName(Locale locale) =>
      languageNames[locale.languageCode] ?? locale.languageCode;

  /// Load the saved language (if any) on app start. When nothing is saved we
  /// leave [value] as null, which makes Flutter follow the system language.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      value = Locale(code);
    }
  }

  /// Switch to a specific language and remember it.
  Future<void> setLocale(Locale locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }

  /// Clear the saved choice and follow the phone's system language.
  Future<void> useSystemLanguage() async {
    value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
