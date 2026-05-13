// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'AUTOHUB';

  @override
  String get navHome => 'Головна';

  @override
  String get navHistory => 'Історія';

  @override
  String get navCars => 'Авто';

  @override
  String get navProfile => 'Профіль';

  @override
  String get commonNext => 'Далі';

  @override
  String get commonCancel => 'Скасувати';

  @override
  String get commonYes => 'Так';

  @override
  String get commonNo => 'Ні';

  @override
  String get commonRequiredField => 'Обовʼязкове поле';

  @override
  String get commonNumbersOnly => 'Тільки число';

  @override
  String get stateOfflineTitle => 'Немає звʼязку';

  @override
  String get stateOfflineSubtitle =>
      'Перевірте інтернет-зʼєднання — і ми спробуємо ще раз.';

  @override
  String get stateRetry => 'Спробувати знову';

  @override
  String get stateWorkOffline => 'Працювати офлайн';

  @override
  String get onboardingSkip => 'Пропустити';

  @override
  String get onboardingTitle => 'Записуйтесь\nза хвилину';

  @override
  String get onboardingSubtitle =>
      'Оберіть послугу, дату і час. Без дзвінків і черг — все в застосунку.';

  @override
  String get phoneBrandTagline => 'VETERAN AUTO HUB';

  @override
  String get phoneGreeting => 'Вітаємо в\nавтохабі';

  @override
  String get phoneInstruction =>
      'Введіть номер телефону — надішлемо SMS з кодом';

  @override
  String get phoneHint => '67 123 45 67';

  @override
  String get phoneConsent =>
      'Згоден на обробку персональних даних та умови використання';

  @override
  String get phoneSubmit => 'Надіслати код';

  @override
  String get phoneDevHint =>
      'DEV · тапни щоб заповнити тестовий номер · код 0000';

  @override
  String get otpTitle => 'Введіть код\nз SMS';

  @override
  String get otpSubmit => 'Підтвердити';

  @override
  String otpResendIn(String seconds) {
    return 'Надіслати ще раз через 0:$seconds';
  }

  @override
  String get otpResendNow => 'Надіслати ще раз';

  @override
  String get homeGreetingPrefix => 'Привіт,';

  @override
  String get homeUserName => 'Богдане';

  @override
  String get homeNotificationsHint => 'Сповіщення';

  @override
  String get homeDesignTokensHint => 'Design tokens (dev)';

  @override
  String get homeDesignTokensSemantics => 'Дизайн-токени (dev)';

  @override
  String get homeEmptyTitle => 'Поки тиша';

  @override
  String get homeEmptySubtitle =>
      'Активних замовлень немає. Запишіться на сервіс — ми про все подбаємо.';

  @override
  String get homeEmptyCta => '+ Записатись на СТО';

  @override
  String get homeBookingCta => '+ Записатись';

  @override
  String get bookingStep1Title => 'Запис · крок 1 з 3';

  @override
  String get bookingPickerHeading => 'Що потрібно?';

  @override
  String get bookingPickerSearchHint => 'Пошук послуги';

  @override
  String bookingServiceDurationAndPrice(int minutes, int price) {
    return '~$minutes хв  ·  від $price ₴';
  }

  @override
  String get bookingStep3Title => 'Запис · крок 3 з 3';

  @override
  String get problemHeading => 'Що сталось?';

  @override
  String get problemSubtitle => 'Опишіть проблему';

  @override
  String get problemHint =>
      'Стук у передній підвісці на нерівностях. Зʼявляється після прогрівання…';

  @override
  String problemPhotosCount(int count, int max) {
    return 'Фото ($count / $max)';
  }

  @override
  String get problemSummaryService => 'Послуга';

  @override
  String get problemSummaryVehicle => 'Авто';

  @override
  String get problemSummaryEstimate => 'Орієнтовно';

  @override
  String problemEstimateFrom(int price) {
    return 'від $price ₴';
  }

  @override
  String get problemSubmit => 'Підтвердити запис';

  @override
  String get problemNoVehicleSnack => 'Спочатку додайте авто';

  @override
  String get photoSourceCamera => 'Камера';

  @override
  String get photoSourceGallery => 'Галерея';

  @override
  String get photoAddSemantics => 'Додати фото';

  @override
  String get photoRemoveSemantics => 'Видалити фото';

  @override
  String photoAddError(String error) {
    return 'Не вдалося додати фото: $error';
  }

  @override
  String get orderNotFoundTitle => 'Замовлення не знайдено';

  @override
  String get orderNotFoundSubtitle => 'Можливо, його було видалено.';

  @override
  String get orderTimelineHeading => 'ХІД РОБОТИ';

  @override
  String get orderJournalHeading => 'ЖУРНАЛ';

  @override
  String get orderEstimate => 'Орієнтовно';

  @override
  String orderEstimateValue(int price) {
    return '$price ₴';
  }

  @override
  String orderEstimateValueFrom(int price) {
    return 'від $price ₴';
  }

  @override
  String get orderPendingHeroLabel => 'ОЧІКУЄ ПІДТВЕРДЖЕННЯ';

  @override
  String get orderCanceledHeroLabel => 'СКАСОВАНО';

  @override
  String get orderScheduledTime => 'Запланований час';

  @override
  String get orderScheduledTbd => 'визначимо невдовзі';

  @override
  String get orderCallMaster => 'Зателефонувати майстру';

  @override
  String get orderCallMasterTodo => 'Виклик майстра: TODO';

  @override
  String get orderCancelLabel => 'Скасувати запис';

  @override
  String get orderCancelDialogTitle => 'Скасувати запис?';

  @override
  String get orderCancelDialogBody => 'Дію не можна буде відмінити.';

  @override
  String get orderCancelDialogConfirm => 'Так, скасувати';

  @override
  String orderCancelError(String error) {
    return 'Не вдалося скасувати: $error';
  }

  @override
  String get orderTimelineEmpty => 'Поки що жодних подій';

  @override
  String get carsListTitle => 'Мої авто';

  @override
  String get carsAddCta => 'Додати авто';

  @override
  String get carDetailNextService => 'Наступне ТО';

  @override
  String carDetailDueIn(int km) {
    return 'через $km км';
  }

  @override
  String get carDetailOverdue => 'настав термін';

  @override
  String get carDetailMileage => 'Пробіг';

  @override
  String carDetailMileageValue(int km) {
    return '$km км';
  }

  @override
  String get carDetailVin => 'VIN';

  @override
  String get carDetailBook => 'Записатись на ремонт';

  @override
  String get carDetailBookTodo => 'Запис: TODO';

  @override
  String get carDetailNotFound => 'Авто не знайдено';

  @override
  String get addCarHeading => 'Розкажіть про вашу машину';

  @override
  String get addCarSubtitle =>
      'Можна заповнити VIN — решта заповниться автоматично';

  @override
  String get addCarFieldVin => 'VIN (опційно)';

  @override
  String get addCarFieldMake => 'Марка';

  @override
  String get addCarFieldModel => 'Модель';

  @override
  String get addCarFieldYear => 'Рік';

  @override
  String get addCarFieldPlate => 'Номер';

  @override
  String addCarYearRange(int max) {
    return '1900–$max';
  }

  @override
  String get addCarSave => 'Зберегти авто';

  @override
  String get historyTitle => 'Історія';

  @override
  String get historyTotalLabel => 'Витрачено за весь час';

  @override
  String get historyEmptyTitle => 'Історія порожня';

  @override
  String get historyEmptySubtitle =>
      'Тут зʼявляться завершені роботи після першого візиту.';

  @override
  String get monthJanuary => 'СІЧЕНЬ';

  @override
  String get monthFebruary => 'ЛЮТИЙ';

  @override
  String get monthMarch => 'БЕРЕЗЕНЬ';

  @override
  String get monthApril => 'КВІТЕНЬ';

  @override
  String get monthMay => 'ТРАВЕНЬ';

  @override
  String get monthJune => 'ЧЕРВЕНЬ';

  @override
  String get monthJuly => 'ЛИПЕНЬ';

  @override
  String get monthAugust => 'СЕРПЕНЬ';

  @override
  String get monthSeptember => 'ВЕРЕСЕНЬ';

  @override
  String get monthOctober => 'ЖОВТЕНЬ';

  @override
  String get monthNovember => 'ЛИСТОПАД';

  @override
  String get monthDecember => 'ГРУДЕНЬ';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get profileMyCars => 'МОЇ АВТО';

  @override
  String profileTOLeftPill(int km) {
    return 'ТО за $km км';
  }

  @override
  String get profileNotifications => 'Сповіщення';

  @override
  String get profileLanguage => 'Мова';

  @override
  String get profileLanguageBadge => 'UA';

  @override
  String get profileSupport => 'Підтримка';

  @override
  String get profileSignOut => 'Вийти';

  @override
  String get profileDeleteAccount => 'Видалити акаунт';

  @override
  String profileAvatarSemantics(String name) {
    return 'Аватар $name';
  }

  @override
  String get profileLanguageTodo => 'Перемикач мови: TODO';

  @override
  String get profileSupportTodo => 'Контакти підтримки: TODO';

  @override
  String get notificationsHeading => 'Що надсилати?';

  @override
  String get notifyStatusTitle => 'Зміна статусу';

  @override
  String get notifyStatusSubtitle => 'Прийнято · діагностика · готово';

  @override
  String get notifyTOTitle => 'Нагадування про ТО';

  @override
  String get notifyTOSubtitle => 'За 30 днів до планового візиту';

  @override
  String get notifyMasterTitle => 'Повідомлення майстра';

  @override
  String get notifyMasterSubtitle => 'Уточнення під час робіт';

  @override
  String get notifyPromosTitle => 'Акції та новини';

  @override
  String get notifyPromosSubtitle => 'Сезонні пропозиції';

  @override
  String get notifyQuietTitle => 'Тихі години';

  @override
  String get notifyQuietSubtitle => '22:00 — 8:00';

  @override
  String get accountDeleteTitle => 'Видалення акаунта';

  @override
  String get accountDeleteHeading => 'Видалити акаунт?';

  @override
  String get accountDeleteBody => 'Ця дія незворотна. Ось що буде видалено:';

  @override
  String get accountDeleteItemProfile => 'Профіль і авто';

  @override
  String get accountDeleteItemHistory => 'Історія обслуговування';

  @override
  String get accountDeleteItemPush => 'Push-сповіщення';

  @override
  String get accountDeleteLegalNote =>
      'Активні замовлення збережуться у СТО для бухгалтерії — згідно ЗУ «Про захист ПД».';

  @override
  String get accountDeleteConfirm => 'Так, видалити';

  @override
  String get accountDeleteSuccessSnack => 'Акаунт видалено (стаб)';

  @override
  String get serviceOilChange => 'Заміна масла';

  @override
  String get serviceTires => 'Шиномонтаж';

  @override
  String get serviceDiagnostics => 'Діагностика двигуна';

  @override
  String get serviceBrakes => 'Гальмівна система';

  @override
  String get serviceAc => 'Кондиціонер';

  @override
  String get orderStatusInProgress => 'У ремонті';

  @override
  String get orderStatusPending => 'Очікує підтвердження';

  @override
  String get orderStatusCanceled => 'Скасовано';

  @override
  String get orderStageAccepted => 'Прийнято';

  @override
  String get orderStageDiagnostics => 'Діагностика';

  @override
  String get orderStageInProgress => 'У ремонті';

  @override
  String get orderStageDone => 'Готово';

  @override
  String get orderStagePending => 'Очікує підтвердження';

  @override
  String get orderStageCanceled => 'Скасовано';

  @override
  String get errorGeneric => 'Сталася помилка';

  @override
  String get errorRestart => 'Перезапустіть застосунок.';

  @override
  String carsLoadFailed(String error) {
    return 'Не вдалося завантажити: $error';
  }

  @override
  String get otpExpiredCode => 'Час дії коду минув';

  @override
  String get otpInvalidCode => 'Невірний код';

  @override
  String get problemVehiclePickerTitle => 'Виберіть авто';

  @override
  String get problemVehicleChangeHint => 'Натисніть, щоб змінити';

  @override
  String get addCarMakeUnknown => 'Виберіть марку зі списку';

  @override
  String get addCarModelUnknown => 'Виберіть модель зі списку';

  @override
  String get addCarPlateInvalid => 'Формат: AA 1234 BB';

  @override
  String get addCarPlateHint => 'AA 1234 BB';
}
