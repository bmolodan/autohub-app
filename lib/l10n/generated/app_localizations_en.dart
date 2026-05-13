// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AUTOHUB';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navCars => 'Cars';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonNext => 'Next';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonRequiredField => 'Required field';

  @override
  String get commonNumbersOnly => 'Numbers only';

  @override
  String get stateOfflineTitle => 'No connection';

  @override
  String get stateOfflineSubtitle =>
      'Check your internet connection and we\'ll try again.';

  @override
  String get stateRetry => 'Try again';

  @override
  String get stateWorkOffline => 'Work offline';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingTitle => 'Book a service\nin a minute';

  @override
  String get onboardingSubtitle =>
      'Pick a service, date and time. No calls, no queues — everything in the app.';

  @override
  String get phoneBrandTagline => 'VETERAN AUTO HUB';

  @override
  String get phoneGreeting => 'Welcome to\nautohub';

  @override
  String get phoneInstruction =>
      'Enter your phone number — we\'ll send an SMS code';

  @override
  String get phoneHint => '67 123 45 67';

  @override
  String get phoneConsent =>
      'I agree to the processing of personal data and terms of use';

  @override
  String get phoneSubmit => 'Send code';

  @override
  String get phoneDevHint => 'DEV · tap to fill the test number · code 0000';

  @override
  String get otpTitle => 'Enter the code\nfrom SMS';

  @override
  String get otpSubmit => 'Confirm';

  @override
  String otpResendIn(String seconds) {
    return 'Resend in 0:$seconds';
  }

  @override
  String get otpResendNow => 'Resend';

  @override
  String get homeGreetingPrefix => 'Hi,';

  @override
  String get homeUserName => 'Bohdan';

  @override
  String get homeNotificationsHint => 'Notifications';

  @override
  String get homeDesignTokensHint => 'Design tokens (dev)';

  @override
  String get homeDesignTokensSemantics => 'Design tokens (dev)';

  @override
  String get homeEmptyTitle => 'All quiet';

  @override
  String get homeEmptySubtitle =>
      'No active orders. Book a service — we\'ll take care of it.';

  @override
  String get homeEmptyCta => '+ Book a service';

  @override
  String get homeBookingCta => '+ Book';

  @override
  String get bookingStep1Title => 'Booking · step 1 of 3';

  @override
  String get bookingPickerHeading => 'What do you need?';

  @override
  String get bookingPickerSearchHint => 'Search service';

  @override
  String bookingServiceDurationAndPrice(int minutes, int price) {
    return '~$minutes min  ·  from $price ₴';
  }

  @override
  String get bookingStep3Title => 'Booking · step 3 of 3';

  @override
  String get problemHeading => 'What happened?';

  @override
  String get problemSubtitle => 'Describe the problem';

  @override
  String get problemHint =>
      'Knocking in the front suspension on bumps. Appears after warm-up…';

  @override
  String problemPhotosCount(int count, int max) {
    return 'Photos ($count / $max)';
  }

  @override
  String get problemSummaryService => 'Service';

  @override
  String get problemSummaryVehicle => 'Car';

  @override
  String get problemSummaryEstimate => 'Estimate';

  @override
  String problemEstimateFrom(int price) {
    return 'from $price ₴';
  }

  @override
  String get problemSubmit => 'Confirm booking';

  @override
  String get problemNoVehicleSnack => 'Add a car first';

  @override
  String get photoSourceCamera => 'Camera';

  @override
  String get photoSourceGallery => 'Gallery';

  @override
  String get photoAddSemantics => 'Add photo';

  @override
  String get photoRemoveSemantics => 'Remove photo';

  @override
  String photoAddError(String error) {
    return 'Could not add photo: $error';
  }

  @override
  String get orderNotFoundTitle => 'Order not found';

  @override
  String get orderNotFoundSubtitle => 'It may have been deleted.';

  @override
  String get orderTimelineHeading => 'PROGRESS';

  @override
  String get orderJournalHeading => 'LOG';

  @override
  String get orderEstimate => 'Estimate';

  @override
  String orderEstimateValue(int price) {
    return '$price ₴';
  }

  @override
  String orderEstimateValueFrom(int price) {
    return 'from $price ₴';
  }

  @override
  String get orderPendingHeroLabel => 'AWAITING CONFIRMATION';

  @override
  String get orderCanceledHeroLabel => 'CANCELED';

  @override
  String get orderScheduledTime => 'Scheduled time';

  @override
  String get orderScheduledTbd => 'to be determined';

  @override
  String get orderCallMaster => 'Call mechanic';

  @override
  String get orderCallMasterTodo => 'Call mechanic: TODO';

  @override
  String get orderCancelLabel => 'Cancel order';

  @override
  String get orderCancelDialogTitle => 'Cancel order?';

  @override
  String get orderCancelDialogBody => 'This action cannot be undone.';

  @override
  String get orderCancelDialogConfirm => 'Yes, cancel';

  @override
  String orderCancelError(String error) {
    return 'Could not cancel: $error';
  }

  @override
  String get orderTimelineEmpty => 'No events yet';

  @override
  String get carsListTitle => 'My cars';

  @override
  String get carsAddCta => 'Add a car';

  @override
  String get carDetailNextService => 'Next service';

  @override
  String carDetailDueIn(int km) {
    return 'in $km km';
  }

  @override
  String get carDetailOverdue => 'overdue';

  @override
  String get carDetailMileage => 'Mileage';

  @override
  String carDetailMileageValue(int km) {
    return '$km km';
  }

  @override
  String get carDetailVin => 'VIN';

  @override
  String get carDetailBook => 'Book a repair';

  @override
  String get carDetailBookTodo => 'Booking: TODO';

  @override
  String get carDetailNotFound => 'Car not found';

  @override
  String get addCarHeading => 'Tell us about your car';

  @override
  String get addCarSubtitle => 'Fill in the VIN — the rest auto-fills';

  @override
  String get addCarFieldVin => 'VIN (optional)';

  @override
  String get addCarFieldMake => 'Make';

  @override
  String get addCarFieldModel => 'Model';

  @override
  String get addCarFieldYear => 'Year';

  @override
  String get addCarFieldPlate => 'Plate';

  @override
  String addCarYearRange(int max) {
    return '1900–$max';
  }

  @override
  String get addCarSave => 'Save car';

  @override
  String get historyTitle => 'History';

  @override
  String get historyTotalLabel => 'Total spent';

  @override
  String get historyEmptyTitle => 'History is empty';

  @override
  String get historyEmptySubtitle =>
      'Completed work will appear here after your first visit.';

  @override
  String get monthJanuary => 'JANUARY';

  @override
  String get monthFebruary => 'FEBRUARY';

  @override
  String get monthMarch => 'MARCH';

  @override
  String get monthApril => 'APRIL';

  @override
  String get monthMay => 'MAY';

  @override
  String get monthJune => 'JUNE';

  @override
  String get monthJuly => 'JULY';

  @override
  String get monthAugust => 'AUGUST';

  @override
  String get monthSeptember => 'SEPTEMBER';

  @override
  String get monthOctober => 'OCTOBER';

  @override
  String get monthNovember => 'NOVEMBER';

  @override
  String get monthDecember => 'DECEMBER';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileMyCars => 'MY CARS';

  @override
  String profileTOLeftPill(int km) {
    return 'Service in $km km';
  }

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageBadge => 'EN';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String profileAvatarSemantics(String name) {
    return 'Avatar of $name';
  }

  @override
  String get profileLanguageTodo => 'Language switcher: TODO';

  @override
  String get profileSupportTodo => 'Support contacts: TODO';

  @override
  String get notificationsHeading => 'What to send?';

  @override
  String get notifyStatusTitle => 'Status changes';

  @override
  String get notifyStatusSubtitle => 'Accepted · diagnostics · ready';

  @override
  String get notifyTOTitle => 'Service reminders';

  @override
  String get notifyTOSubtitle => '30 days before scheduled visit';

  @override
  String get notifyMasterTitle => 'Mechanic messages';

  @override
  String get notifyMasterSubtitle => 'Clarifications during work';

  @override
  String get notifyPromosTitle => 'Promos and news';

  @override
  String get notifyPromosSubtitle => 'Seasonal offers';

  @override
  String get notifyQuietTitle => 'Quiet hours';

  @override
  String get notifyQuietSubtitle => '22:00 — 8:00';

  @override
  String get accountDeleteTitle => 'Account deletion';

  @override
  String get accountDeleteHeading => 'Delete account?';

  @override
  String get accountDeleteBody =>
      'This action is irreversible. Here\'s what will be deleted:';

  @override
  String get accountDeleteItemProfile => 'Profile and cars';

  @override
  String get accountDeleteItemHistory => 'Service history';

  @override
  String get accountDeleteItemPush => 'Push notifications';

  @override
  String get accountDeleteLegalNote =>
      'Active orders are retained by the STO for accounting — per applicable law.';

  @override
  String get accountDeleteConfirm => 'Yes, delete';

  @override
  String get accountDeleteSuccessSnack => 'Account deleted (stub)';

  @override
  String get serviceOilChange => 'Oil change';

  @override
  String get serviceTires => 'Tire service';

  @override
  String get serviceDiagnostics => 'Engine diagnostics';

  @override
  String get serviceBrakes => 'Brake system';

  @override
  String get serviceAc => 'Air conditioning';

  @override
  String get orderStatusInProgress => 'In progress';

  @override
  String get orderStatusPending => 'Awaiting confirmation';

  @override
  String get orderStatusCanceled => 'Canceled';

  @override
  String get orderStageAccepted => 'Accepted';

  @override
  String get orderStageDiagnostics => 'Diagnostics';

  @override
  String get orderStageInProgress => 'In progress';

  @override
  String get orderStageDone => 'Done';

  @override
  String get orderStagePending => 'Awaiting confirmation';

  @override
  String get orderStageCanceled => 'Canceled';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorRestart => 'Please restart the app.';

  @override
  String carsLoadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get otpExpiredCode => 'Code has expired';

  @override
  String get otpInvalidCode => 'Invalid code';

  @override
  String get problemVehiclePickerTitle => 'Choose a car';

  @override
  String get problemVehicleChangeHint => 'Tap to change';

  @override
  String get addCarMakeUnknown => 'Pick a make from the list';

  @override
  String get addCarModelUnknown => 'Pick a model from the list';

  @override
  String get addCarPlateInvalid => 'Format: AA 1234 BB';

  @override
  String get addCarPlateHint => 'AA 1234 BB';
}
