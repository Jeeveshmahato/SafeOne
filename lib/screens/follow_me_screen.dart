import 'dart:async';

import 'package:flutter/material.dart';

import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';
import '../services/sos_service.dart';
import '../widgets/duration_field.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: _running ? _buildRunning() : _buildSetup()),
      ),
    );
  }

  Widget _buildSetup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.my_location, size: 64, color: Colors.deepPurple),
        const SizedBox(height: 16),
        const Text(
          'Your live location will be sent to your emergency contacts every '
          'few minutes until you tap Stop.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        const Text('Send an update every:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        DurationField(
          initial: _interval,
          initialUnit: TimeUnit.minutes,
          onChanged: (d) => _interval = d,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: _start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start sharing'),
        ),
      ],
    );
  }

  Widget _buildRunning() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_sending)
          const CircularProgressIndicator()
        else
          const Icon(Icons.location_on, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          'Sharing your location…',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Updates sent: $_updatesSent'),
        if (_lastSent != null)
          Text(
            'Last update: ${_lastSent!.hour.toString().padLeft(2, '0')}:'
            '${_lastSent!.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.black54),
          ),
        const SizedBox(height: 32),
        SizedBox(
          width: 220,
          height: 60,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _stop,
            icon: const Icon(Icons.stop),
            label: const Text('Stop', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Keep this app open during your journey.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
