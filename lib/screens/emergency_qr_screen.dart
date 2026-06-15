import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/emergency_id.dart';
import '../services/medical_repository.dart';

/// Display a scannable QR code containing the user's emergency ID and medical info.
/// First responders can scan this code (offline) to instantly get critical medical
/// information: blood type, allergies, medical conditions, and emergency contacts.
class EmergencyQrScreen extends StatefulWidget {
  const EmergencyQrScreen({super.key});

  @override
  State<EmergencyQrScreen> createState() => _EmergencyQrScreenState();
}

class _EmergencyQrScreenState extends State<EmergencyQrScreen> {
  final MedicalRepository _medicalRepository = MedicalRepository();
  EmergencyID? _emergencyId;
  bool _loading = true;
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final medicalInfo = await _medicalRepository.load();
    setState(() {
      _emergencyId = EmergencyID(
        fullName: medicalInfo.fullName,
        bloodType: medicalInfo.bloodGroup,
        allergies: medicalInfo.allergies,
        medicalConditions: medicalInfo.medications,
      );
      _qrData = _generateQrData(_emergencyId!);
      _loading = false;
    });
  }

  /// Encode emergency data as JSON for the QR code.
  String _generateQrData(EmergencyID id) {
    final Map<String, dynamic> data = {
      'name': id.fullName,
      'blood': id.bloodType ?? 'Not specified',
      'allergies': id.allergies ?? 'None known',
      'conditions': id.medicalConditions ?? 'None',
      'emergencyContact': id.emergencyContactName ?? 'Not set',
      'emergencyPhone': id.emergencyContactPhone ?? 'Not set',
      'dob': id.dateOfBirth ?? 'Not set',
      'timestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency QR Card'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _emergencyId == null || _emergencyId!.fullName.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No emergency ID set',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'First, fill in your medical info\nin the Medical ID screen.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // QR Code
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Scan for Emergency Info',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              QrImageView(
                                data: _qrData,
                                version: QrVersions.auto,
                                size: 280,
                                embeddedImage: null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Screenshot this for your lock screen',
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Medical Summary
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medical Summary',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'Name',
                                _emergencyId!.fullName,
                                Icons.person,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Blood Type',
                                _emergencyId!.bloodType ?? 'Not specified',
                                Icons.bloodtype_outlined,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Allergies',
                                _emergencyId!.allergies ?? 'None known',
                                Icons.warning_amber_rounded,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Medical Conditions',
                                _emergencyId!.medicalConditions ?? 'None',
                                Icons.health_and_safety,
                              ),
                              if (_emergencyId!.emergencyContactName != null &&
                                  _emergencyId!.emergencyContactName!.isNotEmpty)
                                ...[
                                  const Divider(),
                                  _buildInfoRow(
                                    'Emergency Contact',
                                    '${_emergencyId!.emergencyContactName} - ${_emergencyId!.emergencyContactPhone ?? 'No phone'}',
                                    Icons.phone_in_talk,
                                  ),
                                ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // How it works
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'How it works',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: Colors.blue[700],
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '• Screenshot the QR code and set it as your lock screen wallpaper or save to favorites\n\n'
                                '• First responders can scan it to instantly access your blood type, allergies, and conditions\n\n'
                                '• Works offline — no internet needed\n\n'
                                '• Can be scanned by paramedics, police, or anyone with a camera phone\n\n'
                                '• Update this card anytime you change your medical information',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.6,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Take a screenshot to save the QR code',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.screenshot),
                              label: const Text('Screenshot'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Info'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  /// Helper widget to display info rows.
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
