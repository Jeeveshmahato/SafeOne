// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose your preferred language';

  @override
  String get fakeCallTitle => 'Fake call';

  @override
  String get fakeCallHeader =>
      'Create a fake incoming call to help you leave an unsafe situation. The call looks realistic and gives you a reason to step away.';

  @override
  String get chooseScenario => 'Choose a scenario';

  @override
  String get chooseCaller => 'Choose a caller';

  @override
  String get phoneNumberOptional => 'Phone number (optional)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'Shows on the fake call screen for realism';

  @override
  String get whatToSay => 'What to say (if they pick up)';

  @override
  String get whatToSayHint =>
      'e.g. I\'m on an important call, give me a moment.';

  @override
  String get whatToSayHelper =>
      'Quick message to say if caller picks up by accident';

  @override
  String get callDelay => 'Call delay';

  @override
  String get quickPresets => 'Quick presets';

  @override
  String get orCustomTime => 'Or enter a custom time';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String get seconds => 'Seconds';

  @override
  String get advancedOptions => 'Advanced options';

  @override
  String get repeatCall => 'Repeat call';

  @override
  String get repeatCallSubtitle => 'Call keeps \"ringing\" if you decline it';

  @override
  String get autoEndCall => 'Auto-end call';

  @override
  String get autoEndCallSubtitle => 'Call ends automatically after a set time';

  @override
  String get endAfter => 'End after:';

  @override
  String get ringSound => 'Ring sound';

  @override
  String get ringSoundPhone => 'Phone ringtone';

  @override
  String get ringSoundSiren => 'Police siren';

  @override
  String get startFakeCall => 'Start fake call';

  @override
  String get now => 'Now';

  @override
  String callInCountdown(int seconds) {
    return 'Call in $seconds';
  }

  @override
  String get keepScreenOpen =>
      'Keep this screen open. The fake call will appear when the timer ends. You can put the phone to your ear.';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get incomingCall => 'Incoming call…';

  @override
  String get callEnded => 'Call ended';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get close => 'Close';

  @override
  String get callWillRepeat => 'Call will repeat if declined';

  @override
  String autoEndsIn(int seconds) {
    return 'Auto-ends in ${seconds}s';
  }

  @override
  String get mute => 'Mute';

  @override
  String get speaker => 'Speaker';

  @override
  String get keypad => 'Keypad';

  @override
  String get endCall => 'End call';

  @override
  String secondsShort(int count) {
    return '$count sec';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String hoursShort(int count) {
    return '$count h';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get homeNoContacts => 'Add emergency contacts to get started.';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'Tap SOS to send your location to your contacts.';

  @override
  String get tileSiren => 'Siren';

  @override
  String get tileStopSiren => 'Stop siren';

  @override
  String get tilePoliceSiren => 'Police siren';

  @override
  String get tileStopPolice => 'Stop police';

  @override
  String get tileFlashlight => 'Flashlight';

  @override
  String get tileStopLight => 'Stop light';

  @override
  String get tileSosBlink => 'SOS blink';

  @override
  String get tileStopBlink => 'Stop blink';

  @override
  String get tileRecord => 'Record';

  @override
  String get tileStopRec => 'Stop rec';

  @override
  String get tileImSafe => 'I\'m safe';

  @override
  String get tileSafetyTimer => 'Safety timer';

  @override
  String get tileHelplines => 'Helplines';

  @override
  String get tileShareLocation => 'Share location';

  @override
  String get tileNearbyHelp => 'Nearby help';

  @override
  String get tileFakeCall => 'Fake call';

  @override
  String get tileFollowMe => 'Follow Me';

  @override
  String get tileSafetyTips => 'Safety tips';

  @override
  String get tileIncidentLog => 'Incident log';

  @override
  String get tileMedicalInfo => 'Medical info';

  @override
  String get tileContacts => 'Contacts';

  @override
  String get tileQuickContacts => 'Quick contacts';

  @override
  String get tileBuddyCheckin => 'Buddy check-in';

  @override
  String get tileSafetyLog => 'Safety log';

  @override
  String get tileEmergencyId => 'Emergency ID';

  @override
  String get tilePoliceSos => 'Police SOS';

  @override
  String get tileWhatToDo => 'What to do';

  @override
  String get tileIndiaHelp => 'India help';

  @override
  String get tileJourneySafe => 'Journey safe';

  @override
  String get tileQrCard => 'QR card';

  @override
  String get tileLocationPing => 'Location ping';

  @override
  String get tileDangerZones => 'Danger zones';

  @override
  String get sectionGetHelp => 'Get help';

  @override
  String get sectionShareTrack => 'Share & track';

  @override
  String get sectionMyInfo => 'My info';

  @override
  String get sectionLearn => 'Learn';

  @override
  String get tileLiveTracking => 'Live tracking';

  @override
  String get tileEmergencyProfile => 'Emergency profile';

  @override
  String get tileRecords => 'Records';

  @override
  String get tileSafetyCheckin => 'Check-in timer';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get homeSilentSosHint =>
      'Long-press SOS to send silently (no sound or buzz).';

  @override
  String silentSosSent(int count) {
    return 'Silent alert sent to $count contact(s).';
  }

  @override
  String get sosLiveBannerActive => 'Sharing your live location with contacts';

  @override
  String get sosLiveStop => 'Stop sharing';

  @override
  String get sosLiveStarted =>
      'Live location sharing started. Tap \"I\'m safe\" to stop.';

  @override
  String get sosLiveStopped => 'Live location sharing stopped.';

  @override
  String get lockTitle => 'Enter PIN';

  @override
  String get lockSubtitle => 'Enter your PIN to unlock';

  @override
  String get lockWrongPin => 'Wrong PIN. Try again.';

  @override
  String lockTooManyAttempts(int seconds) {
    return 'Too many attempts. Wait ${seconds}s.';
  }

  @override
  String get lockUseBiometric => 'Use fingerprint / face';

  @override
  String get lockBiometricReason => 'Unlock SafeOne';

  @override
  String get pinSetTitle => 'Set a PIN';

  @override
  String get pinSetSubtitle =>
      'This PIN protects your contacts, medical info and records.';

  @override
  String get pinCreateStep => 'Create a 6-digit PIN';

  @override
  String get pinConfirmStep => 'Re-enter your PIN to confirm';

  @override
  String get pinMismatch => 'PINs do not match. Start again.';

  @override
  String get pinTooShort => 'PIN must be 6 digits.';

  @override
  String get pinSaved => 'PIN saved.';

  @override
  String get pinChangeTitle => 'Change PIN';

  @override
  String get pinCurrentStep => 'Enter your current PIN';

  @override
  String get lockForgotPin => 'Forgot PIN?';

  @override
  String lockTryAgainIn(String time) {
    return 'Too many attempts. Try again in $time.';
  }

  @override
  String get pinSameAsApp =>
      'Choose a PIN that\'s different from your app PIN.';

  @override
  String get pinSameAsContacts =>
      'Choose a PIN that\'s different from your contacts PIN.';

  @override
  String get contactsPinEnterTitle => 'Enter contacts PIN';

  @override
  String get contactsPinEnterSubtitle =>
      'Your contacts PIN is needed to change your emergency contacts.';

  @override
  String get contactsPinSetTitle => 'Set a contacts PIN';

  @override
  String get contactsPinSetSubtitle =>
      'A second PIN, different from your app PIN. It\'s needed to add or remove emergency contacts, so no one can quietly change who gets your SOS.';

  @override
  String get contactsPinChangeTitle => 'Change contacts PIN';

  @override
  String get securityAppPin => 'App PIN';

  @override
  String get securityAppPinSubtitle =>
      'Change or reset the PIN that unlocks SafeOne';

  @override
  String get securityContactsPin => 'Contacts PIN';

  @override
  String get securityContactsPinOn =>
      'Needed to add or remove emergency contacts';

  @override
  String get securityContactsPinOff =>
      'Not set yet. You\'ll create it when you next add a contact.';

  @override
  String get pinResetTitle => 'Reset PIN';

  @override
  String get pinResetIntro =>
      'SafeOne can\'t recover a forgotten PIN, because it never leaves this phone. Prove this is your phone, then choose a new PIN.';

  @override
  String get pinResetWithDevice => 'Use your phone\'s screen lock';

  @override
  String get pinResetWithDeviceSubtitle =>
      'Your phone\'s PIN, pattern, password or fingerprint';

  @override
  String get pinResetDeviceReason =>
      'Confirm it\'s you to reset your SafeOne PIN';

  @override
  String get pinResetDeviceFailed => 'Couldn\'t confirm it\'s you. Try again.';

  @override
  String get pinResetNoDeviceLock =>
      'This phone has no screen lock, so it can\'t be used to prove it\'s yours.';

  @override
  String get pinResetWithAppPin => 'Use your app PIN';

  @override
  String get pinResetWithAppPinSubtitle => 'The PIN you use to unlock SafeOne';

  @override
  String get pinResetErase => 'Erase SafeOne and start over';

  @override
  String get pinResetEraseSubtitle => 'Deletes all SafeOne data on this phone';

  @override
  String get pinResetEraseConfirmTitle => 'Erase all SafeOne data?';

  @override
  String get pinResetEraseConfirmBody =>
      'This permanently deletes your emergency contacts, medical info, settings, saved recordings and photos, and both PINs. It can\'t be undone.';

  @override
  String get pinResetEraseConfirm => 'Erase everything';

  @override
  String get pinResetDone => 'PIN reset.';

  @override
  String get lockBiometricNeedsPin =>
      'Enter your PIN to open your encrypted data.';

  @override
  String get pinResetNeedsStrongAuth =>
      'Use your phone\'s PIN, pattern, password or fingerprint. Face unlock isn\'t secure enough to open your data.';

  @override
  String get pinResetRecoveryUnavailable =>
      'Your data is locked with your old PIN, and this phone\'s screen lock can\'t open it (it was added later or removed since). Use the old PIN, or erase SafeOne and start over.';

  @override
  String get securityProtection => 'Data protection';

  @override
  String get securityProtectionStrongBox =>
      'Encrypted. Keys are in this phone\'s dedicated security chip.';

  @override
  String get securityProtectionTee =>
      'Encrypted. Keys are in this phone\'s secure hardware.';

  @override
  String get securityProtectionSoftware =>
      'Encrypted, but this phone has no secure hardware for the keys.';

  @override
  String get securityRootedTitle => 'This phone appears to be rooted';

  @override
  String get securityRootedBody =>
      'Apps with root access can see what SafeOne shows while it\'s unlocked. Saved data stays encrypted while SafeOne is locked, so keep auto-lock set to Immediately.';

  @override
  String get securitySection => 'Security';

  @override
  String get securityChangePin => 'Change PIN';

  @override
  String get securityBiometric => 'Unlock with fingerprint / face';

  @override
  String get securityBiometricSubtitle =>
      'Use biometrics instead of typing the PIN.';

  @override
  String get securityAutoLock => 'Auto-lock';

  @override
  String get securityAutoLockImmediate => 'Immediately';

  @override
  String securityAutoLockGrace(int seconds) {
    return 'After ${seconds}s in background';
  }

  @override
  String get securitySilentSos => 'Silent SOS';

  @override
  String get securitySilentSosSubtitle =>
      'No vibration confirmation when sending SOS.';

  @override
  String get securityLiveUpdates => 'Repeat location after SOS';

  @override
  String get securityLiveUpdatesSubtitle =>
      'Keep sending your location to contacts until you tap \"I\'m safe\".';

  @override
  String get securityVolumeTrigger => 'Triple-press volume to send SOS';

  @override
  String get securityVolumeTriggerSubtitle =>
      'Press a volume button 3 times quickly to start the SOS.';

  @override
  String get checkinScheduleTitle => 'Auto-alert if I don\'t check in';

  @override
  String get checkinScheduleSubtitle =>
      'If you don\'t tap \"I\'m safe\" before the deadline, your contacts are alerted automatically.';

  @override
  String get checkinSetDeadline => 'Alert my contacts in';

  @override
  String checkinActive(String time) {
    return 'Active — alert at $time';
  }

  @override
  String get checkinStart => 'Start check-in';

  @override
  String get checkinImSafe => 'I\'m safe — cancel';

  @override
  String get checkinCancelled => 'Check-in cancelled.';

  @override
  String get checkinFired => 'You didn\'t check in. Alerting your contacts.';

  @override
  String get checkinReminderTitle => 'Safety check-in due';

  @override
  String get checkinReminderBody =>
      'Tap \"I\'m safe\" or your contacts will be alerted.';

  @override
  String get tabFollowMe => 'Follow me';

  @override
  String get tabJourney => 'Journey';

  @override
  String get tabBuddy => 'Buddy';

  @override
  String get tabPing => 'Ping';

  @override
  String get tabEmergencyId => 'Medical ID';

  @override
  String get tabMedical => 'Medical';

  @override
  String get tabQr => 'QR card';

  @override
  String get tabIncidents => 'Incidents';

  @override
  String get tabSafetyLog => 'Activity';

  @override
  String get tabHelplines => 'Helplines';

  @override
  String get tabIndia => 'India';

  @override
  String get tabPolice => 'Police';

  @override
  String get tabTips => 'Tips';

  @override
  String get tabWhatToDo => 'What to do';

  @override
  String get tabAllContacts => 'All';

  @override
  String get tabQuick => 'Quick';

  @override
  String homeContactsSaved(int count) {
    return '$count emergency contact(s) saved.';
  }

  @override
  String get homeTagline => 'Help is one tap away';

  @override
  String homeContactsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts will be alerted',
      one: '1 contact will be alerted',
    );
    return '$_temp0';
  }

  @override
  String get homeAddContactsTitle => 'Add your emergency contacts';

  @override
  String get homeAddContactsAction => 'Add contacts';

  @override
  String get sosButtonCaption => 'Tap to alert  ·  Hold for silent SOS';

  @override
  String get sosButtonSemantics =>
      'Send SOS alert. Long-press to send silently.';

  @override
  String get sosSending => 'Sending…';

  @override
  String get tileReportPortals => 'Report & portals';

  @override
  String get errorNoContacts =>
      'Please add at least one emergency contact first.';

  @override
  String get errorNoFlashlight => 'This phone has no flashlight.';

  @override
  String get errorMicDenied => 'Microphone permission denied.';

  @override
  String get recordingStarted => 'Recording started.';

  @override
  String get recordingSaved => 'Recording saved to this phone.';

  @override
  String get recordingStopped => 'Recording stopped.';

  @override
  String get sosCountdownTitle => 'Sending SOS';

  @override
  String get sosCountdownBody =>
      'Your location will be sent to your emergency contacts.';

  @override
  String get sosCountdownHint => 'Tap Cancel if this was a mistake.';

  @override
  String get sosSendNow => 'Send now';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionSos => 'SOS alert';

  @override
  String get settingsSectionTriggers => 'Hands-free SOS';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsCountdownTitle => 'SOS countdown';

  @override
  String get settingsCountdownSubtitle =>
      'How long you have to cancel before the SOS is sent.';

  @override
  String get settingsShakeTitle => 'Shake to send SOS';

  @override
  String get settingsShakeSubtitle =>
      'Shaking the phone starts the SOS countdown.';

  @override
  String get settingsPowerTitle => 'Power button SOS';

  @override
  String get settingsPowerSubtitle =>
      'Pressing the power button 3 times quickly starts the SOS.';

  @override
  String get settingsSafetyModeNote =>
      'Safety mode runs in the background so these triggers work even when your phone is locked. You\'ll see a \"Safety mode active\" notification while it\'s on.';

  @override
  String get settingsMessageTitle => 'SOS message';

  @override
  String settingsMessageSubtitle(String token) {
    return 'Sent to your contacts. Keep $token where the map link should appear.';
  }

  @override
  String get settingsMessageHint => 'Type your emergency message…';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsPrivacySubtitle => 'Your data never leaves this phone';

  @override
  String get settingsSupport => 'Contact support';

  @override
  String get settingsMadeBy => 'SafeOne by Tejovan Labs';

  @override
  String get homeAddContactsBody =>
      'When you press SOS, they get an SMS with your live location.';

  @override
  String get homeTools => 'Safety tools';

  @override
  String get fakeCallRingtone => 'Ringtone';

  @override
  String get fakeCallRingtoneDefault => 'Phone\'s default ringtone';

  @override
  String get fakeCallRingtoneChange => 'Change';

  @override
  String get fakeCallRingtoneHint =>
      'Pick any ringtone, or add your own sound.';

  @override
  String get homeReadyTitle => 'Get SOS ready';

  @override
  String get homeReadyIntro =>
      'Allow these now, so nothing slows you down in an emergency:';

  @override
  String get homeReadySms => '• Send your SOS automatically to every contact';

  @override
  String get homeReadyLocation => '• Include a map link to where you are';

  @override
  String get homeReadyAction => 'Allow';

  @override
  String get homeReadySettings => 'Open settings';

  @override
  String get settingsAutoSmsTitle => 'Send SOS automatically';

  @override
  String get settingsAutoSmsOn =>
      'On — each contact gets an SMS, no tap needed';

  @override
  String get settingsAutoSmsOff => 'Off — Messages opens and you tap Send';

  @override
  String get settingsAutoSmsAllow => 'Allow';

  @override
  String get homeReadyBgLocation =>
      '• Include your location even when the phone is locked';
}
