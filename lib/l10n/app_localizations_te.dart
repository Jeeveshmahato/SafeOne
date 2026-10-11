// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'సెట్టింగ్‌లు';

  @override
  String get language => 'భాష';

  @override
  String get languageSubtitle => 'మీకు నచ్చిన భాషను ఎంచుకోండి';

  @override
  String get fakeCallTitle => 'నకిలీ కాల్';

  @override
  String get fakeCallHeader =>
      'అసురక్షిత పరిస్థితి నుండి బయటపడటానికి సహాయంగా ఒక నకిలీ ఇన్‌కమింగ్ కాల్‌ను సృష్టించండి. ఈ కాల్ నిజంగా అనిపిస్తుంది మరియు అక్కడి నుండి వెళ్లడానికి ఒక కారణాన్ని ఇస్తుంది.';

  @override
  String get chooseScenario => 'సన్నివేశాన్ని ఎంచుకోండి';

  @override
  String get chooseCaller => 'కాలర్‌ను ఎంచుకోండి';

  @override
  String get phoneNumberOptional => 'ఫోన్ నంబర్ (ఐచ్ఛికం)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'వాస్తవికత కోసం నకిలీ కాల్ స్క్రీన్‌లో చూపబడుతుంది';

  @override
  String get whatToSay => 'ఏం చెప్పాలి (వారు ఎత్తితే)';

  @override
  String get whatToSayHint =>
      'ఉదా. నేను ఒక ముఖ్యమైన కాల్‌లో ఉన్నాను, కాస్త సమయం ఇవ్వండి.';

  @override
  String get whatToSayHelper =>
      'పొరపాటున కాల్ ఎత్తితే చెప్పడానికి చిన్న సందేశం';

  @override
  String get callDelay => 'కాల్ ఆలస్యం';

  @override
  String get quickPresets => 'త్వరిత ప్రీసెట్‌లు';

  @override
  String get orCustomTime => 'లేదా అనుకూల సమయాన్ని నమోదు చేయండి';

  @override
  String get hours => 'గంటలు';

  @override
  String get minutes => 'నిమిషాలు';

  @override
  String get seconds => 'సెకన్లు';

  @override
  String get advancedOptions => 'అధునాతన ఎంపికలు';

  @override
  String get repeatCall => 'కాల్‌ను పునరావృతం చేయి';

  @override
  String get repeatCallSubtitle => 'మీరు తిరస్కరిస్తే కాల్ మోగుతూనే ఉంటుంది';

  @override
  String get autoEndCall => 'ఆటోమేటిక్‌గా కాల్ ముగించు';

  @override
  String get autoEndCallSubtitle =>
      'నిర్ణీత సమయం తర్వాత కాల్ ఆటోమేటిక్‌గా ముగుస్తుంది';

  @override
  String get endAfter => 'దీని తర్వాత ముగించు:';

  @override
  String get ringSound => 'రింగ్ శబ్దం';

  @override
  String get ringSoundPhone => 'ఫోన్ రింగ్';

  @override
  String get ringSoundSiren => 'పోలీస్ సైరన్';

  @override
  String get startFakeCall => 'నకిలీ కాల్‌ను ప్రారంభించు';

  @override
  String get now => 'ఇప్పుడు';

  @override
  String callInCountdown(int seconds) {
    return '$seconds లో కాల్';
  }

  @override
  String get keepScreenOpen =>
      'ఈ స్క్రీన్‌ను తెరిచి ఉంచండి. టైమర్ ముగిసినప్పుడు నకిలీ కాల్ కనిపిస్తుంది. ఫోన్‌ను చెవి దగ్గర పెట్టుకోవచ్చు.';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'Your phone will ring in $time, even if it\'s locked or the app is closed. If asked, allow notifications and full-screen alerts.';
  }

  @override
  String get cancel => 'రద్దు';

  @override
  String get incomingCall => 'ఇన్‌కమింగ్ కాల్…';

  @override
  String get callEnded => 'కాల్ ముగిసింది';

  @override
  String get decline => 'తిరస్కరించు';

  @override
  String get accept => 'అంగీకరించు';

  @override
  String get close => 'మూసివేయి';

  @override
  String get callWillRepeat => 'తిరస్కరిస్తే కాల్ పునరావృతం అవుతుంది';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds సెకన్లలో ఆటోమేటిక్‌గా ముగుస్తుంది';
  }

  @override
  String get mute => 'మ్యూట్';

  @override
  String get speaker => 'స్పీకర్';

  @override
  String get keypad => 'కీప్యాడ్';

  @override
  String get endCall => 'కాల్ ముగించు';

  @override
  String secondsShort(int count) {
    return '$count సెకన్లు';
  }

  @override
  String minutesShort(int count) {
    return '$count నిమి';
  }

  @override
  String hoursShort(int count) {
    return '$count గం';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursగం $minutesని';
  }

  @override
  String get homeNoContacts =>
      'ప్రారంభించడానికి అత్యవసర సంప్రదింపులను జోడించండి.';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'మీ స్థానాన్ని పంపడానికి SOS నొక్కండి.';

  @override
  String get tileSiren => 'సైరన్';

  @override
  String get tileStopSiren => 'సైరన్ ఆపు';

  @override
  String get tilePoliceSiren => 'పోలీస్ సైరన్';

  @override
  String get tileStopPolice => 'పోలీస్ ఆపు';

  @override
  String get tileFlashlight => 'టార్చ్';

  @override
  String get tileStopLight => 'లైట్ ఆపు';

  @override
  String get tileSosBlink => 'SOS బ్లింక్';

  @override
  String get tileStopBlink => 'బ్లింక్ ఆపు';

  @override
  String get tileRecord => 'రికార్డ్';

  @override
  String get tileStopRec => 'రికార్డ్ ఆపు';

  @override
  String get tileImSafe => 'నేను సురక్షితం';

  @override
  String get tileSafetyTimer => 'భద్రతా టైమర్';

  @override
  String get tileHelplines => 'హెల్ప్‌లైన్లు';

  @override
  String get tileShareLocation => 'స్థానం షేర్';

  @override
  String get tileNearbyHelp => 'సమీప సహాయం';

  @override
  String get tileFakeCall => 'నకిలీ కాల్';

  @override
  String get tileFollowMe => 'నన్ను అనుసరించు';

  @override
  String get tileSafetyTips => 'భద్రతా చిట్కాలు';

  @override
  String get tileIncidentLog => 'సంఘటన లాగ్';

  @override
  String get tileMedicalInfo => 'వైద్య సమాచారం';

  @override
  String get tileContacts => 'సంప్రదింపులు';

  @override
  String get tileQuickContacts => 'త్వరిత సంప్రదింపులు';

  @override
  String get tileBuddyCheckin => 'బడ్డీ చెక్-ఇన్';

  @override
  String get tileSafetyLog => 'భద్రతా లాగ్';

  @override
  String get tileEmergencyId => 'అత్యవసర ID';

  @override
  String get tilePoliceSos => 'పోలీస్ SOS';

  @override
  String get tileWhatToDo => 'ఏం చేయాలి';

  @override
  String get tileIndiaHelp => 'ఇండియా సహాయం';

  @override
  String get tileJourneySafe => 'సురక్షిత ప్రయాణం';

  @override
  String get tileQrCard => 'QR కార్డ్';

  @override
  String get tileLocationPing => 'లొకేషన్ పింగ్';

  @override
  String get tileDangerZones => 'ప్రమాద ప్రాంతాలు';

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
    return '$count అత్యవసర సంప్రదింపులు సేవ్ చేయబడ్డాయి.';
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
