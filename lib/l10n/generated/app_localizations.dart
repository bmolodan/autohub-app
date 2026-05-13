import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @appName.
  ///
  /// In uk, this message translates to:
  /// **'AUTOHUB'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In uk, this message translates to:
  /// **'Головна'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In uk, this message translates to:
  /// **'Історія'**
  String get navHistory;

  /// No description provided for @navCars.
  ///
  /// In uk, this message translates to:
  /// **'Авто'**
  String get navCars;

  /// No description provided for @navProfile.
  ///
  /// In uk, this message translates to:
  /// **'Профіль'**
  String get navProfile;

  /// No description provided for @commonNext.
  ///
  /// In uk, this message translates to:
  /// **'Далі'**
  String get commonNext;

  /// No description provided for @commonCancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get commonCancel;

  /// No description provided for @commonYes.
  ///
  /// In uk, this message translates to:
  /// **'Так'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In uk, this message translates to:
  /// **'Ні'**
  String get commonNo;

  /// No description provided for @commonRequiredField.
  ///
  /// In uk, this message translates to:
  /// **'Обовʼязкове поле'**
  String get commonRequiredField;

  /// No description provided for @commonNumbersOnly.
  ///
  /// In uk, this message translates to:
  /// **'Тільки число'**
  String get commonNumbersOnly;

  /// No description provided for @stateOfflineTitle.
  ///
  /// In uk, this message translates to:
  /// **'Немає звʼязку'**
  String get stateOfflineTitle;

  /// No description provided for @stateOfflineSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Перевірте інтернет-зʼєднання — і ми спробуємо ще раз.'**
  String get stateOfflineSubtitle;

  /// No description provided for @stateRetry.
  ///
  /// In uk, this message translates to:
  /// **'Спробувати знову'**
  String get stateRetry;

  /// No description provided for @stateWorkOffline.
  ///
  /// In uk, this message translates to:
  /// **'Працювати офлайн'**
  String get stateWorkOffline;

  /// No description provided for @onboardingSkip.
  ///
  /// In uk, this message translates to:
  /// **'Пропустити'**
  String get onboardingSkip;

  /// No description provided for @onboardingTitle.
  ///
  /// In uk, this message translates to:
  /// **'Записуйтесь\nза хвилину'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Оберіть послугу, дату і час. Без дзвінків і черг — все в застосунку.'**
  String get onboardingSubtitle;

  /// No description provided for @phoneBrandTagline.
  ///
  /// In uk, this message translates to:
  /// **'VETERAN AUTO HUB'**
  String get phoneBrandTagline;

  /// No description provided for @phoneGreeting.
  ///
  /// In uk, this message translates to:
  /// **'Вітаємо в\nавтохабі'**
  String get phoneGreeting;

  /// No description provided for @phoneInstruction.
  ///
  /// In uk, this message translates to:
  /// **'Введіть номер телефону — надішлемо SMS з кодом'**
  String get phoneInstruction;

  /// No description provided for @phoneHint.
  ///
  /// In uk, this message translates to:
  /// **'67 123 45 67'**
  String get phoneHint;

  /// No description provided for @phoneConsent.
  ///
  /// In uk, this message translates to:
  /// **'Згоден на обробку персональних даних та умови використання'**
  String get phoneConsent;

  /// No description provided for @phoneSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Надіслати код'**
  String get phoneSubmit;

  /// No description provided for @phoneDevHint.
  ///
  /// In uk, this message translates to:
  /// **'DEV · тапни щоб заповнити тестовий номер · код 0000'**
  String get phoneDevHint;

  /// No description provided for @otpTitle.
  ///
  /// In uk, this message translates to:
  /// **'Введіть код\nз SMS'**
  String get otpTitle;

  /// No description provided for @otpSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердити'**
  String get otpSubmit;

  /// No description provided for @otpResendIn.
  ///
  /// In uk, this message translates to:
  /// **'Надіслати ще раз через 0:{seconds}'**
  String otpResendIn(String seconds);

  /// No description provided for @otpResendNow.
  ///
  /// In uk, this message translates to:
  /// **'Надіслати ще раз'**
  String get otpResendNow;

  /// No description provided for @homeGreetingPrefix.
  ///
  /// In uk, this message translates to:
  /// **'Привіт,'**
  String get homeGreetingPrefix;

  /// No description provided for @homeUserName.
  ///
  /// In uk, this message translates to:
  /// **'Богдане'**
  String get homeUserName;

  /// No description provided for @homeNotificationsHint.
  ///
  /// In uk, this message translates to:
  /// **'Сповіщення'**
  String get homeNotificationsHint;

  /// No description provided for @homeDesignTokensHint.
  ///
  /// In uk, this message translates to:
  /// **'Design tokens (dev)'**
  String get homeDesignTokensHint;

  /// No description provided for @homeDesignTokensSemantics.
  ///
  /// In uk, this message translates to:
  /// **'Дизайн-токени (dev)'**
  String get homeDesignTokensSemantics;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In uk, this message translates to:
  /// **'Поки тиша'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Активних замовлень немає. Запишіться на сервіс — ми про все подбаємо.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeEmptyCta.
  ///
  /// In uk, this message translates to:
  /// **'+ Записатись на СТО'**
  String get homeEmptyCta;

  /// No description provided for @homeBookingCta.
  ///
  /// In uk, this message translates to:
  /// **'+ Записатись'**
  String get homeBookingCta;

  /// No description provided for @bookingStep1Title.
  ///
  /// In uk, this message translates to:
  /// **'Запис · крок 1 з 3'**
  String get bookingStep1Title;

  /// No description provided for @bookingPickerHeading.
  ///
  /// In uk, this message translates to:
  /// **'Що потрібно?'**
  String get bookingPickerHeading;

  /// No description provided for @bookingPickerSearchHint.
  ///
  /// In uk, this message translates to:
  /// **'Пошук послуги'**
  String get bookingPickerSearchHint;

  /// No description provided for @bookingServiceDurationAndPrice.
  ///
  /// In uk, this message translates to:
  /// **'~{minutes} хв  ·  від {price} ₴'**
  String bookingServiceDurationAndPrice(int minutes, int price);

  /// No description provided for @bookingStep3Title.
  ///
  /// In uk, this message translates to:
  /// **'Запис · крок 3 з 3'**
  String get bookingStep3Title;

  /// No description provided for @problemHeading.
  ///
  /// In uk, this message translates to:
  /// **'Що сталось?'**
  String get problemHeading;

  /// No description provided for @problemSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Опишіть проблему'**
  String get problemSubtitle;

  /// No description provided for @problemHint.
  ///
  /// In uk, this message translates to:
  /// **'Стук у передній підвісці на нерівностях. Зʼявляється після прогрівання…'**
  String get problemHint;

  /// No description provided for @problemPhotosCount.
  ///
  /// In uk, this message translates to:
  /// **'Фото ({count} / {max})'**
  String problemPhotosCount(int count, int max);

  /// No description provided for @problemSummaryService.
  ///
  /// In uk, this message translates to:
  /// **'Послуга'**
  String get problemSummaryService;

  /// No description provided for @problemSummaryVehicle.
  ///
  /// In uk, this message translates to:
  /// **'Авто'**
  String get problemSummaryVehicle;

  /// No description provided for @problemSummaryEstimate.
  ///
  /// In uk, this message translates to:
  /// **'Орієнтовно'**
  String get problemSummaryEstimate;

  /// No description provided for @problemEstimateFrom.
  ///
  /// In uk, this message translates to:
  /// **'від {price} ₴'**
  String problemEstimateFrom(int price);

  /// No description provided for @problemSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердити запис'**
  String get problemSubmit;

  /// No description provided for @problemNoVehicleSnack.
  ///
  /// In uk, this message translates to:
  /// **'Спочатку додайте авто'**
  String get problemNoVehicleSnack;

  /// No description provided for @photoSourceCamera.
  ///
  /// In uk, this message translates to:
  /// **'Камера'**
  String get photoSourceCamera;

  /// No description provided for @photoSourceGallery.
  ///
  /// In uk, this message translates to:
  /// **'Галерея'**
  String get photoSourceGallery;

  /// No description provided for @photoAddSemantics.
  ///
  /// In uk, this message translates to:
  /// **'Додати фото'**
  String get photoAddSemantics;

  /// No description provided for @photoRemoveSemantics.
  ///
  /// In uk, this message translates to:
  /// **'Видалити фото'**
  String get photoRemoveSemantics;

  /// No description provided for @photoAddError.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося додати фото: {error}'**
  String photoAddError(String error);

  /// No description provided for @orderNotFoundTitle.
  ///
  /// In uk, this message translates to:
  /// **'Замовлення не знайдено'**
  String get orderNotFoundTitle;

  /// No description provided for @orderNotFoundSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Можливо, його було видалено.'**
  String get orderNotFoundSubtitle;

  /// No description provided for @orderTimelineHeading.
  ///
  /// In uk, this message translates to:
  /// **'ХІД РОБОТИ'**
  String get orderTimelineHeading;

  /// No description provided for @orderJournalHeading.
  ///
  /// In uk, this message translates to:
  /// **'ЖУРНАЛ'**
  String get orderJournalHeading;

  /// No description provided for @orderEstimate.
  ///
  /// In uk, this message translates to:
  /// **'Орієнтовно'**
  String get orderEstimate;

  /// No description provided for @orderEstimateValue.
  ///
  /// In uk, this message translates to:
  /// **'{price} ₴'**
  String orderEstimateValue(int price);

  /// No description provided for @orderEstimateValueFrom.
  ///
  /// In uk, this message translates to:
  /// **'від {price} ₴'**
  String orderEstimateValueFrom(int price);

  /// No description provided for @orderPendingHeroLabel.
  ///
  /// In uk, this message translates to:
  /// **'ОЧІКУЄ ПІДТВЕРДЖЕННЯ'**
  String get orderPendingHeroLabel;

  /// No description provided for @orderCanceledHeroLabel.
  ///
  /// In uk, this message translates to:
  /// **'СКАСОВАНО'**
  String get orderCanceledHeroLabel;

  /// No description provided for @orderScheduledTime.
  ///
  /// In uk, this message translates to:
  /// **'Запланований час'**
  String get orderScheduledTime;

  /// No description provided for @orderScheduledTbd.
  ///
  /// In uk, this message translates to:
  /// **'визначимо невдовзі'**
  String get orderScheduledTbd;

  /// No description provided for @orderCallMaster.
  ///
  /// In uk, this message translates to:
  /// **'Зателефонувати майстру'**
  String get orderCallMaster;

  /// No description provided for @orderCallMasterTodo.
  ///
  /// In uk, this message translates to:
  /// **'Виклик майстра: TODO'**
  String get orderCallMasterTodo;

  /// No description provided for @orderCancelLabel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати запис'**
  String get orderCancelLabel;

  /// No description provided for @orderCancelDialogTitle.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати запис?'**
  String get orderCancelDialogTitle;

  /// No description provided for @orderCancelDialogBody.
  ///
  /// In uk, this message translates to:
  /// **'Дію не можна буде відмінити.'**
  String get orderCancelDialogBody;

  /// No description provided for @orderCancelDialogConfirm.
  ///
  /// In uk, this message translates to:
  /// **'Так, скасувати'**
  String get orderCancelDialogConfirm;

  /// No description provided for @orderCancelError.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося скасувати: {error}'**
  String orderCancelError(String error);

  /// No description provided for @orderTimelineEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Поки що жодних подій'**
  String get orderTimelineEmpty;

  /// No description provided for @carsListTitle.
  ///
  /// In uk, this message translates to:
  /// **'Мої авто'**
  String get carsListTitle;

  /// No description provided for @carsAddCta.
  ///
  /// In uk, this message translates to:
  /// **'Додати авто'**
  String get carsAddCta;

  /// No description provided for @carDetailNextService.
  ///
  /// In uk, this message translates to:
  /// **'Наступне ТО'**
  String get carDetailNextService;

  /// No description provided for @carDetailDueIn.
  ///
  /// In uk, this message translates to:
  /// **'через {km} км'**
  String carDetailDueIn(int km);

  /// No description provided for @carDetailOverdue.
  ///
  /// In uk, this message translates to:
  /// **'настав термін'**
  String get carDetailOverdue;

  /// No description provided for @carDetailMileage.
  ///
  /// In uk, this message translates to:
  /// **'Пробіг'**
  String get carDetailMileage;

  /// No description provided for @carDetailMileageValue.
  ///
  /// In uk, this message translates to:
  /// **'{km} км'**
  String carDetailMileageValue(int km);

  /// No description provided for @carDetailVin.
  ///
  /// In uk, this message translates to:
  /// **'VIN'**
  String get carDetailVin;

  /// No description provided for @carDetailBook.
  ///
  /// In uk, this message translates to:
  /// **'Записатись на ремонт'**
  String get carDetailBook;

  /// No description provided for @carDetailBookTodo.
  ///
  /// In uk, this message translates to:
  /// **'Запис: TODO'**
  String get carDetailBookTodo;

  /// No description provided for @carDetailNotFound.
  ///
  /// In uk, this message translates to:
  /// **'Авто не знайдено'**
  String get carDetailNotFound;

  /// No description provided for @addCarHeading.
  ///
  /// In uk, this message translates to:
  /// **'Розкажіть про вашу машину'**
  String get addCarHeading;

  /// No description provided for @addCarSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Можна заповнити VIN — решта заповниться автоматично'**
  String get addCarSubtitle;

  /// No description provided for @addCarFieldVin.
  ///
  /// In uk, this message translates to:
  /// **'VIN (опційно)'**
  String get addCarFieldVin;

  /// No description provided for @addCarFieldMake.
  ///
  /// In uk, this message translates to:
  /// **'Марка'**
  String get addCarFieldMake;

  /// No description provided for @addCarFieldModel.
  ///
  /// In uk, this message translates to:
  /// **'Модель'**
  String get addCarFieldModel;

  /// No description provided for @addCarFieldYear.
  ///
  /// In uk, this message translates to:
  /// **'Рік'**
  String get addCarFieldYear;

  /// No description provided for @addCarFieldPlate.
  ///
  /// In uk, this message translates to:
  /// **'Номер'**
  String get addCarFieldPlate;

  /// No description provided for @addCarYearRange.
  ///
  /// In uk, this message translates to:
  /// **'1900–{max}'**
  String addCarYearRange(int max);

  /// No description provided for @addCarSave.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти авто'**
  String get addCarSave;

  /// No description provided for @historyTitle.
  ///
  /// In uk, this message translates to:
  /// **'Історія'**
  String get historyTitle;

  /// No description provided for @historyTotalLabel.
  ///
  /// In uk, this message translates to:
  /// **'Витрачено за весь час'**
  String get historyTotalLabel;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In uk, this message translates to:
  /// **'Історія порожня'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Тут зʼявляться завершені роботи після першого візиту.'**
  String get historyEmptySubtitle;

  /// No description provided for @monthJanuary.
  ///
  /// In uk, this message translates to:
  /// **'СІЧЕНЬ'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In uk, this message translates to:
  /// **'ЛЮТИЙ'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In uk, this message translates to:
  /// **'БЕРЕЗЕНЬ'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In uk, this message translates to:
  /// **'КВІТЕНЬ'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In uk, this message translates to:
  /// **'ТРАВЕНЬ'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In uk, this message translates to:
  /// **'ЧЕРВЕНЬ'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In uk, this message translates to:
  /// **'ЛИПЕНЬ'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In uk, this message translates to:
  /// **'СЕРПЕНЬ'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In uk, this message translates to:
  /// **'ВЕРЕСЕНЬ'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In uk, this message translates to:
  /// **'ЖОВТЕНЬ'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In uk, this message translates to:
  /// **'ЛИСТОПАД'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In uk, this message translates to:
  /// **'ГРУДЕНЬ'**
  String get monthDecember;

  /// No description provided for @profileTitle.
  ///
  /// In uk, this message translates to:
  /// **'Профіль'**
  String get profileTitle;

  /// No description provided for @profileMyCars.
  ///
  /// In uk, this message translates to:
  /// **'МОЇ АВТО'**
  String get profileMyCars;

  /// No description provided for @profileTOLeftPill.
  ///
  /// In uk, this message translates to:
  /// **'ТО за {km} км'**
  String profileTOLeftPill(int km);

  /// No description provided for @profileNotifications.
  ///
  /// In uk, this message translates to:
  /// **'Сповіщення'**
  String get profileNotifications;

  /// No description provided for @profileLanguage.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get profileLanguage;

  /// No description provided for @profileLanguageBadge.
  ///
  /// In uk, this message translates to:
  /// **'UA'**
  String get profileLanguageBadge;

  /// No description provided for @profileSupport.
  ///
  /// In uk, this message translates to:
  /// **'Підтримка'**
  String get profileSupport;

  /// No description provided for @profileSignOut.
  ///
  /// In uk, this message translates to:
  /// **'Вийти'**
  String get profileSignOut;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In uk, this message translates to:
  /// **'Видалити акаунт'**
  String get profileDeleteAccount;

  /// No description provided for @profileAvatarSemantics.
  ///
  /// In uk, this message translates to:
  /// **'Аватар {name}'**
  String profileAvatarSemantics(String name);

  /// No description provided for @profileLanguageTodo.
  ///
  /// In uk, this message translates to:
  /// **'Перемикач мови: TODO'**
  String get profileLanguageTodo;

  /// No description provided for @profileSupportTodo.
  ///
  /// In uk, this message translates to:
  /// **'Контакти підтримки: TODO'**
  String get profileSupportTodo;

  /// No description provided for @notificationsHeading.
  ///
  /// In uk, this message translates to:
  /// **'Що надсилати?'**
  String get notificationsHeading;

  /// No description provided for @notifyStatusTitle.
  ///
  /// In uk, this message translates to:
  /// **'Зміна статусу'**
  String get notifyStatusTitle;

  /// No description provided for @notifyStatusSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Прийнято · діагностика · готово'**
  String get notifyStatusSubtitle;

  /// No description provided for @notifyTOTitle.
  ///
  /// In uk, this message translates to:
  /// **'Нагадування про ТО'**
  String get notifyTOTitle;

  /// No description provided for @notifyTOSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'За 30 днів до планового візиту'**
  String get notifyTOSubtitle;

  /// No description provided for @notifyMasterTitle.
  ///
  /// In uk, this message translates to:
  /// **'Повідомлення майстра'**
  String get notifyMasterTitle;

  /// No description provided for @notifyMasterSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Уточнення під час робіт'**
  String get notifyMasterSubtitle;

  /// No description provided for @notifyPromosTitle.
  ///
  /// In uk, this message translates to:
  /// **'Акції та новини'**
  String get notifyPromosTitle;

  /// No description provided for @notifyPromosSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Сезонні пропозиції'**
  String get notifyPromosSubtitle;

  /// No description provided for @notifyQuietTitle.
  ///
  /// In uk, this message translates to:
  /// **'Тихі години'**
  String get notifyQuietTitle;

  /// No description provided for @notifyQuietSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'22:00 — 8:00'**
  String get notifyQuietSubtitle;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In uk, this message translates to:
  /// **'Видалення акаунта'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteHeading.
  ///
  /// In uk, this message translates to:
  /// **'Видалити акаунт?'**
  String get accountDeleteHeading;

  /// No description provided for @accountDeleteBody.
  ///
  /// In uk, this message translates to:
  /// **'Ця дія незворотна. Ось що буде видалено:'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleteItemProfile.
  ///
  /// In uk, this message translates to:
  /// **'Профіль і авто'**
  String get accountDeleteItemProfile;

  /// No description provided for @accountDeleteItemHistory.
  ///
  /// In uk, this message translates to:
  /// **'Історія обслуговування'**
  String get accountDeleteItemHistory;

  /// No description provided for @accountDeleteItemPush.
  ///
  /// In uk, this message translates to:
  /// **'Push-сповіщення'**
  String get accountDeleteItemPush;

  /// No description provided for @accountDeleteLegalNote.
  ///
  /// In uk, this message translates to:
  /// **'Активні замовлення збережуться у СТО для бухгалтерії — згідно ЗУ «Про захист ПД».'**
  String get accountDeleteLegalNote;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In uk, this message translates to:
  /// **'Так, видалити'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeleteSuccessSnack.
  ///
  /// In uk, this message translates to:
  /// **'Акаунт видалено (стаб)'**
  String get accountDeleteSuccessSnack;

  /// No description provided for @serviceOilChange.
  ///
  /// In uk, this message translates to:
  /// **'Заміна масла'**
  String get serviceOilChange;

  /// No description provided for @serviceTires.
  ///
  /// In uk, this message translates to:
  /// **'Шиномонтаж'**
  String get serviceTires;

  /// No description provided for @serviceDiagnostics.
  ///
  /// In uk, this message translates to:
  /// **'Діагностика двигуна'**
  String get serviceDiagnostics;

  /// No description provided for @serviceBrakes.
  ///
  /// In uk, this message translates to:
  /// **'Гальмівна система'**
  String get serviceBrakes;

  /// No description provided for @serviceAc.
  ///
  /// In uk, this message translates to:
  /// **'Кондиціонер'**
  String get serviceAc;

  /// No description provided for @orderStatusInProgress.
  ///
  /// In uk, this message translates to:
  /// **'У ремонті'**
  String get orderStatusInProgress;

  /// No description provided for @orderStatusPending.
  ///
  /// In uk, this message translates to:
  /// **'Очікує підтвердження'**
  String get orderStatusPending;

  /// No description provided for @orderStatusCanceled.
  ///
  /// In uk, this message translates to:
  /// **'Скасовано'**
  String get orderStatusCanceled;

  /// No description provided for @orderStageAccepted.
  ///
  /// In uk, this message translates to:
  /// **'Прийнято'**
  String get orderStageAccepted;

  /// No description provided for @orderStageDiagnostics.
  ///
  /// In uk, this message translates to:
  /// **'Діагностика'**
  String get orderStageDiagnostics;

  /// No description provided for @orderStageInProgress.
  ///
  /// In uk, this message translates to:
  /// **'У ремонті'**
  String get orderStageInProgress;

  /// No description provided for @orderStageDone.
  ///
  /// In uk, this message translates to:
  /// **'Готово'**
  String get orderStageDone;

  /// No description provided for @orderStagePending.
  ///
  /// In uk, this message translates to:
  /// **'Очікує підтвердження'**
  String get orderStagePending;

  /// No description provided for @orderStageCanceled.
  ///
  /// In uk, this message translates to:
  /// **'Скасовано'**
  String get orderStageCanceled;

  /// No description provided for @errorGeneric.
  ///
  /// In uk, this message translates to:
  /// **'Сталася помилка'**
  String get errorGeneric;

  /// No description provided for @errorRestart.
  ///
  /// In uk, this message translates to:
  /// **'Перезапустіть застосунок.'**
  String get errorRestart;

  /// No description provided for @carsLoadFailed.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося завантажити: {error}'**
  String carsLoadFailed(String error);

  /// No description provided for @otpExpiredCode.
  ///
  /// In uk, this message translates to:
  /// **'Час дії коду минув'**
  String get otpExpiredCode;

  /// No description provided for @otpInvalidCode.
  ///
  /// In uk, this message translates to:
  /// **'Невірний код'**
  String get otpInvalidCode;

  /// No description provided for @problemVehiclePickerTitle.
  ///
  /// In uk, this message translates to:
  /// **'Виберіть авто'**
  String get problemVehiclePickerTitle;

  /// No description provided for @problemVehicleChangeHint.
  ///
  /// In uk, this message translates to:
  /// **'Натисніть, щоб змінити'**
  String get problemVehicleChangeHint;

  /// No description provided for @addCarMakeUnknown.
  ///
  /// In uk, this message translates to:
  /// **'Виберіть марку зі списку'**
  String get addCarMakeUnknown;

  /// No description provided for @addCarModelUnknown.
  ///
  /// In uk, this message translates to:
  /// **'Виберіть модель зі списку'**
  String get addCarModelUnknown;

  /// No description provided for @addCarPlateInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Формат: AA 1234 BB'**
  String get addCarPlateInvalid;

  /// No description provided for @addCarPlateHint.
  ///
  /// In uk, this message translates to:
  /// **'AA 1234 BB'**
  String get addCarPlateHint;

  /// No description provided for @addCarEditTitle.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати авто'**
  String get addCarEditTitle;

  /// No description provided for @addCarEditHeading.
  ///
  /// In uk, this message translates to:
  /// **'Оновити дані'**
  String get addCarEditHeading;

  /// No description provided for @addCarUpdateSave.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти зміни'**
  String get addCarUpdateSave;

  /// No description provided for @carDetailEditSemantics.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати'**
  String get carDetailEditSemantics;

  /// No description provided for @carDetailDeleteSemantics.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get carDetailDeleteSemantics;

  /// No description provided for @carDeleteDialogTitle.
  ///
  /// In uk, this message translates to:
  /// **'Видалити авто?'**
  String get carDeleteDialogTitle;

  /// No description provided for @carDeleteDialogBody.
  ///
  /// In uk, this message translates to:
  /// **'Цю дію не можна скасувати. Історія обслуговування цього авто залишиться у вашому акаунті.'**
  String get carDeleteDialogBody;

  /// No description provided for @carDeleteDialogConfirm.
  ///
  /// In uk, this message translates to:
  /// **'Так, видалити'**
  String get carDeleteDialogConfirm;

  /// No description provided for @carDeleteSuccessSnack.
  ///
  /// In uk, this message translates to:
  /// **'Авто видалено'**
  String get carDeleteSuccessSnack;

  /// No description provided for @carUpdateSuccessSnack.
  ///
  /// In uk, this message translates to:
  /// **'Дані авто оновлено'**
  String get carUpdateSuccessSnack;

  /// No description provided for @registerTitle.
  ///
  /// In uk, this message translates to:
  /// **'Знайомство'**
  String get registerTitle;

  /// No description provided for @registerHeading.
  ///
  /// In uk, this message translates to:
  /// **'Як до вас звертатись?'**
  String get registerHeading;

  /// No description provided for @registerSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Це допоможе майстру звертатись до вас особисто.'**
  String get registerSubtitle;

  /// No description provided for @registerFieldName.
  ///
  /// In uk, this message translates to:
  /// **'Імʼя'**
  String get registerFieldName;

  /// No description provided for @registerFieldEmail.
  ///
  /// In uk, this message translates to:
  /// **'Email (необовʼязково)'**
  String get registerFieldEmail;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Перевірте email'**
  String get registerEmailInvalid;

  /// No description provided for @registerSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Продовжити'**
  String get registerSubmit;

  /// No description provided for @registerEditTitle.
  ///
  /// In uk, this message translates to:
  /// **'Особисті дані'**
  String get registerEditTitle;

  /// No description provided for @registerEditSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти зміни'**
  String get registerEditSubmit;

  /// No description provided for @registerUpdatedSnack.
  ///
  /// In uk, this message translates to:
  /// **'Дані оновлено'**
  String get registerUpdatedSnack;

  /// No description provided for @profileEditSemantics.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати'**
  String get profileEditSemantics;

  /// No description provided for @profileNoEmail.
  ///
  /// In uk, this message translates to:
  /// **'Email не вказано'**
  String get profileNoEmail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
