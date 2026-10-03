// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get language => 'ਭਾਸ਼ਾ';

  @override
  String get languageSubtitle => 'ਆਪਣੀ ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ ਚੁਣੋ';

  @override
  String get fakeCallTitle => 'ਨਕਲੀ ਕਾਲ';

  @override
  String get fakeCallHeader =>
      'ਅਸੁਰੱਖਿਅਤ ਸਥਿਤੀ ਤੋਂ ਬਾਹਰ ਨਿਕਲਣ ਵਿੱਚ ਮਦਦ ਲਈ ਇੱਕ ਨਕਲੀ ਆਉਣ ਵਾਲੀ ਕਾਲ ਬਣਾਓ। ਇਹ ਕਾਲ ਅਸਲੀ ਲੱਗਦੀ ਹੈ ਅਤੇ ਉੱਥੋਂ ਹਟਣ ਦਾ ਬਹਾਨਾ ਦਿੰਦੀ ਹੈ।';

  @override
  String get chooseScenario => 'ਸਥਿਤੀ ਚੁਣੋ';

  @override
  String get chooseCaller => 'ਕਾਲ ਕਰਨ ਵਾਲਾ ਚੁਣੋ';

  @override
  String get phoneNumberOptional => 'ਫ਼ੋਨ ਨੰਬਰ (ਚੋਣਵਾਂ)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'ਅਸਲੀਅਤ ਲਈ ਨਕਲੀ ਕਾਲ ਸਕਰੀਨ \'ਤੇ ਦਿਖਾਇਆ ਜਾਂਦਾ ਹੈ';

  @override
  String get whatToSay => 'ਕੀ ਕਹਿਣਾ ਹੈ (ਜੇ ਉਹ ਚੁੱਕ ਲੈਣ)';

  @override
  String get whatToSayHint =>
      'ਜਿਵੇਂ ਮੈਂ ਇੱਕ ਜ਼ਰੂਰੀ ਕਾਲ \'ਤੇ ਹਾਂ, ਥੋੜ੍ਹਾ ਸਮਾਂ ਦਿਓ।';

  @override
  String get whatToSayHelper =>
      'ਗਲਤੀ ਨਾਲ ਕਾਲ ਚੁੱਕੀ ਜਾਵੇ ਤਾਂ ਕਹਿਣ ਲਈ ਛੋਟਾ ਸੁਨੇਹਾ';

  @override
  String get callDelay => 'ਕਾਲ ਦੇਰੀ';

  @override
  String get quickPresets => 'ਤੇਜ਼ ਪ੍ਰੀਸੈੱਟ';

  @override
  String get orCustomTime => 'ਜਾਂ ਕਸਟਮ ਸਮਾਂ ਦਰਜ ਕਰੋ';

  @override
  String get hours => 'ਘੰਟੇ';

  @override
  String get minutes => 'ਮਿੰਟ';

  @override
  String get seconds => 'ਸਕਿੰਟ';

  @override
  String get advancedOptions => 'ਉੱਨਤ ਵਿਕਲਪ';

  @override
  String get repeatCall => 'ਕਾਲ ਦੁਹਰਾਓ';

  @override
  String get repeatCallSubtitle =>
      'ਜੇ ਤੁਸੀਂ ਅਸਵੀਕਾਰ ਕਰਦੇ ਹੋ ਤਾਂ ਕਾਲ ਵੱਜਦੀ ਰਹਿੰਦੀ ਹੈ';

  @override
  String get autoEndCall => 'ਆਪਣੇ ਆਪ ਕਾਲ ਖ਼ਤਮ ਕਰੋ';

  @override
  String get autoEndCallSubtitle =>
      'ਤੈਅ ਸਮੇਂ ਬਾਅਦ ਕਾਲ ਆਪਣੇ ਆਪ ਖ਼ਤਮ ਹੋ ਜਾਂਦੀ ਹੈ';

  @override
  String get endAfter => 'ਇਸ ਤੋਂ ਬਾਅਦ ਖ਼ਤਮ ਕਰੋ:';

  @override
  String get ringSound => 'ਰਿੰਗ ਆਵਾਜ਼';

  @override
  String get ringSoundPhone => 'ਫ਼ੋਨ ਰਿੰਗ';

  @override
  String get ringSoundSiren => 'ਪੁਲਿਸ ਸਾਇਰਨ';

  @override
  String get startFakeCall => 'ਨਕਲੀ ਕਾਲ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get now => 'ਹੁਣ';

  @override
  String callInCountdown(int seconds) {
    return '$seconds ਵਿੱਚ ਕਾਲ';
  }

  @override
  String get keepScreenOpen =>
      'ਇਸ ਸਕਰੀਨ ਨੂੰ ਖੁੱਲ੍ਹਾ ਰੱਖੋ। ਟਾਈਮਰ ਖ਼ਤਮ ਹੋਣ \'ਤੇ ਨਕਲੀ ਕਾਲ ਦਿਖਾਈ ਦੇਵੇਗੀ। ਤੁਸੀਂ ਫ਼ੋਨ ਨੂੰ ਕੰਨ ਕੋਲ ਰੱਖ ਸਕਦੇ ਹੋ।';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get incomingCall => 'ਆਉਣ ਵਾਲੀ ਕਾਲ…';

  @override
  String get callEnded => 'ਕਾਲ ਖ਼ਤਮ';

  @override
  String get decline => 'ਅਸਵੀਕਾਰ ਕਰੋ';

  @override
  String get accept => 'ਸਵੀਕਾਰ ਕਰੋ';

  @override
  String get close => 'ਬੰਦ ਕਰੋ';

  @override
  String get callWillRepeat => 'ਅਸਵੀਕਾਰ ਕਰਨ \'ਤੇ ਕਾਲ ਦੁਹਰਾਈ ਜਾਵੇਗੀ';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds ਸਕਿੰਟਾਂ ਵਿੱਚ ਆਪਣੇ ਆਪ ਖ਼ਤਮ';
  }

  @override
  String get mute => 'ਮਿਊਟ';

  @override
  String get speaker => 'ਸਪੀਕਰ';

  @override
  String get keypad => 'ਕੀਪੈਡ';

  @override
  String get endCall => 'ਕਾਲ ਖ਼ਤਮ ਕਰੋ';

  @override
  String secondsShort(int count) {
    return '$count ਸਕਿੰਟ';
  }

  @override
  String minutesShort(int count) {
    return '$count ਮਿੰਟ';
  }

  @override
  String hoursShort(int count) {
    return '$count ਘੰਟੇ';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursਘੰ $minutesਮਿ';
  }

  @override
  String get homeNoContacts => 'ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਐਮਰਜੈਂਸੀ ਸੰਪਰਕ ਸ਼ਾਮਲ ਕਰੋ।';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'ਆਪਣਾ ਟਿਕਾਣਾ ਭੇਜਣ ਲਈ SOS ਦਬਾਓ।';

  @override
  String get tileSiren => 'ਸਾਇਰਨ';

  @override
  String get tileStopSiren => 'ਸਾਇਰਨ ਬੰਦ';

  @override
  String get tilePoliceSiren => 'ਪੁਲਿਸ ਸਾਇਰਨ';

  @override
  String get tileStopPolice => 'ਪੁਲਿਸ ਬੰਦ';

  @override
  String get tileFlashlight => 'ਟੌਰਚ';

  @override
  String get tileStopLight => 'ਲਾਈਟ ਬੰਦ';

  @override
  String get tileSosBlink => 'SOS ਬਲਿੰਕ';

  @override
  String get tileStopBlink => 'ਬਲਿੰਕ ਬੰਦ';

  @override
  String get tileRecord => 'ਰਿਕਾਰਡ';

  @override
  String get tileStopRec => 'ਰਿਕਾਰਡ ਬੰਦ';

  @override
  String get tileImSafe => 'ਮੈਂ ਸੁਰੱਖਿਅਤ ਹਾਂ';

  @override
  String get tileSafetyTimer => 'ਸੁਰੱਖਿਆ ਟਾਈਮਰ';

  @override
  String get tileHelplines => 'ਹੈਲਪਲਾਈਨ';

  @override
  String get tileShareLocation => 'ਟਿਕਾਣਾ ਸਾਂਝਾ';

  @override
  String get tileNearbyHelp => 'ਨੇੜਲੀ ਮਦਦ';

  @override
  String get tileFakeCall => 'ਨਕਲੀ ਕਾਲ';

  @override
  String get tileFollowMe => 'ਮੈਨੂੰ ਫਾਲੋ ਕਰੋ';

  @override
  String get tileSafetyTips => 'ਸੁਰੱਖਿਆ ਸੁਝਾਅ';

  @override
  String get tileIncidentLog => 'ਘਟਨਾ ਲੌਗ';

  @override
  String get tileMedicalInfo => 'ਮੈਡੀਕਲ ਜਾਣਕਾਰੀ';

  @override
  String get tileContacts => 'ਸੰਪਰਕ';

  @override
  String get tileQuickContacts => 'ਤੇਜ਼ ਸੰਪਰਕ';

  @override
  String get tileBuddyCheckin => 'ਬੱਡੀ ਚੈੱਕ-ਇਨ';

  @override
  String get tileSafetyLog => 'ਸੁਰੱਖਿਆ ਲੌਗ';

  @override
  String get tileEmergencyId => 'ਐਮਰਜੈਂਸੀ ID';

  @override
  String get tilePoliceSos => 'ਪੁਲਿਸ SOS';

  @override
  String get tileWhatToDo => 'ਕੀ ਕਰਨਾ ਹੈ';

  @override
  String get tileIndiaHelp => 'ਭਾਰਤ ਮਦਦ';

  @override
  String get tileJourneySafe => 'ਸੁਰੱਖਿਅਤ ਸਫ਼ਰ';

  @override
  String get tileQrCard => 'QR ਕਾਰਡ';

  @override
  String get tileLocationPing => 'ਟਿਕਾਣਾ ਪਿੰਗ';

  @override
  String get tileDangerZones => 'ਖ਼ਤਰੇ ਵਾਲੇ ਖੇਤਰ';

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
    return '$count ਐਮਰਜੈਂਸੀ ਸੰਪਰਕ ਸੰਭਾਲੇ ਗਏ।';
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
  String get homeLocationTitle => 'Allow location access';

  @override
  String get homeLocationBody =>
      'So your SOS includes a map link to where you are. Do it now, not during an emergency.';

  @override
  String get homeLocationAction => 'Allow location';

  @override
  String get homeLocationSettings => 'Open settings';

  @override
  String get homeTools => 'Safety tools';
}
