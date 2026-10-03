import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/india_emergency_resources.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

class IndiaEmergencyResourcesScreen extends StatefulWidget {
  /// Which tab to open on: 'emergency' (default), 'fraud' or 'portals'.
  final String initialTab;

  const IndiaEmergencyResourcesScreen({super.key, this.initialTab = 'emergency'});

  @override
  State<IndiaEmergencyResourcesScreen> createState() =>
      _IndiaEmergencyResourcesScreenState();
}

class _IndiaEmergencyResourcesScreenState
    extends State<IndiaEmergencyResourcesScreen> {
  late String _selectedTab = widget.initialTab; // emergency, fraud, portals
  final LocationService _locationService = LocationService();
  bool _copyingLocation = false;

  /// Get the current location and copy a Google Maps link to the clipboard, so
  /// the user can paste it into a complaint/report form on a portal.
  Future<void> _copyMyLocation() async {
    setState(() => _copyingLocation = true);
    try {
      final pos = await _locationService.getCurrentLocation();
      final link = _locationService.buildMapsLink(pos.latitude, pos.longitude);
      await Clipboard.setData(ClipboardData(text: link));
      if (!mounted) return;
      showAppSnack(context, 'Location link copied — paste it into the form.',
          tone: Tone.success);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context,
          "Couldn't get location: ${e.toString().replaceFirst('Exception: ', '')}",
          tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _copyingLocation = false);
    }
  }

  /// Make sure a URL has a scheme so it can be launched/parsed.
  String _normalizeUrl(String raw) {
    final u = raw.trim();
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return 'https://$u';
  }

  /// Try to launch [uri]; returns false if it couldn't be opened. We attempt a
  /// couple of launch modes because some devices/handlers reject one of them.
  Future<bool> _tryLaunch(Uri uri,
      {LaunchMode mode = LaunchMode.externalApplication}) async {
    try {
      if (await launchUrl(uri, mode: mode)) return true;
    } catch (_) {/* fall through to the platform-default attempt */}
    try {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  Future<void> _callNumber(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final ok = await _tryLaunch(Uri.parse('tel:$clean'),
        mode: LaunchMode.platformDefault);
    if (!ok && mounted) {
      _showCopyableSnack("Couldn't open the dialer", clean);
    }
  }

  Future<void> _openUrl(String rawUrl) async {
    final url = _normalizeUrl(rawUrl);
    final ok = await _tryLaunch(Uri.parse(url));
    if (!ok && mounted) {
      _showCopyableSnack("Couldn't open the link", url);
    }
  }

  /// Copy a value to the clipboard and confirm it.
  Future<void> _copy(String value, {String label = 'Copied'}) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) showAppSnack(context, '$label: $value', tone: Tone.success);
  }

  /// Show a snackbar that lets the user copy a value when it can't be opened.
  void _showCopyableSnack(String message, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message\n$value'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: 'Copy', onPressed: () => _copy(value)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('India emergency resources')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                      value: 'emergency',
                      icon: Icon(Icons.emergency_rounded),
                      label: Text('Emergency')),
                  ButtonSegment(
                      value: 'fraud',
                      icon: Icon(Icons.gpp_bad_rounded),
                      label: Text('Fraud')),
                  ButtonSegment(
                      value: 'portals',
                      icon: Icon(Icons.account_balance_rounded),
                      label: Text('Portals')),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (v) =>
                    setState(() => _selectedTab = v.first),
              ),
            ),
          ),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 'emergency') {
      return _buildEmergencyTab();
    } else if (_selectedTab == 'fraud') {
      return _buildFraudTab();
    } else {
      return _buildPortalsTab();
    }
  }

  EdgeInsets get _listPadding => EdgeInsets.fromLTRB(
      16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom);

  Widget _buildEmergencyTab() {
    return ListView(
      padding: _listPadding,
      children: [
        const NoticeCard(
          tone: Tone.danger,
          title: 'India emergency numbers',
          message: 'Tap a number to call. All of these are free to call.',
        ),
        const SizedBox(height: 16),
        for (final resource in IndiaEmergencies.resources)
          _buildEmergencyCard(resource),
      ],
    );
  }

  Widget _buildEmergencyCard(IndiaEmergencyResource resource) {
    final theme = Theme.of(context);
    final s = context.safety;
    final color = switch (resource.phoneNumber) {
      '100' || '112' => s.sos,
      '1091' => theme.colorScheme.primary,
      '102' || '108' => s.success,
      '101' => s.warning,
      _ => s.info,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _callNumber(resource.phoneNumber),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 64),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  resource.phoneNumber,
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.name, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      resource.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Call ${resource.phoneNumber}',
                icon: const Icon(Icons.call_rounded),
                onPressed: () => _callNumber(resource.phoneNumber),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFraudTab() {
    return ListView(
      padding: _listPadding,
      children: [
        const NoticeCard(
          tone: Tone.warning,
          title: 'Online fraud guides',
          message: 'Pick the type of fraud for step-by-step reporting '
              'instructions and the official portal.',
        ),
        const SizedBox(height: 16),
        for (final guide in IndiaEmergencies.fraudGuides)
          _buildFraudCard(guide),
      ],
    );
  }

  Widget _buildFraudCard(OnlineFraudGuide guide) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: IconBadge(
            icon: Icons.gpp_bad_rounded, color: context.safety.warning),
        title: Text(guide.title, style: theme.textTheme.titleSmall),
        subtitle: Text(guide.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Steps to report', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final step in guide.steps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(step, style: theme.textTheme.bodyMedium),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      _callNumber(guide.phoneNumber.replaceAll('-', '')),
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: Text('Call ${guide.phoneNumber}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openUrl(guide.reportingUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Report'),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Copy link',
                onPressed: () => _copy(_normalizeUrl(guide.reportingUrl),
                    label: 'Link copied'),
                icon: const Icon(Icons.copy_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortalsTab() {
    return ListView(
      padding: _listPadding,
      children: [
        const NoticeCard(
          tone: Tone.info,
          title: 'Government portals',
          message: 'Official websites for filing complaints and reporting '
              'crimes. Tap to open.',
        ),
        const SizedBox(height: 12),
        // Most complaint forms ask "where did it happen" — let the user copy
        // their current location link to paste straight in.
        OutlinedButton.icon(
          onPressed: _copyingLocation ? null : _copyMyLocation,
          icon: _copyingLocation
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded),
          label: const Text('Copy my live location'),
        ),
        const SizedBox(height: 16),
        for (final portal in IndiaEmergencies.governmentPortals)
          _buildPortalCard(portal),
      ],
    );
  }

  Widget _buildPortalCard(IndiaGovernmentPortal portal) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final url = _normalizeUrl(portal.url);
    final host = Uri.tryParse(url)?.host ?? url;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(portal.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              portal.description,
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.safety.infoContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'For: ${portal.caseType}',
                style: theme.textTheme.labelMedium!
                    .copyWith(color: context.safety.onInfoContainer),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openUrl(portal.url),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(host, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Copy link',
                  onPressed: () => _copy(url, label: 'Link copied'),
                  icon: const Icon(Icons.copy_rounded, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
