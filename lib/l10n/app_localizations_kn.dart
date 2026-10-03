// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get language => 'ಭಾಷೆ';

  @override
  String get languageSubtitle => 'ನಿಮ್ಮ ಇಷ್ಟದ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get fakeCallTitle => 'ನಕಲಿ ಕರೆ';

  @override
  String get fakeCallHeader =>
      'ಅಸುರಕ್ಷಿತ ಪರಿಸ್ಥಿತಿಯಿಂದ ಹೊರಬರಲು ಸಹಾಯ ಮಾಡಲು ಒಂದು ನಕಲಿ ಒಳಬರುವ ಕರೆಯನ್ನು ರಚಿಸಿ. ಈ ಕರೆ ನಿಜವಾದಂತೆ ಕಾಣುತ್ತದೆ ಮತ್ತು ಅಲ್ಲಿಂದ ದೂರ ಸರಿಯಲು ಕಾರಣ ನೀಡುತ್ತದೆ.';

  @override
  String get chooseScenario => 'ಸನ್ನಿವೇಶವನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get chooseCaller => 'ಕರೆ ಮಾಡುವವರನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get phoneNumberOptional => 'ಫೋನ್ ಸಂಖ್ಯೆ (ಐಚ್ಛಿಕ)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'ವಾಸ್ತವಿಕತೆಗಾಗಿ ನಕಲಿ ಕರೆ ಪರದೆಯಲ್ಲಿ ತೋರಿಸಲಾಗುತ್ತದೆ';

  @override
  String get whatToSay => 'ಏನು ಹೇಳಬೇಕು (ಅವರು ಎತ್ತಿಕೊಂಡರೆ)';

  @override
  String get whatToSayHint =>
      'ಉದಾ. ನಾನು ಮುಖ್ಯ ಕರೆಯಲ್ಲಿದ್ದೇನೆ, ಸ್ವಲ್ಪ ಸಮಯ ಕೊಡಿ.';

  @override
  String get whatToSayHelper => 'ತಪ್ಪಿನಿಂದ ಕರೆ ಎತ್ತಿಕೊಂಡರೆ ಹೇಳಲು ಚಿಕ್ಕ ಸಂದೇಶ';

  @override
  String get callDelay => 'ಕರೆ ವಿಳಂಬ';

  @override
  String get quickPresets => 'ತ್ವರಿತ ಪ್ರೀಸೆಟ್‌ಗಳು';

  @override
  String get orCustomTime => 'ಅಥವಾ ಕಸ್ಟಮ್ ಸಮಯವನ್ನು ನಮೂದಿಸಿ';

  @override
  String get hours => 'ಗಂಟೆಗಳು';

  @override
  String get minutes => 'ನಿಮಿಷಗಳು';

  @override
  String get seconds => 'ಸೆಕೆಂಡುಗಳು';

  @override
  String get advancedOptions => 'ಸುಧಾರಿತ ಆಯ್ಕೆಗಳು';

  @override
  String get repeatCall => 'ಕರೆಯನ್ನು ಪುನರಾವರ್ತಿಸಿ';

  @override
  String get repeatCallSubtitle =>
      'ನೀವು ತಿರಸ್ಕರಿಸಿದರೆ ಕರೆ ರಿಂಗ್ ಆಗುತ್ತಲೇ ಇರುತ್ತದೆ';

  @override
  String get autoEndCall => 'ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಕರೆ ಮುಗಿಸಿ';

  @override
  String get autoEndCallSubtitle =>
      'ನಿಗದಿತ ಸಮಯದ ನಂತರ ಕರೆ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಮುಗಿಯುತ್ತದೆ';

  @override
  String get endAfter => 'ಇದರ ನಂತರ ಮುಗಿಸಿ:';

  @override
  String get ringSound => 'ರಿಂಗ್ ಶಬ್ದ';

  @override
  String get ringSoundPhone => 'ಫೋನ್ ರಿಂಗ್';

  @override
  String get ringSoundSiren => 'ಪೊಲೀಸ್ ಸೈರನ್';

  @override
  String get startFakeCall => 'ನಕಲಿ ಕರೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get now => 'ಈಗ';

  @override
  String callInCountdown(int seconds) {
    return '$seconds ರಲ್ಲಿ ಕರೆ';
  }

  @override
  String get keepScreenOpen =>
      'ಈ ಪರದೆಯನ್ನು ತೆರೆದಿಡಿ. ಟೈಮರ್ ಮುಗಿದಾಗ ನಕಲಿ ಕರೆ ಕಾಣಿಸುತ್ತದೆ. ನೀವು ಫೋನ್ ಅನ್ನು ಕಿವಿ ಬಳಿ ಇಡಬಹುದು.';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get incomingCall => 'ಒಳಬರುವ ಕರೆ…';

  @override
  String get callEnded => 'ಕರೆ ಮುಗಿದಿದೆ';

  @override
  String get decline => 'ತಿರಸ್ಕರಿಸಿ';

  @override
  String get accept => 'ಸ್ವೀಕರಿಸಿ';

  @override
  String get close => 'ಮುಚ್ಚಿ';

  @override
  String get callWillRepeat => 'ತಿರಸ್ಕರಿಸಿದರೆ ಕರೆ ಪುನರಾವರ್ತನೆಯಾಗುತ್ತದೆ';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds ಸೆಕೆಂಡುಗಳಲ್ಲಿ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಮುಗಿಯುತ್ತದೆ';
  }

  @override
  String get mute => 'ಮ್ಯೂಟ್';

  @override
  String get speaker => 'ಸ್ಪೀಕರ್';

  @override
  String get keypad => 'ಕೀಪ್ಯಾಡ್';

  @override
  String get endCall => 'ಕರೆ ಮುಗಿಸಿ';

  @override
  String secondsShort(int count) {
    return '$count ಸೆಕೆಂ';
  }

  @override
  String minutesShort(int count) {
    return '$count ನಿಮಿ';
  }

  @override
  String hoursShort(int count) {
    return '$count ಗಂ';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursಗಂ $minutesನಿ';
  }

  @override
  String get homeNoContacts => 'ಪ್ರಾರಂಭಿಸಲು ತುರ್ತು ಸಂಪರ್ಕಗಳನ್ನು ಸೇರಿಸಿ.';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'ನಿಮ್ಮ ಸ್ಥಳವನ್ನು ಕಳುಹಿಸಲು SOS ಒತ್ತಿರಿ.';

  @override
  String get tileSiren => 'ಸೈರನ್';

  @override
  String get tileStopSiren => 'ಸೈರನ್ ನಿಲ್ಲಿಸಿ';

  @override
  String get tilePoliceSiren => 'ಪೊಲೀಸ್ ಸೈರನ್';

  @override
  String get tileStopPolice => 'ಪೊಲೀಸ್ ನಿಲ್ಲಿಸಿ';

  @override
  String get tileFlashlight => 'ಟಾರ್ಚ್';

  @override
  String get tileStopLight => 'ಬೆಳಕು ನಿಲ್ಲಿಸಿ';

  @override
  String get tileSosBlink => 'SOS ಮಿನುಗು';

  @override
  String get tileStopBlink => 'ಮಿನುಗು ನಿಲ್ಲಿಸಿ';

  @override
  String get tileRecord => 'ರೆಕಾರ್ಡ್';

  @override
  String get tileStopRec => 'ರೆಕಾರ್ಡ್ ನಿಲ್ಲಿಸಿ';

  @override
  String get tileImSafe => 'ನಾನು ಸುರಕ್ಷಿತ';

  @override
  String get tileSafetyTimer => 'ಸುರಕ್ಷತಾ ಟೈಮರ್';

  @override
  String get tileHelplines => 'ಸಹಾಯವಾಣಿ';

  @override
  String get tileShareLocation => 'ಸ್ಥಳ ಹಂಚಿಕೆ';

  @override
  String get tileNearbyHelp => 'ಹತ್ತಿರದ ಸಹಾಯ';

  @override
  String get tileFakeCall => 'ನಕಲಿ ಕರೆ';

  @override
  String get tileFollowMe => 'ನನ್ನನ್ನು ಅನುಸರಿಸಿ';

  @override
  String get tileSafetyTips => 'ಸುರಕ್ಷತಾ ಸಲಹೆಗಳು';

  @override
  String get tileIncidentLog => 'ಘಟನೆ ಲಾಗ್';

  @override
  String get tileMedicalInfo => 'ವೈದ್ಯಕೀಯ ಮಾಹಿತಿ';

  @override
  String get tileContacts => 'ಸಂಪರ್ಕಗಳು';

  @override
  String get tileQuickContacts => 'ತ್ವರಿತ ಸಂಪರ್ಕಗಳು';

  @override
  String get tileBuddyCheckin => 'ಬಡ್ಡಿ ಚೆಕ್-ಇನ್';

  @override
  String get tileSafetyLog => 'ಸುರಕ್ಷತಾ ಲಾಗ್';

  @override
  String get tileEmergencyId => 'ತುರ್ತು ID';

  @override
  String get tilePoliceSos => 'ಪೊಲೀಸ್ SOS';

  @override
  String get tileWhatToDo => 'ಏನು ಮಾಡಬೇಕು';

  @override
  String get tileIndiaHelp => 'ಭಾರತ ಸಹಾಯ';

  @override
  String get tileJourneySafe => 'ಸುರಕ್ಷಿತ ಪ್ರಯಾಣ';

  @override
  String get tileQrCard => 'QR ಕಾರ್ಡ್';

  @override
  String get tileLocationPing => 'ಸ್ಥಳ ಪಿಂಗ್';

  @override
  String get tileDangerZones => 'ಅಪಾಯ ವಲಯಗಳು';

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
    return '$count ತುರ್ತು ಸಂಪರ್ಕಗಳು ಉಳಿಸಲಾಗಿದೆ.';
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
