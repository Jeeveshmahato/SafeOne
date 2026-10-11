// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class AppLocalizationsAs extends AppLocalizations {
  AppLocalizationsAs([String locale = 'as']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'ছেটিংছ';

  @override
  String get language => 'ভাষা';

  @override
  String get languageSubtitle => 'আপোনাৰ পছন্দৰ ভাষা বাছনি কৰক';

  @override
  String get fakeCallTitle => 'নকল কল';

  @override
  String get fakeCallHeader =>
      'অসুৰক্ষিত পৰিস্থিতিৰ পৰা ওলাই আহিবলৈ সহায় কৰিবলৈ এটা নকল অহা কল সৃষ্টি কৰক। এই কলটো সঁচা যেন লাগে আৰু তাৰ পৰা আঁতৰি যোৱাৰ এটা কাৰণ দিয়ে।';

  @override
  String get chooseScenario => 'পৰিস্থিতি বাছনি কৰক';

  @override
  String get chooseCaller => 'কল কৰোঁতাজনক বাছনি কৰক';

  @override
  String get phoneNumberOptional => 'ফোন নম্বৰ (বৈকল্পিক)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'বাস্তৱতাৰ বাবে নকল কল স্ক্ৰীনত দেখুওৱা হয়';

  @override
  String get whatToSay => 'কি ক\'ব (যদি তেওঁলোকে ধৰে)';

  @override
  String get whatToSayHint =>
      'যেনে মই এটা গুৰুত্বপূৰ্ণ কলত আছোঁ, অলপ সময় দিয়ক।';

  @override
  String get whatToSayHelper => 'ভুলবশতঃ কল ধৰা হ\'লে কোৱাৰ বাবে চুটি বাৰ্তা';

  @override
  String get callDelay => 'কল পলম';

  @override
  String get quickPresets => 'দ্ৰুত প্ৰিছেট';

  @override
  String get orCustomTime => 'অথবা কাষ্টম সময় দিয়ক';

  @override
  String get hours => 'ঘণ্টা';

  @override
  String get minutes => 'মিনিট';

  @override
  String get seconds => 'ছেকেণ্ড';

  @override
  String get advancedOptions => 'উন্নত বিকল্প';

  @override
  String get repeatCall => 'কল পুনৰাবৃত্তি কৰক';

  @override
  String get repeatCallSubtitle => 'আপুনি প্ৰত্যাখ্যান কৰিলে কল বাজি থাকে';

  @override
  String get autoEndCall => 'স্বয়ংক্ৰিয়ভাৱে কল সমাপ্ত কৰক';

  @override
  String get autoEndCallSubtitle =>
      'নিৰ্ধাৰিত সময়ৰ পিছত কল স্বয়ংক্ৰিয়ভাৱে সমাপ্ত হয়';

  @override
  String get endAfter => 'ইয়াৰ পিছত সমাপ্ত কৰক:';

  @override
  String get ringSound => 'ৰিং শব্দ';

  @override
  String get ringSoundPhone => 'ফোন ৰিং';

  @override
  String get ringSoundSiren => 'পুলিচ চাইৰেন';

  @override
  String get startFakeCall => 'নকল কল আৰম্ভ কৰক';

  @override
  String get now => 'এতিয়া';

  @override
  String callInCountdown(int seconds) {
    return '$seconds ত কল';
  }

  @override
  String get keepScreenOpen =>
      'এই স্ক্ৰীনখন খোলা ৰাখক। টাইমাৰ শেষ হ\'লে নকল কল দেখা যাব। আপুনি ফোনটো কাণৰ ওচৰত ৰাখিব পাৰে।';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'Your phone will ring in $time, even if it\'s locked or the app is closed. If asked, allow notifications and full-screen alerts.';
  }

  @override
  String get cancel => 'বাতিল কৰক';

  @override
  String get incomingCall => 'অহা কল…';

  @override
  String get callEnded => 'কল সমাপ্ত';

  @override
  String get decline => 'প্ৰত্যাখ্যান কৰক';

  @override
  String get accept => 'গ্ৰহণ কৰক';

  @override
  String get close => 'বন্ধ কৰক';

  @override
  String get callWillRepeat => 'প্ৰত্যাখ্যান কৰিলে কল পুনৰাবৃত্তি হ\'ব';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds ছেকেণ্ডত স্বয়ংক্ৰিয়ভাৱে সমাপ্ত';
  }

  @override
  String get mute => 'মিউট';

  @override
  String get speaker => 'স্পীকাৰ';

  @override
  String get keypad => 'কীপেড';

  @override
  String get endCall => 'কল সমাপ্ত কৰক';

  @override
  String secondsShort(int count) {
    return '$count ছেকেণ্ড';
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
  String get homeNoContacts => 'আৰম্ভ কৰিবলৈ জৰুৰীকালীন যোগাযোগ যোগ কৰক।';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'আপোনাৰ অৱস্থান পঠিয়াবলৈ SOS টিপক।';

  @override
  String get tileSiren => 'চাইৰেন';

  @override
  String get tileStopSiren => 'চাইৰেন বন্ধ';

  @override
  String get tilePoliceSiren => 'পুলিচ চাইৰেন';

  @override
  String get tileStopPolice => 'পুলিচ বন্ধ';

  @override
  String get tileFlashlight => 'টৰ্চ';

  @override
  String get tileStopLight => 'লাইট বন্ধ';

  @override
  String get tileSosBlink => 'SOS ব্লিংক';

  @override
  String get tileStopBlink => 'ব্লিংক বন্ধ';

  @override
  String get tileRecord => 'ৰেকৰ্ড';

  @override
  String get tileStopRec => 'ৰেকৰ্ড বন্ধ';

  @override
  String get tileImSafe => 'মই সুৰক্ষিত';

  @override
  String get tileSafetyTimer => 'সুৰক্ষা টাইমাৰ';

  @override
  String get tileHelplines => 'হেল্পলাইন';

  @override
  String get tileShareLocation => 'অৱস্থান শ্বেয়াৰ';

  @override
  String get tileNearbyHelp => 'ওচৰৰ সহায়';

  @override
  String get tileFakeCall => 'নকল কল';

  @override
  String get tileFollowMe => 'মোক অনুসৰণ কৰক';

  @override
  String get tileSafetyTips => 'সুৰক্ষা টিপছ';

  @override
  String get tileIncidentLog => 'ঘটনা লগ';

  @override
  String get tileMedicalInfo => 'চিকিৎসা তথ্য';

  @override
  String get tileContacts => 'যোগাযোগ';

  @override
  String get tileQuickContacts => 'দ্ৰুত যোগাযোগ';

  @override
  String get tileBuddyCheckin => 'বাডী চেক-ইন';

  @override
  String get tileSafetyLog => 'সুৰক্ষা লগ';

  @override
  String get tileEmergencyId => 'জৰুৰীকালীন ID';

  @override
  String get tilePoliceSos => 'পুলিচ SOS';

  @override
  String get tileWhatToDo => 'কি কৰিব';

  @override
  String get tileIndiaHelp => 'ভাৰত সহায়';

  @override
  String get tileJourneySafe => 'সুৰক্ষিত যাত্ৰা';

  @override
  String get tileQrCard => 'QR কাৰ্ড';

  @override
  String get tileLocationPing => 'অৱস্থান পিং';

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
      'Hold SOS to send it silently, with no sound or vibration.';

  @override
  String silentSosSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent to all $count contacts.',
      one: 'Sent to your contact.',
    );
    return '$_temp0';
  }

  @override
  String get sosLiveBannerActive => 'Sharing your location with your contacts';

  @override
  String get sosLiveStop => 'Stop sharing';

  @override
  String get sosLiveStarted =>
      'Your contacts will keep getting your location until you tap \"I\'m safe\".';

  @override
  String get sosLiveStopped => 'Stopped sharing your location.';

  @override
  String get lockTitle => 'Enter PIN';

  @override
  String get lockSubtitle => 'Enter your PIN to open SafeOne';

  @override
  String get lockWrongPin => 'Wrong PIN. Try again.';

  @override
  String lockTooManyAttempts(int seconds) {
    return 'Too many tries. Wait ${seconds}s.';
  }

  @override
  String get lockUseBiometric => 'Use fingerprint / face';

  @override
  String get lockBiometricReason => 'Unlock SafeOne';

  @override
  String get pinSetTitle => 'Set a PIN';

  @override
  String get pinSetSubtitle =>
      'Your PIN keeps your contacts, medical info and records private.';

  @override
  String get pinCreateStep => 'Create a 6-digit PIN';

  @override
  String get pinConfirmStep => 'Enter it again to confirm';

  @override
  String get pinMismatch => 'Those PINs didn\'t match. Try again.';

  @override
  String get pinTooShort => 'Your PIN needs 6 digits.';

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
    return 'Too many tries. Try again in $time.';
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
      'Enter your contacts PIN to change who gets your SOS.';

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
      'SafeOne can\'t recover a forgotten PIN, because it never leaves this phone. Confirm it\'s your phone, then pick a new one.';

  @override
  String get pinResetWithDevice => 'Use your phone\'s screen lock';

  @override
  String get pinResetWithDeviceSubtitle =>
      'Your phone\'s PIN, pattern, password or fingerprint';

  @override
  String get pinResetDeviceReason =>
      'Confirm it\'s you to reset your SafeOne PIN';

  @override
  String get pinResetDeviceFailed => 'That didn\'t work. Try again.';

  @override
  String get pinResetNoDeviceLock =>
      'This phone has no screen lock, so we can\'t use it to confirm it\'s you.';

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
  String get pinResetDone => 'Your new PIN is set.';

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
      'Encrypted. The keys are kept in this phone\'s security chip.';

  @override
  String get securityProtectionTee =>
      'Encrypted. The keys are kept in this phone\'s secure hardware.';

  @override
  String get securityProtectionSoftware =>
      'Encrypted, but this phone has no secure hardware to keep the keys in.';

  @override
  String get securityRootedTitle => 'This phone looks rooted';

  @override
  String get securityRootedBody =>
      'Apps with root access can see what SafeOne shows while it\'s open. Your saved data stays encrypted while SafeOne is locked, so keep Auto-lock set to Immediately.';

  @override
  String get securitySection => 'Security';

  @override
  String get securityChangePin => 'Change PIN';

  @override
  String get securityBiometric => 'Unlock with fingerprint / face';

  @override
  String get securityBiometricSubtitle => 'Skip typing your PIN.';

  @override
  String get securityAutoLock => 'Auto-lock';

  @override
  String get securityAutoLockImmediate => 'Immediately';

  @override
  String securityAutoLockGrace(int seconds) {
    return 'After ${seconds}s away';
  }

  @override
  String get securitySilentSos => 'Silent SOS';

  @override
  String get securitySilentSosSubtitle =>
      'Don\'t vibrate when the SOS goes out.';

  @override
  String get securityLiveUpdates => 'Repeat location after SOS';

  @override
  String get securityLiveUpdatesSubtitle =>
      'Keep texting your location to contacts until you tap \"I\'m safe\".';

  @override
  String get securityVolumeTrigger => 'Triple-press volume to send SOS';

  @override
  String get securityVolumeTriggerSubtitle =>
      'Press a volume button 3 times quickly to start an SOS.';

  @override
  String get checkinScheduleTitle => 'Auto-alert if I don\'t check in';

  @override
  String get checkinScheduleSubtitle =>
      'If you don\'t tap \"I\'m safe\" in time, your contacts are alerted automatically.';

  @override
  String get checkinSetDeadline => 'Alert my contacts in';

  @override
  String checkinActive(String time) {
    return 'On. Your contacts will be alerted at $time.';
  }

  @override
  String get checkinStart => 'Start check-in';

  @override
  String get checkinImSafe => 'I\'m safe';

  @override
  String get checkinCancelled => 'Check-in stopped. Glad you\'re safe.';

  @override
  String get checkinFired =>
      'You didn\'t check in, so your contacts are being alerted.';

  @override
  String get checkinReminderTitle => 'Are you okay?';

  @override
  String get checkinReminderBody =>
      'Tap \"I\'m safe\", or your contacts will be alerted soon.';

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
    return '$countটা জৰুৰীকালীন যোগাযোগ সাঁচি থোৱা হ\'ল।';
  }

  @override
  String get homeTagline => 'Help is one tap away';

  @override
  String homeContactsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts will get your SOS',
      one: '1 contact will get your SOS',
    );
    return '$_temp0';
  }

  @override
  String get homeAddContactsTitle => 'Add your emergency contacts';

  @override
  String get homeAddContactsAction => 'Add contacts';

  @override
  String get sosButtonCaption => 'Tap for SOS  ·  Hold to send silently';

  @override
  String get sosButtonSemantics =>
      'Send SOS alert. Long-press to send silently.';

  @override
  String get sosSending => 'Sending…';

  @override
  String get tileReportPortals => 'Report & portals';

  @override
  String get errorNoContacts => 'Add at least one emergency contact first.';

  @override
  String get errorNoFlashlight => 'This phone doesn\'t have a flashlight.';

  @override
  String get errorMicDenied =>
      'SafeOne needs the microphone to record. You can allow it in Settings.';

  @override
  String get recordingStarted => 'Recording started.';

  @override
  String get recordingSaved => 'Recording saved on this phone.';

  @override
  String get recordingStopped => 'Recording stopped.';

  @override
  String get sosCountdownTitle => 'Sending your SOS';

  @override
  String get sosCountdownBody =>
      'Your contacts will get a text with your location.';

  @override
  String get sosCountdownHint => 'Pressed it by mistake? Tap Cancel.';

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
      'How long you have to cancel before it goes out.';

  @override
  String get settingsShakeTitle => 'Shake to send SOS';

  @override
  String get settingsShakeSubtitle =>
      'Shake your phone hard 3 times to send your SOS, even when it\'s locked. Uses a little more battery while the screen is off.';

  @override
  String get settingsPowerTitle => 'Power button SOS';

  @override
  String get settingsPowerSubtitle =>
      'Press the power button 3 times quickly to start an SOS.';

  @override
  String get settingsSafetyModeNote =>
      'To make these work with the screen locked, SafeOne keeps running in the background. You\'ll see a \"Safety mode is on\" notification while it does.';

  @override
  String get settingsMessageTitle => 'SOS message';

  @override
  String settingsMessageSubtitle(String token) {
    return 'This is what your contacts get. Keep $token where your map link should go.';
  }

  @override
  String get settingsMessageHint => 'Write your SOS message…';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsPrivacySubtitle => 'Your data stays on this phone';

  @override
  String get settingsSupport => 'Contact support';

  @override
  String get settingsMadeBy => 'SafeOne by Tejovan Labs';

  @override
  String get homeAddContactsBody =>
      'When you press SOS, they get a text with your location.';

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
      'Pick any ringtone, or use your own sound.';

  @override
  String get homeReadyTitle => 'Get SOS ready';

  @override
  String get homeReadyIntro =>
      'Allow these now, so nothing slows you down in an emergency:';

  @override
  String get homeReadySms => '• Text your SOS to every contact by itself';

  @override
  String get homeReadyLocation => '• Add a map link to where you are';

  @override
  String get homeReadyAction => 'Allow';

  @override
  String get homeReadySettings => 'Open settings';

  @override
  String get settingsAutoSmsTitle => 'Send SOS automatically';

  @override
  String get settingsAutoSmsOn =>
      'On. Your SOS goes out without you tapping Send.';

  @override
  String get settingsAutoSmsOff => 'Off. Messages opens and you tap Send.';

  @override
  String get settingsAutoSmsAllow => 'Allow';

  @override
  String get settingsShutdownNote =>
      'No app can tell when a phone is forced off (holding the power button for 10+ seconds) or its battery dies or is pulled, so nothing is sent then.';

  @override
  String get homeReadyBgLocation =>
      '• Add your location even when the phone is locked';

  @override
  String get settingsShutdownSwitchTitle =>
      'Text my location before my phone switches off';

  @override
  String get settingsShutdownSwitchSubtitle =>
      'When your phone is switched off, restarted or reset, your contacts get your last location.';

  @override
  String get settingsShutdownScopeActive => 'Only during an SOS or check-in';

  @override
  String get settingsShutdownScopeActiveHint =>
      'Recommended. Everyday restarts don\'t text anyone.';

  @override
  String get settingsShutdownScopeAlways => 'Every time';

  @override
  String get settingsShutdownScopeAlwaysHint =>
      'Keeps the \"Safety mode is on\" notification showing.';

  @override
  String get settingsShutdownNeedsSms =>
      'Allow SMS so the text can go out by itself.';

  @override
  String get settingsShutdownNeedsLocation =>
      'Allow location \"All the time\" so your location is included.';

  @override
  String get bgLocationTitle => 'Allow location all the time?';

  @override
  String get bgLocationBody =>
      'SafeOne uses your location in the background only to add it to texts for your emergency contacts: your SOS, live updates, a missed check-in, or when your phone is switched off. It\'s never uploaded anywhere.\n\nOn the next screen, choose \"Allow all the time\".';

  @override
  String get notNow => 'Not now';

  @override
  String get continueLabel => 'Continue';
}
