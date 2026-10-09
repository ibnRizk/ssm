import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/delivery_otp_card.dart';
import '../../domain/entities/c2c_parcel_status.dart';
import '../cubit/c2c_parcel_tracking_cubit.dart';
import '../cubit/c2c_parcel_tracking_state.dart';
import '../utils/c2c_parcel_labels.dart';

/// Bottom sheets of the tracking screen. Each one is opened with the
/// screen's cubit, since a sheet is a new route outside its provider.
abstract final class C2cParcelSheets {
  /// Shows the delivery (or return) code, fetching one first if none is
  /// shown yet. The sheet follows the cubit, so "new code" updates it.
  static Future<void> showOtp(BuildContext context) {
    final C2cParcelTrackingCubit cubit = context.read<C2cParcelTrackingCubit>();
    final C2cParcelTrackingState state = cubit.state;
    if (state is C2cTrackingLoaded && state.otp is! OtpReady) {
      cubit.requestOtp();
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider<C2cParcelTrackingCubit>.value(
        value: cubit,
        child: const _OtpSheet(),
      ),
    );
  }

  /// Asks for a reason (and an optional note), then cancels.
  static Future<void> showCancel(BuildContext context) async {
    final C2cParcelTrackingCubit cubit = context.read<C2cParcelTrackingCubit>();
    final (C2cCancelReason, String)? answer =
        await showModalBottomSheet<(C2cCancelReason, String)>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _CancelSheet(),
        );
    if (answer != null) await cubit.cancel(answer.$1, note: answer.$2);
  }

  /// Asks for a reason and a description, then opens a support case.
  static Future<void> showSupport(BuildContext context) async {
    final C2cParcelTrackingCubit cubit = context.read<C2cParcelTrackingCubit>();
    final (C2cSupportReason, String)? answer =
        await showModalBottomSheet<(C2cSupportReason, String)>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _SupportSheet(),
        );
    if (answer != null) await cubit.openSupportCase(answer.$1, answer.$2);
  }
}

class _OtpSheet extends StatelessWidget {
  const _OtpSheet();

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      child: BlocBuilder<C2cParcelTrackingCubit, C2cParcelTrackingState>(
        buildWhen:
            (C2cParcelTrackingState previous, C2cParcelTrackingState current) =>
                previous is! C2cTrackingLoaded ||
                current is! C2cTrackingLoaded ||
                previous.otp != current.otp ||
                previous.details.status != current.details.status,
        builder: (BuildContext context, C2cParcelTrackingState state) {
          if (state is! C2cTrackingLoaded) return const SizedBox.shrink();
          final bool isReturn = state.details.status.allowsReturnOtp;
          return DeliveryOtpCard(
            otp: state.otp,
            title: isReturn
                ? Strings.c2cTrackingReturnOtpTitle
                : Strings.c2cTrackingOtpTitle,
            subtitle: state.details.reference,
            hint: isReturn
                ? Strings.c2cTrackingOtpHintReturn
                : Strings.c2cTrackingOtpHintDelivery,
            onRequest: context.read<C2cParcelTrackingCubit>().requestOtp,
          );
        },
      ),
    );
  }
}

/// Stateful only for the picked reason and the note's controller.
class _CancelSheet extends StatefulWidget {
  const _CancelSheet();

  @override
  State<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<_CancelSheet> {
  C2cCancelReason _reason = C2cCancelReason.senderCancelled;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return _SheetFrame(
      title: Strings.c2cTrackingCancelTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            Strings.c2cTrackingReasonLabel,
            style: AppTextStyles.body(color: c.textSecondary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          _ReasonChips<C2cCancelReason>(
            values: C2cCancelReason.values,
            selected: _reason,
            label: (C2cCancelReason r) => r.label,
            onSelected: (C2cCancelReason r) => setState(() => _reason = r),
          ),
          SizedBox(height: AppSpacing.md.h),
          TextField(
            controller: _note,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: Strings.c2cTrackingNoteHint,
              counterText: '',
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          AppButton(
            btnText: Strings.c2cTrackingCancelConfirm,
            color: c.error,
            onPressed: () => Navigator.pop<(C2cCancelReason, String)>(context, (
              _reason,
              _note.text,
            )),
          ),
        ],
      ),
    );
  }
}

/// Stateful only for the picked reason and the description's controller.
class _SupportSheet extends StatefulWidget {
  const _SupportSheet();

  @override
  State<_SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends State<_SupportSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  C2cSupportReason _reason = C2cSupportReason.other;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _description = TextEditingController();
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _send() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop<(C2cSupportReason, String)>(context, (
      _reason,
      _description.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return _SheetFrame(
      title: Strings.c2cTrackingSupportTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              Strings.c2cTrackingReasonLabel,
              style: AppTextStyles.body(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.xs.h),
            _ReasonChips<C2cSupportReason>(
              values: C2cSupportReason.values,
              selected: _reason,
              label: (C2cSupportReason r) => r.label,
              onSelected: (C2cSupportReason r) => setState(() => _reason = r),
            ),
            SizedBox(height: AppSpacing.md.h),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: Strings.c2cTrackingSupportDescription,
                counterText: '',
              ),
              validator: (String? value) => (value ?? '').trim().length < 5
                  ? Strings.c2cTrackingSupportTooShort
                  : null,
            ),
            SizedBox(height: AppSpacing.lg.h),
            AppButton(
              btnText: Strings.c2cTrackingSupportSend,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonChips<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  const _ReasonChips({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Wrap(
      spacing: AppSpacing.xs.w,
      runSpacing: AppSpacing.xs.h,
      children: <Widget>[
        for (final T value in values)
          ChoiceChip(
            label: Text(
              label(value),
              style: AppTextStyles.body(
                color: value == selected ? Colors.white : c.textPrimary,
              ),
            ),
            selected: value == selected,
            showCheckmark: false,
            selectedColor: c.primary,
            backgroundColor: c.surface,
            side: BorderSide(color: value == selected ? c.primary : c.border),
            onSelected: (_) => onSelected(value),
          ),
      ],
    );
  }
}

/// Padding, an optional title, and room for the keyboard.
class _SheetFrame extends StatelessWidget {
  final String? title;
  final Widget child;

  const _SheetFrame({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final String? title = this.title;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.lg.h,
          AppSpacing.screen.w,
          AppSpacing.lg.h + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (title != null) ...<Widget>[
                Text(
                  title,
                  style: AppTextStyles.h2(color: context.colors.textPrimary),
                ),
                SizedBox(height: AppSpacing.md.h),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
