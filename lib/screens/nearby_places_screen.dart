import 'package:flutter/material.dart';

import '../services/nearby_places_service.dart';

/// Screen that lets the user find nearby emergency / useful places.
///
/// Tapping a place type opens Google Maps showing those places around the
/// user's current location. No paid maps API is used — it just opens the
/// public Google Maps app/website, so it is free and works offline-installed.
class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  final NearbyPlacesService _service = NearbyPlacesService();

  // true while we are getting the location / opening Maps, so we can show a
  // spinner and stop double taps.
  bool _opening = false;

  // The list of place types shown in the grid. To add a new one, just add a
  // line here: a label, an icon, and the words to search on the map.
  static const List<({String label, IconData icon, String query})> _places = [
    // Safety services first.
    (label: 'Police station', icon: Icons.local_police, query: 'police station'),
    (label: 'Hospital', icon: Icons.local_hospital, query: 'hospital'),
    (label: 'Pharmacy', icon: Icons.local_pharmacy, query: 'pharmacy medical store'),
    // Transport hubs — usually staffed, lit and crowded, so good places to head
    // to if you feel unsafe.
    (label: 'Metro station', icon: Icons.directions_subway, query: 'metro station'),
    (label: 'Railway station', icon: Icons.directions_railway, query: 'railway station'),
    (label: 'Airport', icon: Icons.local_airport, query: 'airport'),
    (label: 'Bus stand', icon: Icons.directions_bus, query: 'bus stand'),
    (label: 'Taxi / Auto stand', icon: Icons.local_taxi, query: 'taxi auto stand'),
    // Other useful spots.
    (label: 'Hotel / Lodge', icon: Icons.hotel, query: 'hotel lodge'),
    (label: 'Petrol pump', icon: Icons.local_gas_station, query: 'petrol pump'),
    (label: 'ATM / Bank', icon: Icons.local_atm, query: 'atm bank'),
    (label: 'Crowded place', icon: Icons.people, query: 'mall market restaurant'),
  ];

  Future<void> _open(String query) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await _service.openNearby(query);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby help')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Tap a place to see the nearest ones around you on Google Maps. '
                'Make sure your location (GPS) is turned on.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: _places.map((place) {
                  return _PlaceTile(
                    icon: place.icon,
                    label: place.label,
                    onTap: () => _open(place.query),
                  );
                }).toList(),
              ),
            ],
          ),
          // A dim overlay with a spinner while Maps is opening.
          if (_opening)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

/// One tappable card in the grid: an icon and a label.
class _PlaceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PlaceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
