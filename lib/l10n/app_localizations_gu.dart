// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'સેટિંગ્સ';

  @override
  String get language => 'ભાષા';

  @override
  String get languageSubtitle => 'તમારી પસંદગીની ભાષા પસંદ કરો';

  @override
  String get fakeCallTitle => 'નકલી કૉલ';

  @override
  String get fakeCallHeader =>
      'અસુરક્ષિત પરિસ્થિતિમાંથી બહાર નીકળવામાં મદદ માટે એક નકલી આવનારો કૉલ બનાવો. આ કૉલ વાસ્તવિક લાગે છે અને ત્યાંથી દૂર જવાનું કારણ આપે છે.';

  @override
  String get chooseScenario => 'પરિસ્થિતિ પસંદ કરો';

  @override
  String get chooseCaller => 'કૉલ કરનાર પસંદ કરો';

  @override
  String get phoneNumberOptional => 'ફોન નંબર (વૈકલ્પિક)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'વાસ્તવિકતા માટે નકલી કૉલ સ્ક્રીન પર બતાવાય છે';

  @override
  String get whatToSay => 'શું કહેવું (જો તેઓ ઉપાડે)';

  @override
  String get whatToSayHint => 'દા.ત. હું એક મહત્વના કૉલ પર છું, થોડી વાર આપો.';

  @override
  String get whatToSayHelper => 'ભૂલથી કૉલ ઉપાડાય તો કહેવા માટે ટૂંકો સંદેશ';

  @override
  String get callDelay => 'કૉલ વિલંબ';

  @override
  String get quickPresets => 'ઝડપી પ્રીસેટ';

  @override
  String get orCustomTime => 'અથવા કસ્ટમ સમય દાખલ કરો';

  @override
  String get hours => 'કલાક';

  @override
  String get minutes => 'મિનિટ';

  @override
  String get seconds => 'સેકન્ડ';

  @override
  String get advancedOptions => 'અદ્યતન વિકલ્પો';

  @override
  String get repeatCall => 'કૉલ ફરી કરો';

  @override
  String get repeatCallSubtitle => 'તમે નકારશો તો કૉલ વાગતો રહેશે';

  @override
  String get autoEndCall => 'આપમેળે કૉલ સમાપ્ત કરો';

  @override
  String get autoEndCallSubtitle => 'નક્કી સમય પછી કૉલ આપમેળે સમાપ્ત થાય છે';

  @override
  String get endAfter => 'આ પછી સમાપ્ત કરો:';

  @override
  String get ringSound => 'રિંગ અવાજ';

  @override
  String get ringSoundPhone => 'ફોન રિંગ';

  @override
  String get ringSoundSiren => 'પોલીસ સાયરન';

  @override
  String get startFakeCall => 'નકલી કૉલ શરૂ કરો';

  @override
  String get now => 'હમણાં';

  @override
  String callInCountdown(int seconds) {
    return '$seconds માં કૉલ';
  }

  @override
  String get keepScreenOpen =>
      'આ સ્ક્રીન ખુલ્લી રાખો. ટાઈમર પૂરો થતાં નકલી કૉલ દેખાશે. તમે ફોન કાન પાસે રાખી શકો છો.';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'The call will ring in $time, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.';
  }

  @override
  String get cancel => 'રદ કરો';

  @override
  String get incomingCall => 'આવનારો કૉલ…';

  @override
  String get callEnded => 'કૉલ સમાપ્ત';

  @override
  String get decline => 'નકારો';

  @override
  String get accept => 'સ્વીકારો';

  @override
  String get close => 'બંધ કરો';

  @override
  String get callWillRepeat => 'નકારશો તો કૉલ ફરી આવશે';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds સેકન્ડમાં આપમેળે સમાપ્ત';
  }

  @override
  String get mute => 'મ્યૂટ';

  @override
  String get speaker => 'સ્પીકર';

  @override
  String get keypad => 'કીપૅડ';

  @override
  String get endCall => 'કૉલ સમાપ્ત કરો';

  @override
  String secondsShort(int count) {
    return '$count સેકન્ડ';
  }

  @override
  String minutesShort(int count) {
    return '$count મિનિટ';
  }

  @override
  String hoursShort(int count) {
    return '$count કલાક';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursક $minutesમિ';
  }

  @override
  String get homeNoContacts => 'શરૂ કરવા માટે કટોકટી સંપર્કો ઉમેરો.';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'તમારું સ્થાન મોકલવા SOS દબાવો.';

  @override
  String get tileSiren => 'સાયરન';

  @override
  String get tileStopSiren => 'સાયરન બંધ';

  @override
  String get tilePoliceSiren => 'પોલીસ સાયરન';

  @override
  String get tileStopPolice => 'પોલીસ બંધ';

  @override
  String get tileFlashlight => 'ટોર્ચ';

  @override
  String get tileStopLight => 'લાઇટ બંધ';

  @override
  String get tileSosBlink => 'SOS બ્લિંક';

  @override
  String get tileStopBlink => 'બ્લિંક બંધ';

  @override
  String get tileRecord => 'રેકોર્ડ';

  @override
  String get tileStopRec => 'રેકોર્ડ બંધ';

  @override
  String get tileImSafe => 'હું સુરક્ષિત છું';

  @override
  String get tileSafetyTimer => 'સલામતી ટાઈમર';

  @override
  String get tileHelplines => 'હેલ્પલાઇન';

  @override
  String get tileShareLocation => 'સ્થાન શેર';

  @override
  String get tileNearbyHelp => 'નજીકની મદદ';

  @override
  String get tileFakeCall => 'નકલી કૉલ';

  @override
  String get tileFollowMe => 'મને ફોલો કરો';

  @override
  String get tileSafetyTips => 'સલામતી ટિપ્સ';

  @override
  String get tileIncidentLog => 'ઘટના લોગ';

  @override
  String get tileMedicalInfo => 'તબીબી માહિતી';

  @override
  String get tileContacts => 'સંપર્કો';

  @override
  String get tileQuickContacts => 'ઝડપી સંપર્કો';

  @override
  String get tileBuddyCheckin => 'બડી ચેક-ઇન';

  @override
  String get tileSafetyLog => 'સલામતી લોગ';

  @override
  String get tileEmergencyId => 'ઇમરજન્સી ID';

  @override
  String get tilePoliceSos => 'પોલીસ SOS';

  @override
  String get tileWhatToDo => 'શું કરવું';

  @override
  String get tileIndiaHelp => 'ભારત મદદ';

  @override
  String get tileJourneySafe => 'સલામત મુસાફરી';

  @override
  String get tileQrCard => 'QR કાર્ડ';

  @override
  String get tileLocationPing => 'લોકેશન પિંગ';

  @override
  String get tileDangerZones => 'જોખમ વિસ્તારો';

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
    return '$count કટોકટી સંપર્કો સાચવ્યા.';
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
