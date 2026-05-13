import '../../../l10n/generated/app_localizations.dart';
import '../domain/active_order.dart';

String orderStatusLabel(AppLocalizations l, ActiveOrderStatus status) =>
    switch (status) {
      ActiveOrderStatus.inProgress => l.orderStatusInProgress,
      ActiveOrderStatus.pendingConfirmation => l.orderStatusPending,
      ActiveOrderStatus.canceled => l.orderStatusCanceled,
    };

String orderStageLabel(AppLocalizations l, OrderStage stage) => switch (stage) {
      OrderStage.accepted => l.orderStageAccepted,
      OrderStage.diagnostics => l.orderStageDiagnostics,
      OrderStage.inProgress => l.orderStageInProgress,
      OrderStage.done => l.orderStageDone,
      OrderStage.pendingConfirmation => l.orderStagePending,
      OrderStage.canceled => l.orderStageCanceled,
    };
