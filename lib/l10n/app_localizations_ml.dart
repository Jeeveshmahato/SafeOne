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
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
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
    return '$count അടിയന്തര കോൺടാക്റ്റുകൾ സംരക്ഷിച്ചു.';
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
