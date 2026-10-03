import 'package:flutter/material.dart';

import '../services/nearby_places_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

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
      showAppSnack(context, error.toString().replaceFirst('Exception: ', ''),
          tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby help')),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
            children: [
              const NoticeCard(
                tone: Tone.info,
                icon: Icons.map_outlined,
                message: 'Tap a place to see the nearest ones on Google Maps. '
                    'Make sure location (GPS) is on.',
              ),
              const SizedBox(height: 16),
              // Two per row; each row sizes to its tallest tile so long
              // labels or large fonts never overflow.
              for (var i = 0; i < _places.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var j = i; j < i + 2; j++) ...[
                          if (j > i) const SizedBox(width: 12),
                          Expanded(
                            child: j < _places.length
                                ? _PlaceTile(
                                    icon: _places[j].icon,
                                    label: _places[j].label,
                                    onTap: () => _open(_places[j].query),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // A dim overlay with a spinner while Maps is opening.
          if (_opening)
            ColoredBox(
              color: scheme.scrim.withValues(alpha: 0.32),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: scheme.outlineVariant),
    );
    return Material(
      color: scheme.surfaceContainerLowest,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: scheme.onSurface),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
