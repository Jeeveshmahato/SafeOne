import 'package:flutter/material.dart';

import '../models/medical_info.dart';
import '../services/medical_repository.dart';

/// Screen to view and edit the user's medical information.
///
/// In an emergency this can be shown to a doctor or paramedic. Everything is
/// saved on the phone.
class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  final MedicalRepository _repository = MedicalRepository();

  // One controller per text field.
  final _nameController = TextEditingController();
  final _bloodController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final info = await _repository.load();
    setState(() {
      _nameController.text = info.fullName;
      _bloodController.text = info.bloodGroup;
      _allergiesController.text = info.allergies;
      _medicationsController.text = info.medications;
      _notesController.text = info.notes;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final info = MedicalInfo(
      fullName: _nameController.text.trim(),
      bloodGroup: _bloodController.text.trim(),
      allergies: _allergiesController.text.trim(),
      medications: _medicationsController.text.trim(),
      notes: _notesController.text.trim(),
    );
    await _repository.save(info);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medical info saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical info')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Fill in details that could help a doctor or paramedic in an '
                  'emergency. This stays on your phone.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                _field(_nameController, 'Full name'),
                _field(_bloodController, 'Blood group (e.g. O+)'),
                _field(_allergiesController, 'Allergies'),
                _field(_medicationsController, 'Current medications'),
                _field(_notesController, 'Other notes', lines: 3),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
    );
  }

  /// A helper that builds one labelled text box (keeps the code short).
  Widget _field(TextEditingController controller, String label,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
