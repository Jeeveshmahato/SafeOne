import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/flashlight_service.dart';
import '../services/siren_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

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
    try {
      await launchUrl(uri);
    } catch (_) {/* no dialer */}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sc = context.safety;
    return Scaffold(
      appBar: AppBar(title: const Text('Police SOS')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_sosActive) ...[
              const NoticeCard(
                tone: Tone.danger,
                title: 'Police SOS mode',
                message: 'Plays a loud police siren and flashes SOS in Morse '
                    'code to draw attention. Use only in a real emergency.',
              ),
              const SizedBox(height: 20),

              // Main activation button
              Material(
                color: sc.sos,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _activatePoliceMode,
                  child: SizedBox(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_police_rounded,
                            size: 72, color: sc.onSos),
                        const SizedBox(height: 12),
                        Text(
                          'Activate police SOS',
                          style: theme.textTheme.titleLarge!
                              .copyWith(color: sc.onSos),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to start siren and SOS flashing',
                          style: theme.textTheme.bodyMedium!.copyWith(
                              color: sc.onSos.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick call button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: sc.sos,
                  side: BorderSide(color: sc.sos, width: 1.5),
                ),
                onPressed: _callPolice,
                icon: const Icon(Icons.call_rounded),
                label: const Text('Call 112 (Police / Emergency)'),
              ),

              SectionLabel('How it helps'),
              _buildInfoCard(
                icon: Icons.campaign_rounded,
                title: 'Loud siren',
                description:
                    'Alerts police and nearby people that you need help right now.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.flashlight_on_rounded,
                title: 'SOS light signal',
                description:
                    'Blinking SOS in Morse code (··· ––– ···) is recognised as a distress signal worldwide.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.visibility_rounded,
                title: 'Stay visible',
                description:
                    'Noise and light help police and others find you quickly.',
              ),
            ] else ...[
              // Active mode UI
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sc.sos,
                  ),
                  child: Icon(Icons.local_police_rounded,
                      size: 84, color: sc.onSos),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Police SOS active',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall!.copyWith(color: sc.sos),
              ),
              const SizedBox(height: 4),
              Text(
                'Running for $_countdownSeconds seconds',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _signal(Icons.campaign_rounded,
                          _sirenOn ? 'Siren on' : 'Siren off', _sirenOn),
                      _signal(Icons.flashlight_on_rounded,
                          _flashOn ? 'SOS flash on' : 'Flash off', _flashOn),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.inverseSurface,
                  foregroundColor: scheme.onInverseSurface,
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: _deactivatePoliceMode,
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Stop SOS'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _signal(IconData icon, String label, bool on) {
    final theme = Theme.of(context);
    final color =
        on ? context.safety.sos : theme.colorScheme.onSurfaceVariant;
    return Column(
      children: [
        IconBadge(icon: icon, color: color, size: 56),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.labelLarge!.copyWith(color: color)),
      ],
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String title,
      required String description}) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon: icon, color: context.safety.success, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
