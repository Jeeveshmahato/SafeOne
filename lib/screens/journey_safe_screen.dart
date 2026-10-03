import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';
import '../services/location_service.dart';
import '../services/sms_service.dart';
import '../services/sos_service.dart';
import '../widgets/duration_field.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// Track your journey to a destination. The app monitors your ETA and sends
/// periodic location updates to your contacts. If time expires without you
/// tapping "I Arrived", the app sends an automatic SOS alert.
class JourneySafeScreen extends StatefulWidget {
  const JourneySafeScreen({super.key});

  @override
  State<JourneySafeScreen> createState() => _JourneySafeScreenState();
}

class _JourneySafeScreenState extends State<JourneySafeScreen> {
  final ContactsRepository _contactsRepository = ContactsRepository();
  final SosService _sosService = SosService();
  final SmsService _smsService = SmsService();
  final LocationService _locationService = LocationService();

  String _destination = '';
  // Both customisable in seconds, minutes or hours.
  Duration _eta = const Duration(minutes: 30);
  bool _journeyActive = false;
  int _elapsedSeconds = 0;
  Duration _pingInterval = const Duration(minutes: 5);
  late Timer _elapsedTimer;
  late Timer _locationPingTimer;

  @override
  void dispose() {
    _elapsedTimer.cancel();
    _locationPingTimer.cancel();
    super.dispose();
  }

  /// Start the journey tracking.
  Future<void> _startJourney() async {
    if (_destination.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a destination')),
        );
      }
      return;
    }

    final contacts = await _contactsRepository.loadContacts();
    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add emergency contacts first'),
          ),
        );
      }
      return;
    }
    if (!mounted) return;

    setState(() {
      _journeyActive = true;
      _elapsedSeconds = 0;
    });

    // Vibrate to confirm start.
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 200);
    }

    // Timer to tick elapsed time.
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });

      // Check if ETA has expired.
      if (_elapsedSeconds >= _eta.inSeconds) {
        _triggerAutoSos(contacts);
        timer.cancel();
      }
    });

    // Timer to send periodic location updates.
    _locationPingTimer = Timer.periodic(_pingInterval, (_) {
      _sendLocationUpdate(contacts);
    });

    // Send initial location update.
    _sendLocationUpdate(contacts);
  }

  /// Cancel the journey.
  Future<void> _cancelJourney() async {
    _elapsedTimer.cancel();
    _locationPingTimer.cancel();

    setState(() {
      _journeyActive = false;
      _elapsedSeconds = 0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journey tracking stopped')),
      );
    }
  }

  /// Mark as safely arrived.
  Future<void> _markArrived() async {
    _elapsedTimer.cancel();
    _locationPingTimer.cancel();

    final contacts = await _contactsRepository.loadContacts();
    if (!mounted) return;

    setState(() {
      _journeyActive = false;
      _elapsedSeconds = 0;
    });

    // Send check-in message.
    await _sosService.sendCheckIn(contacts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arrived safely! Check-in sent.')),
      );
    }
  }

  /// Send location update to all contacts.
  Future<void> _sendLocationUpdate(List<EmergencyContact> contacts) async {
    if (contacts.isEmpty) return;

    try {
      final position = await _locationService.getCurrentLocation();
      final mapsLink =
          _locationService.buildMapsLink(position.latitude, position.longitude);

      final message =
          'Journey to "$_destination": I am on the way. Location: $mapsLink';

      await _smsService.sendSos(
        phoneNumbers: contacts.map((c) => c.phone).toList(),
        message: message,
      );

      // Subtle vibration to indicate ping sent.
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      // Location unavailable, but journey continues.
    }
  }

  /// Automatically trigger SOS if ETA expires.
  Future<void> _triggerAutoSos(List<EmergencyContact> contacts) async {
    _elapsedTimer.cancel();
    _locationPingTimer.cancel();

    final result = await _sosService.sendSos(
      contacts,
      messageTemplate:
          'EMERGENCY: I did not reach "$_destination" by expected time. My location: {location}',
    );

    if (!mounted) return;

    setState(() {
      _journeyActive = false;
    });

    showAppSnack(context, result.message,
        tone: result.success ? Tone.success : Tone.danger);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sc = context.safety;
    final totalSeconds = _eta.inSeconds;
    final remainingSeconds = totalSeconds - _elapsedSeconds;
    final isExpired = remainingSeconds <= 0;
    final progressValue =
        totalSeconds > 0 ? (_elapsedSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;
    final statusColor = isExpired ? sc.sos : scheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Journey')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          if (!_journeyActive) ...[
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Journey details', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        setState(() => _destination = value);
                      },
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        hintText: 'e.g. Home, Work, Station',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Expected time to arrive',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DurationField(
                      initial: _eta,
                      initialUnit: TimeUnit.minutes,
                      onChanged: (d) => _eta = d,
                    ),
                    const SizedBox(height: 20),
                    Text('Send location updates every',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DurationField(
                      initial: _pingInterval,
                      initialUnit: TimeUnit.minutes,
                      onChanged: (d) => _pingInterval = d,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _startJourney,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start journey'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const NoticeCard(
              tone: Tone.info,
              title: 'How it works',
              message: '• Your contacts get location updates at the interval '
                  'you choose\n'
                  '• Tap "I arrived" when you reach your destination\n'
                  '• If time runs out without confirmation, an SOS is sent '
                  'automatically',
            ),
          ] else ...[
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _destination.trim().isEmpty
                          ? 'Journey in progress'
                          : 'Journey to $_destination',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isExpired ? 'Time expired' : 'Time remaining',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge!
                          .copyWith(color: statusColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(remainingSeconds.clamp(0, totalSeconds)),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium!.copyWith(
                        color: statusColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8,
                        color: statusColor,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Elapsed ${_formatTime(_elapsedSeconds)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: sc.success,
                foregroundColor: scheme.surface,
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: _markArrived,
              icon: const Icon(Icons.check_rounded),
              label: const Text('I arrived'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _cancelJourney,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel journey'),
            ),
          ],
        ],
      ),
    );
  }
}
