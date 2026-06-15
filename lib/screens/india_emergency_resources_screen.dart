import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/india_emergency_resources.dart';
import '../services/location_service.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location link copied — paste it into the form.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Couldn't get location: ${e.toString().replaceFirst('Exception: ', '')}"),
        ),
      );
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label: $value'),
            duration: const Duration(seconds: 2)),
      );
    }
  }

  /// Show a snackbar that lets the user copy a value when it can't be opened.
  void _showCopyableSnack(String message, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message\n$value'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: 'COPY', onPressed: () => _copy(value)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🇮🇳 India Emergency Resources'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('emergency', '🚨 Emergency'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton('fraud', '🚫 Online Fraud'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton('portals', '📋 Gov Portals'),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label) {
    final isSelected = _selectedTab == tabId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.blue : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => setState(() => _selectedTab = tabId),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
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

  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚨 INDIA EMERGENCY NUMBERS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap any number to call immediately. These are free emergency numbers.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...IndiaEmergencies.resources.map((resource) {
            return _buildEmergencyCard(resource);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(IndiaEmergencyResource resource) {
    Color getColor() {
      if (resource.phoneNumber == '100') return Colors.red;
      if (resource.phoneNumber == '1091') return Colors.pink;
      if (resource.phoneNumber == '102') return Colors.green;
      if (resource.phoneNumber == '101') return Colors.orange;
      return Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getColor().withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                resource.phoneNumber,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: getColor(),
                  fontFamily: 'Courier',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.description,
                    style: const TextStyle(fontSize: 11, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.call, color: getColor()),
              onPressed: () => _callNumber(resource.phoneNumber),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFraudTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚫 ONLINE FRAUD GUIDES',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your fraud type to get step-by-step reporting instructions and government portal links.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...IndiaEmergencies.fraudGuides.map((guide) {
            return _buildFraudCard(guide);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFraudCard(OnlineFraudGuide guide) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          guide.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(guide.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STEPS TO REPORT:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ...guide.steps.map((step) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 12, height: 1.4),
                      ),
                    )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () =>
                            _callNumber(guide.phoneNumber.replaceAll('-', '')),
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call 1930', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _openUrl(guide.reportingUrl),
                        icon: const Icon(Icons.language, size: 16),
                        label: const Text('Report Online', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Copy link',
                      onPressed: () => _copy(_normalizeUrl(guide.reportingUrl),
                          label: 'Link copied'),
                      icon: const Icon(Icons.copy, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 GOVERNMENT PORTALS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Official government websites for filing complaints and reporting crimes. Tap to open.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Most complaint forms ask "where did it happen" — let the user copy
          // their current location link to paste straight in.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyingLocation ? null : _copyMyLocation,
              icon: _copyingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Copy my live location'),
            ),
          ),
          const SizedBox(height: 16),
          ...IndiaEmergencies.governmentPortals.map((portal) {
            return _buildPortalCard(portal);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPortalCard(IndiaGovernmentPortal portal) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              portal.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              portal.description,
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'For: ${portal.caseType}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openUrl(portal.url),
                    icon: const Icon(Icons.open_in_browser, size: 16),
                    label: Text(
                      'Open Portal: ${portal.url.split('/')[2]}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      _copy(_normalizeUrl(portal.url), label: 'Link copied'),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
