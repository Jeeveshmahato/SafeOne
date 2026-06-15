import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/safety_event.dart';
import '../services/safety_event_repository.dart';

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
          TextButton(
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
        title: const Text('Safety Log'),
        centerTitle: true,
        actions: [
          if (_events.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Export / share log',
              onPressed: _exportLog,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear log',
              onPressed: _clearAll,
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logIncident,
        icon: const Icon(Icons.add),
        label: const Text('Log incident'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          size: 80, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No safety events yet',
                        style:
                            TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SOS alerts, check-ins and incidents you log\n'
                        'will appear here.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
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

  Color _getEventColor() {
    switch (event.type) {
      case SafetyEventType.sos:
        return Colors.red;
      case SafetyEventType.checkIn:
        return Colors.green;
      case SafetyEventType.fakeCall:
        return Colors.blue;
      case SafetyEventType.incidentLogged:
        return Colors.orange;
      case SafetyEventType.locationShared:
        return Colors.purple;
    }
  }

  IconData _getEventIcon() {
    switch (event.type) {
      case SafetyEventType.sos:
        return Icons.emergency;
      case SafetyEventType.checkIn:
        return Icons.check_circle;
      case SafetyEventType.fakeCall:
        return Icons.phone;
      case SafetyEventType.incidentLogged:
        return Icons.warning;
      case SafetyEventType.locationShared:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: Icon(
          _getEventIcon(),
          color: _getEventColor(),
          size: 28,
        ),
        title: Text(
          event.typeLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, HH:mm').format(event.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
            if (event.location != null)
              Text(
                event.location!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (event.contactsNotified != null && event.contactsNotified!.isNotEmpty)
              Text(
                '→ ${event.contactsNotified!.join(', ')}',
                style: const TextStyle(fontSize: 11, color: Colors.blue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red, size: 20),
          onPressed: onDelete,
        ),
        onTap: () => _showEventDetails(context),
      ),
    );
  }

  void _showEventDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.typeLabel,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Time',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            Text(
              DateFormat('EEEE, MMM d, yyyy · HH:mm:ss').format(event.timestamp),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Description',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            Text(
              event.description,
              style: const TextStyle(fontSize: 14),
            ),
            if (event.location != null) ...[
              const SizedBox(height: 12),
              Text(
                'Location',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
              Text(
                event.location!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (event.contactsNotified != null && event.contactsNotified!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Contacts Notified',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
              ...event.contactsNotified!.map((name) => Text('• $name')),
            ],
          ],
        ),
      ),
    );
  }
}
