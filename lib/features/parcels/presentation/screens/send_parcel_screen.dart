import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../cubit/send_parcel_cubit.dart';
import '../cubit/send_parcel_state.dart';
import '../widgets/parcel_point_field.dart';
import '../widgets/parcel_quote_summary.dart';
import '../widgets/parcel_size_selector.dart';

/// Pushed from the Parcels tab. Prices a door-to-door parcel: both ends,
/// size, weight and whether it's fragile; the server applies the
/// customer's parcel plan when one fits. Expects a [SendParcelCubit] above
/// it (provided at the route).
///
/// Stateful only to own the form key and the text controllers.
class SendParcelScreen extends StatefulWidget {
  const SendParcelScreen({super.key});

  @override
  State<SendParcelScreen> createState() => _SendParcelScreenState();
}

class _SendParcelScreenState extends State<SendParcelScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Accepts a decimal comma ("2,5") as well as a point.
  static double? _parseWeight(String? text) =>
      double.tryParse((text ?? '').trim().replaceAll(',', '.'));

  void _requestQuote() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<SendParcelCubit>().requestQuote(
      weightKg: _parseWeight(_weightController.text)!,
      title: _contentController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final TextStyle inputStyle = AppTextStyles.bodyLarge(color: c.textPrimary);
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.sendParcelTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: _LocationNoticeListener(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen.w,
              AppSpacing.lg.h,
              AppSpacing.screen.w,
              AppSpacing.xxl.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LabeledField(
                    label: Strings.sendParcelPickupLabel,
                    child: const ParcelPointField(end: ParcelEnd.pickup),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  LabeledField(
                    label: Strings.sendParcelDropoffLabel,
                    child: const ParcelPointField(end: ParcelEnd.dropoff),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  LabeledField(
                    label: Strings.sendParcelSizeLabel,
                    child: const _SizeSelector(),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  LabeledField(
                    label: Strings.sendParcelWeightLabel,
                    child: TextFormField(
                      controller: _weightController,
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      style: inputStyle,
                      decoration: InputDecoration(
                        hintText: Strings.sendParcelWeightHint,
                      ),
                      onChanged: (_) =>
                          context.read<SendParcelCubit>().inputsChanged(),
                      validator: (String? value) =>
                          (_parseWeight(value) ?? 0) > 0
                          ? null
                          : Strings.sendParcelWeightInvalid,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  LabeledField(
                    label: Strings.sendParcelContentLabel,
                    child: TextFormField(
                      controller: _contentController,
                      textInputAction: TextInputAction.done,
                      maxLength: 100,
                      style: inputStyle,
                      decoration: InputDecoration(
                        hintText: Strings.sendParcelContentHint,
                        counterText: '',
                      ),
                      onChanged: (_) =>
                          context.read<SendParcelCubit>().inputsChanged(),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  const _FragileSwitch(),
                  SizedBox(height: AppSpacing.lg.h),
                  BlocSelector<SendParcelCubit, SendParcelState, bool>(
                    selector: (SendParcelState state) =>
                        state.quote is QuoteLoading,
                    builder: (BuildContext context, bool isLoading) =>
                        AppButton(
                          btnText: Strings.sendParcelQuoteButton,
                          isLoading: isLoading,
                          onPressed: _requestQuote,
                        ),
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                  _QuoteResult(onRetry: _requestQuote),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SendParcelCubit, SendParcelState, ParcelSize>(
      selector: (SendParcelState state) => state.size,
      builder: (BuildContext context, ParcelSize size) => ParcelSizeSelector(
        selected: size,
        onChanged: context.read<SendParcelCubit>().setSize,
      ),
    );
  }
}

class _FragileSwitch extends StatelessWidget {
  const _FragileSwitch();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<SendParcelCubit, SendParcelState, bool>(
      selector: (SendParcelState state) => state.isFragile,
      builder: (BuildContext context, bool isFragile) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: isFragile,
        activeTrackColor: c.secondary,
        secondary: Icon(Icons.wine_bar_outlined, color: c.textSecondary),
        title: Text(
          Strings.sendParcelFragile,
          style: AppTextStyles.body(color: c.textPrimary),
        ),
        onChanged: context.read<SendParcelCubit>().setFragile,
      ),
    );
  }
}

/// The priced parcel, or why it couldn't be priced. Empty until asked and
/// after any input change.
class _QuoteResult extends StatelessWidget {
  final VoidCallback onRetry;

  const _QuoteResult({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SendParcelCubit, SendParcelState, QuoteStatus>(
      selector: (SendParcelState state) => state.quote,
      builder: (BuildContext context, QuoteStatus quote) => switch (quote) {
        QuoteReady(:final quote) => ParcelQuoteSummary(quote: quote),
        QuoteFailed(:final failure) => ErrorText(
          message: failure.userMessage,
          margin: EdgeInsets.zero,
          onRetry: onRetry,
        ),
        QuoteIdle() || QuoteLoading() => const SizedBox.shrink(),
      },
    );
  }
}

/// Snack bar for a failed GPS read. Never rebuilds [child].
class _LocationNoticeListener extends StatelessWidget {
  final Widget child;

  const _LocationNoticeListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendParcelCubit, SendParcelState>(
      listenWhen: (SendParcelState previous, SendParcelState current) =>
          current.notice != null,
      listener: (BuildContext context, SendParcelState state) =>
          showAppSnackBar(
            context: context,
            message: state.notice!.userMessage,
            type: ToastType.error,
          ),
      child: child,
    );
  }
}
