import 'package:flutter/material.dart';

import '../models/emergency_id.dart';

class EmergencyIDScreen extends StatefulWidget {
  const EmergencyIDScreen({super.key});

  @override
  State<EmergencyIDScreen> createState() => _EmergencyIDScreenState();
}

class _EmergencyIDScreenState extends State<EmergencyIDScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _dateOfBirthController;

  bool _isEditing = false;
  EmergencyID? _currentID;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadEmergencyID();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _bloodTypeController = TextEditingController();
    _allergiesController = TextEditingController();
    _conditionsController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _dateOfBirthController = TextEditingController();
  }

  Future<void> _loadEmergencyID() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      final emergency = EmergencyID(
        fullName: 'Your Name',
        bloodType: 'O+',
        allergies: 'Penicillin',
        medicalConditions: 'Asthma',
        emergencyContactName: 'Mom',
        emergencyContactPhone: '+91 98765 43210',
      );
      setState(() {
        _currentID = emergency;
        _populateControllers(emergency);
      });
    }
  }

  void _populateControllers(EmergencyID id) {
    _nameController.text = id.fullName;
    _bloodTypeController.text = id.bloodType ?? '';
    _allergiesController.text = id.allergies ?? '';
    _conditionsController.text = id.medicalConditions ?? '';
    _emergencyNameController.text = id.emergencyContactName ?? '';
    _emergencyPhoneController.text = id.emergencyContactPhone ?? '';
    _dateOfBirthController.text = id.dateOfBirth ?? '';
  }

  void _saveEmergencyID() {
    final id = EmergencyID(
      fullName: _nameController.text.trim(),
      bloodType: _bloodTypeController.text.trim().isEmpty ? null : _bloodTypeController.text.trim(),
      allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
      medicalConditions: _conditionsController.text.trim().isEmpty ? null : _conditionsController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim().isEmpty ? null : _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim().isEmpty ? null : _dateOfBirthController.text.trim(),
    );

    setState(() {
      _currentID = id;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency ID saved')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentID == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Emergency ID')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency ID Card'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _saveEmergencyID,
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (!_isEditing) _buildIDCard(_currentID!) else _buildEditForm(),
              const SizedBox(height: 24),
              if (!_isEditing) _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIDCard(EmergencyID id) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EMERGENCY IDENTIFICATION',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              id.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildIDRow('Blood Type', id.bloodType ?? 'Not specified'),
            _buildIDRow('Allergies', id.allergies ?? 'None specified'),
            _buildIDRow('Medical Conditions', id.medicalConditions ?? 'None'),
            const SizedBox(height: 20),
            const Divider(color: Colors.white30),
            const SizedBox(height: 12),
            _buildIDRow('Emergency Contact', id.emergencyContactName ?? 'Not specified'),
            _buildIDRow('Contact Phone', id.emergencyContactPhone ?? 'Not specified'),
            if (id.dateOfBirth != null) ...[
              const SizedBox(height: 12),
              _buildIDRow('Date of Birth', id.dateOfBirth!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIDRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildTextField('Full Name *', _nameController, Icons.person),
        _buildTextField('Blood Type', _bloodTypeController, Icons.bloodtype),
        _buildTextField('Allergies', _allergiesController, Icons.warning),
        _buildTextField('Medical Conditions', _conditionsController, Icons.local_hospital),
        const SizedBox(height: 20),
        const Text(
          'Emergency Contact Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField('Contact Name', _emergencyNameController, Icons.person),
        _buildTextField('Contact Phone', _emergencyPhoneController, Icons.phone),
        _buildTextField('Date of Birth', _dateOfBirthController, Icons.cake),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          helperText: label.endsWith('*') ? 'Required field' : '',
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💡 How to Use This Card',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Show this to first responders if you\'re in danger\n'
                '• Critical if you\'re unconscious or can\'t communicate\n'
                '• Keep it updated with latest medical info\n'
                '• Your emergency contact will be notified immediately',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                '⚠️ Important Information',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Keep your info current and accurate\n'
                '• Update after health changes\n'
                '• Verify emergency contact info is correct\n'
                '• This info is stored locally on your device only',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
