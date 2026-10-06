import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/pin_setup_screen.dart';
import 'services/app_lock_service.dart';
import 'services/app_reset_service.dart';
import 'services/locale_controller.dart';
import 'services/notification_service.dart';
import 'services/vault.dart';
import 'theme/app_theme.dart';
import 'widgets/app_ui.dart';

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
          // Colours, fonts and component styles live in AppTheme; the app
          // follows the phone's light/dark setting.
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          // Language settings: a null locale means "follow the phone".
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AppGate(),
        );
      },
    );
  }
}

/// Sits in front of the app and enforces the screen lock.
///
/// Flow:
///   * First ever launch (no PIN yet) -> the user must create a PIN.
///   * Normal launch -> show the [LockScreen] until the right PIN/biometric.
///   * While unlocked, watch the app lifecycle: when the app goes to the
///     background and comes back after the grace period (or the phone itself
///     was locked meanwhile), re-lock it.
///
/// A re-lock pushes a full-screen lock page on top of EVERY open screen. Just
/// swapping this widget for the lock screen would leave pages opened from
/// home (Settings, Contacts, Medical ID…) sitting on top of it, still usable.
/// Things that must show over a locked app, like a scheduled fake call or the
/// SOS countdown, push their own page above the lock and still appear.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> with WidgetsBindingObserver {
  static const _deviceChannel = MethodChannel('com.safeone.app/device');

  final AppLockService _lock = AppLockService();

  bool _loading = true;
  bool _pinSet = false;
  // False until the first unlock of this session; until then this widget IS
  // the lock screen (so a fake call opened on a cold start can sit above it).
  bool _unlockedOnce = false;
  // The lock page pushed over everything on a re-lock (null when unlocked).
  Route<void>? _lockRoute;
  // Bumped after "Erase and start over" so the home screen starts fresh.
  int _session = 0;
  DateTime? _backgroundedAt;

  int get _graceSeconds => AppLockService.graceSeconds.value;
  bool get _unlocked => _unlockedOnce && _lockRoute == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppResetService.erased.addListener(_onErased);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppResetService.erased.removeListener(_onErased);
    super.dispose();
  }

  Future<void> _init() async {
    final pinSet = await _lock.isPinSet();
    await _lock.loadGraceSeconds();
    if (!mounted) return;
    setState(() {
      _pinSet = pinSet;
      _loading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_pinSet) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Only start the auto-lock timer if we were actually UNLOCKED, and not
      // because a system fingerprint / screen-lock prompt covered the app:
      // counting that as "backgrounded" re-locked the app right after a
      // successful unlock, which re-showed the prompt in a loop.
      if (!_unlocked || AppLockService.systemPromptActive) return;
      _backgroundedAt ??= DateTime.now();
      // Lock now rather than on return, so the app never comes back showing
      // its content, even for a frame.
      if (_graceSeconds <= 0) _relock();
    } else if (state == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      if (_unlocked && since != null) _relockIfDue(since);
    }
  }

  Future<void> _relockIfDue(DateTime since) async {
    final elapsed = DateTime.now().difference(since).inSeconds;
    // SafeOne may appear over the phone's lock screen (for the fake call).
    // Never show unlocked content there, whatever the grace period.
    if (elapsed >= _graceSeconds || await _isPhoneLocked()) _relock();
  }

  Future<bool> _isPhoneLocked() async {
    try {
      return await _deviceChannel.invokeMethod<bool>('isKeyguardLocked') ??
          false;
    } catch (_) {
      return false; // not Android
    }
  }

  void _relock() {
    final nav = rootNavigatorKey.currentState;
    if (!mounted || !_unlocked || nav == null) return;
    final route = PageRouteBuilder<void>(
      // No slide-in: the lock has to cover the screen immediately.
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, _, _) => PopScope(
        canPop: false,
        // Back from the lock leaves the app, like it does on first launch.
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) SystemNavigator.pop();
        },
        child: LockScreen(onUnlocked: _onUnlocked),
      ),
    );
    // Drop the key to the encrypted data until the PIN is entered again.
    Vault.instance.lock();
    // Messages move to whichever page is on top, so a "Asha removed / Undo"
    // would otherwise show (and work) on the lock screen.
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    // Close the keyboard: focus would otherwise stay in a text field of the
    // hidden screen, which would keep receiving typing.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _lockRoute = route);
    nav.push(route);
  }

  void _onUnlocked() {
    final route = _lockRoute;
    setState(() {
      _unlockedOnce = true;
      _lockRoute = null;
      _pinSet = true;
      // Don't let a timestamp captured during the unlock flow re-lock us.
      _backgroundedAt = null;
    });
    // removeRoute, not pop: a fake call may be ringing on top of the lock.
    if (route != null && route.isActive) {
      rootNavigatorKey.currentState?.removeRoute(route);
    }
  }

  /// "Erase and start over" finished: close every screen and go back to
  /// creating a PIN, with a brand-new home screen.
  void _onErased() {
    rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() {
      _pinSet = false;
      _unlockedOnce = false;
      _lockRoute = null;
      _backgroundedAt = null;
      _session++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _Splash();
    if (!_pinSet) return PinSetupScreen(onComplete: _onUnlocked);
    if (!_unlockedOnce) return LockScreen(onUnlocked: _onUnlocked);
    return HomeScreen(key: ValueKey(_session));
  }
}

/// A quiet branded placeholder shown for the split second while the lock state
/// loads, instead of a bare spinner.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: AppLogo(size: 72)));
  }
}
