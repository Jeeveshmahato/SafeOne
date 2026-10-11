// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'ക്രമീകരണങ്ങൾ';

  @override
  String get language => 'ഭാഷ';

  @override
  String get languageSubtitle => 'നിങ്ങൾക്ക് ഇഷ്ടമുള്ള ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get fakeCallTitle => 'വ്യാജ കോൾ';

  @override
  String get fakeCallHeader =>
      'സുരക്ഷിതമല്ലാത്ത സാഹചര്യത്തിൽ നിന്ന് പുറത്തുകടക്കാൻ സഹായിക്കുന്നതിന് ഒരു വ്യാജ ഇൻകമിംഗ് കോൾ സൃഷ്ടിക്കുക. ഈ കോൾ യഥാർത്ഥമായി തോന്നുകയും അവിടെ നിന്ന് മാറിപ്പോകാൻ ഒരു കാരണം നൽകുകയും ചെയ്യുന്നു.';

  @override
  String get chooseScenario => 'സാഹചര്യം തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseCaller => 'വിളിക്കുന്നയാളെ തിരഞ്ഞെടുക്കുക';

  @override
  String get phoneNumberOptional => 'ഫോൺ നമ്പർ (ഓപ്ഷണൽ)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper =>
      'യാഥാർത്ഥ്യത്തിനായി വ്യാജ കോൾ സ്ക്രീനിൽ കാണിക്കുന്നു';

  @override
  String get whatToSay => 'എന്ത് പറയണം (അവർ എടുത്താൽ)';

  @override
  String get whatToSayHint => 'ഉദാ. ഞാൻ ഒരു പ്രധാന കോളിലാണ്, അൽപ്പം സമയം തരൂ.';

  @override
  String get whatToSayHelper =>
      'അബദ്ധത്തിൽ കോൾ എടുത്താൽ പറയാനുള്ള ഒരു ചെറിയ സന്ദേശം';

  @override
  String get callDelay => 'കോൾ കാലതാമസം';

  @override
  String get quickPresets => 'പെട്ടെന്നുള്ള പ്രീസെറ്റുകൾ';

  @override
  String get orCustomTime => 'അല്ലെങ്കിൽ ഇഷ്ടാനുസൃത സമയം നൽകുക';

  @override
  String get hours => 'മണിക്കൂർ';

  @override
  String get minutes => 'മിനിറ്റ്';

  @override
  String get seconds => 'സെക്കൻഡ്';

  @override
  String get advancedOptions => 'വിപുലമായ ഓപ്ഷനുകൾ';

  @override
  String get repeatCall => 'കോൾ ആവർത്തിക്കുക';

  @override
  String get repeatCallSubtitle =>
      'നിങ്ങൾ നിരസിച്ചാൽ കോൾ വീണ്ടും റിംഗ് ചെയ്യും';

  @override
  String get autoEndCall => 'സ്വയമേവ കോൾ അവസാനിപ്പിക്കുക';

  @override
  String get autoEndCallSubtitle =>
      'നിശ്ചിത സമയത്തിന് ശേഷം കോൾ സ്വയമേവ അവസാനിക്കും';

  @override
  String get endAfter => 'ഇതിന് ശേഷം അവസാനിപ്പിക്കുക:';

  @override
  String get ringSound => 'റിംഗ് ശബ്ദം';

  @override
  String get ringSoundPhone => 'ഫോൺ റിംഗ്';

  @override
  String get ringSoundSiren => 'പോലീസ് സൈറൺ';

  @override
  String get startFakeCall => 'വ്യാജ കോൾ ആരംഭിക്കുക';

  @override
  String get now => 'ഇപ്പോൾ';

  @override
  String callInCountdown(int seconds) {
    return '$seconds ൽ കോൾ';
  }

  @override
  String get keepScreenOpen =>
      'ഈ സ്ക്രീൻ തുറന്നുവയ്ക്കുക. ടൈമർ അവസാനിക്കുമ്പോൾ വ്യാജ കോൾ ദൃശ്യമാകും. നിങ്ങൾക്ക് ഫോൺ ചെവിയോട് ചേർത്ത് വയ്ക്കാം.';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'Your phone will ring in $time, even if it\'s locked or the app is closed. If asked, allow notifications and full-screen alerts.';
  }

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get incomingCall => 'ഇൻകമിംഗ് കോൾ…';

  @override
  String get callEnded => 'കോൾ അവസാനിച്ചു';

  @override
  String get decline => 'നിരസിക്കുക';

  @override
  String get accept => 'സ്വീകരിക്കുക';

  @override
  String get close => 'അടയ്ക്കുക';

  @override
  String get callWillRepeat => 'നിരസിച്ചാൽ കോൾ ആവർത്തിക്കും';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds സെക്കൻഡിൽ സ്വയമേവ അവസാനിക്കും';
  }

  @override
  String get mute => 'മ്യൂട്ട്';

  @override
  String get speaker => 'സ്പീക്കർ';

  @override
  String get keypad => 'കീപാഡ്';

  @override
  String get endCall => 'കോൾ അവസാനിപ്പിക്കുക';

  @override
  String secondsShort(int count) {
    return '$count സെ';
  }

  @override
  String minutesShort(int count) {
    return '$count മി';
  }

  @override
  String hoursShort(int count) {
    return '$count മ';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursമ $minutesമി';
  }

  @override
  String get homeNoContacts => 'ആരംഭിക്കാൻ അടിയന്തര കോൺടാക്റ്റുകൾ ചേർക്കുക.';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'നിങ്ങളുടെ സ്ഥാനം അയയ്ക്കാൻ SOS അമർത്തുക.';

  @override
  String get tileSiren => 'സൈറൻ';

  @override
  String get tileStopSiren => 'സൈറൻ നിർത്തുക';

  @override
  String get tilePoliceSiren => 'പോലീസ് സൈറൻ';

  @override
  String get tileStopPolice => 'പോലീസ് നിർത്തുക';

  @override
  String get tileFlashlight => 'ടോർച്ച്';

  @override
  String get tileStopLight => 'ലൈറ്റ് നിർത്തുക';

  @override
  String get tileSosBlink => 'SOS ബ്ലിങ്ക്';

  @override
  String get tileStopBlink => 'ബ്ലിങ്ക് നിർത്തുക';

  @override
  String get tileRecord => 'റെക്കോർഡ്';

  @override
  String get tileStopRec => 'റെക്കോർഡ് നിർത്തുക';

  @override
  String get tileImSafe => 'ഞാൻ സുരക്ഷിതം';

  @override
  String get tileSafetyTimer => 'സുരക്ഷാ ടൈമർ';

  @override
  String get tileHelplines => 'ഹെൽപ്പ്‌ലൈനുകൾ';

  @override
  String get tileShareLocation => 'സ്ഥാനം പങ്കിടുക';

  @override
  String get tileNearbyHelp => 'അടുത്തുള്ള സഹായം';

  @override
  String get tileFakeCall => 'വ്യാജ കോൾ';

  @override
  String get tileFollowMe => 'എന്നെ പിന്തുടരുക';

  @override
  String get tileSafetyTips => 'സുരക്ഷാ നുറുങ്ങുകൾ';

  @override
  String get tileIncidentLog => 'സംഭവ ലോഗ്';

  @override
  String get tileMedicalInfo => 'മെഡിക്കൽ വിവരം';

  @override
  String get tileContacts => 'കോൺടാക്റ്റുകൾ';

  @override
  String get tileQuickContacts => 'പെട്ടെന്നുള്ള കോൺടാക്റ്റുകൾ';

  @override
  String get tileBuddyCheckin => 'ബഡ്ഡി ചെക്ക്-ഇൻ';

  @override
  String get tileSafetyLog => 'സുരക്ഷാ ലോഗ്';

  @override
  String get tileEmergencyId => 'അടിയന്തര ID';

  @override
  String get tilePoliceSos => 'പോലീസ് SOS';

  @override
  String get tileWhatToDo => 'എന്ത് ചെയ്യണം';

  @override
  String get tileIndiaHelp => 'ഇന്ത്യ സഹായം';

  @override
  String get tileJourneySafe => 'സുരക്ഷിത യാത്ര';

  @override
  String get tileQrCard => 'QR കാർഡ്';

  @override
  String get tileLocationPing => 'ലൊക്കേഷൻ പിംഗ്';

  @override
  String get tileDangerZones => 'അപകട മേഖലകൾ';

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
    return '$count അടിയന്തര കോൺടാക്റ്റുകൾ സംരക്ഷിച്ചു.';
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
