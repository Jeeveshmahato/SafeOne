// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get languageSubtitle => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String get fakeCallTitle => 'नकली कॉल';

  @override
  String get fakeCallHeader =>
      'असुरक्षित स्थिति से निकलने में मदद के लिए एक नकली इनकमिंग कॉल बनाएं। यह कॉल असली जैसी दिखती है और आपको वहां से हटने का बहाना देती है।';

  @override
  String get chooseScenario => 'परिदृश्य चुनें';

  @override
  String get chooseCaller => 'कॉल करने वाला चुनें';

  @override
  String get phoneNumberOptional => 'फ़ोन नंबर (वैकल्पिक)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'वास्तविकता के लिए नकली कॉल स्क्रीन पर दिखता है';

  @override
  String get whatToSay => 'क्या कहें (अगर वे उठा लें)';

  @override
  String get whatToSayHint => 'जैसे मैं एक ज़रूरी कॉल पर हूँ, एक पल दीजिए।';

  @override
  String get whatToSayHelper =>
      'अगर गलती से कॉल उठ जाए तो कहने के लिए छोटा संदेश';

  @override
  String get callDelay => 'कॉल में देरी';

  @override
  String get quickPresets => 'त्वरित विकल्प';

  @override
  String get orCustomTime => 'या कस्टम समय दर्ज करें';

  @override
  String get hours => 'घंटे';

  @override
  String get minutes => 'मिनट';

  @override
  String get seconds => 'सेकंड';

  @override
  String get advancedOptions => 'उन्नत विकल्प';

  @override
  String get repeatCall => 'कॉल दोहराएं';

  @override
  String get repeatCallSubtitle =>
      'अगर आप अस्वीकार करते हैं तो कॉल बजती रहती है';

  @override
  String get autoEndCall => 'कॉल अपने आप समाप्त करें';

  @override
  String get autoEndCallSubtitle =>
      'तय समय के बाद कॉल अपने आप समाप्त हो जाती है';

  @override
  String get endAfter => 'इसके बाद समाप्त करें:';

  @override
  String get ringSound => 'रिंग ध्वनि';

  @override
  String get ringSoundPhone => 'फ़ोन रिंग';

  @override
  String get ringSoundSiren => 'पुलिस सायरन';

  @override
  String get startFakeCall => 'नकली कॉल शुरू करें';

  @override
  String get now => 'अभी';

  @override
  String callInCountdown(int seconds) {
    return '$seconds में कॉल';
  }

  @override
  String get keepScreenOpen =>
      'इस स्क्रीन को खुला रखें। टाइमर समाप्त होने पर नकली कॉल दिखाई देगी। आप फ़ोन को कान के पास रख सकते हैं।';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get incomingCall => 'इनकमिंग कॉल…';

  @override
  String get callEnded => 'कॉल समाप्त';

  @override
  String get decline => 'अस्वीकार करें';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get close => 'बंद करें';

  @override
  String get callWillRepeat => 'अस्वीकार करने पर कॉल दोहराई जाएगी';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds सेकंड में अपने आप समाप्त';
  }

  @override
  String get mute => 'म्यूट';

  @override
  String get speaker => 'स्पीकर';

  @override
  String get keypad => 'कीपैड';

  @override
  String get endCall => 'कॉल समाप्त करें';

  @override
  String secondsShort(int count) {
    return '$count सेकंड';
  }

  @override
  String minutesShort(int count) {
    return '$count मिनट';
  }

  @override
  String hoursShort(int count) {
    return '$count घंटे';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursघं $minutesमि';
  }

  @override
  String get homeNoContacts => 'शुरू करने के लिए आपातकालीन संपर्क जोड़ें।';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'अपने संपर्कों को स्थान भेजने के लिए SOS दबाएं।';

  @override
  String get tileSiren => 'सायरन';

  @override
  String get tileStopSiren => 'सायरन बंद करें';

  @override
  String get tilePoliceSiren => 'पुलिस सायरन';

  @override
  String get tileStopPolice => 'पुलिस बंद करें';

  @override
  String get tileFlashlight => 'टॉर्च';

  @override
  String get tileStopLight => 'लाइट बंद करें';

  @override
  String get tileSosBlink => 'SOS ब्लिंक';

  @override
  String get tileStopBlink => 'ब्लिंक बंद करें';

  @override
  String get tileRecord => 'रिकॉर्ड';

  @override
  String get tileStopRec => 'रिकॉर्ड बंद';

  @override
  String get tileImSafe => 'मैं सुरक्षित हूँ';

  @override
  String get tileSafetyTimer => 'सुरक्षा टाइमर';

  @override
  String get tileHelplines => 'हेल्पलाइन';

  @override
  String get tileShareLocation => 'स्थान साझा करें';

  @override
  String get tileNearbyHelp => 'नज़दीकी मदद';

  @override
  String get tileFakeCall => 'नकली कॉल';

  @override
  String get tileFollowMe => 'मुझे फॉलो करें';

  @override
  String get tileSafetyTips => 'सुरक्षा सुझाव';

  @override
  String get tileIncidentLog => 'घटना लॉग';

  @override
  String get tileMedicalInfo => 'चिकित्सा जानकारी';

  @override
  String get tileContacts => 'संपर्क';

  @override
  String get tileQuickContacts => 'त्वरित संपर्क';

  @override
  String get tileBuddyCheckin => 'बडी चेक-इन';

  @override
  String get tileSafetyLog => 'सुरक्षा लॉग';

  @override
  String get tileEmergencyId => 'आपातकालीन ID';

  @override
  String get tilePoliceSos => 'पुलिस SOS';

  @override
  String get tileWhatToDo => 'क्या करें';

  @override
  String get tileIndiaHelp => 'भारत सहायता';

  @override
  String get tileJourneySafe => 'सुरक्षित यात्रा';

  @override
  String get tileQrCard => 'QR कार्ड';

  @override
  String get tileLocationPing => 'लोकेशन पिंग';

  @override
  String get tileDangerZones => 'खतरे के क्षेत्र';

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
    return '$count आपातकालीन संपर्क सहेजे गए।';
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
