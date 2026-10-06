// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get language => 'भाषा';

  @override
  String get languageSubtitle => 'तुमची आवडती भाषा निवडा';

  @override
  String get fakeCallTitle => 'बनावट कॉल';

  @override
  String get fakeCallHeader =>
      'असुरक्षित परिस्थितीतून बाहेर पडण्यासाठी मदत म्हणून एक बनावट येणारा कॉल तयार करा. हा कॉल खरा वाटतो आणि तिथून निघण्याचे कारण देतो.';

  @override
  String get chooseScenario => 'परिस्थिती निवडा';

  @override
  String get chooseCaller => 'कॉल करणारा निवडा';

  @override
  String get phoneNumberOptional => 'फोन नंबर (पर्यायी)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'खरेपणासाठी बनावट कॉल स्क्रीनवर दाखवले जाते';

  @override
  String get whatToSay => 'काय बोलावे (त्यांनी उचलल्यास)';

  @override
  String get whatToSayHint =>
      'उदा. मी एका महत्त्वाच्या कॉलवर आहे, थोडा वेळ द्या.';

  @override
  String get whatToSayHelper =>
      'चुकून कॉल उचलला गेल्यास बोलण्यासाठी छोटा संदेश';

  @override
  String get callDelay => 'कॉल विलंब';

  @override
  String get quickPresets => 'त्वरित प्रीसेट';

  @override
  String get orCustomTime => 'किंवा सानुकूल वेळ प्रविष्ट करा';

  @override
  String get hours => 'तास';

  @override
  String get minutes => 'मिनिटे';

  @override
  String get seconds => 'सेकंद';

  @override
  String get advancedOptions => 'प्रगत पर्याय';

  @override
  String get repeatCall => 'कॉल पुन्हा करा';

  @override
  String get repeatCallSubtitle => 'तुम्ही नाकारल्यास कॉल वाजत राहतो';

  @override
  String get autoEndCall => 'कॉल आपोआप संपवा';

  @override
  String get autoEndCallSubtitle => 'ठरलेल्या वेळेनंतर कॉल आपोआप संपतो';

  @override
  String get endAfter => 'यानंतर संपवा:';

  @override
  String get ringSound => 'रिंग आवाज';

  @override
  String get ringSoundPhone => 'फोन रिंग';

  @override
  String get ringSoundSiren => 'पोलिस सायरन';

  @override
  String get startFakeCall => 'बनावट कॉल सुरू करा';

  @override
  String get now => 'आता';

  @override
  String callInCountdown(int seconds) {
    return '$seconds मध्ये कॉल';
  }

  @override
  String get keepScreenOpen =>
      'ही स्क्रीन उघडी ठेवा. टायमर संपल्यावर बनावट कॉल दिसेल. तुम्ही फोन कानाजवळ ठेवू शकता.';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'रद्द करा';

  @override
  String get incomingCall => 'येणारा कॉल…';

  @override
  String get callEnded => 'कॉल संपला';

  @override
  String get decline => 'नाकारा';

  @override
  String get accept => 'स्वीकारा';

  @override
  String get close => 'बंद करा';

  @override
  String get callWillRepeat => 'नाकारल्यास कॉल पुन्हा येईल';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds सेकंदात आपोआप संपेल';
  }

  @override
  String get mute => 'म्यूट';

  @override
  String get speaker => 'स्पीकर';

  @override
  String get keypad => 'कीपॅड';

  @override
  String get endCall => 'कॉल संपवा';

  @override
  String secondsShort(int count) {
    return '$count सेकंद';
  }

  @override
  String minutesShort(int count) {
    return '$count मिनिटे';
  }

  @override
  String hoursShort(int count) {
    return '$count तास';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursता $minutesमि';
  }

  @override
  String get homeNoContacts => 'सुरू करण्यासाठी आणीबाणी संपर्क जोडा.';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'तुमचे स्थान पाठवण्यासाठी SOS दाबा.';

  @override
  String get tileSiren => 'सायरन';

  @override
  String get tileStopSiren => 'सायरन थांबवा';

  @override
  String get tilePoliceSiren => 'पोलिस सायरन';

  @override
  String get tileStopPolice => 'पोलिस थांबवा';

  @override
  String get tileFlashlight => 'बॅटरी';

  @override
  String get tileStopLight => 'लाइट थांबवा';

  @override
  String get tileSosBlink => 'SOS ब्लिंक';

  @override
  String get tileStopBlink => 'ब्लिंक थांबवा';

  @override
  String get tileRecord => 'रेकॉर्ड';

  @override
  String get tileStopRec => 'रेकॉर्ड थांबवा';

  @override
  String get tileImSafe => 'मी सुरक्षित आहे';

  @override
  String get tileSafetyTimer => 'सुरक्षा टायमर';

  @override
  String get tileHelplines => 'हेल्पलाइन';

  @override
  String get tileShareLocation => 'स्थान शेअर';

  @override
  String get tileNearbyHelp => 'जवळची मदत';

  @override
  String get tileFakeCall => 'बनावट कॉल';

  @override
  String get tileFollowMe => 'मला फॉलो करा';

  @override
  String get tileSafetyTips => 'सुरक्षा टिप्स';

  @override
  String get tileIncidentLog => 'घटना नोंद';

  @override
  String get tileMedicalInfo => 'वैद्यकीय माहिती';

  @override
  String get tileContacts => 'संपर्क';

  @override
  String get tileQuickContacts => 'त्वरित संपर्क';

  @override
  String get tileBuddyCheckin => 'बडी चेक-इन';

  @override
  String get tileSafetyLog => 'सुरक्षा नोंद';

  @override
  String get tileEmergencyId => 'आणीबाणी ID';

  @override
  String get tilePoliceSos => 'पोलिस SOS';

  @override
  String get tileWhatToDo => 'काय करावे';

  @override
  String get tileIndiaHelp => 'भारत मदत';

  @override
  String get tileJourneySafe => 'सुरक्षित प्रवास';

  @override
  String get tileQrCard => 'QR कार्ड';

  @override
  String get tileLocationPing => 'लोकेशन पिंग';

  @override
  String get tileDangerZones => 'धोक्याचे क्षेत्र';

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
    return '$count आणीबाणी संपर्क जतन केले.';
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
