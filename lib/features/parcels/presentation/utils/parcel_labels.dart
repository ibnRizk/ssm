import 'package:intl/intl.dart';

import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../../domain/entities/parcel.dart';

extension ParcelLabels on Parcel {
  /// "Cash on delivery: 45 SAR" or "Prepaid".
  String get paymentLabel => paymentType == ParcelPaymentType.cod
      ? Strings.parcelsPaymentCod(
          formatAmount(codAmount),
          currencySymbol(currency),
        )
      : Strings.parcelsPaymentPrepaid;

  /// Warehouse → out for delivery → delivered, with the current stage
  /// active (orange). The middle step's subtitle tells the customer whether
  /// the parcel is waiting on them.
  List<TimelineStep> get timeline {
    TimelineStepState stateOf(ParcelStatus step) {
      if (status == ParcelStatus.delivered) return TimelineStepState.completed;
      if (status.index > step.index) return TimelineStepState.completed;
      if (status == step) return TimelineStepState.active;
      return TimelineStepState.pending;
    }

    return <TimelineStep>[
      TimelineStep(
        title: Strings.parcelsStepArrivedTitle,
        subtitle: Strings.parcelsStepArrivedSubtitle,
        state: stateOf(ParcelStatus.atWarehouse),
      ),
      TimelineStep(
        title: Strings.parcelsStepDeliveringTitle,
        subtitle: switch (status) {
          ParcelStatus.outForDelivery ||
          ParcelStatus.delivered => Strings.parcelsStepDeliveringOnTheWay,
          _ when hasDropoffLocation =>
            Strings.parcelsStepDeliveringLocationSent,
          _ => Strings.parcelsStepDeliveringSubtitle,
        },
        state: stateOf(ParcelStatus.outForDelivery),
      ),
      TimelineStep(
        title: Strings.parcelsStepDeliveredTitle,
        subtitle: status == ParcelStatus.delivered
            ? Strings.parcelsStepDeliveredDone
            : Strings.parcelsStepDeliveredSubtitle,
        state: stateOf(ParcelStatus.delivered),
      ),
    ];
  }
}

/// "Updated just now / 5 min ago / 3 h ago / on 12 Sep 2026", relative to
/// [now].
String parcelUpdatedLabel(DateTime updatedAt, DateTime now, String locale) {
  final Duration age = now.difference(updatedAt);
  if (age.inMinutes < 1) return Strings.parcelsUpdatedJustNow;
  if (age.inMinutes < 60) {
    return Strings.parcelsUpdatedMinutesAgo(age.inMinutes);
  }
  if (age.inHours < 24) return Strings.parcelsUpdatedHoursAgo(age.inHours);
  return Strings.parcelsUpdatedOn(
    DateFormat.yMMMd(locale).format(updatedAt.toLocal()),
  );
}
