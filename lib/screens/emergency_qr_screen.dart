import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/medical_info.dart';
import '../services/medical_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/tabbed_hub.dart';

/// Shows a scannable QR code with the user's Medical ID. Anyone can scan it
/// offline with a normal phone camera to read blood group, allergies,
/// conditions and who to call.
class EmergencyQrScreen extends StatefulWidget {
  const EmergencyQrScreen({super.key});

  @override
  State<EmergencyQrScreen> createState() => _EmergencyQrScreenState();
}

class _EmergencyQrScreenState extends State<EmergencyQrScreen> {
  final MedicalRepository _medicalRepository = MedicalRepository();
  MedicalInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
    // The ID tab may be edited while this tab stays alive in the hub.
    MedicalRepository.changes.addListener(_load);
  }

  @override
  void dispose() {
    MedicalRepository.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final info = await _medicalRepository.load();
    if (!mounted) return;
    setState(() => _info = info);
  }

  /// Plain, human-readable text: a phone camera shows it as-is, so a
  /// paramedic can read it without any special app (raw JSON was unreadable).
  String _qrText(MedicalInfo info) {
    final lines = <String>['EMERGENCY MEDICAL ID', 'Name: ${info.fullName}'];
    void add(String label, String value) {
      if (value.trim().isNotEmpty) lines.add('$label: ${value.trim()}');
    }

    add('Date of birth', info.dateOfBirth);
    add('Blood group', info.bloodGroup);
    add('Allergies', info.allergies);
    add('Conditions', info.conditions);
    add('Medications', info.medications);
    add('Notes', info.notes);
    final contact = [info.emergencyContactName, info.emergencyContactPhone]
        .where((v) => v.trim().isNotEmpty)
        .join(' ');
    add('Emergency contact', contact);
    return lines.join('\n');
  }

  /// The Medical ID is the first tab of the profile hub.
  void _openEditor() => TabbedHub.select(context, 0);

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      appBar: AppBar(title: const Text('QR card')),
      body: info == null
          ? const Center(child: CircularProgressIndicator())
          : info.isEmpty
              ? EmptyState(
                  icon: Icons.qr_code_2_rounded,
                  title: 'No Medical ID yet',
                  message: 'Create your Medical ID first. Your QR card is '
                      'made from it automatically.',
                  action: FilledButton(
                    onPressed: _openEditor,
                    child: const Text('Create Medical ID'),
                  ),
                )
              : _buildCard(info),
    );
  }

  Widget _buildCard(MedicalInfo info) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(info.fullName,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(
                  'Scan for emergency medical info',
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                // Always dark-on-white, even in dark mode: QR scanners need
                // the contrast.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Semantics(
                    label: 'QR code with your Medical ID',
                    child: QrImageView(
                      data: _qrText(info),
                      version: QrVersions.auto,
                      size: 240,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const NoticeCard(
          tone: Tone.info,
          title: 'Keep it handy',
          message: 'Take a screenshot and set it as your lock-screen '
              'wallpaper. Anyone can scan it with a phone camera, with no '
              'internet or app needed.',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _openEditor,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Medical ID'),
        ),
      ],
    );
  }
}
