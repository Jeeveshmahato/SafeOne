import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/flashlight_service.dart';
import '../services/siren_service.dart';

class PoliceSosScreen extends StatefulWidget {
  const PoliceSosScreen({super.key});

  @override
  State<PoliceSosScreen> createState() => _PoliceSosScreenState();
}

class _PoliceSosScreenState extends State<PoliceSosScreen> {
  final SirenService _sirenService = SirenService();
  final FlashlightService _flashlightService = FlashlightService();

  bool _sirenOn = false;
  bool _flashOn = false;
  bool _sosActive = false;
  int _countdownSeconds = 30;

  @override
  void dispose() {
    _sirenService.dispose();
    _flashlightService.stop();
    super.dispose();
  }

  Future<void> _activatePoliceMode() async {
    setState(() => _sosActive = true);

    // Turn on siren
    await _sirenService.start();
    setState(() => _sirenOn = true);

    // Turn on flashlight SOS
    if (await _flashlightService.isAvailable()) {
      await _flashlightService.startSos();
      setState(() => _flashOn = true);
    }

    // Countdown for police to arrive
    for (int i = _countdownSeconds; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _countdownSeconds = i);
      }
    }
  }

  Future<void> _deactivatePoliceMode() async {
    await _sirenService.stop();
    await _flashlightService.stop();
    setState(() {
      _sosActive = false;
      _sirenOn = false;
      _flashOn = false;
      _countdownSeconds = 30;
    });
  }

  Future<void> _callPolice() async {
    // 112 is India's single national emergency number (reaches police).
    final uri = Uri.parse('tel:112');
    try {
      if (await launchUrl(uri, mode: LaunchMode.platformDefault)) return;
    } catch (_) {/* ignore and try the canLaunch path below */}
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police SOS'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_sosActive) ...[
              // Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ POLICE SOS MODE',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will:\n'
                      '• Activate loud police siren\n'
                      '• Flash SOS Morse code continuously\n'
                      '• Attract police & public attention\n'
                      '• Make it obvious you need help\n\n'
                      'Use only in actual police emergency.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main activation button
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[600]!, Colors.red[900]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _activatePoliceMode,
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sos,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ACTIVATE POLICE SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Press and hold to activate',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick call button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _callPolice,
                  icon: const Icon(Icons.call),
                  label: const Text(
                    'Call 112 (Police / Emergency)',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Info cards
              _buildInfoCard(
                icon: Icons.volume_up,
                title: 'Why Siren?',
                description:
                    'Loud police siren alerts police and nearby people that you need immediate help.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.flashlight_on,
                title: 'Why Flashlight?',
                description:
                    'SOS Morse code blinking (... --- ...) is recognized as distress signal worldwide.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.location_on,
                title: 'Why Stay Visible?',
                description:
                    'Making noise and light ensures police CAN FIND you quickly in dangerous situations.',
              ),
            ] else ...[
              // Active mode UI
              Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.7),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sos,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'POLICE SOS ACTIVE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Emergency Signals Active:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.volume_up,
                                  size: 48,
                                  color: _sirenOn ? Colors.red : Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _sirenOn ? 'SIREN ON' : 'SIREN OFF',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _sirenOn ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.flashlight_on,
                                  size: 48,
                                  color: _flashOn ? Colors.amber : Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _flashOn ? 'SOS FLASH ON' : 'FLASH OFF',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _flashOn ? Colors.amber : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Police SOS running for $_countdownSeconds seconds',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _deactivatePoliceMode,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop SOS'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String title,
      required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green[600], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
