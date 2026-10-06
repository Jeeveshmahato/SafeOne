// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get languageSubtitle => 'আপনার পছন্দের ভাষা বেছে নিন';

  @override
  String get fakeCallTitle => 'নকল কল';

  @override
  String get fakeCallHeader =>
      'অনিরাপদ পরিস্থিতি থেকে বেরিয়ে আসতে সাহায্য করার জন্য একটি নকল ইনকামিং কল তৈরি করুন। কলটি বাস্তব দেখায় এবং সরে যাওয়ার একটি কারণ দেয়।';

  @override
  String get chooseScenario => 'পরিস্থিতি বেছে নিন';

  @override
  String get chooseCaller => 'কলার বেছে নিন';

  @override
  String get phoneNumberOptional => 'ফোন নম্বর (ঐচ্ছিক)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'বাস্তবতার জন্য নকল কল স্ক্রিনে দেখানো হয়';

  @override
  String get whatToSay => 'কী বলবেন (যদি তারা ধরে)';

  @override
  String get whatToSayHint => 'যেমন আমি একটি জরুরি কলে আছি, একটু সময় দিন।';

  @override
  String get whatToSayHelper => 'ভুলবশত কল ধরা হলে বলার জন্য সংক্ষিপ্ত বার্তা';

  @override
  String get callDelay => 'কল বিলম্ব';

  @override
  String get quickPresets => 'দ্রুত প্রিসেট';

  @override
  String get orCustomTime => 'অথবা কাস্টম সময় লিখুন';

  @override
  String get hours => 'ঘণ্টা';

  @override
  String get minutes => 'মিনিট';

  @override
  String get seconds => 'সেকেন্ড';

  @override
  String get advancedOptions => 'উন্নত বিকল্প';

  @override
  String get repeatCall => 'কল পুনরাবৃত্তি';

  @override
  String get repeatCallSubtitle => 'আপনি প্রত্যাখ্যান করলে কল বাজতে থাকে';

  @override
  String get autoEndCall => 'স্বয়ংক্রিয়ভাবে কল শেষ করুন';

  @override
  String get autoEndCallSubtitle =>
      'নির্দিষ্ট সময়ের পর কল স্বয়ংক্রিয়ভাবে শেষ হয়';

  @override
  String get endAfter => 'এর পরে শেষ করুন:';

  @override
  String get ringSound => 'রিং শব্দ';

  @override
  String get ringSoundPhone => 'ফোন রিং';

  @override
  String get ringSoundSiren => 'পুলিশ সাইরেন';

  @override
  String get startFakeCall => 'নকল কল শুরু করুন';

  @override
  String get now => 'এখন';

  @override
  String callInCountdown(int seconds) {
    return '$seconds এ কল';
  }

  @override
  String get keepScreenOpen =>
      'এই স্ক্রিনটি খোলা রাখুন। টাইমার শেষ হলে নকল কল দেখা যাবে। আপনি ফোনটি কানের কাছে রাখতে পারেন।';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'বাতিল';

  @override
  String get incomingCall => 'ইনকামিং কল…';

  @override
  String get callEnded => 'কল শেষ';

  @override
  String get decline => 'প্রত্যাখ্যান';

  @override
  String get accept => 'গ্রহণ';

  @override
  String get close => 'বন্ধ';

  @override
  String get callWillRepeat => 'প্রত্যাখ্যান করলে কল পুনরাবৃত্তি হবে';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds সেকেন্ডে স্বয়ংক্রিয়ভাবে শেষ';
  }

  @override
  String get mute => 'মিউট';

  @override
  String get speaker => 'স্পিকার';

  @override
  String get keypad => 'কীপ্যাড';

  @override
  String get endCall => 'কল শেষ করুন';

  @override
  String secondsShort(int count) {
    return '$count সেকেন্ড';
  }

  @override
  String minutesShort(int count) {
    return '$count মিনিট';
  }

  @override
  String hoursShort(int count) {
    return '$count ঘণ্টা';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursঘ $minutesমি';
  }

  @override
  String get homeNoContacts => 'শুরু করতে জরুরি যোগাযোগ যোগ করুন।';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'আপনার অবস্থান পাঠাতে SOS-এ ট্যাপ করুন।';

  @override
  String get tileSiren => 'সাইরেন';

  @override
  String get tileStopSiren => 'সাইরেন বন্ধ';

  @override
  String get tilePoliceSiren => 'পুলিশ সাইরেন';

  @override
  String get tileStopPolice => 'পুলিশ বন্ধ';

  @override
  String get tileFlashlight => 'টর্চ';

  @override
  String get tileStopLight => 'আলো বন্ধ';

  @override
  String get tileSosBlink => 'SOS ব্লিঙ্ক';

  @override
  String get tileStopBlink => 'ব্লিঙ্ক বন্ধ';

  @override
  String get tileRecord => 'রেকর্ড';

  @override
  String get tileStopRec => 'রেকর্ড বন্ধ';

  @override
  String get tileImSafe => 'আমি নিরাপদ';

  @override
  String get tileSafetyTimer => 'সুরক্ষা টাইমার';

  @override
  String get tileHelplines => 'হেল্পলাইন';

  @override
  String get tileShareLocation => 'অবস্থান শেয়ার';

  @override
  String get tileNearbyHelp => 'কাছের সাহায্য';

  @override
  String get tileFakeCall => 'নকল কল';

  @override
  String get tileFollowMe => 'আমাকে অনুসরণ';

  @override
  String get tileSafetyTips => 'সুরক্ষা টিপস';

  @override
  String get tileIncidentLog => 'ঘটনা লগ';

  @override
  String get tileMedicalInfo => 'চিকিৎসা তথ্য';

  @override
  String get tileContacts => 'যোগাযোগ';

  @override
  String get tileQuickContacts => 'দ্রুত যোগাযোগ';

  @override
  String get tileBuddyCheckin => 'বন্ধু চেক-ইন';

  @override
  String get tileSafetyLog => 'সুরক্ষা লগ';

  @override
  String get tileEmergencyId => 'জরুরি আইডি';

  @override
  String get tilePoliceSos => 'পুলিশ SOS';

  @override
  String get tileWhatToDo => 'কী করবেন';

  @override
  String get tileIndiaHelp => 'ভারত সহায়তা';

  @override
  String get tileJourneySafe => 'নিরাপদ যাত্রা';

  @override
  String get tileQrCard => 'QR কার্ড';

  @override
  String get tileLocationPing => 'লোকেশন পিং';

  @override
  String get tileDangerZones => 'বিপদ অঞ্চল';

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
    return '$countটি জরুরি যোগাযোগ সংরক্ষিত।';
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
