import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/call_scenario.dart';
import '../models/fake_call_preset.dart';
import '../models/scheduled_fake_call.dart';
import '../services/device_ringtone.dart';
import '../services/fake_caller_repository.dart';
import '../services/notification_service.dart';
import '../services/scheduled_call_repository.dart';
import '../services/settings_repository.dart';
import 'background_setup_screen.dart';
import 'fake_call_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/reveal.dart';

/// Enhanced fake call setup screen with preset callers, custom delays, and more.
///
/// Users can:
/// - Choose a preset caller (Mom, Dad, Boss, Friend, Emergency)
/// - Add custom phone number for realism
/// - Set delay in seconds, minutes, or hours using both presets and custom input
/// - Save favorite callers for quick access
/// - Enable repeat calls (keeps "ringing" if declined)
/// - Auto-end call after a set duration
class FakeCallSetupScreen extends StatefulWidget {
  const FakeCallSetupScreen({super.key});

  @override
  State<FakeCallSetupScreen> createState() => _FakeCallSetupScreenState();
}

class _FakeCallSetupScreenState extends State<FakeCallSetupScreen> {
  // Default preset callers available
  static const List<FakeCallPreset> defaultPresets = [
    FakeCallPreset(id: '1', name: 'Mom', phoneNumber: '+91 98765 43210'),
    FakeCallPreset(id: '2', name: 'Dad', phoneNumber: '+91 98765 11223'),
    FakeCallPreset(id: '3', name: 'Boss', phoneNumber: '+91 98765 55667'),
    FakeCallPreset(id: '4', name: 'Friend', phoneNumber: '+91 98765 99001'),
    FakeCallPreset(
      id: '5',
      name: 'Emergency',
      phoneNumber: '112',
    ),
  ];

  // Call scenarios for different situations
  static const List<CallScenario> callScenarios = [
    CallScenario(
      id: '1',
      name: 'Work Meeting',
      description: 'Important work call (sounds professional)',
      presetCallerName: 'Boss',
      suggestedMessage: 'I need to take this work call. Give me a moment.',
    ),
    CallScenario(
      id: '2',
      name: 'Family Check-in',
      description: 'Family member checking on you',
      presetCallerName: 'Mom',
      suggestedMessage: 'My mom is calling, I should take this.',
    ),
    CallScenario(
      id: '3',
      name: 'Friend Hangout',
      description: 'Friend asking to meet up',
      presetCallerName: 'Friend',
      suggestedMessage: 'My friend is calling. I\'ll let you know!',
    ),
    CallScenario(
      id: '4',
      name: 'Doctor Appointment',
      description: 'Medical clinic or doctor\'s office',
      presetCallerName: 'Dr. Smith',
      suggestedMessage: 'I have a call from my doctor. I need to take it.',
    ),
    CallScenario(
      id: '5',
      name: 'Delivery Notification',
      description: 'Package or delivery alert',
      presetCallerName: 'Delivery',
      suggestedMessage: 'I need to check on my delivery.',
    ),
  ];

  // Quick delay presets (in seconds)
  static const List<int> _delayPresets = [0, 5, 10, 30, 60, 300, 600, 1800, 3600];

  final FakeCallerRepository _callerRepo = FakeCallerRepository();
  List<FakeCallPreset> _customCallers = [];

  late FakeCallPreset _selectedPreset;
  CallScenario? _selectedScenario;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _customHoursController =
      TextEditingController();
  final TextEditingController _customMinutesController =
      TextEditingController();
  final TextEditingController _customSecondsController =
      TextEditingController();
  final TextEditingController _suggestionController = TextEditingController();

  int _selectedDelaySeconds = 0;
  bool _enableRepeat = false;
  bool _enableAutoEnd = false;
  int _autoEndSeconds = 60;
  RingSound _ringSound = RingSound.phoneRing;

  /// Lets the auto-end duration picker scroll into view when it appears.
  final GlobalKey _autoEndKey = GlobalKey();

