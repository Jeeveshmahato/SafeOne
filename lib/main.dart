import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/pin_setup_screen.dart';
import 'services/app_lock_service.dart';
import 'services/locale_controller.dart';
import 'services/notification_service.dart';

/// This is where the app starts running.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the saved language before building the UI so the app opens in the
  // right language straight away.
  await LocaleController.instance.load();
  // Set up local notifications (used by the safety check-in). Best-effort:
  // failures here must not stop the app from launching.
  try {
    await NotificationService.instance.init();
    // If a scheduled fake call launched the app (cold start), open it.
    await NotificationService.instance.handleLaunch();
  } catch (_) {/* notifications unavailable */}
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const WomenSafetyApp());
}

/// The root of the app. It sets up the overall theme (colors, fonts), the
/// supported languages, and tells Flutter which screen to show first.
class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app whenever the chosen language changes.
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance,
      builder: (context, locale, _) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            // A purple-based color scheme. Change the seedColor to recolor
            // the whole app.
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          // Language settings: a null locale means "follow the phone".
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return SafeArea(
              top: false,
              child: child!,
            );
          },
          home: const AppGate(),
        );
      },
    );
  }
}

/// Sits in front of the app and enforces the screen lock.
///
/// Flow:
///   * First ever launch (no PIN yet) -> force the user to create a PIN.
///   * Normal launch -> show the [LockScreen] until the right PIN/biometric.
///   * While unlocked, watch the app lifecycle: when the app goes to the
///     background and comes back after the grace period, re-lock it.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> with WidgetsBindingObserver {
  final AppLockService _lock = AppLockService();

  bool _loading = true;
  bool _pinSet = false;
  bool _unlocked = false;
  DateTime? _backgroundedAt;
  int _graceSeconds = AppLockService.defaultGraceSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _init() async {
    final pinSet = await _lock.isPinSet();
    final grace = await _lock.loadGraceSeconds();
    if (!mounted) return;
    setState(() {
      _pinSet = pinSet;
      _graceSeconds = grace;
      _loading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_pinSet) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Only start the auto-lock timer if we were actually UNLOCKED. While the
      // lock screen is showing, the system biometric prompt ALSO pauses the
      // app — counting that as "backgrounded" caused an immediate re-lock right
      // after a successful fingerprint unlock, which re-showed the prompt in a
      // loop (the reported glitch).
      if (_unlocked) _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      if (_unlocked &&
          since != null &&
          DateTime.now().difference(since).inSeconds >= _graceSeconds) {
        setState(() => _unlocked = false);
      }
    }
  }

  Future<void> _startPinSetup() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PinSetupScreen()),
    );
    if (created == true && mounted) {
      final grace = await _lock.loadGraceSeconds();
      if (!mounted) return;
      setState(() {
        _pinSet = true;
        _unlocked = true;
        _graceSeconds = grace;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_pinSet) {
      // Nudge into mandatory PIN setup right after the first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_unlocked) _startPinSetup();
      });
      return const Scaffold(body: Center(child: Icon(Icons.shield, size: 64)));
    }
    if (!_unlocked) {
      return LockScreen(
        onUnlocked: () => setState(() {
          _unlocked = true;
          // Don't let a timestamp captured during the unlock flow re-lock us.
          _backgroundedAt = null;
        }),
      );
    }
    return const HomeScreen();
  }
}
