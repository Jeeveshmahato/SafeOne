import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';

class QuickContactsScreen extends StatefulWidget {
  const QuickContactsScreen({super.key});

  @override
  State<QuickContactsScreen> createState() => _QuickContactsScreenState();
}

class _QuickContactsScreenState extends State<QuickContactsScreen> {
  final ContactsRepository _contactsRepository = ContactsRepository();
  List<EmergencyContact> _contacts = [];
  final List<String> _favoriteNames = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _contactsRepository.loadContacts();
    if (mounted) {
      setState(() => _contacts = contacts);
    }
  }

  void _toggleFavorite(String contactName) {
    setState(() {
      if (_favoriteNames.contains(contactName)) {
        _favoriteNames.remove(contactName);
      } else {
        if (_favoriteNames.length < 5) {
          _favoriteNames.add(contactName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only favorite up to 5 contacts')),
          );
        }
      }
    });
  }

  Future<void> _callContact(EmergencyContact contact) async {
    final url = 'tel:${contact.phone}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make call')),
        );
      }
    }
  }

  Future<void> _messageContact(EmergencyContact contact) async {
    final url = 'sms:${contact.phone}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _contacts
        .where((c) => _favoriteNames.contains(c.name))
        .toList();
    final others = _contacts
        .where((c) => !_favoriteNames.contains(c.name))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Contacts'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
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
                    '⚡ Quick Access',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mark up to 5 contacts as favorites for instant 1-tap calling or messaging. '
                    'Perfect for emergencies when every second counts.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Favorites section
            if (favorites.isNotEmpty) ...[
              const Text(
                '⭐ Favorite Contacts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...favorites.map((contact) => _buildFavoriteCard(contact)).toList(),
              const SizedBox(height: 24),
            ],

            // All contacts section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Contacts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_contactsRepository.toString()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_contacts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.person_add, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text(
                        'No contacts added',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...others.map((contact) => _buildContactCard(contact)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.red,
                child: const Icon(Icons.star, color: Colors.white),
              ),
              title: Text(
                contact.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(contact.phone),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _toggleFavorite(contact.name),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _callContact(contact),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _messageContact(contact),
                    icon: const Icon(Icons.sms, size: 18),
                    label: const Text('SMS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(contact.name[0]),
        ),
        title: Text(contact.name),
        subtitle: Text(contact.phone),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green, size: 20),
              onPressed: () => _callContact(contact),
              tooltip: 'Call',
            ),
            IconButton(
              icon: const Icon(Icons.sms, color: Colors.blue, size: 20),
              onPressed: () => _messageContact(contact),
              tooltip: 'Message',
            ),
            IconButton(
              icon: const Icon(Icons.star_border, color: Colors.orange, size: 20),
              onPressed: () => _toggleFavorite(contact.name),
              tooltip: 'Add to favorites',
            ),
          ],
        ),
      ),
    );
  }
}
