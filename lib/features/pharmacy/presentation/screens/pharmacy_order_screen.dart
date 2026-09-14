import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/pharmacy_attachment_box.dart';
import '../widgets/pharmacy_delivery_fee_card.dart';
import '../widgets/pharmacy_dropdown_field.dart';
import '../widgets/pharmacy_header.dart';
import '../widgets/pharmacy_request_field.dart';
import '../widgets/pharmacy_selection_banner.dart';
import '../widgets/pharmacy_warning_note.dart';

/// Placeholder default until a real pharmacy-type picker exists.
const String _placeholderDropdownLabel = 'صيدلية الدواء';

/// Placeholder zone/fee — swap for the resolved delivery zone and a real
/// quoted fee once the pricing feature exists.
const String _placeholderDeliveryFeeLabel = 'رسوم التوصيل · تربة';
const String _placeholderDeliveryFeeAmount = '10 ر.س';

/// Pharmacy order tab body. The bottom navigation bar and its Scaffold live
/// in [MainScaffold] — this widget is only the scrollable content for that
/// tab.
class PharmacyOrderScreen extends StatefulWidget {
  const PharmacyOrderScreen({super.key});

  @override
  State<PharmacyOrderScreen> createState() => _PharmacyOrderScreenState();
}

class _PharmacyOrderScreenState extends State<PharmacyOrderScreen> {
  late final TextEditingController _requestController;

  @override
  void initState() {
    super.initState();
    _requestController = TextEditingController();
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: wire to the pharmacy order API once that contract exists.
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.lg.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PharmacyHeader(onBack: () => context.pop()),
            SizedBox(height: AppSpacing.lg.h),
            // TODO: open the pharmacy picker once that flow exists.
            const PharmacySelectionBanner(),
            SizedBox(height: AppSpacing.lg.h),
            // TODO: open the pharmacy-type picker once that flow exists.
            const PharmacyDropdownField(label: _placeholderDropdownLabel),
            SizedBox(height: AppSpacing.xl.h),
            Text(
              Strings.pharmacyRequestLabel,
              style: AppTextStyles.body(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.xs.h),
            PharmacyRequestField(controller: _requestController),
            SizedBox(height: AppSpacing.lg.h),
            const PharmacyAttachmentBox(),
            SizedBox(height: AppSpacing.lg.h),
            const PharmacyWarningNote(),
            SizedBox(height: AppSpacing.xl.h),
            const PharmacyDeliveryFeeCard(
              label: _placeholderDeliveryFeeLabel,
              feeLabel: _placeholderDeliveryFeeAmount,
            ),
            SizedBox(height: AppSpacing.lg.h),
            AppButton(
              btnText: Strings.pharmacySubmitButton,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
