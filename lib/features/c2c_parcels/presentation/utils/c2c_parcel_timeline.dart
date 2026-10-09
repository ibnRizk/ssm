import 'package:intl/intl.dart';

import '../../../../core/widgets/vertical_timeline.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/entities/c2c_parcel_status.dart';
import 'c2c_parcel_labels.dart';

/// The delivery path a parcel normally takes, for the steps still ahead.
const List<C2cParcelStatus> _happyPath = <C2cParcelStatus>[
  C2cParcelStatus.dispatching,
  C2cParcelStatus.driverAccepted,
  C2cParcelStatus.pickedUp,
  C2cParcelStatus.outForDelivery,
  C2cParcelStatus.delivered,
];

/// Where [status] sits on [_happyPath]; null off it (cancelled, returns).
int? _pathIndex(C2cParcelStatus status) => switch (status) {
  C2cParcelStatus.quoted ||
  C2cParcelStatus.pendingPayment ||
  C2cParcelStatus.pendingDispatch ||
  C2cParcelStatus.dispatching ||
  C2cParcelStatus.assignmentFailed ||
  C2cParcelStatus.driverAssigned => 0,
  C2cParcelStatus.driverAccepted || C2cParcelStatus.driverAtPickup => 1,
  C2cParcelStatus.pickedUp => 2,
  C2cParcelStatus.outForDelivery || C2cParcelStatus.failedDelivery => 3,
  C2cParcelStatus.delivered => 4,
  _ => null,
};

/// What happened (the server's history, oldest first, timestamped), then —
/// while the parcel is still on its way — the steps still ahead, greyed.
List<TimelineStep> c2cTimelineSteps(
  C2cParcelDetails parcel, {
  required String languageCode,
}) {
  final DateFormat format = DateFormat('d MMM, HH:mm', languageCode);
  final List<C2cTimelineEntry> history = <C2cTimelineEntry>[
    for (final C2cTimelineEntry entry in parcel.timeline)
      if (entry.status != C2cParcelStatus.draft) entry,
  ];
  if (history.isEmpty || history.last.status != parcel.status) {
    history.add(C2cTimelineEntry(status: parcel.status));
  }

  final List<TimelineStep> steps = <TimelineStep>[];
  for (int i = 0; i < history.length; i++) {
    final C2cTimelineEntry entry = history[i];
    // Repeated statuses (e.g. two dispatch rounds) collapse into one step.
    if (i > 0 && history[i - 1].status == entry.status) continue;
    final bool isCurrent = i == history.length - 1;
    final DateTime? at = entry.occurredAt;
    steps.add(
      TimelineStep(
        title: entry.status.title,
        subtitle: at == null
            ? entry.status.description
            : format.format(at.toLocal()),
        state: isCurrent && !parcel.status.isTerminal
            ? TimelineStepState.active
            : TimelineStepState.completed,
      ),
    );
  }

  final int? index = _pathIndex(parcel.status);
  if (!parcel.status.isTerminal && index != null) {
    for (final C2cParcelStatus next in _happyPath.skip(index + 1)) {
      steps.add(
        TimelineStep(
          title: next.title,
          subtitle: next.description,
          state: TimelineStepState.pending,
        ),
      );
    }
  }
  return steps;
}
