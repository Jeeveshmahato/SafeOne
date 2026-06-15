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
  String get fakeCallTitle => 'Fake Call';

  @override
  String get fakeCallHeader =>
      'Create a fake incoming call to help you leave an unsafe situation. The call looks realistic and gives you a reason to step away.';

  @override
  String get chooseScenario => 'Choose a Scenario';

  @override
  String get chooseCaller => 'Choose a Caller';

  @override
  String get phoneNumberOptional => 'Phone Number (Optional)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'Shows on the fake call screen for realism';

  @override
  String get whatToSay => 'What to Say (If They Pick Up)';

  @override
  String get whatToSayHint =>
      'e.g. I\'m on an important call, give me a moment.';

  @override
  String get whatToSayHelper =>
      'Quick message to say if caller picks up by accident';

  @override
  String get callDelay => 'Call Delay';

  @override
  String get quickPresets => 'Quick Presets';

  @override
  String get orCustomTime => 'Or Enter Custom Time';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String get seconds => 'Seconds';

  @override
  String get advancedOptions => 'Advanced Options';

  @override
  String get repeatCall => 'Repeat Call';

  @override
  String get repeatCallSubtitle => 'Call keeps \"ringing\" if you decline it';

  @override
  String get autoEndCall => 'Auto-End Call';

  @override
  String get autoEndCallSubtitle => 'Call ends automatically after a set time';

  @override
  String get endAfter => 'End after:';

  @override
  String get ringSound => 'Ring Sound';

  @override
  String get ringSoundPhone => 'Phone ring';

  @override
  String get ringSoundSiren => 'Police siren';

  @override
  String get startFakeCall => 'Start Fake Call';

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
  String get callEnded => 'Call Ended';

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
  String get endCall => 'End Call';

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
  String get tileWhatToDo => 'What To Do';

  @override
  String get tileIndiaHelp => 'India Help';

  @override
  String get tileJourneySafe => 'Journey Safe';

  @override
  String get tileQrCard => 'QR Card';

  @override
  String get tileLocationPing => 'Location Ping';

  @override
  String get tileDangerZones => 'Danger Zones';

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
  String get tileSafetyCheckin => 'Safety check-in';

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
  String get lockBiometricReason => 'Unlock Women Safety';

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
  String get tabEmergencyId => 'ID';

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
}
