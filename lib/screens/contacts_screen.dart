import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/emergency_contact.dart';
import '../services/app_lock_service.dart';
import '../services/contacts_repository.dart';
import '../services/sms_service.dart';
import '../widgets/app_ui.dart';
import 'lock_screen.dart';
import 'pin_setup_screen.dart';

/// Screen where the user adds, views, and deletes emergency contacts.
///
/// It owns its own copy of the list, saves every change to the phone, and
/// shows the live list. When the user goes back, the home screen reloads.
///
/// Changing the list needs the separate contacts PIN (created the first time
/// a contact is added). Once entered, it stays valid until the user leaves
/// this screen or the app goes to the background.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactsRepository _repository = ContactsRepository();
  final AppLockService _lock = AppLockService();
  List<EmergencyContact> _contacts = [];
  bool _loading = true;

  /// True once the contacts PIN was entered on this visit.
  bool _pinVerified = false;
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    // Leaving the app forgets the PIN, unless it was only the fingerprint /
    // screen-lock prompt (from "Forgot PIN?") covering the screen.
    onHide: () {
      if (!AppLockService.systemPromptActive) _pinVerified = false;
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle; // start listening
    _load();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Make sure the contacts PIN was entered (or create it the first time).
  Future<bool> _ensurePin() async {
    if (_pinVerified) return true;
    final hasPin = await _lock.isPinSet(PinKind.contacts);
    if (!mounted) return false;
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => hasPin
            ? LockScreen(
                kind: PinKind.contacts,
                onUnlocked: () => Navigator.pop(context, true),
              )
            : const PinSetupScreen(kind: PinKind.contacts),
      ),
    );
    if (ok == true) _pinVerified = true;
    return ok == true;
  }

  Future<void> _load() async {
    final contacts = await _repository.loadContacts();
    setState(() {
      _contacts = contacts;
      _loading = false;
    });
  }

  /// Digits with an optional leading "+": 3 digits for short codes like 112,
  /// up to 15 (the international maximum).
  static final RegExp _validPhone = RegExp(r'^\+?\d{3,15}$');

  /// Drop the spaces, dashes, dots and brackets people type in numbers.
  static String _normalisePhone(String raw) =>
      raw.trim().replaceAll(RegExp(r'[\s\-().]'), '');

  /// Show a popup form to add a new contact.
  Future<void> _showAddDialog() async {
    if (!await _ensurePin() || !mounted) return;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add contact'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  // Incognito keyboard: private text must not be learned or synced
                  // by the keyboard app.
                  enableIMEPersonalizedLearning: false,
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter a name'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  // Incognito keyboard: private text must not be learned or synced
                  // by the keyboard app.
                  enableIMEPersonalizedLearning: false,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.call_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a phone number';
                    }
                    // The SOS SMS goes to this number, so catch typos now
                    // rather than during an emergency.
                    if (!_validPhone.hasMatch(_normalisePhone(value))) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () {
                // Only close with "true" if the form is valid.
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // Ask again if the PIN expired while the form was open.
    if (saved == true && await _ensurePin()) {
      final newContact = EmergencyContact(
        name: nameController.text.trim(),
        phone: _normalisePhone(phoneController.text),
      );
      setState(() => _contacts = [..._contacts, newContact]);
      await _repository.saveContacts(_contacts);
      await _offerAutoSms();
    }
  }

  /// Right after a contact is added is when "send the SOS by itself" makes
  /// sense to the user, so ask for SMS permission here, with the reason,
  /// rather than leaving the SOS to fall back to a tap in Messages.
  Future<void> _offerAutoSms() async {
    if (!mounted || await SmsService.canSendAutomatically()) return;
    final status = await SmsService.permissionStatus();
    if (status.isRestricted || !mounted) return; // no SIM / telephony
    final allow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.sms_outlined),
        title: const Text('Send your SOS automatically?'),
        content: const Text(
          'Allow SMS so SafeOne can text your emergency contacts by itself, '
          'with no tap needed when every second counts.\n\n'
          'SafeOne only sends messages when you trigger an SOS, a check-in '
          'or live location — never anything else.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    if (allow != true) return;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    final result = await SmsService.requestPermission();
    if (!mounted || result.isGranted) return;
    // Android shows no prompt once it's blocked (denied twice, or a
    // "restricted setting"): the user has to switch it on in app settings.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('SMS is off for SafeOne. Turn it on in app '
          'settings to send your SOS automatically.'),
      action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
    ));
  }

  Future<void> _deleteContact(int index) async {
    if (!await _ensurePin() || !mounted) return;
    final removed = _contacts[index];
    setState(() {
      _contacts = [..._contacts]..removeAt(index);
    });
    await _repository.saveContacts(_contacts);
    if (!mounted) return;
    // Removing someone from the SOS list must be easy to undo.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${removed.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final restored = [..._contacts]
              ..insert(index.clamp(0, _contacts.length), removed);
            setState(() => _contacts = restored);
            await _repository.saveContacts(restored);
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency contacts')),
      // The empty state has its own "Add contact" button; showing the FAB too
      // would put two identical buttons on screen.
      floatingActionButton: _loading || _contacts.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add contact'),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? EmptyState(
                  icon: Icons.group_add_outlined,
                  title: 'No emergency contacts yet',
                  message: 'Add the people who should get your SOS alert '
                      'and live location.',
                  action: FilledButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Add contact'),
                  ),
                )
              : ListView.builder(
                  // Room at the bottom so the FAB never covers a contact.
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, 96 + MediaQuery.paddingOf(context).bottom),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    final name = contact.name.trim();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                          child: Text(
                            name.isEmpty
                                ? '?'
                                : name.characters.first.toUpperCase(),
                            style: theme.textTheme.titleMedium!
                                .copyWith(color: scheme.onSecondaryContainer),
                          ),
                        ),
                        title: Text(contact.name),
                        subtitle: Text(contact.phone),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          tooltip: 'Remove ${contact.name}',
                          onPressed: () => _deleteContact(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
