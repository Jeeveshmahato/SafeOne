import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// A guided checklist that walks the user through the permissions needed for
/// the scheduled fake call to ring when the app is closed or the phone is
/// locked. Each row shows whether it's set and a button to turn it on.
///
/// Re-checks statuses whenever the user returns from a system settings page.
class BackgroundSetupScreen extends StatefulWidget {
  const BackgroundSetupScreen({super.key});

  @override
  State<BackgroundSetupScreen> createState() => _BackgroundSetupScreenState();
}

class _BackgroundSetupScreenState extends State<BackgroundSetupScreen>
    with WidgetsBindingObserver {
  // null = unknown/can't read, true = on, false = off.
  bool? _notifications;
  bool? _exactAlarm;
  bool? _battery;
  bool? _overlay;
  bool? _bgLocation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from a settings screen — re-read the statuses.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final notif = await NotificationService.instance.notificationsEnabled();
    final exact = await NotificationService.instance.exactAlarmsAllowed();
    final battery = await Permission.ignoreBatteryOptimizations.isGranted;
    final overlay = await Permission.systemAlertWindow.isGranted;
    final bgLocation = await Permission.locationAlways.isGranted;
    if (!mounted) return;
    setState(() {
      _notifications = notif;
      _exactAlarm = exact;
      _battery = battery;
      _overlay = overlay;
      _bgLocation = bgLocation;
      _loading = false;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    await action();
    await _refresh();
  }

  /// Google Play requires a prominent disclosure shown BEFORE requesting
  /// background ("Allow all the time") location. We explain what the data is
  /// used for and that it is never uploaded, and only request the permission if
  /// the user agrees.
  Future<void> _requestBackgroundLocation() async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).bgLocationTitle),
        content: Text(AppLocalizations.of(ctx).bgLocationBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx).notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(ctx).continueLabel),
          ),
        ],
      ),
    );
    if (agreed == true) {
      await Permission.locationAlways.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up background calls')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
              children: [
                const NoticeCard(
                  tone: Tone.info,
                  message: 'Turn these on so the scheduled fake call, live '
                      'location sharing and the check-in auto-alert keep '
                      'working when the app is closed or the phone is locked.',
                ),
                const SizedBox(height: 16),
                _SetupTile(
                  icon: Icons.notifications_active,
                  title: 'Notifications',
                  subtitle: 'Allow the app to show the incoming call.',
                  status: _notifications,
                  onFix: () => _run(() =>
                      Permission.notification.request().then((_) {})),
                ),
                _SetupTile(
                  icon: Icons.alarm,
                  title: 'Alarms & reminders',
                  subtitle: 'So the call rings exactly on time.',
                  status: _exactAlarm,
                  onFix: () => _run(
                      NotificationService.instance.requestExactAlarms),
                ),
                _SetupTile(
                  icon: Icons.fullscreen,
                  title: 'Full-screen / appear on top',
                  subtitle: 'So the call shows over the lock screen.',
                  status: null, // can't reliably read this one
                  onFix: () => _run(
                      NotificationService.instance.requestFullScreenIntent),
                ),
                _SetupTile(
                  icon: Icons.battery_charging_full,
                  title: 'Unrestricted battery',
                  subtitle:
                      'So closing the app doesn\'t cancel the scheduled call.',
                  status: _battery,
                  onFix: () => _run(() =>
                      Permission.ignoreBatteryOptimizations.request().then((_) {})),
                ),
                _SetupTile(
                  icon: Icons.layers,
                  title: 'Display over other apps',
                  subtitle: 'So the call can pop up over whatever you\'re using.',
                  status: _overlay,
                  onFix: () => _run(
                      () => Permission.systemAlertWindow.request().then((_) {})),
                ),
                _SetupTile(
                  icon: Icons.location_on,
                  title: 'Location: Allow all the time',
                  subtitle:
                      'So live sharing & check-in can read your location while '
                      'the app is closed.',
                  status: _bgLocation,
                  onFix: () => _run(_requestBackgroundLocation),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _run(() => openAppSettings().then((_) {})),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Open app settings'),
                ),
                const SizedBox(height: 16),
                const NoticeCard(
                  tone: Tone.neutral,
                  message: 'Tip: on some phones (Motorola, Xiaomi, etc.) also '
                      'enable "Autostart" / "Allow background activity" for '
                      'SafeOne.',
                ),
              ],
            ),
    );
  }
}

class _SetupTile extends StatelessWidget {
  const _SetupTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onFix,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool? status; // null = unknown
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final ok = status == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: IconBadge(
          icon: icon,
          color: ok ? context.safety.success : null,
          size: 40,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ok
            ? Icon(Icons.check_circle_rounded, color: context.safety.success)
            : FilledButton.tonal(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                onPressed: onFix,
                child: Text(status == null ? 'Allow' : 'Fix'),
              ),
      ),
    );
  }
}
