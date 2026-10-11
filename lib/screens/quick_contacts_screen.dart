import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

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
          showAppSnack(context, 'You can star up to 5 contacts',
              tone: Tone.warning);
        }
      }
    });
  }

  /// Opens the dialer / messages app. We launch directly rather than asking
  /// `canLaunchUrl` first, which can wrongly report false on Android 11+.
  Future<void> _launch(Uri uri, String error) async {
    var ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {}
    if (!ok && mounted) showAppSnack(context, error, tone: Tone.danger);
  }

  Future<void> _callContact(EmergencyContact contact) =>
      _launch(Uri.parse('tel:${contact.phone}'), "Couldn't start the call");

  Future<void> _messageContact(EmergencyContact contact) =>
      _launch(Uri.parse('sms:${contact.phone}'), "Couldn't open Messages");

  @override
  Widget build(BuildContext context) {
    final favorites = _contacts
        .where((c) => _favoriteNames.contains(c.name))
        .toList();
    final others = _contacts
        .where((c) => !_favoriteNames.contains(c.name))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quick contacts')),
      body: _contacts.isEmpty
          ? const EmptyState(
              icon: Icons.star_outline_rounded,
              title: 'No contacts yet',
              message: 'Add emergency contacts in the "All" tab, then star up '
                  'to 5 of them here for one-tap calling.',
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
              children: [
                const NoticeCard(
                  tone: Tone.info,
                  icon: Icons.bolt_rounded,
                  title: 'One-tap access',
                  message: 'Star up to 5 contacts to call or message them '
                      'with one tap.',
                ),
                if (favorites.isNotEmpty) ...[
                  SectionLabel('Starred (${favorites.length}/5)'),
                  for (final contact in favorites) _buildFavoriteCard(contact),
                ],
                if (others.isNotEmpty) ...[
                  SectionLabel('All contacts (${others.length})'),
                  for (final contact in others) _buildContactCard(contact),
                ],
              ],
            ),
    );
  }

  Widget _avatar(EmergencyContact contact, {bool favourite = false}) {
    final scheme = Theme.of(context).colorScheme;
    final name = contact.name.trim();
    return CircleAvatar(
      radius: 22,
      backgroundColor:
          favourite ? context.safety.sosContainer : scheme.secondaryContainer,
      foregroundColor:
          favourite ? context.safety.onSosContainer : scheme.onSecondaryContainer,
      child: favourite
          ? const Icon(Icons.star_rounded)
          : Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium!
                  .copyWith(color: scheme.onSecondaryContainer)),
    );
  }

  Widget _buildFavoriteCard(EmergencyContact contact) {
    final s = context.safety;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              leading: _avatar(contact, favourite: true),
              title: Text(contact.name),
              subtitle: Text(contact.phone),
              trailing: IconButton(
                icon: const Icon(Icons.star_rounded),
                color: s.warning,
                tooltip: 'Unstar',
                onPressed: () => _toggleFavorite(contact.name),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: s.sos,
                        foregroundColor: s.onSos,
                      ),
                      onPressed: () => _callContact(contact),
                      icon: const Icon(Icons.call_rounded, size: 20),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _messageContact(contact),
                      icon: const Icon(Icons.sms_rounded, size: 20),
                      label: const Text('SMS'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        leading: _avatar(contact),
        title: Text(contact.name),
        subtitle: Text(contact.phone),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call_rounded),
              color: context.safety.success,
              onPressed: () => _callContact(contact),
              tooltip: 'Call',
            ),
            IconButton(
              icon: const Icon(Icons.sms_rounded),
              color: context.safety.info,
              onPressed: () => _messageContact(contact),
              tooltip: 'Message',
            ),
            IconButton(
              icon: const Icon(Icons.star_outline_rounded),
              onPressed: () => _toggleFavorite(contact.name),
              tooltip: 'Star',
            ),
          ],
        ),
      ),
    );
  }
}
