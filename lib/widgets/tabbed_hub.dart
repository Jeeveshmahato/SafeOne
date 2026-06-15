import 'package:flutter/material.dart';

/// One entry in a [TabbedHub]: a bottom-bar destination and the screen it shows.
class HubTab {
  const HubTab({required this.icon, required this.label, required this.screen});

  final IconData icon;
  final String label;
  final Widget screen;
}

/// Groups several existing full screens under a single entry point, switching
/// between them with a bottom navigation bar.
///
/// Each child keeps its own [Scaffold]/AppBar (which acts as the section
/// title), so there are no stacked app bars and the original screens are
/// reused untouched. An [IndexedStack] keeps each tab's state alive while the
/// user moves between them.
class TabbedHub extends StatefulWidget {
  const TabbedHub({super.key, required this.tabs, this.initialIndex = 0});

  final List<HubTab> tabs;
  final int initialIndex;

  @override
  State<TabbedHub> createState() => _TabbedHubState();
}

class _TabbedHubState extends State<TabbedHub> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final tab in widget.tabs) tab.screen],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final tab in widget.tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}
