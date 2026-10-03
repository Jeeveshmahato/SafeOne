import 'dart:async';

import 'package:flutter/material.dart';

import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';
import '../services/sos_service.dart';
import '../widgets/duration_field.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// "Follow Me" live-tracking.
///
/// While this is running, the app sends your current location to your
/// emergency contacts every few minutes, so they can follow your journey.
/// Tap Stop when you arrive. Keep the app open during the journey (this simple
/// first version has no background service).
class FollowMeScreen extends StatefulWidget {
  const FollowMeScreen({super.key});

  @override
  State<FollowMeScreen> createState() => _FollowMeScreenState();
}

class _FollowMeScreenState extends State<FollowMeScreen> {
  final ContactsRepository _contactsRepository = ContactsRepository();
  final SosService _sosService = SosService();

  // How often to send an update. Customisable in seconds, minutes or hours.
  Duration _interval = const Duration(minutes: 5);

  Timer? _timer;
  bool _running = false;
  bool _sending = false;
  int _updatesSent = 0;
  DateTime? _lastSent;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    showAppSnack(context, text, tone: isError ? Tone.danger : Tone.success);
  }

  Future<void> _start() async {
    final contacts = await _contactsRepository.loadContacts();
    if (contacts.isEmpty) {
      _showMessage('Please add at least one emergency contact first.',
          isError: true);
      return;
    }

    setState(() {
      _running = true;
      _updatesSent = 0;
    });

    // Send one straight away, then keep sending on the chosen interval.
    await _sendUpdate(contacts);
    _timer = Timer.periodic(_interval, (_) {
      _sendUpdate(contacts);
    });
  }

  Future<void> _sendUpdate(List<EmergencyContact> contacts) async {
    if (_sending) return;
    setState(() => _sending = true);
    final result = await _sosService.sendFollowMe(contacts);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (result.success) {
        _updatesSent++;
        _lastSent = DateTime.now();
      }
    });
    if (!result.success) {
      _showMessage(result.message, isError: true);
    }
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _running = false);
    _showMessage('Follow Me stopped.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow Me')),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _running ? _buildRunning() : _buildSetup(),
          ),
        ),
      ),
    );
  }

  Widget _buildSetup() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: IconBadge(icon: Icons.my_location_rounded, size: 72),
        ),
        const SizedBox(height: 20),
        Text('Share your journey',
            textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Your live location is sent to your emergency contacts at a regular '
          'interval until you tap Stop.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send an update every', style: theme.textTheme.titleSmall),
                const SizedBox(height: 12),
                DurationField(
                  initial: _interval,
                  initialUnit: TimeUnit.minutes,
                  onChanged: (d) => _interval = d,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start sharing'),
        ),
      ],
    );
  }

  Widget _buildRunning() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.safety;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 72,
            height: 72,
            child: _sending
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                : IconBadge(
                    icon: Icons.location_on_rounded,
                    color: s.success,
                    size: 72,
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Sharing your location',
            textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          _lastSent == null
              ? 'Updates sent: $_updatesSent'
              : 'Updates sent: $_updatesSent  ·  Last at '
                  '${_lastSent!.hour.toString().padLeft(2, '0')}:'
                  '${_lastSent!.minute.toString().padLeft(2, '0')}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: s.sos,
            foregroundColor: s.onSos,
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: _stop,
          icon: const Icon(Icons.stop_rounded),
          label: const Text('Stop sharing'),
        ),
        const SizedBox(height: 16),
        const NoticeCard(
          tone: Tone.warning,
          message: 'Keep SafeOne open during your journey so updates keep '
              'going out.',
        ),
      ],
    );
  }
}
