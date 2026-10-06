import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../../domain/entities/order_status.dart';

extension OrderStatusLabels on OrderStatus {
  /// The banner's headline: the current step's title, or what went wrong.
  String get headline => switch (this) {
    OrderStatus.rejected => Strings.orderTrackingRejectedTitle,
    OrderStatus.cancelled => Strings.orderTrackingCancelledTitle,
    OrderStatus.assignmentFailed => Strings.orderTrackingAssignmentFailedTitle,
    _ => stage!.title,
  };

  String get description => switch (this) {
    OrderStatus.delivered => Strings.orderTrackingStepDeliveredSubtitle,
    OrderStatus.assignmentFailed =>
      Strings.orderTrackingAssignmentFailedDescription,
    _ when isFailed => Strings.orderTrackingFailedDescription,
    _ => Strings.orderTrackingStatusDescription,
  };

  /// The five steps, marked against this status. A failed order shows only
  /// its first step as done — how far it got isn't known.
  List<TimelineStep> timeline(String storeName) {
    final OrderStage? current = stage;
    return <TimelineStep>[
      for (final OrderStage step in OrderStage.values)
        TimelineStep(
          title: step.title,
          subtitle: step.subtitle(storeName),
          state: switch (current) {
            null =>
              step == OrderStage.placed
                  ? TimelineStepState.completed
                  : TimelineStepState.pending,
            // Delivered is the end: nothing left in progress.
            OrderStage.delivered => TimelineStepState.completed,
            _ when step.index < current.index => TimelineStepState.completed,
            _ when step == current => TimelineStepState.active,
            _ => TimelineStepState.pending,
          },
        ),
    ];
  }
}

extension on OrderStage {
  String get title => switch (this) {
    OrderStage.placed => Strings.orderTrackingStepSentTitle,
    OrderStage.preparing => Strings.orderTrackingStepPreparingTitle,
    OrderStage.courierToStore => Strings.orderTrackingStepCourierToStoreTitle,
    OrderStage.courierToCustomer => Strings.orderTrackingStepCourierToYouTitle,
    OrderStage.delivered => Strings.orderTrackingStepDeliveredTitle,
  };

  String subtitle(String storeName) => switch (this) {
    OrderStage.placed => Strings.orderTrackingStepSentSubtitle,
    OrderStage.preparing => Strings.orderTrackingStepPreparingSubtitle(
      storeName,
    ),
    OrderStage.courierToStore =>
      Strings.orderTrackingStepCourierToStoreSubtitle,
    OrderStage.courierToCustomer =>
      Strings.orderTrackingStepCourierToYouSubtitle,
    OrderStage.delivered => Strings.orderTrackingStepDeliveredSubtitle,
  };
}
