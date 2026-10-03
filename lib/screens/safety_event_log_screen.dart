import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/safety_event.dart';
import '../services/safety_event_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// The single Safety Log. Shows every real safety action the app recorded (SOS,
/// check-in, location shared, fake call) and lets the user log an incident by
/// hand, delete entries, export, or clear. Replaces the old demo-only Incident
/// Vault + Safety Event Log screens.
class SafetyEventLogScreen extends StatefulWidget {
  const SafetyEventLogScreen({super.key});

  @override
  State<SafetyEventLogScreen> createState() => _SafetyEventLogScreenState();
}

class _SafetyEventLogScreenState extends State<SafetyEventLogScreen> {
  final SafetyEventRepository _repo = SafetyEventRepository();
  List<SafetyEvent> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _repo.load();
    if (!mounted) return;
    setState(() {
      _events = events; // already sorted newest-first by the repo
      _loading = false;
    });
  }

  Future<void> _deleteEvent(SafetyEvent event) async {
    await _repo.remove(event.id);
    await _loadEvents();
    if (!mounted) return;
    // Log entries can be evidence, so a stray tap must be easy to undo.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Text('Entry deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await _repo.add(event);
            await _loadEvents();
          },
        ),
      ));
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear the whole log?'),
        content: const Text('This permanently deletes all logged events.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Theme.of(ctx).colorScheme.onError,
                minimumSize: const Size(0, 44),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok != true) return;
    await _repo.clear();
    await _loadEvents();
  }

  /// Let the user record an incident by hand (place + what happened).
  Future<void> _logIncident() async {
    final locationCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log an incident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Where',
                hintText: 'e.g. Bus stop, MG Road',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What happened',
                hintText: 'Describe the incident',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (saved != true) return;
    final desc = descCtrl.text.trim();
    final loc = locationCtrl.text.trim();
    if (desc.isEmpty && loc.isEmpty) return;
    await _repo.log(
      SafetyEventType.incidentLogged,
      desc.isEmpty ? 'Incident logged' : desc,
      location: loc.isEmpty ? null : loc,
    );
    await _loadEvents();
  }

  Future<void> _exportLog() async {
    final buffer = StringBuffer();
    buffer.writeln('SAFETY LOG');
    buffer.writeln(
        'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('-' * 60);
    for (final event in _events) {
      buffer.writeln('\n${event.typeLabel}');
      buffer.writeln(
          'Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.timestamp)}');
      buffer.writeln('Details: ${event.description}');
      if (event.location != null) buffer.writeln('Location: ${event.location}');
      if (event.contactsNotified?.isNotEmpty ?? false) {
        buffer.writeln('Contacts: ${event.contactsNotified!.join(', ')}');
      }
      buffer.writeln('-' * 60);
    }
    await SharePlus.instance.share(
      ShareParams(text: buffer.toString(), subject: 'My safety log'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety log'),
        actions: [
          if (_events.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: 'Export / share log',
              onPressed: _exportLog,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear log',
              onPressed: _clearAll,
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logIncident,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Log incident'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const EmptyState(
                  icon: Icons.history_rounded,
                  title: 'No safety events yet',
                  message: 'SOS alerts, check-ins and incidents you log '
                      'will appear here.',
                )
              : ListView.builder(
                  // Leave room at the bottom so the FAB never hides an entry.
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, 96 + MediaQuery.paddingOf(context).bottom),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index]; // newest first
                    return _EventCard(
                      event: event,
                      onDelete: () => _deleteEvent(event),
                    );
                  },
                ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SafetyEvent event;
  final VoidCallback onDelete;

  const _EventCard({
    required this.event,
    required this.onDelete,
  });

  Color _getEventColor(BuildContext context) {
    final s = context.safety;
    switch (event.type) {
      case SafetyEventType.sos:
        return s.sos;
      case SafetyEventType.checkIn:
        return s.success;
      case SafetyEventType.fakeCall:
        return s.info;
      case SafetyEventType.incidentLogged:
        return s.warning;
      case SafetyEventType.locationShared:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getEventIcon() {
    switch (event.type) {
      case SafetyEventType.sos:
        return Icons.sos_rounded;
      case SafetyEventType.checkIn:
        return Icons.verified_user_rounded;
      case SafetyEventType.fakeCall:
        return Icons.phone_in_talk_rounded;
      case SafetyEventType.incidentLogged:
        return Icons.edit_note_rounded;
      case SafetyEventType.locationShared:
        return Icons.share_location_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        leading: IconBadge(
          icon: _getEventIcon(),
          color: _getEventColor(context),
        ),
        title: Text(event.typeLabel),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(DateFormat('d MMM, HH:mm').format(event.timestamp),
                style: muted),
            if (event.location != null)
              Text(
                event.location!,
                style: muted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (event.contactsNotified != null &&
                event.contactsNotified!.isNotEmpty)
              Text(
                '→ ${event.contactsNotified!.join(', ')}',
                style: muted!.copyWith(color: theme.colorScheme.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 22),
          tooltip: 'Delete entry',
          onPressed: onDelete,
        ),
        onTap: () => _showEventDetails(context),
      ),
    );
  }

  void _showEventDetails(BuildContext context) {
    final theme = Theme.of(context);
    Widget field(String label, Widget value) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              value,
            ],
          ),
        );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(
                      icon: _getEventIcon(), color: _getEventColor(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(event.typeLabel,
                        style: theme.textTheme.titleLarge),
                  ),
                ],
              ),
              field(
                'Time',
                Text(
                  DateFormat('EEEE, d MMM yyyy · HH:mm:ss')
                      .format(event.timestamp),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              field('Description',
                  Text(event.description, style: theme.textTheme.bodyLarge)),
              if (event.location != null)
                field('Location',
                    Text(event.location!, style: theme.textTheme.bodyLarge)),
              if (event.contactsNotified != null &&
                  event.contactsNotified!.isNotEmpty)
                field(
                  'Contacts notified',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final name in event.contactsNotified!)
                        Text('• $name', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