  final ScheduledCallRepository _scheduleRepo = ScheduledCallRepository();
  final SettingsRepository _settings = SettingsRepository();

  /// The ringtone for "Phone ringtone" (content URI; null = phone default)
  /// and its display name.
  String? _ringtoneUri;
  String? _ringtoneTitle;
  List<ScheduledFakeCall> _scheduled = [];
  // When non-null, the user is editing this already-scheduled call; pressing
  // "Start" replaces it instead of creating a new one.
  int? _editingId;
  // Refreshes the live "rings in MM:SS" countdowns once a second while there
  // are upcoming calls on screen.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _selectedPreset = defaultPresets[0]; // Default to "Mom"
    _phoneController.text = _selectedPreset.phoneNumber;
    _selectedScenario = callScenarios[0]; // Default to "Work Meeting"
    _suggestionController.text = _selectedScenario!.suggestedMessage ?? '';
    _loadCustomCallers();
    _loadScheduled();
    _loadRingtone();
  }

  Future<void> _loadRingtone() async {
    final uri = await _settings.loadFakeCallRingtone();
    final title = await DeviceRingtone.title(uri);
    if (!mounted) return;
    setState(() {
      _ringtoneUri = uri;
      _ringtoneTitle = title;
    });
  }

  /// Opens the phone's ringtone picker and remembers the choice for future
  /// fake calls.
  Future<void> _pickRingtone() async {
    final picked = await DeviceRingtone.pick(current: _ringtoneUri);
    if (picked == null || !mounted) return;
    await _settings.saveFakeCallRingtone(picked.uri);
    if (!mounted) return;
    setState(() {
      _ringtoneUri = picked.uri;
      _ringtoneTitle = picked.title;
      _ringSound = RingSound.phoneRing;
    });
  }

  Future<void> _loadScheduled() async {
    final list = await _scheduleRepo.loadUpcoming();
    if (!mounted) return;
    setState(() => _scheduled = list);
    _syncTicker();
  }

  /// Run the 1-second countdown ticker only while upcoming calls are shown.
  void _syncTicker() {
    final shouldRun = _scheduled.isNotEmpty;
    if (shouldRun && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        // Drop any that have just fired, otherwise just refresh countdowns.
        if (_scheduled.any((c) => c.hasFired)) {
          _loadScheduled();
        } else {
          setState(() {});
        }
      });
    } else if (!shouldRun) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  Future<void> _loadCustomCallers() async {
    final callers = await _callerRepo.load();
    if (!mounted) return;
    setState(() => _customCallers = callers);
  }

  /// Add a new caller, or edit an existing custom one, via a small dialog.
  Future<void> _addOrEditCaller({FakeCallPreset? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController =
        TextEditingController(text: existing?.phoneNumber ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add caller' : 'Edit caller'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Mom, Boss, Priya',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: 'e.g. +91 98765 43210',
              ),
            ),
          ],
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    final phone = phoneController.text.trim();

    final updated = List<FakeCallPreset>.from(_customCallers);
    if (existing == null) {
      updated.add(FakeCallPreset(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phoneNumber: phone,
      ));
    } else {
      final i = updated.indexWhere((c) => c.id == existing.id);
      if (i != -1) {
        updated[i] = existing.copyWith(name: name, phoneNumber: phone);
      }
    }
    await _callerRepo.save(updated);
    if (!mounted) return;
    setState(() {
      _customCallers = updated;
      // Keep the just-saved caller selected for convenience.
      final toSelect = existing == null
          ? updated.last
          : updated.firstWhere((c) => c.id == existing.id,
              orElse: () => updated.last);
      _selectPreset(toSelect);
    });
  }

  Future<void> _deleteCaller(FakeCallPreset caller) async {
    final updated =
        _customCallers.where((c) => c.id != caller.id).toList();
    await _callerRepo.save(updated);
    if (!mounted) return;
    setState(() {
      _customCallers = updated;
      if (_selectedPreset.id == caller.id) {
        _selectPreset(defaultPresets[0]);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _phoneController.dispose();
    _customHoursController.dispose();
    _customMinutesController.dispose();
    _customSecondsController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  /// Update selected preset and sync phone number.
  void _selectPreset(FakeCallPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _phoneController.text = preset.phoneNumber;
    });
  }

  /// Select a call scenario and auto-fill suggestion.
  void _selectScenario(CallScenario scenario) {
    setState(() {
      _selectedScenario = scenario;
      _suggestionController.text = scenario.suggestedMessage ?? '';
      if (scenario.presetCallerName != null) {
        final matchingPreset = defaultPresets.firstWhere(
          (p) => p.name == scenario.presetCallerName,
          orElse: () => defaultPresets[0],
        );
        _selectPreset(matchingPreset);
      }
    });
  }

  /// Get total delay in seconds from custom input fields.
  int _getCustomDelaySeconds() {
    final hours = int.tryParse(_customHoursController.text) ?? 0;
    final minutes = int.tryParse(_customMinutesController.text) ?? 0;
    final seconds = int.tryParse(_customSecondsController.text) ?? 0;
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  /// Determine the actual delay to use (preset or custom).
  int _getActiveDelaySeconds() {
    final customSeconds = _getCustomDelaySeconds();
    if (customSeconds > 0) {
      return customSeconds;
    }
    return _selectedDelaySeconds;
  }

  /// Schedule the fake call. A "Now" call rings immediately; a delayed call is
  /// handed to the OS so it rings even if the app is closed or the phone is
  /// locked, and is added to the "Upcoming calls" list.
  Future<void> _schedule() async {
    final delaySeconds = _getActiveDelaySeconds();
    final name = _selectedPreset.name;
    final phone = _phoneController.text.trim();

    if (delaySeconds == 0) {
      // If we were editing a scheduled call, "Now" means: drop the schedule
      // and ring immediately.
      if (_editingId != null) await _removeScheduled(_editingId!);
      _ring(name, phone);
      return;
    }

    // Permission prompts can open system pages and take a while, so ask
    // BEFORE working out the ring time. (Computing it first meant a short
    // delay like "5 sec" was already in the past by the time the user tapped
    // Allow, and the call silently never got scheduled.)
    await NotificationService.instance.ensureCanRingWhenClosed();
    if (!mounted) return;
    final when = DateTime.now().add(Duration(seconds: delaySeconds));

    // If editing, reuse the same id so the entry is replaced (and its old
    // alarm cancelled) rather than duplicated.
    final id = _editingId ?? await _scheduleRepo.nextId();
    if (_editingId != null) {
      await NotificationService.instance.cancelFakeCall(id);
    }

    final call = ScheduledFakeCall(
      id: id,
      callerName: name,
      callerPhone: phone,
      scheduledAt: when,
      ringIndex: _ringSound.index,
      shouldRepeat: _enableRepeat,
      autoEndSeconds: _enableAutoEnd ? _autoEndSeconds : null,
      ringtoneUri: _ringtoneUri,
    );

    // Goes straight to AlarmManager via zonedSchedule, so the OS delivers the
    // full-screen call notification natively even if the app is force-stopped —
    // no background Dart isolate has to start.
    try {
      await NotificationService.instance.scheduleFakeCall(
        id: call.id,
        when: call.scheduledAt,
        callerName: call.callerName,
        callerPhone: call.callerPhone,
        ringIndex: call.ringIndex,
        shouldRepeat: call.shouldRepeat,
        autoEndSeconds: call.autoEndSeconds,
        ringtoneUri: call.ringtoneUri,
      );
    } catch (_) {
      if (!mounted) return;
      showAppSnack(context, "Couldn't schedule the call. Please try again.",
          tone: Tone.danger);
      return;
    }
    await _scheduleRepo.update(call);

    if (!mounted) return;
    final wasEditing = _editingId != null;
    setState(() => _editingId = null);
    await _loadScheduled();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasEditing
            ? 'Call to ${call.callerName} updated'
            : 'Call from ${call.callerName} scheduled'),
      ),
    );
  }

  /// Navigate to the fake call screen (immediate "Now" call).
  Future<void> _ring(String name, String phone) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FakeCallScreen(
          callerName: name,
          callerPhone: phone,
          shouldRepeat: _enableRepeat,
          autoEndSeconds: _enableAutoEnd ? _autoEndSeconds : null,
          ringSound: _ringSound,
          ringtoneUri: _ringtoneUri,
        ),
      ),
    );
  }

  /// Cancel a specific upcoming call: drop its OS alarm + remove from the list.
  Future<void> _removeScheduled(int id) async {
    await NotificationService.instance.cancelFakeCall(id);
    await _scheduleRepo.remove(id);
    if (_editingId == id) _editingId = null;
    await _loadScheduled();
  }

  Future<void> _cancelScheduled(ScheduledFakeCall call) async {
    await _removeScheduled(call.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Call from ${call.callerName} cancelled')),
    );
  }

  /// Load an upcoming call's settings back into the form for editing. Pressing
  /// "Start" will then replace it (see [_schedule]).
  void _editScheduled(ScheduledFakeCall call) {
    final remaining = call.scheduledAt.difference(DateTime.now());
    final secs = remaining.inSeconds < 0 ? 0 : remaining.inSeconds;
    setState(() {
      _editingId = call.id;
      _selectedPreset = FakeCallPreset(
        id: 'edit',
        name: call.callerName,
        phoneNumber: call.callerPhone,
      );
      _phoneController.text = call.callerPhone;
      _ringSound = RingSound.values[call.ringIndex];
      if (call.ringtoneUri != null) _ringtoneUri = call.ringtoneUri;
      _enableRepeat = call.shouldRepeat;
      _enableAutoEnd = call.autoEndSeconds != null;
      if (call.autoEndSeconds != null) _autoEndSeconds = call.autoEndSeconds!;
      // Pre-fill the delay using H/M/S so the remaining time is editable.
      _selectedDelaySeconds = 0;
      _customHoursController.text =
          secs >= 3600 ? '${secs ~/ 3600}' : '';
      _customMinutesController.text =
          (secs % 3600) ~/ 60 > 0 ? '${(secs % 3600) ~/ 60}' : '';
      _customSecondsController.text =
          secs % 60 > 0 ? '${secs % 60}' : '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing call from ${call.callerName} — '
            'adjust and tap Start to save'),
      ),
    );
  }

  /// Format delay in human-readable, localized format.
  /// MM:SS (or H:MM:SS) for the live countdown.
  String _formatClock(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  String _formatDelay(int seconds, AppLocalizations t) {
    if (seconds == 0) return t.now;
    if (seconds < 60) return t.secondsShort(seconds);
    if (seconds < 3600) {
      final mins = seconds ~/ 60;
      return t.minutesShort(mins);
    }
    final hours = seconds ~/ 3600;
    final remainingMins = (seconds % 3600) ~/ 60;
    if (remainingMins == 0) return t.hoursShort(hours);
    return t.hoursMinutesShort(hours, remainingMins);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.fakeCallTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Set up background calls',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const BackgroundSetupScreen(),
              ),
            ),
          ),
        ],
      ),
      body: _buildSetup(),
    );
  }

  /// Setup UI: choose caller, delay, options.
  Widget _buildSetup() {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header text
          NoticeCard(
            tone: Tone.info,
            icon: Icons.phone_in_talk_outlined,
            message: t.fakeCallHeader,
          ),
          const SizedBox(height: 24),

          // Upcoming scheduled calls (editable / cancelable).
          _buildUpcomingSection(),

          // Call scenarios
          _buildScenarioSection(),
          const SizedBox(height: 20),

          // Preset callers
          _buildPresetSection(),
          const SizedBox(height: 20),

          // Phone number input
          _buildPhoneSection(),
          const SizedBox(height: 20),

          // Suggestion message
          _buildSuggestionSection(),
          const SizedBox(height: 20),

          // Delay options
          _buildDelaySection(),
          const SizedBox(height: 20),

          // Ring sound
          _buildRingSoundSection(),
          const SizedBox(height: 20),

          // Advanced options
          _buildAdvancedOptions(),
          const SizedBox(height: 32),

          // Start button
          FilledButton.icon(
            onPressed: _schedule,
            icon: Icon(_editingId != null
                ? Icons.save
                : Icons.phone_in_talk),
            label: Text(
              _editingId != null ? 'Save changes' : t.startFakeCall,
            ),
          ),
          if (_editingId != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _editingId = null),
              child: const Text('Cancel editing'),
            ),
          ],
        ],
      ),
    );
  }

  /// Lists every upcoming scheduled call with a live countdown plus edit and
  /// cancel actions. Hidden when there are none.
  Widget _buildUpcomingSection() {
    if (_scheduled.isEmpty) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming calls',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final call in _scheduled) _upcomingTile(call, t),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _upcomingTile(ScheduledFakeCall call, AppLocalizations t) {
    final remaining = call.scheduledAt.difference(DateTime.now());
    final secs = remaining.inSeconds < 0 ? 0 : remaining.inSeconds;
    final isEditing = _editingId == call.id;
    return Card(
      color: isEditing ? Theme.of(context).colorScheme.secondaryContainer : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.phone_in_talk)),
        title: Text(call.callerName),
        subtitle: Text(
          'Rings in ${_formatClock(secs)}'
          '${call.callerPhone.isNotEmpty ? ' · ${call.callerPhone}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modify',
              onPressed: () => _editScheduled(call),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Cancel call',
              onPressed: () => _cancelScheduled(call),
            ),
          ],
        ),
      ),
    );
  }

  /// Section for choosing what plays while the call rings.
  Widget _buildRingSoundSection() {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.ringSound, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.ring_volume_outlined, size: 18),
              label: Text(t.ringSoundPhone),
              selected: _ringSound == RingSound.phoneRing,
              onSelected: (_) =>
                  setState(() => _ringSound = RingSound.phoneRing),
            ),
            ChoiceChip(
              avatar: const Icon(Icons.local_police_outlined, size: 18),
              label: Text(t.ringSoundSiren),
              selected: _ringSound == RingSound.policeSiren,
              onSelected: (_) =>
                  setState(() => _ringSound = RingSound.policeSiren),
            ),
          ],
        ),
        // Which ringtone plays — the phone's own by default; "Change" opens
        // the system picker, which also offers "Add ringtone" for a custom
        // sound file.
        if (_ringSound == RingSound.phoneRing) ...[
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              leading: const Icon(Icons.music_note_outlined),
              title: Text(t.fakeCallRingtone),
              subtitle: Text(
                _ringtoneTitle ??
                    (_ringtoneUri == null ? t.fakeCallRingtoneDefault : '…'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: TextButton(
                onPressed: _pickRingtone,
                child: Text(t.fakeCallRingtoneChange),
              ),
              onTap: _pickRingtone,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: Text(t.fakeCallRingtoneHint,
                style: theme.textTheme.bodySmall),
          ),
        ],
      ],
    );
  }


  /// Section for selecting a call scenario.
  Widget _buildScenarioSection() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.chooseScenario,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: callScenarios.map((scenario) {
              final isSelected = scenario.id == _selectedScenario?.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(scenario.name),
                  selected: isSelected,
                  onSelected: (_) => _selectScenario(scenario),
                  showCheckmark: isSelected,
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedScenario != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedScenario!.description,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }

  /// Section for selecting a preset caller.
  Widget _buildPresetSection() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.chooseCaller,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to pick. Long-press your own callers to edit or delete.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in [...defaultPresets, ..._customCallers])
              _callerChip(preset),
            // "Add caller" chip.
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              onPressed: () => _addOrEditCaller(),
            ),
          ],
        ),
      ],
    );
  }

  /// One caller chip. Custom callers (id starts with "c") can be long-pressed
  /// to edit or delete; default callers are select-only.
  Widget _callerChip(FakeCallPreset preset) {
    final isSelected = preset.id == _selectedPreset.id;
    final isCustom = preset.id.startsWith('c');
    final chip = FilterChip(
      label: Text(preset.name),
      selected: isSelected,
      onSelected: (_) => _selectPreset(preset),
      showCheckmark: isSelected,
    );
    if (!isCustom) return chip;
    return GestureDetector(
      onLongPress: () => _showCallerOptions(preset),
      child: chip,
    );
  }

  void _showCallerOptions(FakeCallPreset preset) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('Edit "${preset.name}"'),
              onTap: () {
                Navigator.pop(ctx);
                _addOrEditCaller(existing: preset);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteCaller(preset);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Section for custom phone number.
  Widget _buildPhoneSection() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.phoneNumberOptional,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: t.phoneHint,
            prefixIcon: const Icon(Icons.phone),
            helperText: t.phoneHelper,
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  /// Section for suggestion message.
  Widget _buildSuggestionSection() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.whatToSay,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _suggestionController,
          maxLines: 3,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: t.whatToSayHint,
            prefixIcon: const Icon(Icons.chat),
            helperText: t.whatToSayHelper,
          ),
        ),
      ],
    );
  }

  /// Section for setting the call delay.
  Widget _buildDelaySection() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.callDelay,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Quick preset buttons
        Text(
          t.quickPresets,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _delayPresets.map((seconds) {
            final isSelected = seconds == _selectedDelaySeconds;
            return ChoiceChip(
              label: Text(_formatDelay(seconds, t)),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedDelaySeconds = seconds;
                  _customMinutesController.clear();
                  _customSecondsController.clear();
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Custom delay input
        Text(
          t.orCustomTime,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Hours input
            Expanded(
              child: TextField(
                controller: _customHoursController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: t.hours,
                  hintText: '0',
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Minutes input
            Expanded(
              child: TextField(
                controller: _customMinutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: t.minutes,
                  hintText: '0',
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Seconds input
            Expanded(
              child: TextField(
                controller: _customSecondsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: t.seconds,
                  hintText: '0',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section for advanced safety options.
  Widget _buildAdvancedOptions() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.advancedOptions,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Repeat calls checkbox
        CheckboxListTile(
          title: Text(t.repeatCall),
          subtitle: Text(t.repeatCallSubtitle),
          value: _enableRepeat,
          onChanged: (value) => setState(() => _enableRepeat = value ?? false),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),

        // Auto-end call checkbox
        CheckboxListTile(
          title: Text(t.autoEndCall),
          subtitle: Text(t.autoEndCallSubtitle),
          value: _enableAutoEnd,
          onChanged: (value) {
            setState(() => _enableAutoEnd = value ?? false);
            // The duration picker appears below; bring it into view.
            if (_enableAutoEnd) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final ctx = _autoEndKey.currentContext;
                if (ctx != null) revealInScrollable(ctx);
              });
            }
          },
          contentPadding: EdgeInsets.zero,
        ),

        // Auto-end duration selector (shown if enabled)
        if (_enableAutoEnd) ...[
          const SizedBox(height: 12),
          Padding(
            key: _autoEndKey,
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Text('${t.endAfter} '),
                const SizedBox(width: 12),
                DropdownMenu<int>(
                  initialSelection: _autoEndSeconds,
                  onSelected: (value) {
                    if (value != null) {
                      setState(() => _autoEndSeconds = value);
                    }
                  },
                  dropdownMenuEntries: [30, 60, 120, 300, 600]
                      .map((sec) => DropdownMenuEntry(
                            value: sec,
                            label: sec < 60
                                ? t.secondsShort(sec)
                                : t.minutesShort(sec ~/ 60),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

}
