import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/tinted_note.dart';

class PharmacyWarningNote extends StatelessWidget {
  const PharmacyWarningNote({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return TintedNote(
      text: Strings.pharmacyWarningNote,
      backgroundColor: c.warningLight,
      textColor: c.warning,
    );
  }
}
