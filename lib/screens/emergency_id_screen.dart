import 'package:flutter/material.dart';

import '../models/medical_info.dart';
import '../services/medical_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// The user's Medical ID: who they are, critical medical facts and who to
/// call. Shown as a card for first responders, with an edit form. Everything
/// is saved on the phone and also feeds the QR card.
class EmergencyIDScreen extends StatefulWidget {
  const EmergencyIDScreen({super.key});

  @override
  State<EmergencyIDScreen> createState() => _EmergencyIDScreenState();
}

class _EmergencyIDScreenState extends State<EmergencyIDScreen> {
  final MedicalRepository _repository = MedicalRepository();
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _blood = TextEditingController();
  final _allergies = TextEditingController();
  final _conditions = TextEditingController();
  final _medications = TextEditingController();
  final _notes = TextEditingController();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();

  MedicalInfo? _info;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _name, _dob, _blood, _allergies, _conditions, _medications, _notes,
      _contactName, _contactPhone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final info = await _repository.load();
    if (!mounted) return;
    setState(() {
      _info = info;
      // Nothing saved yet: go straight to the form.
      _editing = info.isEmpty;
    });
    _fillControllers(info);
  }

  void _fillControllers(MedicalInfo info) {
    _name.text = info.fullName;
    _dob.text = info.dateOfBirth;
    _blood.text = info.bloodGroup;
    _allergies.text = info.allergies;
    _conditions.text = info.conditions;
    _medications.text = info.medications;
    _notes.text = info.notes;
    _contactName.text = info.emergencyContactName;
    _contactPhone.text = info.emergencyContactPhone;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final info = MedicalInfo(
      fullName: _name.text.trim(),
      dateOfBirth: _dob.text.trim(),
      bloodGroup: _blood.text.trim(),
      allergies: _allergies.text.trim(),
      conditions: _conditions.text.trim(),
      medications: _medications.text.trim(),
      notes: _notes.text.trim(),
      emergencyContactName: _contactName.text.trim(),
      emergencyContactPhone: _contactPhone.text.trim(),
    );
    await _repository.save(info);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _info = info;
      _editing = false;
      _saving = false;
    });
    showAppSnack(context, 'Medical ID saved', tone: Tone.success);
  }

  void _cancelEdit() {
    _fillControllers(_info!);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical ID'),
        actions: [
          if (info != null && !_editing && !info.isEmpty)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: info == null
          ? const Center(child: CircularProgressIndicator())
          : _editing
              ? _buildForm(info)
              : _buildCard(info),
    );
  }

  // ---------------------------------------------------------------------------
  // View
  // ---------------------------------------------------------------------------

  Widget _buildCard(MedicalInfo info) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.safety;
    String orDash(String v) => v.trim().isEmpty ? '—' : v;

    return ListView(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header band: solid SOS colour so it reads as a medical card.
              Container(
                color: s.sos,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Row(
                  children: [
                    Icon(Icons.medical_information_rounded, color: s.onSos),
                    const SizedBox(width: 10),
                    Text(
                      'MEDICAL ID',
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: s.onSos,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.fullName, style: theme.textTheme.headlineSmall),
                    if (info.dateOfBirth.isNotEmpty)
                      Text('Born ${info.dateOfBirth}',
                          style: theme.textTheme.bodyMedium!
                              .copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _Fact(
                            label: 'Blood group',
                            value: orDash(info.bloodGroup),
                            emphasise: true,
                          ),
                        ),
                        Expanded(
                          child: _Fact(
                            label: 'Allergies',
                            value: orDash(info.allergies),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              _Fact.tile('Medical conditions', orDash(info.conditions)),
              _Fact.tile('Medications', orDash(info.medications)),
              if (info.notes.isNotEmpty) _Fact.tile('Notes', info.notes),
              const Divider(),
              _Fact.tile(
                'Emergency contact',
                info.emergencyContactName.isEmpty &&
                        info.emergencyContactPhone.isEmpty
                    ? '—'
                    : [info.emergencyContactName, info.emergencyContactPhone]
                        .where((v) => v.isNotEmpty)
                        .join(' · '),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const NoticeCard(
          tone: Tone.info,
          title: 'How first responders use this',
          message: 'Show this card, or the QR card, if you are hurt or '
              "can't speak. Keep it up to date. It's stored only on this "
              'phone.',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Edit
  // ---------------------------------------------------------------------------

  Widget _buildForm(MedicalInfo info) {
    final hasSaved = !info.isEmpty;
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          if (!hasSaved)
            const NoticeCard(
              tone: Tone.info,
              icon: Icons.medical_information_outlined,
              title: 'Create your Medical ID',
              message: 'Helps paramedics treat you quickly. Fill in what '
                  "you're comfortable sharing. It stays on this phone.",
            ),
          const SectionLabel('About you'),
          _field(_name, 'Full name', Icons.person_outline_rounded,
              required: true),
          _field(_dob, 'Date of birth', Icons.cake_outlined,
              hint: 'e.g. 14 Feb 1995'),
          const SectionLabel('Medical'),
          _field(_blood, 'Blood group', Icons.bloodtype_outlined,
              hint: 'e.g. O+'),
          _field(_allergies, 'Allergies', Icons.warning_amber_rounded),
          _field(_conditions, 'Medical conditions',
              Icons.monitor_heart_outlined),
          _field(_medications, 'Current medications',
              Icons.medication_outlined),
          _field(_notes, 'Other notes', Icons.notes_rounded, lines: 3),
          const SectionLabel('Emergency contact'),
          _field(_contactName, 'Name', Icons.person_outline_rounded),
          _field(_contactPhone, 'Phone number', Icons.call_outlined,
              keyboard: TextInputType.phone),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Text('Save Medical ID'),
          ),
          if (hasSaved) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: _cancelEdit, child: const Text('Cancel')),
          ],
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
    bool required = false,
    int lines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        minLines: lines,
        maxLines: lines == 1 ? 1 : lines + 2,
        keyboardType: keyboard,
        textCapitalization: keyboard == null
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        textInputAction:
            lines == 1 ? TextInputAction.next : TextInputAction.newline,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }
}

/// One labelled fact on the Medical ID card.
class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.emphasise = false,
    this.padding = EdgeInsets.zero,
  });

  /// A full-width fact row inside the card.
  factory _Fact.tile(String label, String value) => _Fact(
        label: label,
        value: value,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      );

  final String label;
  final String value;
  final bool emphasise;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelMedium!
                  .copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            value,
            style: emphasise
                ? theme.textTheme.headlineSmall!
                    .copyWith(color: context.safety.sos)
                : theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
