import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/tinted_note.dart';

class SubscriptionsFooterNote extends StatelessWidget {
  /// The parcel side explains how parcel plans differ instead.
  final bool forParcels;

  const SubscriptionsFooterNote({super.key, this.forParcels = false});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return TintedNote(
      text: forParcels
          ? Strings.subscriptionsParcelFooterNote
          : Strings.subscriptionsFooterNote,
      backgroundColor: c.secondaryLight,
      textColor: c.secondaryDark,
    );
  }
}
