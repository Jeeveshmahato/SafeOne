import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';
import '../services/location_service.dart';
import '../services/sms_service.dart';
import '../services/sos_service.dart';
import '../widgets/duration_field.dart';

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _eta.inSeconds;
    final remainingSeconds = totalSeconds - _elapsedSeconds;
    final isExpired = remainingSeconds <= 0;
    final progressValue =
        totalSeconds > 0 ? _elapsedSeconds / totalSeconds : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Safe'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_journeyActive) ...[
              // Input section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set your journey details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) {
                          setState(() => _destination = value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Destination',
                          hintText: 'e.g. Home, Work, Station',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Expected time to arrive:'),
                      const SizedBox(height: 8),
                      DurationField(
                        initial: _eta,
                        initialUnit: TimeUnit.minutes,
                        onChanged: (d) => _eta = d,
                      ),
                      const SizedBox(height: 16),
                      const Text('Send location updates every:'),
                      const SizedBox(height: 8),
                      DurationField(
                        initial: _pingInterval,
                        initialUnit: TimeUnit.minutes,
                        onChanged: (d) => _pingInterval = d,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _startJourney,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Journey'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How it works',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Location updates sent to your contacts every few minutes\n'
                        '• Tap "I Arrived" when you reach your destination\n'
                        '• If time runs out without confirmation, SOS is automatically sent\n'
                        '• Perfect for commutes and travel',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Active journey section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Journey to $_destination',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            isExpired ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? Colors.red[50]
                              : Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isExpired ? 'TIME EXPIRED' : 'TIME REMAINING',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isExpired
                                        ? Colors.red[700]
                                        : Colors.blue[700],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTime(remainingSeconds.clamp(0, totalSeconds)),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    color: isExpired ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Elapsed: ${_formatTime(_elapsedSeconds)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _cancelJourney,
                              icon: const Icon(Icons.close),
                              label: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _markArrived,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('I Arrived'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
