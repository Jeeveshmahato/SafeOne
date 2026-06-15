// Unit tests for the language switcher (LocaleController): default state,
// switching, persistence, and resetting to the system language.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_app/services/locale_controller.dart';

void main() {
  final controller = LocaleController.instance;

  setUp(() async {
    // Start each test with empty stored prefs and a clean (system) locale.
    SharedPreferences.setMockInitialValues({});
    await controller.useSystemLanguage();
  });

  test('defaults to null locale (follow system language)', () {
    expect(controller.value, isNull);
  });

  test('setLocale updates value and persists the choice', () async {
    await controller.setLocale(const Locale('hi'));
    expect(controller.value, const Locale('hi'));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'hi');
  });

  test('load restores a previously saved language', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'ta'});
    controller.value = null; // clear in-memory value WITHOUT touching prefs
    await controller.load();
    expect(controller.value, const Locale('ta'));
  });

  test('useSystemLanguage clears the saved choice', () async {
    await controller.setLocale(const Locale('bn'));
    await controller.useSystemLanguage();
    expect(controller.value, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), isNull);
  });

  test('every supported locale has a display name', () {
    for (final locale in LocaleController.supportedLocales) {
      final name = LocaleController.displayName(locale);
      expect(name, isNotEmpty);
      // displayName falls back to the raw code; ensure we have a real name.
      expect(name, isNot(locale.languageCode),
          reason: 'Missing display name for ${locale.languageCode}');
    }
  });

  test('ships the expected Indian languages', () {
    final codes =
        LocaleController.supportedLocales.map((l) => l.languageCode).toSet();
    expect(
      codes,
      containsAll(<String>[
        'en', 'hi', 'bn', 'ta', 'te', 'mr', 'gu', 'kn', 'ml', 'pa', 'ur',
        'or', 'as',
      ]),
    );
  });
}
