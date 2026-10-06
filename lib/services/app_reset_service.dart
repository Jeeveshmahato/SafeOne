import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_lock_service.dart';
import 'locale_controller.dart';
import 'notification_service.dart';
import 'safety_monitor_service.dart';
import 'vault.dart';

/// "Erase and start over": the last resort when the app PIN is forgotten and
/// the phone has no screen lock to prove who is holding it.
///
/// Everything SafeOne stored is deleted (contacts, medical info, settings,
/// both PINs, the vault and its hardware keys, recordings and photos) so
/// that whoever sets the new PIN can't see the previous owner's data.
/// Only the chosen language is kept.
class AppResetService {
  AppResetService._();

  /// Bumped after each erase; the app gate listens and restarts from PIN
  /// setup.
  static final ValueNotifier<int> erased = ValueNotifier<int>(0);

  static Future<void> eraseEverything() async {
    // Stop anything still running in the background first, so it can't send
    // an alert or ring after the data is gone.
    await SafetyMonitorService.stopLiveShare();
    await SafetyMonitorService.cancelCheckin();
    try {
      await NotificationService.instance.cancelAll();
    } catch (_) {/* notifications unavailable */}

    final locale = LocaleController.instance.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await AppLockService().deleteAll();
    await Vault.instance.deleteAll();
    AppLockService.graceSeconds.value = AppLockService.defaultGraceSeconds;
    // With every trigger flag cleared the native side stops the service.
    await SafetyMonitorService.stop();
    if (locale != null) await LocaleController.instance.setLocale(locale);

    // Recordings and evidence photos live in the app's documents folder.
    try {
      final dir = await getApplicationDocumentsDirectory();
      for (final entity in dir.listSync()) {
        try {
          entity.deleteSync(recursive: true);
        } catch (_) {/* skip files we can't delete */}
      }
    } catch (_) {/* no documents folder on this platform */}

    erased.value++;
  }
}
