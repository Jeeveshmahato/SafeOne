import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../models/danger_zone.dart';
import '../services/danger_zone_repository.dart';

/// Screen to manage danger zones (unsafe areas marked by the user).
/// Users can add zones with current location and a note, view all zones, and delete them.
class DangerZonesScreen extends StatefulWidget {
  const DangerZonesScreen({super.key});

  @override
  State<DangerZonesScreen> createState() => _DangerZonesScreenState();
}

class _DangerZonesScreenState extends State<DangerZonesScreen> {
  final DangerZoneRepository _repository = DangerZoneRepository();
  List<DangerZone> _zones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final zones = await _repository.loadZones();
    setState(() {
      _zones = zones;
      _loading = false;
    });
  }

  /// Show a dialog to add a new danger zone.
  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    double? capturedLat;
    double? capturedLng;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Mark danger zone'),
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
                      decoration: const InputDecoration(labelText: 'Zone name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Give this place a name'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      // Incognito keyboard: private text must not be learned or synced
                      // by the keyboard app.
                      enableIMEPersonalizedLearning: false,
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (e.g. reason, time of day)',
                        hintText: 'Unsafe alley after 9 PM',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      capturedLat != null && capturedLng != null
                          ? 'Location: ${capturedLat!.toStringAsFixed(4)}, ${capturedLng!.toStringAsFixed(4)}'
                          : 'No location captured yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: capturedLat != null ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final position =
                              await Geolocator.getCurrentPosition();
                          setDialogState(() {
                            capturedLat = position.latitude;
                            capturedLng = position.longitude;
                          });
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.location_on),
                      label: const Text('Use current location'),
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
                    if (formKey.currentState!.validate() &&
                        capturedLat != null &&
                        capturedLng != null) {
                      Navigator.pop(context, true);
                    } else if (capturedLat == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tap 'Use current location' first"),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && capturedLat != null && capturedLng != null) {
      final newZone = DangerZone(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        note: noteController.text.trim(),
        latitude: capturedLat!,
        longitude: capturedLng!,
        createdAt: DateTime.now(),
      );

      await _repository.addZone(newZone);
      await _load();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Danger zone added')),
        );
      }
    }

    nameController.dispose();
    noteController.dispose();
  }

  /// Delete a danger zone.
  Future<void> _deleteZone(DangerZone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete zone?'),
          content: Text('Remove "${zone.name}" from danger zones?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _repository.deleteZone(zone.id);
      await _load();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zone deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danger Zones'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _zones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No danger zones marked yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mark unsafe areas to get warnings\nwhen you\'re nearby',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _zones.length,
                  itemBuilder: (context, index) {
                    final zone = _zones[index];
                    final dateStr = DateFormat('MMM d, yyyy').format(zone.createdAt);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          Icons.location_off,
                          color: Colors.red[400],
                        ),
                        title: Text(zone.name),
                        subtitle: Text(
                          '${zone.note}\n${zone.latitude.toStringAsFixed(4)}, ${zone.longitude.toStringAsFixed(4)} · $dateStr',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteZone(zone),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Add danger zone',
        child: const Icon(Icons.add),
      ),
    );
  }
}
