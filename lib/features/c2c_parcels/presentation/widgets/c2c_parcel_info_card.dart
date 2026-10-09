import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../utils/c2c_parcel_labels.dart';

/// What the parcel is, both ends and the price. Sender-only fields
/// (description, declared value, pickup instructions) come from
/// [C2cParcelDetails]' role-aware getters, so a recipient never sees them
/// even if a response carried them.
class C2cParcelInfoCard extends StatelessWidget {
  final C2cParcelDetails parcel;

  const C2cParcelInfoCard({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final C2cParcelItem item = parcel.item;
    final C2cPricing? pricing = parcel.pricing;
    final double? weight = item.weightKg;
    final double? declaredValue = parcel.declaredValue;
    final List<String> chips = <String>[
      if (item.category != null) item.category!.label,
      if (weight != null) Strings.c2cTrackingWeight(formatAmount(weight)),
      if (item.isFragile) Strings.sendParcelFragile,
      if (parcel.imageCount > 0)
        Strings.c2cTrackingPhotos('${parcel.imageCount}'),
    ];

    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.c2cTrackingDetailsTitle,
            style: AppTextStyles.title(color: c.textPrimary),
          ),
          if (item.title case final String title) ...<Widget>[
            SizedBox(height: AppSpacing.xs.h),
            Text(title, style: AppTextStyles.titleSmall(color: c.primary)),
          ],
          if (chips.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSpacing.sm.h),
            Wrap(
              spacing: AppSpacing.xs.w,
              runSpacing: AppSpacing.xs.h,
              children: <Widget>[
                for (final String chip in chips)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: c.secondaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      chip,
                      style: AppTextStyles.label(color: c.secondaryDark),
                    ),
                  ),
              ],
            ),
          ],
          _Line(
            label: Strings.c2cTrackingDescription,
            value: parcel.description,
          ),
          _Line(
            label: Strings.c2cTrackingDeclaredValue,
            value: declaredValue == null ? null : formatSar(declaredValue),
          ),
          _Line(
            label: Strings.c2cTrackingPickupInstructions,
            value: parcel.pickupInstructions,
          ),
          _Line(
            label: Strings.c2cTrackingDeliveryInstructions,
            value: item.deliveryInstructions,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
            child: Divider(height: 1, color: c.border),
          ),
          _Party(
            icon: Icons.outbox_outlined,
            label: Strings.c2cTrackingSender,
            party: parcel.sender,
          ),
          SizedBox(height: AppSpacing.sm.h),
          _Party(
            icon: Icons.move_to_inbox_outlined,
            label: Strings.c2cTrackingRecipient,
            party: parcel.recipient,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
            child: Divider(height: 1, color: c.border),
          ),
          _Line(
            label: Strings.c2cTrackingPayment,
            value: parcel.paymentMethod.label,
            dense: true,
          ),
          if (pricing != null)
            _Line(
              label: Strings.c2cTrackingTotal,
              value:
                  '${formatAmount(pricing.totalFee)} '
                  '${currencySymbol(pricing.currency)}',
              dense: true,
              emphasize: true,
            ),
        ],
      ),
    );
  }
}

/// A labelled value; nothing at all when [value] is null.
class _Line extends StatelessWidget {
  final String label;
  final String? value;
  final bool dense;
  final bool emphasize;

  const _Line({
    required this.label,
    required this.value,
    this.dense = false,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final String? text = value;
    if (text == null) return const SizedBox.shrink();
    final AppColors c = context.colors;
    final Widget valueText = Text(
      text,
      style: emphasize
          ? AppTextStyles.h2(color: c.secondary)
          : AppTextStyles.body(color: c.textPrimary),
    );
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm.h),
      child: dense
          ? Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                ),
                valueText,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
                valueText,
              ],
            ),
    );
  }
}

class _Party extends StatelessWidget {
  final IconData icon;
  final String label;
  final C2cParty party;

  const _Party({required this.icon, required this.label, required this.party});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String details = <String?>[
      party.address,
      ...party.details.values,
    ].whereType<String>().join(' · ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: c.secondary, size: 20.r),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: AppTextStyles.caption(color: c.textSecondary)),
              Text(
                <String?>[
                  party.name,
                  party.phone,
                ].whereType<String>().join(' · '),
                style: AppTextStyles.titleSmall(color: c.textPrimary),
              ),
              if (details.isNotEmpty)
                Text(
                  details,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
