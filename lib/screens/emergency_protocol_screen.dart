import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/emergency_protocol.dart';

class EmergencyProtocolScreen extends StatefulWidget {
  const EmergencyProtocolScreen({super.key});

  @override
  State<EmergencyProtocolScreen> createState() =>
      _EmergencyProtocolScreenState();
}

class _EmergencyProtocolScreenState extends State<EmergencyProtocolScreen> {
  EmergencyProtocol? _selectedProtocol;

  Future<void> _callEmergency(String number) async {
    final url = 'tel:$number';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedProtocol != null) {
      return _buildProtocolDetail();
    }
    return _buildProtocolList();
  }

  Widget _buildProtocolList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Protocols'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🚨 Know What To Do',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select your situation and get step-by-step guidance. '
                    'Always call 112 first in life-threatening situations.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Protocol cards
            const Text(
              'Choose Your Situation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...EmergencyProtocol.standardProtocols.map((protocol) {
              return _buildProtocolCard(protocol);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolCard(EmergencyProtocol protocol) {
    Color getColor() {
      switch (protocol.type) {
        case EmergencyType.police:
          return Colors.blue;
        case EmergencyType.assault:
          return Colors.red;
        case EmergencyType.stalking:
          return Colors.orange;
        case EmergencyType.harassment:
          return Colors.amber;
        case EmergencyType.medical:
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          protocol.type == EmergencyType.police ? Icons.local_police :
          protocol.type == EmergencyType.assault ? Icons.warning :
          protocol.type == EmergencyType.stalking ? Icons.gps_fixed :
          protocol.type == EmergencyType.harassment ? Icons.block :
          Icons.local_hospital,
          color: getColor(),
          size: 28,
        ),
        title: Text(
          protocol.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(protocol.description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => setState(() => _selectedProtocol = protocol),
      ),
    );
  }

  Widget _buildProtocolDetail() {
    final protocol = _selectedProtocol!;
    return Scaffold(
      appBar: AppBar(
        title: Text(protocol.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedProtocol = null),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency number - big and prominent
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'EMERGENCY NUMBER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    protocol.emergencyNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () => _callEmergency(protocol.emergencyNumber),
                      icon: const Icon(Icons.call, color: Colors.red),
                      label: const Text(
                        'CALL NOW',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Steps
            const Text(
              'What To Do:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(protocol.steps.length, (index) {
              final step = protocol.steps[index];
              return _buildStep(index + 1, step);
            }),
            const SizedBox(height: 24),

            // Important notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Important',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Always prioritize your safety first\n'
                    '• Call 112 immediately if in danger (Police 100)\n'
                    '• Women Helpline: 1091 • Ambulance: 102 / 108\n'
                    '• Provide clear location information\n'
                    '• Stay on the line with the operator\n'
                    '• Follow official instructions',
                    style: TextStyle(fontSize: 12, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
