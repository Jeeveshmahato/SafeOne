import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/reveal.dart';

/// A built-in, OFFLINE guide of safety and basic first-aid tips. All the text
/// is stored inside the app, so it works with no internet and no cost.
///
/// This is general information, NOT a substitute for professional medical help.
/// In a real emergency, call your local emergency number first.
class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  // Each tip has a title, an icon, and the steps to follow. To add a new tip,
  // just add another entry to this list.
  static const List<({String title, IconData icon, String body})> _tips = [
    (
      title: 'If you feel you are being followed',
      icon: Icons.directions_walk,
      body: '1. Stay calm and keep moving towards a crowded, well-lit place '
          '(shop, restaurant, bus stop).\n'
          '2. Cross the road or change direction to confirm you are followed.\n'
          '3. Call someone and say your location out loud.\n'
          '4. Use the SOS button or Fake Call in this app.\n'
          '5. Don\'t go straight home. Go somewhere busy first.',
    ),
    (
      title: 'Severe bleeding',
      icon: Icons.water_drop,
      body: '1. Press firmly on the wound with a clean cloth.\n'
          '2. Keep pressing. Don\'t stop to check it.\n'
          '3. If possible, raise the injured part above the heart.\n'
          '4. Add more cloth on top if it soaks through (do not remove the '
          'first).\n'
          '5. Get medical help quickly.',
    ),
    (
      title: 'Choking',
      icon: Icons.air,
      body: '1. Ask "Are you choking?" If they cannot speak or cough, act.\n'
          '2. Give 5 firm back blows between the shoulder blades.\n'
          '3. Then 5 abdominal thrusts (hands just above the navel, pull '
          'inwards and upwards).\n'
          '4. Repeat back blows and thrusts until the object comes out.\n'
          '5. If they become unconscious, start CPR and call for help.',
    ),
    (
      title: 'CPR (no breathing)',
      icon: Icons.favorite,
      body: '1. Call emergency services first (or ask someone to).\n'
          '2. Push hard and fast in the centre of the chest, about twice per '
          'second.\n'
          '3. Let the chest rise fully between pushes.\n'
          '4. Keep going until help arrives or the person wakes.\n'
          'Note: hands-only CPR is fine if you are not trained in rescue '
          'breaths.',
    ),
    (
      title: 'Burns',
      icon: Icons.local_fire_department,
      body: '1. Cool the burn under cool (not ice-cold) running water for at '
          'least 20 minutes.\n'
          '2. Remove tight items (rings, watches) before swelling starts.\n'
          '3. Do NOT apply toothpaste, butter or ice.\n'
          '4. Cover loosely with cling film or a clean cloth.\n'
          '5. Get medical help for large or deep burns.',
    ),
    (
      title: 'Safe travel at night',
      icon: Icons.nightlight,
      body: '• Share your live trip using Follow Me before you leave.\n'
          '• Sit near the driver or other women in shared transport.\n'
          '• Note the vehicle number and message it to a friend.\n'
          '• Keep your phone charged and SOS within reach.\n'
          '• Trust your gut. If something feels wrong, get out in a '
          'public place.',
    ),
    (
      title: 'If someone grabs you',
      icon: Icons.pan_tool,
      body: '• Shout loudly: "Help!" or "Fire!" to attract attention.\n'
          '• Aim for weak points: eyes, nose, throat, knees.\n'
          '• Use the loud Siren in this app to draw a crowd.\n'
          '• Break free and run towards people, not away from them.\n'
          '• Once safe, call the police and report immediately.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Safety & first aid')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          const NoticeCard(
            tone: Tone.warning,
            message: 'General guidance only. In a real emergency, call your '
                'local emergency number (112 in India) first.',
          ),
          const SizedBox(height: 16),
          for (final tip in _tips)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: RevealExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                leading: IconBadge(icon: tip.icon, size: 40),
                title: Text(tip.title, style: theme.textTheme.titleSmall),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tip.body, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
