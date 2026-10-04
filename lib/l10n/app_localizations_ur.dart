// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get language => 'زبان';

  @override
  String get languageSubtitle => 'اپنی پسندیدہ زبان منتخب کریں';

  @override
  String get fakeCallTitle => 'جعلی کال';

  @override
  String get fakeCallHeader =>
      'غیر محفوظ صورتحال سے نکلنے میں مدد کے لیے ایک جعلی آنے والی کال بنائیں۔ یہ کال حقیقی لگتی ہے اور وہاں سے ہٹنے کا بہانہ دیتی ہے۔';

  @override
  String get chooseScenario => 'منظرنامہ منتخب کریں';

  @override
  String get chooseCaller => 'کال کرنے والا منتخب کریں';

  @override
  String get phoneNumberOptional => 'فون نمبر (اختیاری)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'حقیقت کے لیے جعلی کال اسکرین پر دکھایا جاتا ہے';

  @override
  String get whatToSay => 'کیا کہیں (اگر وہ اٹھا لیں)';

  @override
  String get whatToSayHint => 'مثلاً میں ایک اہم کال پر ہوں، تھوڑا وقت دیں۔';

  @override
  String get whatToSayHelper =>
      'اگر غلطی سے کال اٹھ جائے تو کہنے کے لیے مختصر پیغام';

  @override
  String get callDelay => 'کال میں تاخیر';

  @override
  String get quickPresets => 'فوری پری سیٹ';

  @override
  String get orCustomTime => 'یا اپنی مرضی کا وقت درج کریں';

  @override
  String get hours => 'گھنٹے';

  @override
  String get minutes => 'منٹ';

  @override
  String get seconds => 'سیکنڈ';

  @override
  String get advancedOptions => 'اعلیٰ اختیارات';

  @override
  String get repeatCall => 'کال دہرائیں';

  @override
  String get repeatCallSubtitle => 'اگر آپ مسترد کریں تو کال بجتی رہتی ہے';

  @override
  String get autoEndCall => 'خودکار طور پر کال ختم کریں';

  @override
  String get autoEndCallSubtitle =>
      'مقررہ وقت کے بعد کال خودکار طور پر ختم ہو جاتی ہے';

  @override
  String get endAfter => 'اس کے بعد ختم کریں:';

  @override
  String get ringSound => 'گھنٹی کی آواز';

  @override
  String get ringSoundPhone => 'فون رنگ';

  @override
  String get ringSoundSiren => 'پولیس سائرن';

  @override
  String get startFakeCall => 'جعلی کال شروع کریں';

  @override
  String get now => 'ابھی';

  @override
  String callInCountdown(int seconds) {
    return '$seconds میں کال';
  }

  @override
  String get keepScreenOpen =>
      'اس اسکرین کو کھلا رکھیں۔ ٹائمر ختم ہونے پر جعلی کال ظاہر ہوگی۔ آپ فون کو کان کے قریب رکھ سکتے ہیں۔';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get incomingCall => 'آنے والی کال…';

  @override
  String get callEnded => 'کال ختم';

  @override
  String get decline => 'مسترد کریں';

  @override
  String get accept => 'قبول کریں';

  @override
  String get close => 'بند کریں';

  @override
  String get callWillRepeat => 'مسترد کرنے پر کال دہرائی جائے گی';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds سیکنڈ میں خودکار طور پر ختم';
  }

  @override
  String get mute => 'خاموش';

  @override
  String get speaker => 'اسپیکر';

  @override
  String get keypad => 'کی پیڈ';

  @override
  String get endCall => 'کال ختم کریں';

  @override
  String secondsShort(int count) {
    return '$count سیکنڈ';
  }

  @override
  String minutesShort(int count) {
    return '$count منٹ';
  }

  @override
  String hoursShort(int count) {
    return '$count گھنٹے';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursگھ $minutesم';
  }

  @override
  String get homeNoContacts => 'شروع کرنے کے لیے ہنگامی رابطے شامل کریں۔';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'اپنا مقام بھیجنے کے لیے SOS دبائیں۔';

  @override
  String get tileSiren => 'سائرن';

  @override
  String get tileStopSiren => 'سائرن بند';

  @override
  String get tilePoliceSiren => 'پولیس سائرن';

  @override
  String get tileStopPolice => 'پولیس بند';

  @override
  String get tileFlashlight => 'ٹارچ';

  @override
  String get tileStopLight => 'لائٹ بند';

  @override
  String get tileSosBlink => 'SOS بلنک';

  @override
  String get tileStopBlink => 'بلنک بند';

  @override
  String get tileRecord => 'ریکارڈ';

  @override
  String get tileStopRec => 'ریکارڈ بند';

  @override
  String get tileImSafe => 'میں محفوظ ہوں';

  @override
  String get tileSafetyTimer => 'حفاظتی ٹائمر';

  @override
  String get tileHelplines => 'ہیلپ لائنز';

  @override
  String get tileShareLocation => 'مقام شیئر';

  @override
  String get tileNearbyHelp => 'قریبی مدد';

  @override
  String get tileFakeCall => 'جعلی کال';

  @override
  String get tileFollowMe => 'میرا پیچھا کریں';

  @override
  String get tileSafetyTips => 'حفاظتی تجاویز';

  @override
  String get tileIncidentLog => 'واقعہ لاگ';

  @override
  String get tileMedicalInfo => 'طبی معلومات';

  @override
  String get tileContacts => 'رابطے';

  @override
  String get tileQuickContacts => 'فوری رابطے';

  @override
  String get tileBuddyCheckin => 'بڈی چیک ان';

  @override
  String get tileSafetyLog => 'حفاظتی لاگ';

  @override
  String get tileEmergencyId => 'ہنگامی شناخت';

  @override
  String get tilePoliceSos => 'پولیس SOS';

  @override
  String get tileWhatToDo => 'کیا کریں';

  @override
  String get tileIndiaHelp => 'انڈیا مدد';

  @override
  String get tileJourneySafe => 'محفوظ سفر';

  @override
  String get tileQrCard => 'QR کارڈ';

  @override
  String get tileLocationPing => 'لوکیشن پنگ';

  @override
  String get tileDangerZones => 'خطرناک علاقے';

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
    return '$count ہنگامی رابطے محفوظ ہیں۔';
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
