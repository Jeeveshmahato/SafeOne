import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/emergency_protocol.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

class EmergencyProtocolScreen extends StatefulWidget {
  const EmergencyProtocolScreen({super.key});

  @override
  State<EmergencyProtocolScreen> createState() =>
      _EmergencyProtocolScreenState();
}

class _EmergencyProtocolScreenState extends State<EmergencyProtocolScreen> {
  EmergencyProtocol? _selectedProtocol;

  Future<void> _callEmergency(String number) async {
    // Launch directly: `canLaunchUrl` can wrongly report false on Android 11+,
    // which would make this emergency button silently do nothing.
    var ok = false;
    try {
      ok = await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {}
    if (!ok && mounted) {
      showAppSnack(context, "Couldn't open the dialer. Call $number yourself.",
          tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedProtocol;
    // While a protocol is open, the system back gesture returns to the list
    // instead of leaving the screen.
    return PopScope(
      canPop: selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _selectedProtocol = null);
      },
      child: selected != null
          ? _buildProtocolDetail(selected)
          : _buildProtocolList(),
    );
  }

  static IconData _iconFor(EmergencyType type) => switch (type) {
        EmergencyType.police => Icons.local_police_rounded,
        EmergencyType.assault => Icons.warning_rounded,
        EmergencyType.stalking => Icons.gps_fixed_rounded,
        EmergencyType.harassment => Icons.block_rounded,
        _ => Icons.local_hospital_rounded,
      };

  Color _colorFor(EmergencyType type) {
    final s = context.safety;
    return switch (type) {
      EmergencyType.police => s.info,
      EmergencyType.assault => s.sos,
      EmergencyType.stalking => s.warning,
      EmergencyType.harassment => Theme.of(context).colorScheme.primary,
      EmergencyType.medical => s.success,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }

  Widget _buildProtocolList() {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency protocols')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          const NoticeCard(
            tone: Tone.danger,
            title: 'Know what to do',
            message: 'Pick your situation for step-by-step guidance. '
                'In a life-threatening situation, call 112 first.',
          ),
          const SectionLabel('Choose your situation'),
          for (final protocol in EmergencyProtocol.standardProtocols)
            _buildProtocolCard(protocol),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(EmergencyProtocol protocol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: IconBadge(
          icon: _iconFor(protocol.type),
          color: _colorFor(protocol.type),
        ),
        title: Text(protocol.title),
        subtitle: Text(protocol.description),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => setState(() => _selectedProtocol = protocol),
      ),
    );
  }

  Widget _buildProtocolDetail(EmergencyProtocol protocol) {
    final theme = Theme.of(context);
    final s = context.safety;
    return Scaffold(
      appBar: AppBar(
        title: Text(protocol.title),
        leading: BackButton(
          onPressed: () => setState(() => _selectedProtocol = null),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          // Emergency number - big and prominent
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: s.sos,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  'Emergency number',
                  style: theme.textTheme.labelLarge!
                      .copyWith(color: s.onSos.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 4),
                Text(
                  protocol.emergencyNumber,
                  style: theme.textTheme.displayMedium!.copyWith(
                    color: s.onSos,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: s.onSos,
                      foregroundColor: s.sos,
                    ),
                    onPressed: () => _callEmergency(protocol.emergencyNumber),
                    icon: const Icon(Icons.call_rounded),
                    label: const Text('Call now'),
                  ),
                ),
              ],
            ),
          ),

          // Steps
          const SectionLabel('What to do'),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < protocol.steps.length; i++)
                    _buildStep(i + 1, protocol.steps[i]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Important notes
          const NoticeCard(
            tone: Tone.warning,
            title: 'Important',
            message: '• Put your own safety first\n'
                '• Call 112 immediately if in danger (Police 100)\n'
                '• Women Helpline: 1091 • Ambulance: 102 / 108\n'
                '• Give clear location details\n'
                '• Stay on the line with the operator\n'
                '• Follow official instructions',
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: theme.textTheme.labelLarge!
                  .copyWith(color: scheme.onSecondaryContainer),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(text, style: theme.textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
