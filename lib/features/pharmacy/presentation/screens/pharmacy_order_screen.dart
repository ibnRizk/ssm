import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../../domain/entities/prescription_image.dart';
import '../../domain/repos/pharmacy_repository.dart';
import '../cubit/pharmacy_order_cubit.dart';
import '../cubit/pharmacy_order_state.dart';
import '../utils/pharmacy_messages.dart';
import '../widgets/pharmacy_attachment_box.dart';
import '../widgets/pharmacy_dropdown_field.dart';
import '../widgets/pharmacy_header.dart';
import '../widgets/pharmacy_option_sheet.dart';
import '../widgets/pharmacy_request_field.dart';
import '../widgets/pharmacy_selection_banner.dart';
import '../widgets/pharmacy_warning_note.dart';

/// Pharmacy order tab body. The bottom navigation bar and its Scaffold live
/// in [MainScaffold] — this widget is only the scrollable content for that
/// tab. Expects a [PharmacyOrderCubit] above it (provided at the route).
///
/// Stateful only to own the request text's controller.
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

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return _PharmacyFeedbackListener(
      child: SafeArea(
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
              const _PharmacyChoices(),
              SizedBox(height: AppSpacing.xl.h),
              Text(
                Strings.pharmacyRequestLabel,
                style: AppTextStyles.body(color: c.textSecondary),
              ),
              SizedBox(height: AppSpacing.xs.h),
              PharmacyRequestField(controller: _requestController),
              SizedBox(height: AppSpacing.lg.h),
              const _Attachment(),
              SizedBox(height: AppSpacing.lg.h),
              const PharmacyWarningNote(),
              SizedBox(height: AppSpacing.xl.h),
              BlocSelector<PharmacyOrderCubit, PharmacyOrderState, bool>(
                selector: (PharmacyOrderState state) => state.submitting,
                builder: (BuildContext context, bool submitting) => AppButton(
                  btnText: Strings.pharmacySubmitButton,
                  isLoading: submitting,
                  onPressed: () => context.read<PharmacyOrderCubit>().submit(
                    _requestController.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The pharmacy and delivery-address pickers, once there's something to
/// pick from.
class _PharmacyChoices extends StatelessWidget {
  const _PharmacyChoices();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocBuilder<PharmacyOrderCubit, PharmacyOrderState>(
      buildWhen: (PharmacyOrderState previous, PharmacyOrderState current) =>
          previous.options != current.options ||
          previous.pharmacyId != current.pharmacyId ||
          previous.addressId != current.addressId,
      builder: (BuildContext context, PharmacyOrderState state) =>
          switch (state.options) {
            PharmacyOptionsLoading() => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
            PharmacyOptionsError(:final failure) => ErrorText(
              message: failure.userMessage,
              margin: EdgeInsets.zero,
              onRetry: () => context.read<PharmacyOrderCubit>().loadOptions(),
            ),
            PharmacyOptionsLoaded(:final pharmacies, :final addresses) =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PharmacySelectionBanner(
                    selectedName: state.selectedPharmacy?.name,
                    onTap: () => _pickPharmacy(context, pharmacies, state),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    Strings.pharmacyAddressLabel,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  PharmacyDropdownField(
                    label: switch (state.selectedAddress) {
                      final Address address => address.address,
                      null when addresses.isEmpty => Strings.pharmacyAddAddress,
                      null => Strings.pharmacyAddressPlaceholder,
                    },
                    onTap: addresses.isEmpty
                        ? () => _addAddress(context)
                        : () => _pickAddress(context, addresses, state),
                  ),
                ],
              ),
          },
    );
  }

  Future<void> _pickPharmacy(
    BuildContext context,
    List<Store> pharmacies,
    PharmacyOrderState state,
  ) async {
    final PharmacyOrderCubit cubit = context.read<PharmacyOrderCubit>();
    final int? picked = await PharmacyOptionSheet.show(
      context,
      title: Strings.pharmacySelectTitle,
      emptyText: Strings.pharmacyNoPharmacies,
      selectedId: state.pharmacyId,
      options: <PharmacyOption>[
        for (final Store store in pharmacies)
          PharmacyOption(
            id: store.id,
            title: store.name,
            subtitle: store.address,
          ),
      ],
    );
    if (picked != null) cubit.selectPharmacy(picked);
  }

  Future<void> _pickAddress(
    BuildContext context,
    List<Address> addresses,
    PharmacyOrderState state,
  ) async {
    final PharmacyOrderCubit cubit = context.read<PharmacyOrderCubit>();
    final int? picked = await PharmacyOptionSheet.show(
      context,
      title: Strings.pharmacyAddressLabel,
      emptyText: Strings.pharmacyAddAddress,
      selectedId: state.addressId,
      options: <PharmacyOption>[
        for (final Address address in addresses)
          PharmacyOption(
            id: address.id,
            title: address.address,
            subtitle: address.contactPersonName,
          ),
      ],
    );
    if (picked != null) cubit.selectAddress(picked);
  }

  /// Add Address pops `true` on save — then the new address is offered.
  Future<void> _addAddress(BuildContext context) async {
    final PharmacyOrderCubit cubit = context.read<PharmacyOrderCubit>();
    final bool? added = await context.push<bool>(AppRoutes.addAddress);
    if (added ?? false) await cubit.loadOptions();
  }
}

class _Attachment extends StatelessWidget {
  const _Attachment();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      PharmacyOrderCubit,
      PharmacyOrderState,
      (PrescriptionImage?, bool)
    >(
      selector: (PharmacyOrderState state) =>
          (state.prescription, state.picking),
      builder: (BuildContext context, (PrescriptionImage?, bool) slice) =>
          PharmacyAttachmentBox(
            image: slice.$1,
            picking: slice.$2,
            onPick: () => _chooseSource(context),
            onRemove: () =>
                context.read<PharmacyOrderCubit>().removePrescription(),
          ),
    );
  }

  Future<void> _chooseSource(BuildContext context) async {
    final PharmacyOrderCubit cubit = context.read<PharmacyOrderCubit>();
    final PrescriptionSource? source =
        await showModalBottomSheet<PrescriptionSource>(
          context: context,
          builder: (BuildContext context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(Strings.pharmacyTakePhoto),
                  onTap: () =>
                      Navigator.pop(context, PrescriptionSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(Strings.pharmacyChoosePhoto),
                  onTap: () =>
                      Navigator.pop(context, PrescriptionSource.gallery),
                ),
              ],
            ),
          ),
        );
    if (source != null) await cubit.pickPrescription(source);
  }
}

