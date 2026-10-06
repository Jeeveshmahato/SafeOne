// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get language => 'மொழி';

  @override
  String get languageSubtitle =>
      'உங்களுக்கு விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get fakeCallTitle => 'போலி அழைப்பு';

  @override
  String get fakeCallHeader =>
      'பாதுகாப்பற்ற சூழ்நிலையிலிருந்து வெளியேற உதவ ஒரு போலி உள்வரும் அழைப்பை உருவாக்கவும். இந்த அழைப்பு உண்மையானதாகத் தோன்றும், விலகிச் செல்ல ஒரு காரணத்தைத் தரும்.';

  @override
  String get chooseScenario => 'சூழ்நிலையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chooseCaller => 'அழைப்பாளரைத் தேர்ந்தெடுக்கவும்';

  @override
  String get phoneNumberOptional => 'தொலைபேசி எண் (விருப்பத்திற்குரியது)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper =>
      'உண்மைத்தன்மைக்காக போலி அழைப்பு திரையில் காட்டப்படும்';

  @override
  String get whatToSay => 'என்ன சொல்வது (அவர்கள் எடுத்தால்)';

  @override
  String get whatToSayHint =>
      'எ.கா. நான் ஒரு முக்கியமான அழைப்பில் இருக்கிறேன், சற்று நேரம் கொடுங்கள்.';

  @override
  String get whatToSayHelper =>
      'தவறுதலாக அழைப்பு எடுக்கப்பட்டால் சொல்ல ஒரு குறுஞ்செய்தி';

  @override
  String get callDelay => 'அழைப்பு தாமதம்';

  @override
  String get quickPresets => 'விரைவு முன்னமைப்புகள்';

  @override
  String get orCustomTime => 'அல்லது தனிப்பயன் நேரத்தை உள்ளிடவும்';

  @override
  String get hours => 'மணிநேரம்';

  @override
  String get minutes => 'நிமிடங்கள்';

  @override
  String get seconds => 'வினாடிகள்';

  @override
  String get advancedOptions => 'மேம்பட்ட விருப்பங்கள்';

  @override
  String get repeatCall => 'மீண்டும் அழை';

  @override
  String get repeatCallSubtitle =>
      'நீங்கள் நிராகரித்தால் அழைப்பு தொடர்ந்து ஒலிக்கும்';

  @override
  String get autoEndCall => 'தானாக அழைப்பை முடி';

  @override
  String get autoEndCallSubtitle =>
      'குறிப்பிட்ட நேரத்திற்குப் பிறகு அழைப்பு தானாக முடிகிறது';

  @override
  String get endAfter => 'இதற்குப் பிறகு முடி:';

  @override
  String get ringSound => 'ஒலி அழைப்பு';

  @override
  String get ringSoundPhone => 'தொலைபேசி ஒலி';

  @override
  String get ringSoundSiren => 'காவல்துறை சைரன்';

  @override
  String get startFakeCall => 'போலி அழைப்பைத் தொடங்கு';

  @override
  String get now => 'இப்போது';

  @override
  String callInCountdown(int seconds) {
    return '$seconds இல் அழைப்பு';
  }

  @override
  String get keepScreenOpen =>
      'இந்தத் திரையைத் திறந்த நிலையில் வைக்கவும். டைமர் முடிந்ததும் போலி அழைப்பு தோன்றும். தொலைபேசியை காதருகே வைக்கலாம்.';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'ரத்து';

  @override
  String get incomingCall => 'உள்வரும் அழைப்பு…';

  @override
  String get callEnded => 'அழைப்பு முடிந்தது';

  @override
  String get decline => 'நிராகரி';

  @override
  String get accept => 'ஏற்க';

  @override
  String get close => 'மூடு';

  @override
  String get callWillRepeat => 'நிராகரித்தால் அழைப்பு மீண்டும் வரும்';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds வினாடிகளில் தானாக முடிகிறது';
  }

  @override
  String get mute => 'முடக்கு';

  @override
  String get speaker => 'ஸ்பீக்கர்';

  @override
  String get keypad => 'கீபேட்';

  @override
  String get endCall => 'அழைப்பை முடி';

  @override
  String secondsShort(int count) {
    return '$count வி';
  }

  @override
  String minutesShort(int count) {
    return '$count நி';
  }

  @override
  String hoursShort(int count) {
    return '$count ம';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursம $minutesநி';
  }

  @override
  String get homeNoContacts => 'தொடங்க அவசர தொடர்புகளைச் சேர்க்கவும்.';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'உங்கள் இருப்பிடத்தை அனுப்ப SOS ஐ அழுத்தவும்.';

  @override
  String get tileSiren => 'சைரன்';

  @override
  String get tileStopSiren => 'சைரனை நிறுத்து';

  @override
  String get tilePoliceSiren => 'காவல் சைரன்';

  @override
  String get tileStopPolice => 'காவலை நிறுத்து';

  @override
  String get tileFlashlight => 'டார்ச்';

  @override
  String get tileStopLight => 'விளக்கை நிறுத்து';

  @override
  String get tileSosBlink => 'SOS ஒளி';

  @override
  String get tileStopBlink => 'ஒளியை நிறுத்து';

  @override
  String get tileRecord => 'பதிவு';

  @override
  String get tileStopRec => 'பதிவை நிறுத்து';

  @override
  String get tileImSafe => 'நான் பாதுகாப்பாக';

  @override
  String get tileSafetyTimer => 'பாதுகாப்பு டைமர்';

  @override
  String get tileHelplines => 'உதவி எண்கள்';

  @override
  String get tileShareLocation => 'இருப்பிடம் பகிர்';

  @override
  String get tileNearbyHelp => 'அருகில் உதவி';

  @override
  String get tileFakeCall => 'போலி அழைப்பு';

  @override
  String get tileFollowMe => 'என்னைப் பின்தொடர்';

  @override
  String get tileSafetyTips => 'பாதுகாப்பு குறிப்புகள்';

  @override
  String get tileIncidentLog => 'சம்பவப் பதிவு';

  @override
  String get tileMedicalInfo => 'மருத்துவ தகவல்';

  @override
  String get tileContacts => 'தொடர்புகள்';

  @override
  String get tileQuickContacts => 'விரைவு தொடர்புகள்';

  @override
  String get tileBuddyCheckin => 'நண்பர் செக்-இன்';

  @override
  String get tileSafetyLog => 'பாதுகாப்பு பதிவு';

  @override
  String get tileEmergencyId => 'அவசர அடையாளம்';

  @override
  String get tilePoliceSos => 'காவல் SOS';

  @override
  String get tileWhatToDo => 'என்ன செய்வது';

  @override
  String get tileIndiaHelp => 'இந்தியா உதவி';

  @override
  String get tileJourneySafe => 'பயணம் பாதுகாப்பு';

  @override
  String get tileQrCard => 'QR அட்டை';

  @override
  String get tileLocationPing => 'இருப்பிட பிங்';

  @override
  String get tileDangerZones => 'ஆபத்து மண்டலங்கள்';

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
    return '$count அவசர தொடர்புகள் சேமிக்கப்பட்டன.';
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
