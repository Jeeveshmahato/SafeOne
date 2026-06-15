import 'package:flutter/material.dart';

import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';

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
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter a name'
                          : null,
                ),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: 'Phone number'),
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
            ElevatedButton(
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
    setState(() {
      _contacts = [..._contacts]..removeAt(index);
    });
    await _repository.saveContacts(_contacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency contacts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No contacts yet.\nTap "Add" to add someone who should '
                      'be alerted in an emergency.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: _contacts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(contact.name),
                      subtitle: Text(contact.phone),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteContact(index),
                      ),
                    );
                  },
                ),
    );
  }
}
