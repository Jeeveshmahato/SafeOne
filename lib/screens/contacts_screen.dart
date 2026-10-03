import 'package:flutter/material.dart';

import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';
import '../widgets/app_ui.dart';

/// Screen where the user adds, views, and deletes emergency contacts.
///
/// It owns its own copy of the list, saves every change to the phone, and
/// shows the live list. When the user goes back, the home screen reloads.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactsRepository _repository = ContactsRepository();
  List<EmergencyContact> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final contacts = await _repository.loadContacts();
    setState(() {
      _contacts = contacts;
      _loading = false;
    });
  }

  /// Show a popup form to add a new contact.
  Future<void> _showAddDialog() async {
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
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.call_outlined),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter a phone number'
                          : null,
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

    if (saved == true) {
      final newContact = EmergencyContact(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      setState(() => _contacts = [..._contacts, newContact]);
      await _repository.saveContacts(_contacts);
    }
  }

  Future<void> _deleteContact(int index) async {
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
      floatingActionButton: FloatingActionButton.extended(
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
