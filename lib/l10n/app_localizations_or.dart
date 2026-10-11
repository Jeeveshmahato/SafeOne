// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get appTitle => 'SafeOne';

  @override
  String get settingsTitle => 'ସେଟିଂସ୍';

  @override
  String get language => 'ଭାଷା';

  @override
  String get languageSubtitle => 'ଆପଣଙ୍କ ପସନ୍ଦର ଭାଷା ବାଛନ୍ତୁ';

  @override
  String get fakeCallTitle => 'ନକଲି କଲ୍';

  @override
  String get fakeCallHeader =>
      'ଅସୁରକ୍ଷିତ ପରିସ୍ଥିତିରୁ ବାହାରିବାରେ ସାହାଯ୍ୟ ପାଇଁ ଏକ ନକଲି ଆସୁଥିବା କଲ୍ ତିଆରି କରନ୍ତୁ। ଏହି କଲ୍ ବାସ୍ତବ ଭଳି ଦେଖାଯାଏ ଏବଂ ସେଠାରୁ ଯିବାର କାରଣ ଦିଏ।';

  @override
  String get chooseScenario => 'ପରିସ୍ଥିତି ବାଛନ୍ତୁ';

  @override
  String get chooseCaller => 'କଲ୍ କରୁଥିବା ବ୍ୟକ୍ତି ବାଛନ୍ତୁ';

  @override
  String get phoneNumberOptional => 'ଫୋନ୍ ନମ୍ବର (ବୈକଳ୍ପିକ)';

  @override
  String get phoneHint => 'e.g. +91 98765 43210';

  @override
  String get phoneHelper => 'ବାସ୍ତବତା ପାଇଁ ନକଲି କଲ୍ ସ୍କ୍ରିନରେ ଦେଖାଯାଏ';

  @override
  String get whatToSay => 'କଣ କହିବେ (ଯଦି ସେମାନେ ଉଠାନ୍ତି)';

  @override
  String get whatToSayHint =>
      'ଯଥା ମୁଁ ଏକ ଗୁରୁତ୍ୱପୂର୍ଣ୍ଣ କଲରେ ଅଛି, ଟିକିଏ ସମୟ ଦିଅନ୍ତୁ।';

  @override
  String get whatToSayHelper => 'ଭୁଲରେ କଲ୍ ଉଠିଲେ କହିବା ପାଇଁ ଛୋଟ ବାର୍ତ୍ତା';

  @override
  String get callDelay => 'କଲ୍ ବିଳମ୍ବ';

  @override
  String get quickPresets => 'ଶୀଘ୍ର ପ୍ରିସେଟ୍';

  @override
  String get orCustomTime => 'କିମ୍ବା କଷ୍ଟମ୍ ସମୟ ଦିଅନ୍ତୁ';

  @override
  String get hours => 'ଘଣ୍ଟା';

  @override
  String get minutes => 'ମିନିଟ୍';

  @override
  String get seconds => 'ସେକେଣ୍ଡ';

  @override
  String get advancedOptions => 'ଉନ୍ନତ ବିକଳ୍ପ';

  @override
  String get repeatCall => 'କଲ୍ ପୁନରାବୃତ୍ତି କରନ୍ତୁ';

  @override
  String get repeatCallSubtitle => 'ଆପଣ ପ୍ରତ୍ୟାଖ୍ୟାନ କଲେ କଲ୍ ବାଜୁଥିବ';

  @override
  String get autoEndCall => 'ସ୍ୱୟଂଚାଳିତ ଭାବେ କଲ୍ ସମାପ୍ତ କରନ୍ତୁ';

  @override
  String get autoEndCallSubtitle =>
      'ନିର୍ଦ୍ଧାରିତ ସମୟ ପରେ କଲ୍ ସ୍ୱୟଂଚାଳିତ ଭାବେ ସମାପ୍ତ ହୁଏ';

  @override
  String get endAfter => 'ଏହା ପରେ ସମାପ୍ତ କରନ୍ତୁ:';

  @override
  String get ringSound => 'ରିଙ୍ଗ ଶବ୍ଦ';

  @override
  String get ringSoundPhone => 'ଫୋନ୍ ରିଙ୍ଗ';

  @override
  String get ringSoundSiren => 'ପୋଲିସ୍ ସାଇରେନ୍';

  @override
  String get startFakeCall => 'ନକଲି କଲ୍ ଆରମ୍ଭ କରନ୍ତୁ';

  @override
  String get now => 'ବର୍ତ୍ତମାନ';

  @override
  String callInCountdown(int seconds) {
    return '$seconds ରେ କଲ୍';
  }

  @override
  String get keepScreenOpen =>
      'ଏହି ସ୍କ୍ରିନକୁ ଖୋଲା ରଖନ୍ତୁ। ଟାଇମର୍ ସମାପ୍ତ ହେଲେ ନକଲି କଲ୍ ଦେଖାଯିବ। ଆପଣ ଫୋନକୁ କାନ ପାଖରେ ରଖିପାରିବେ।';

  @override
  String get fakeCallScheduledTitle => 'Call scheduled';

  @override
  String fakeCallScheduledHint(String time) {
    return 'Your phone will ring in $time, even if it\'s locked or the app is closed. If asked, allow notifications and full-screen alerts.';
  }

  @override
  String get cancel => 'ବାତିଲ୍ କରନ୍ତୁ';

  @override
  String get incomingCall => 'ଆସୁଥିବା କଲ୍…';

  @override
  String get callEnded => 'କଲ୍ ସମାପ୍ତ';

  @override
  String get decline => 'ପ୍ରତ୍ୟାଖ୍ୟାନ କରନ୍ତୁ';

  @override
  String get accept => 'ଗ୍ରହଣ କରନ୍ତୁ';

  @override
  String get close => 'ବନ୍ଦ କରନ୍ତୁ';

  @override
  String get callWillRepeat => 'ପ୍ରତ୍ୟାଖ୍ୟାନ କଲେ କଲ୍ ପୁନରାବୃତ୍ତି ହେବ';

  @override
  String autoEndsIn(int seconds) {
    return '$seconds ସେକେଣ୍ଡରେ ସ୍ୱୟଂଚାଳିତ ଭାବେ ସମାପ୍ତ';
  }

  @override
  String get mute => 'ମ୍ୟୁଟ୍';

  @override
  String get speaker => 'ସ୍ପିକର୍';

  @override
  String get keypad => 'କୀପ୍ୟାଡ୍';

  @override
  String get endCall => 'କଲ୍ ସମାପ୍ତ କରନ୍ତୁ';

  @override
  String secondsShort(int count) {
    return '$count ସେକେଣ୍ଡ';
  }

  @override
  String minutesShort(int count) {
    return '$count ମିନିଟ୍';
  }

  @override
  String hoursShort(int count) {
    return '$count ଘଣ୍ଟା';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hoursଘ $minutesମି';
  }

  @override
  String get homeNoContacts => 'ଆରମ୍ଭ କରିବାକୁ ଜରୁରୀ ଯୋଗାଯୋଗ ଯୋଡନ୍ତୁ।';

  @override
  String get sos => 'SOS';

  @override
  String get homeSosHint => 'ଆପଣଙ୍କ ଅବସ୍ଥାନ ପଠାଇବାକୁ SOS ଦବାନ୍ତୁ।';

  @override
  String get tileSiren => 'ସାଇରେନ୍';

  @override
  String get tileStopSiren => 'ସାଇରେନ୍ ବନ୍ଦ';

  @override
  String get tilePoliceSiren => 'ପୋଲିସ୍ ସାଇରେନ୍';

  @override
  String get tileStopPolice => 'ପୋଲିସ୍ ବନ୍ଦ';

  @override
  String get tileFlashlight => 'ଟର୍ଚ୍';

  @override
  String get tileStopLight => 'ଲାଇଟ୍ ବନ୍ଦ';

  @override
  String get tileSosBlink => 'SOS ବ୍ଲିଙ୍କ';

  @override
  String get tileStopBlink => 'ବ୍ଲିଙ୍କ ବନ୍ଦ';

  @override
  String get tileRecord => 'ରେକର୍ଡ';

  @override
  String get tileStopRec => 'ରେକର୍ଡ ବନ୍ଦ';

  @override
  String get tileImSafe => 'ମୁଁ ସୁରକ୍ଷିତ';

  @override
  String get tileSafetyTimer => 'ସୁରକ୍ଷା ଟାଇମର୍';

  @override
  String get tileHelplines => 'ହେଲ୍ପଲାଇନ୍';

  @override
  String get tileShareLocation => 'ଅବସ୍ଥାନ ସେୟାର୍';

  @override
  String get tileNearbyHelp => 'ନିକଟସ୍ଥ ସାହାଯ୍ୟ';

  @override
  String get tileFakeCall => 'ନକଲି କଲ୍';

  @override
  String get tileFollowMe => 'ମୋତେ ଅନୁସରଣ କରନ୍ତୁ';

  @override
  String get tileSafetyTips => 'ସୁରକ୍ଷା ଟିପ୍ସ';

  @override
  String get tileIncidentLog => 'ଘଟଣା ଲଗ୍';

  @override
  String get tileMedicalInfo => 'ଚିକିତ୍ସା ସୂଚନା';

  @override
  String get tileContacts => 'ଯୋଗାଯୋଗ';

  @override
  String get tileQuickContacts => 'ଶୀଘ୍ର ଯୋଗାଯୋଗ';

  @override
  String get tileBuddyCheckin => 'ବଡି ଚେକ୍-ଇନ୍';

  @override
  String get tileSafetyLog => 'ସୁରକ୍ଷା ଲଗ୍';

  @override
  String get tileEmergencyId => 'ଜରୁରୀ ID';

  @override
  String get tilePoliceSos => 'ପୋଲିସ୍ SOS';

  @override
  String get tileWhatToDo => 'କଣ କରିବେ';

  @override
  String get tileIndiaHelp => 'ଭାରତ ସାହାଯ୍ୟ';

  @override
  String get tileJourneySafe => 'ସୁରକ୍ଷିତ ଯାତ୍ରା';

  @override
  String get tileQrCard => 'QR କାର୍ଡ';

  @override
  String get tileLocationPing => 'ଲୋକେସନ୍ ପିଙ୍ଗ';

  @override
  String get tileDangerZones => 'ବିପଦ ଅଞ୍ଚଳ';

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
    return '$countଟି ଜରୁରୀ ଯୋଗାଯୋଗ ସଞ୍ଚିତ।';
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
