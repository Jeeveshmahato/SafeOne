import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SafeOne'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageSubtitle;

  /// No description provided for @fakeCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Fake Call'**
  String get fakeCallTitle;

  /// No description provided for @fakeCallHeader.
  ///
  /// In en, this message translates to:
  /// **'Create a fake incoming call to help you leave an unsafe situation. The call looks realistic and gives you a reason to step away.'**
  String get fakeCallHeader;

  /// No description provided for @chooseScenario.
  ///
  /// In en, this message translates to:
  /// **'Choose a Scenario'**
  String get chooseScenario;

  /// No description provided for @chooseCaller.
  ///
  /// In en, this message translates to:
  /// **'Choose a Caller'**
  String get chooseCaller;

  /// No description provided for @phoneNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get phoneNumberOptional;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +91 98765 43210'**
  String get phoneHint;

  /// No description provided for @phoneHelper.
  ///
  /// In en, this message translates to:
  /// **'Shows on the fake call screen for realism'**
  String get phoneHelper;

  /// No description provided for @whatToSay.
  ///
  /// In en, this message translates to:
  /// **'What to Say (If They Pick Up)'**
  String get whatToSay;

  /// No description provided for @whatToSayHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. I\'m on an important call, give me a moment.'**
  String get whatToSayHint;

  /// No description provided for @whatToSayHelper.
  ///
  /// In en, this message translates to:
  /// **'Quick message to say if caller picks up by accident'**
  String get whatToSayHelper;

  /// No description provided for @callDelay.
  ///
  /// In en, this message translates to:
  /// **'Call Delay'**
  String get callDelay;

  /// No description provided for @quickPresets.
  ///
  /// In en, this message translates to:
  /// **'Quick Presets'**
  String get quickPresets;

  /// No description provided for @orCustomTime.
  ///
  /// In en, this message translates to:
  /// **'Or Enter Custom Time'**
  String get orCustomTime;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @advancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get advancedOptions;

  /// No description provided for @repeatCall.
  ///
  /// In en, this message translates to:
  /// **'Repeat Call'**
  String get repeatCall;

  /// No description provided for @repeatCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Call keeps \"ringing\" if you decline it'**
  String get repeatCallSubtitle;

  /// No description provided for @autoEndCall.
  ///
  /// In en, this message translates to:
  /// **'Auto-End Call'**
  String get autoEndCall;

  /// No description provided for @autoEndCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Call ends automatically after a set time'**
  String get autoEndCallSubtitle;

  /// No description provided for @endAfter.
  ///
  /// In en, this message translates to:
  /// **'End after:'**
  String get endAfter;

  /// No description provided for @ringSound.
  ///
  /// In en, this message translates to:
  /// **'Ring Sound'**
  String get ringSound;

  /// No description provided for @ringSoundPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone ring'**
  String get ringSoundPhone;

  /// No description provided for @ringSoundSiren.
  ///
  /// In en, this message translates to:
  /// **'Police siren'**
  String get ringSoundSiren;

  /// No description provided for @startFakeCall.
  ///
  /// In en, this message translates to:
  /// **'Start Fake Call'**
  String get startFakeCall;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @callInCountdown.
  ///
  /// In en, this message translates to:
  /// **'Call in {seconds}'**
  String callInCountdown(int seconds);

  /// No description provided for @keepScreenOpen.
  ///
  /// In en, this message translates to:
  /// **'Keep this screen open. The fake call will appear when the timer ends. You can put the phone to your ear.'**
  String get keepScreenOpen;

  /// No description provided for @fakeCallScheduledTitle.
  ///
  /// In en, this message translates to:
  /// **'Call scheduled'**
  String get fakeCallScheduledTitle;

  /// No description provided for @fakeCallScheduledHint.
  ///
  /// In en, this message translates to:
  /// **'The call will ring in {time}, even if you lock your phone or close the app. Grant the notification and full-screen permissions if asked.'**
  String fakeCallScheduledHint(String time);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @incomingCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming call…'**
  String get incomingCall;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call Ended'**
  String get callEnded;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @callWillRepeat.
  ///
  /// In en, this message translates to:
  /// **'Call will repeat if declined'**
  String get callWillRepeat;

  /// No description provided for @autoEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Auto-ends in {seconds}s'**
  String autoEndsIn(int seconds);

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @keypad.
  ///
  /// In en, this message translates to:
  /// **'Keypad'**
  String get keypad;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get endCall;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} sec'**
  String secondsShort(int count);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String hoursShort(int count);

  /// No description provided for @hoursMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String hoursMinutesShort(int hours, int minutes);

  /// No description provided for @homeNoContacts.
  ///
  /// In en, this message translates to:
  /// **'Add emergency contacts to get started.'**
  String get homeNoContacts;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @homeSosHint.
  ///
  /// In en, this message translates to:
  /// **'Tap SOS to send your location to your contacts.'**
  String get homeSosHint;

  /// No description provided for @tileSiren.
  ///
  /// In en, this message translates to:
  /// **'Siren'**
  String get tileSiren;

  /// No description provided for @tileStopSiren.
  ///
  /// In en, this message translates to:
  /// **'Stop siren'**
  String get tileStopSiren;

  /// No description provided for @tilePoliceSiren.
  ///
  /// In en, this message translates to:
  /// **'Police siren'**
  String get tilePoliceSiren;

  /// No description provided for @tileStopPolice.
  ///
  /// In en, this message translates to:
  /// **'Stop police'**
  String get tileStopPolice;

  /// No description provided for @tileFlashlight.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get tileFlashlight;

  /// No description provided for @tileStopLight.
  ///
  /// In en, this message translates to:
  /// **'Stop light'**
  String get tileStopLight;

  /// No description provided for @tileSosBlink.
  ///
  /// In en, this message translates to:
  /// **'SOS blink'**
  String get tileSosBlink;

  /// No description provided for @tileStopBlink.
  ///
  /// In en, this message translates to:
  /// **'Stop blink'**
  String get tileStopBlink;

  /// No description provided for @tileRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get tileRecord;

  /// No description provided for @tileStopRec.
  ///
  /// In en, this message translates to:
  /// **'Stop rec'**
  String get tileStopRec;

  /// No description provided for @tileImSafe.
  ///
  /// In en, this message translates to:
  /// **'I\'m safe'**
  String get tileImSafe;

  /// No description provided for @tileSafetyTimer.
  ///
  /// In en, this message translates to:
  /// **'Safety timer'**
  String get tileSafetyTimer;

  /// No description provided for @tileHelplines.
  ///
  /// In en, this message translates to:
  /// **'Helplines'**
  String get tileHelplines;

  /// No description provided for @tileShareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share location'**
  String get tileShareLocation;

  /// No description provided for @tileNearbyHelp.
  ///
  /// In en, this message translates to:
  /// **'Nearby help'**
  String get tileNearbyHelp;

  /// No description provided for @tileFakeCall.
  ///
  /// In en, this message translates to:
  /// **'Fake call'**
  String get tileFakeCall;

  /// No description provided for @tileFollowMe.
  ///
  /// In en, this message translates to:
  /// **'Follow Me'**
  String get tileFollowMe;

  /// No description provided for @tileSafetyTips.
  ///
  /// In en, this message translates to:
  /// **'Safety tips'**
  String get tileSafetyTips;

  /// No description provided for @tileIncidentLog.
  ///
  /// In en, this message translates to:
  /// **'Incident log'**
  String get tileIncidentLog;

  /// No description provided for @tileMedicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Medical info'**
  String get tileMedicalInfo;

  /// No description provided for @tileContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get tileContacts;

  /// No description provided for @tileQuickContacts.
  ///
  /// In en, this message translates to:
  /// **'Quick contacts'**
  String get tileQuickContacts;

  /// No description provided for @tileBuddyCheckin.
  ///
  /// In en, this message translates to:
  /// **'Buddy check-in'**
  String get tileBuddyCheckin;

  /// No description provided for @tileSafetyLog.
  ///
  /// In en, this message translates to:
  /// **'Safety log'**
  String get tileSafetyLog;

  /// No description provided for @tileEmergencyId.
  ///
  /// In en, this message translates to:
  /// **'Emergency ID'**
  String get tileEmergencyId;

  /// No description provided for @tilePoliceSos.
  ///
  /// In en, this message translates to:
  /// **'Police SOS'**
  String get tilePoliceSos;

  /// No description provided for @tileWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What To Do'**
  String get tileWhatToDo;

  /// No description provided for @tileIndiaHelp.
  ///
  /// In en, this message translates to:
  /// **'India Help'**
  String get tileIndiaHelp;

  /// No description provided for @tileJourneySafe.
  ///
  /// In en, this message translates to:
  /// **'Journey Safe'**
  String get tileJourneySafe;

  /// No description provided for @tileQrCard.
  ///
  /// In en, this message translates to:
  /// **'QR Card'**
  String get tileQrCard;

  /// No description provided for @tileLocationPing.
  ///
  /// In en, this message translates to:
  /// **'Location Ping'**
  String get tileLocationPing;

  /// No description provided for @tileDangerZones.
  ///
  /// In en, this message translates to:
  /// **'Danger Zones'**
  String get tileDangerZones;

  /// No description provided for @sectionGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get sectionGetHelp;

  /// No description provided for @sectionShareTrack.
  ///
  /// In en, this message translates to:
  /// **'Share & track'**
  String get sectionShareTrack;

  /// No description provided for @sectionMyInfo.
  ///
  /// In en, this message translates to:
  /// **'My info'**
  String get sectionMyInfo;

  /// No description provided for @sectionLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get sectionLearn;

  /// No description provided for @tileLiveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live tracking'**
  String get tileLiveTracking;

  /// No description provided for @tileEmergencyProfile.
  ///
  /// In en, this message translates to:
  /// **'Emergency profile'**
  String get tileEmergencyProfile;

  /// No description provided for @tileRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get tileRecords;

  /// No description provided for @tileSafetyCheckin.
  ///
  /// In en, this message translates to:
  /// **'Safety check-in'**
  String get tileSafetyCheckin;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @homeSilentSosHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press SOS to send silently (no sound or buzz).'**
  String get homeSilentSosHint;

  /// No description provided for @silentSosSent.
  ///
  /// In en, this message translates to:
  /// **'Silent alert sent to {count} contact(s).'**
  String silentSosSent(int count);

  /// No description provided for @sosLiveBannerActive.
  ///
  /// In en, this message translates to:
  /// **'Sharing your live location with contacts'**
  String get sosLiveBannerActive;

  /// No description provided for @sosLiveStop.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get sosLiveStop;

  /// No description provided for @sosLiveStarted.
  ///
  /// In en, this message translates to:
  /// **'Live location sharing started. Tap \"I\'m safe\" to stop.'**
  String get sosLiveStarted;

  /// No description provided for @sosLiveStopped.
  ///
  /// In en, this message translates to:
  /// **'Live location sharing stopped.'**
  String get sosLiveStopped;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get lockTitle;

  /// No description provided for @lockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to unlock'**
  String get lockSubtitle;

  /// No description provided for @lockWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Try again.'**
  String get lockWrongPin;

  /// No description provided for @lockTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait {seconds}s.'**
  String lockTooManyAttempts(int seconds);

  /// No description provided for @lockUseBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint / face'**
  String get lockUseBiometric;

  /// No description provided for @lockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Women Safety'**
  String get lockBiometricReason;

  /// No description provided for @pinSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get pinSetTitle;

  /// No description provided for @pinSetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This PIN protects your contacts, medical info and records.'**
  String get pinSetSubtitle;

  /// No description provided for @pinCreateStep.
  ///
  /// In en, this message translates to:
  /// **'Create a 6-digit PIN'**
  String get pinCreateStep;

  /// No description provided for @pinConfirmStep.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your PIN to confirm'**
  String get pinConfirmStep;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Start again.'**
  String get pinMismatch;

  /// No description provided for @pinTooShort.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 6 digits.'**
  String get pinTooShort;

  /// No description provided for @pinSaved.
  ///
  /// In en, this message translates to:
  /// **'PIN saved.'**
  String get pinSaved;

  /// No description provided for @pinChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get pinChangeTitle;

  /// No description provided for @pinCurrentStep.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get pinCurrentStep;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @securityChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get securityChangePin;

  /// No description provided for @securityBiometric.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint / face'**
  String get securityBiometric;

  /// No description provided for @securityBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics instead of typing the PIN.'**
  String get securityBiometricSubtitle;

  /// No description provided for @securityAutoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get securityAutoLock;

  /// No description provided for @securityAutoLockImmediate.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get securityAutoLockImmediate;

  /// No description provided for @securityAutoLockGrace.
  ///
  /// In en, this message translates to:
  /// **'After {seconds}s in background'**
  String securityAutoLockGrace(int seconds);

  /// No description provided for @securitySilentSos.
  ///
  /// In en, this message translates to:
  /// **'Silent SOS'**
  String get securitySilentSos;

  /// No description provided for @securitySilentSosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No vibration confirmation when sending SOS.'**
  String get securitySilentSosSubtitle;

  /// No description provided for @securityLiveUpdates.
  ///
  /// In en, this message translates to:
  /// **'Repeat location after SOS'**
  String get securityLiveUpdates;

  /// No description provided for @securityLiveUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep sending your location to contacts until you tap \"I\'m safe\".'**
  String get securityLiveUpdatesSubtitle;

  /// No description provided for @securityVolumeTrigger.
  ///
  /// In en, this message translates to:
  /// **'Triple-press volume to send SOS'**
  String get securityVolumeTrigger;

  /// No description provided for @securityVolumeTriggerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Press a volume button 3 times quickly to start the SOS.'**
  String get securityVolumeTriggerSubtitle;

  /// No description provided for @checkinScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-alert if I don\'t check in'**
  String get checkinScheduleTitle;

  /// No description provided for @checkinScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t tap \"I\'m safe\" before the deadline, your contacts are alerted automatically.'**
  String get checkinScheduleSubtitle;

  /// No description provided for @checkinSetDeadline.
  ///
  /// In en, this message translates to:
  /// **'Alert my contacts in'**
  String get checkinSetDeadline;

  /// No description provided for @checkinActive.
  ///
  /// In en, this message translates to:
  /// **'Active — alert at {time}'**
  String checkinActive(String time);

  /// No description provided for @checkinStart.
  ///
  /// In en, this message translates to:
  /// **'Start check-in'**
  String get checkinStart;

  /// No description provided for @checkinImSafe.
  ///
  /// In en, this message translates to:
  /// **'I\'m safe — cancel'**
  String get checkinImSafe;

  /// No description provided for @checkinCancelled.
  ///
  /// In en, this message translates to:
  /// **'Check-in cancelled.'**
  String get checkinCancelled;

  /// No description provided for @checkinFired.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t check in. Alerting your contacts.'**
  String get checkinFired;

  /// No description provided for @checkinReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety check-in due'**
  String get checkinReminderTitle;

  /// No description provided for @checkinReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Tap \"I\'m safe\" or your contacts will be alerted.'**
  String get checkinReminderBody;

  /// No description provided for @tabFollowMe.
  ///
  /// In en, this message translates to:
  /// **'Follow me'**
  String get tabFollowMe;

  /// No description provided for @tabJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get tabJourney;

  /// No description provided for @tabBuddy.
  ///
  /// In en, this message translates to:
  /// **'Buddy'**
  String get tabBuddy;

  /// No description provided for @tabPing.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get tabPing;

  /// No description provided for @tabEmergencyId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get tabEmergencyId;

  /// No description provided for @tabMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get tabMedical;

  /// No description provided for @tabQr.
  ///
  /// In en, this message translates to:
  /// **'QR card'**
  String get tabQr;

  /// No description provided for @tabIncidents.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get tabIncidents;

  /// No description provided for @tabSafetyLog.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabSafetyLog;

  /// No description provided for @tabHelplines.
  ///
  /// In en, this message translates to:
  /// **'Helplines'**
  String get tabHelplines;

  /// No description provided for @tabIndia.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get tabIndia;

  /// No description provided for @tabPolice.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get tabPolice;

  /// No description provided for @tabTips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tabTips;

  /// No description provided for @tabWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get tabWhatToDo;

  /// No description provided for @tabAllContacts.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAllContacts;

  /// No description provided for @tabQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get tabQuick;

  /// No description provided for @homeContactsSaved.
  ///
  /// In en, this message translates to:
  /// **'{count} emergency contact(s) saved.'**
  String homeContactsSaved(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'as',
    'bn',
    'en',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'or',
    'pa',
    'ta',
    'te',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
