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
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
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
    return '$countটা জৰুৰীকালীন যোগাযোগ সাঁচি থোৱা হ\'ল।';
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
