import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// A list of important emergency phone numbers the user can call with one tap.
///
/// Tapping a number opens the phone's normal dialer with the number filled in
/// (it does NOT auto-call, so there is no risk of an accidental call and no
/// special permission is needed).
///
/// These are India's national helplines. To change them for another country,
/// just edit the [_helplines] list below.
class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  // Each helpline is a name + a phone number.
  static const List<({String name, String number, IconData icon})> _helplines =
      [
    (name: 'Police', number: '100', icon: Icons.local_police),
    (name: 'Emergency (police, fire, ambulance)', number: '112', icon: Icons.emergency),
    (name: 'Women Helpline', number: '1091', icon: Icons.woman),
    (name: 'Domestic Abuse Helpline', number: '181', icon: Icons.home),
    (name: 'Ambulance', number: '102', icon: Icons.local_hospital),
    (name: 'Child Helpline', number: '1098', icon: Icons.child_care),
    (name: 'Cyber Crime', number: '1930', icon: Icons.computer),
  ];

  /// Open the dialer with the chosen number. Launches directly: asking
  /// `canLaunchUrl` first can wrongly report false on Android 11+.
  Future<void> _dial(BuildContext context, String number) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {}
    if (!ok && context.mounted) {
      showAppSnack(context, "Couldn't open the dialer. Call $number yourself.",
          tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency helplines')),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
        itemCount: _helplines.length,
        itemBuilder: (context, index) {
          final line = _helplines[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
              leading: IconBadge(icon: line.icon),
              title: Text(line.name),
              subtitle: Text(
                line.number,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              trailing: IconButton.filledTonal(
                icon: const Icon(Icons.call_rounded),
                tooltip: 'Call ${line.number}',
                onPressed: () => _dial(context, line.number),
              ),
              onTap: () => _dial(context, line.number),
            ),
          );
        },
      ),
    );
  }
}
