import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/number_input.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/entities/c2c_parcel_draft.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/entities/c2c_parcel_status.dart';
import '../cubit/create_parcel_cubit.dart';
import '../cubit/create_parcel_state.dart';
import '../utils/c2c_parcel_labels.dart';
import '../widgets/c2c_contact_fields.dart';
import '../widgets/parcel_photos_picker.dart';
import '../widgets/parcel_price_breakdown.dart';

/// The details step of sending a parcel: both contacts, what's inside,
/// who pays, photos and the prohibited-items declaration. The ends,
/// category and weight are the quoted ones and can't change here — going
/// back re-prices them. Expects a [CreateParcelCubit] above it.
///
/// Stateful only to own the form key and the text controllers.
class CreateParcelScreen extends StatefulWidget {
  const CreateParcelScreen({super.key});

  @override
  State<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends State<CreateParcelScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final C2cContactControllers _sender = C2cContactControllers();
  final C2cContactControllers _recipient = C2cContactControllers();
  late final TextEditingController _title;
  final TextEditingController _description = TextEditingController();
  final TextEditingController _declaredValue = TextEditingController();
  final TextEditingController _pickupInstructions = TextEditingController();
  final TextEditingController _deliveryInstructions = TextEditingController();
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    // The quote step's title, when one was given.
    _title = TextEditingController(
      text: context.read<CreateParcelCubit>().state.request.title,
    );
  }

  @override
  void dispose() {
    _sender.dispose();
    _recipient.dispose();
    for (final TextEditingController c in <TextEditingController>[
      _title,
      _description,
      _declaredValue,
      _pickupInstructions,
      _deliveryInstructions,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CreateParcelCubit>().submit(
      CreateParcelForm(
        senderName: _sender.name.text,
        senderPhone: _sender.phone.text,
        senderAddress: _sender.address.text,
        senderBuilding: _sender.building.text,
        senderFloor: _sender.floor.text,
        senderApartment: _sender.apartment.text,
        senderNotes: _sender.notes.text,
        recipientName: _recipient.name.text,
        recipientPhone: _recipient.phone.text,
        recipientAddress: _recipient.address.text,
        recipientBuilding: _recipient.building.text,
        recipientFloor: _recipient.floor.text,
        recipientApartment: _recipient.apartment.text,
        recipientNotes: _recipient.notes.text,
        title: _title.text,
        description: _description.text,
        // The validator has already refused text that isn't an amount.
        declaredValue: NumberInput.parseAmount(_declaredValue.text),
        pickupInstructions: _pickupInstructions.text,
        deliveryInstructions: _deliveryInstructions.text,
        prohibitedItemsAcknowledged: _acknowledged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final TextStyle inputStyle = AppTextStyles.bodyLarge(color: c.textPrimary);
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.createParcelTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: _CreateFeedbackListener(
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
                  const _QuoteCard(),
                  SizedBox(height: AppSpacing.lg.h),
                  C2cContactFields(
                    title: Strings.createParcelSenderSection,
                    icon: Icons.outbox_outlined,
                    controllers: _sender,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  C2cContactFields(
                    title: Strings.createParcelRecipientSection,
                    icon: Icons.move_to_inbox_outlined,
                    controllers: _recipient,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  _Section(
                    title: Strings.createParcelItemSection,
                    icon: Icons.inventory_2_outlined,
                    children: <Widget>[
                      LabeledField(
                        label: Strings.createParcelItemTitleLabel,
                        child: TextFormField(
                          controller: _title,
                          textInputAction: TextInputAction.next,
                          maxLength: 120,
                          style: inputStyle,
                          decoration: InputDecoration(
                            hintText: Strings.createParcelItemTitleHint,
                            counterText: '',
                          ),
                          validator: (String? value) => Validator.call(
                            value: value,
                            type: ValidatorType.standard,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      LabeledField(
                        label: Strings.createParcelDescriptionLabel,
                        child: TextFormField(
                          controller: _description,
                          minLines: 2,
                          maxLines: 4,
                          maxLength: 1000,
                          style: inputStyle,
                          decoration: const InputDecoration(counterText: ''),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      LabeledField(
                        label: Strings.createParcelDeclaredValueLabel,
                        child: TextFormField(
                          controller: _declaredValue,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              NumberInput.amountCharacters,
                            ),
                          ],
                          style: inputStyle,
                          // Optional, but what's typed must be an amount —
                          // never silently dropped or misread.
                          validator: (String? value) =>
                              (value ?? '').trim().isEmpty ||
                                  NumberInput.parseAmount(value!) != null
                              ? null
                              : Strings.createParcelDeclaredValueInvalid,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      LabeledField(
                        label: Strings.createParcelPickupInstructionsLabel,
                        child: TextFormField(
                          controller: _pickupInstructions,
                          maxLength: 500,
                          style: inputStyle,
                          decoration: const InputDecoration(counterText: ''),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      LabeledField(
                        label: Strings.createParcelDeliveryInstructionsLabel,
                        child: TextFormField(
                          controller: _deliveryInstructions,
                          maxLength: 500,
                          style: inputStyle,
                          decoration: const InputDecoration(counterText: ''),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  _Section(
                    title: Strings.createParcelPhotosSection,
                    icon: Icons.photo_camera_outlined,
                    children: const <Widget>[_Photos()],
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  _Section(
                    title: Strings.createParcelPaymentSection,
                    icon: Icons.payments_outlined,
                    children: const <Widget>[_PaymentSelector()],
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  FormField<bool>(
                    validator: (_) => _acknowledged
                        ? null
                        : Strings.createParcelAcknowledgeRequired,
                    builder: (FormFieldState<bool> field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CheckboxListTile(
                          value: _acknowledged,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: c.secondary,
                          title: Text(
                            Strings.createParcelAcknowledge,
                            style: AppTextStyles.caption(color: c.textPrimary),
                          ),
                          onChanged: (bool? value) {
                            setState(() => _acknowledged = value ?? false);
                            field.didChange(_acknowledged);
                          },
                        ),
                        if (field.errorText case final String error)
                          Text(
                            error,
                            style: AppTextStyles.caption(color: c.error),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  BlocSelector<CreateParcelCubit, CreateParcelState, bool>(
                    selector: (CreateParcelState state) =>
                        state.submitting || state.requoting,
                    builder: (BuildContext context, bool busy) => AppButton(
                      btnText: Strings.createParcelSubmit,
                      isLoading: busy,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The accepted trip and price, read-only. Updates when a lapsed price is
/// replaced.
class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocBuilder<CreateParcelCubit, CreateParcelState>(
      buildWhen: (CreateParcelState previous, CreateParcelState current) =>
          previous.quote != current.quote,
      builder: (BuildContext context, CreateParcelState state) {
        final C2cParcelQuote quote = state.quote;
        final C2cQuoteRequest request = state.request;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              Strings.createParcelTripSummary(
                formatAmount(quote.distanceKm ?? 0),
                request.category.label,
                formatAmount(request.weightKg),
              ),
              style: AppTextStyles.caption(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.xs.h),
            ParcelPriceBreakdown(
              baseTotalFee: quote.baseTotalFee,
              subscriptionDiscount: quote.appliedSubscription == null
                  ? null
                  : quote.subscriptionDiscount,
              totalFee: quote.totalFee,
              currency: quote.currency,
            ),
          ],
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: c.secondary, size: 20.r),
              SizedBox(width: AppSpacing.xs.w),
              Text(title, style: AppTextStyles.title(color: c.textPrimary)),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          ...children,
        ],
      ),
    );
  }
}

class _Photos extends StatelessWidget {
  const _Photos();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      CreateParcelCubit,
      CreateParcelState,
      (List<C2cParcelPhoto>, bool)
    >(
      selector: (CreateParcelState state) => (state.photos, state.picking),
      builder: (BuildContext context, (List<C2cParcelPhoto>, bool) slice) =>
          ParcelPhotosPicker(
            photos: slice.$1,
            picking: slice.$2,
            onAdd: context.read<CreateParcelCubit>().pickPhotos,
            onRemove: context.read<CreateParcelCubit>().removePhoto,
          ),
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<CreateParcelCubit, CreateParcelState, C2cPaymentMethod>(
      selector: (CreateParcelState state) => state.paymentMethod,
      builder: (BuildContext context, C2cPaymentMethod selected) => Column(
        children: <Widget>[
          for (final C2cPaymentMethod method in C2cPaymentMethod.values)
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                onTap: () =>
                    context.read<CreateParcelCubit>().setPaymentMethod(method),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                    border: Border.all(
                      color: method == selected ? c.secondary : c.border,
                      width: method == selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        method == selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: method == selected ? c.secondary : c.textHint,
                        size: 20.r,
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Expanded(
                        child: Text(
                          method.label,
                          style: AppTextStyles.body(color: c.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Snack bars and the price-changed dialog; on success, the new parcel's
/// tracking screen replaces this flow. Never rebuilds [child].
class _CreateFeedbackListener extends StatelessWidget {
  final Widget child;

  const _CreateFeedbackListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<CreateParcelCubit, CreateParcelState>>[
        BlocListener<CreateParcelCubit, CreateParcelState>(
          listenWhen: (CreateParcelState previous, CreateParcelState current) =>
              current.notice != null,
          listener: (BuildContext context, CreateParcelState state) {
            switch (state.notice) {
              case PriceChanged(:final C2cParcelQuote quote):
                showDialog<void>(
                  context: context,
                  builder: (BuildContext dialogContext) => AlertDialog(
                    title: Text(Strings.createParcelPriceChangedTitle),
                    content: Text(
                      Strings.createParcelPriceChangedMessage(
                        '${formatAmount(quote.totalFee)} '
                        '${currencySymbol(quote.currency)}',
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(Strings.ok),
                      ),
                    ],
                  ),
                );
              case PhotosRejected(:final issue):
                showAppSnackBar(
                  context: context,
                  message: issue.message,
                  type: ToastType.warning,
                );
              case PhotosRequired():
                showAppSnackBar(
                  context: context,
                  message: Strings.createParcelPhotosRequired,
                  type: ToastType.warning,
                );
              case MaybeAlreadySent():
                showAppSnackBar(
                  context: context,
                  message: Strings.createParcelMaybeSent,
                  type: ToastType.warning,
                );
              case CreateFailed(:final failure):
                showAppSnackBar(
                  context: context,
                  message: failure.c2cMessage,
                  type: ToastType.error,
                );
              case null:
                break;
            }
          },
        ),
        BlocListener<CreateParcelCubit, CreateParcelState>(
          listenWhen: (CreateParcelState previous, CreateParcelState current) =>
              previous.created == null && current.created != null,
          listener: (BuildContext context, CreateParcelState state) {
            showAppSnackBar(
              context: context,
              message: Strings.createParcelCreated,
              type: ToastType.success,
            );
            // Back is the Parcels tab, not the finished form.
            final GoRouter router = GoRouter.of(context);
            router.go(AppRoutes.parcels);
            router.push(AppRoutes.c2cParcelPath(state.created!.id));
          },
        ),
      ],
      child: child,
    );
  }
}
