import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    (name: 'Emergency (All-in-one)', number: '112', icon: Icons.emergency),
    (name: 'Women Helpline', number: '1091', icon: Icons.woman),
    (name: 'Domestic Abuse Helpline', number: '181', icon: Icons.home),
    (name: 'Ambulance', number: '102', icon: Icons.local_hospital),
    (name: 'Child Helpline', number: '1098', icon: Icons.child_care),
    (name: 'Cyber Crime', number: '1930', icon: Icons.computer),
  ];

  /// Open the dialer with the chosen number.
  Future<void> _dial(BuildContext context, String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open dialer for $number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency helplines')),
      body: ListView.separated(
        itemCount: _helplines.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final line = _helplines[index];
          return ListTile(
            leading: CircleAvatar(child: Icon(line.icon)),
            title: Text(line.name),
            subtitle: Text(line.number),
            trailing: const Icon(Icons.call, color: Colors.green),
            onTap: () => _dial(context, line.number),
          );
        },
      ),
    );
  }
}
