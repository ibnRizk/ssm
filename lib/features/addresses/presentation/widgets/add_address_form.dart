import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../domain/entities/address.dart';
import '../cubit/add_address_cubit.dart';
import '../cubit/add_address_state.dart';
import '../utils/address_messages.dart';
import 'address_location_field.dart';
import 'address_type_selector.dart';

/// Type, contact name/phone, street details and GPS location — every field
/// `POST /customer/address/add` requires.
class AddAddressForm extends StatefulWidget {
  const AddAddressForm({super.key});

  @override
  State<AddAddressForm> createState() =>
      _AddAddressFormState();
}

class _AddAddressFormState extends State<AddAddressForm> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  AddressType _type = AddressType.home;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false))
      return;
    context.read<AddAddressCubit>().submit(
      type: _type,
      contactPersonName: _nameController.text,
      contactPersonNumber: _phoneController.text,
      address: _addressController.text,
    );
  }

  void _onStateChanged(
    BuildContext context,
    AddAddressState state,
  ) {
    if (state.status == AddAddressStatus.success) {
      showAppSnackBar(
        context: context,
        message: Strings.addressAdded,
        type: ToastType.success,
      );
      context.pop(true);
      return;
    }
    // Location problems (incl. out of coverage) show under the location
    // row instead — see [AddressLocationField].
    final failure = state.failure;
    if (failure != null && !failure.isLocationProblem) {
      showAppSnackBar(
        context: context,
        message: failure.addressmssage,
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle inputStyle = AppTextStyles.bodyLarge(
      color: context.colors.textPrimary,
    );

    return BlocListener<AddAddressCubit, AddAddressState>(
      listenWhen:
          (
            AddAddressState previous,
            AddAddressState current,
          ) =>
              previous.status != current.status ||
              previous.failure != current.failure,
      listener: _onStateChanged,
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
                label: Strings.addressTypeLabel,
                child: AddressTypeSelector(
                  selected: _type,
                  onChanged: (AddressType type) =>
                      setState(() => _type = type),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              LabeledField(
                label: Strings.addressLocationLabel,
                child: const AddressLocationField(),
              ),
              SizedBox(height: AppSpacing.lg.h),
              LabeledField(
                label: Strings.addressDetailsLabel,
                child: TextFormField(
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.streetAddress,
                  minLines: 2,
                  maxLines: 4,
                  style: inputStyle,
                  decoration: InputDecoration(
                    hintText: Strings.addressDetailsHint,
                  ),
                  validator: (String? value) =>
                      Validator.call(
                        value: value,
                        type: ValidatorType.standard,
                      ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              LabeledField(
                label: Strings.addressContactNameLabel,
                child: TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization:
                      TextCapitalization.words,
                  autofillHints: const <String>[
                    AutofillHints.name,
                  ],
                  style: inputStyle,
                  decoration: InputDecoration(
                    hintText:
                        Strings.addressContactNameHint,
                  ),
                  validator: (String? value) =>
                      Validator.call(
                        value: value,
                        type: ValidatorType.standard,
                      ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              LabeledField(
                label: Strings.addressContactPhoneLabel,
                child: PhoneField(
                  controller: _phoneController,
                  textInputAction: TextInputAction.done,
                ),
              ),
              SizedBox(height: AppSpacing.xl.h),
              // Only the button rebuilds while a request runs.
              BlocSelector<
                AddAddressCubit,
                AddAddressState,
                (bool, bool)
              >(
                selector: (AddAddressState state) => (
                  state.status ==
                      AddAddressStatus.submitting,
                  state.isBusy,
                ),
                builder:
                    (
                      BuildContext context,
                      (bool, bool) flags,
                    ) {
                      final (
                        bool isSubmitting,
                        bool isBusy,
                      ) = flags;
                      return AppButton(
                        btnText: Strings.save,
                        isLoading: isSubmitting,
                        onPressed: isBusy ? null : _submit,
                      );
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