/// Snackbars for notices, and the confirmation — with the backend's price
/// disclaimer — once the request is sent. Never rebuilds [child].
class _PharmacyFeedbackListener extends StatelessWidget {
  final Widget child;

  const _PharmacyFeedbackListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PharmacyOrderCubit, PharmacyOrderState>(
          listenWhen:
              (PharmacyOrderState previous, PharmacyOrderState current) =>
                  current.notice != null && previous.notice != current.notice,
          listener: (BuildContext context, PharmacyOrderState state) =>
              showAppSnackBar(
                context: context,
                message: state.notice!.message,
                type: state.notice is PharmacyActionFailed
                    ? ToastType.error
                    : ToastType.warning,
              ),
        ),
        BlocListener<PharmacyOrderCubit, PharmacyOrderState>(
          listenWhen:
              (PharmacyOrderState previous, PharmacyOrderState current) =>
                  previous.receipt == null && current.receipt != null,
          listener: (BuildContext context, PharmacyOrderState state) =>
              _confirmSent(context, state.receipt!),
        ),
      ],
      child: child,
    );
  }

  Future<void> _confirmSent(
    BuildContext context,
    PharmacyRequestReceipt receipt,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(Strings.pharmacySentTitle),
        content: Text(receipt.warning ?? Strings.pharmacyWarningNote),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Strings.ok),
          ),
        ],
      ),
    );
    if (context.mounted) context.pop();
  }
}
