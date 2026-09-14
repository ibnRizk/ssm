import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/auth_phone_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_toggle_link.dart';

/// Placeholder SSM delivery zones — swap for real data once the backend
/// exposes serviceable regions (the subscriptions and cart screens price
/// delivery per zone the same way).
const List<String> _ssmRegions = <String>[
  'تربة',
  'العلاوة',
  'الحايرية',
  'القويعية',
  'الحشرج',
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String? _region;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: wire to AuthCubit.register(name, phone, region) once the auth
    // API contract exists. For now this proves the screen and the flow.
    context.goNamed(AppRoutes.homeName);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.authRegisterTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1(color: context.colors.textPrimary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            Strings.authRegisterSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xxl.h),
          Text(
            Strings.authFullNameLabel,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.bodyLarge(color: context.colors.textPrimary),
            decoration: InputDecoration(hintText: Strings.authFullNameHint),
          ),
          SizedBox(height: AppSpacing.lg.h),
          Text(
            Strings.authPhoneLabel,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          AuthPhoneField(controller: _phoneController),
          SizedBox(height: AppSpacing.lg.h),
          Text(
            Strings.authRegionLabel,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          DropdownButtonFormField<String>(
            initialValue: _region,
            style: AppTextStyles.bodyLarge(color: context.colors.textPrimary),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: context.colors.textSecondary,
            ),
            decoration: InputDecoration(hintText: Strings.authRegionHint),
            items: _ssmRegions
                .map(
                  (String region) => DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  ),
                )
                .toList(),
            onChanged: (String? value) => setState(() => _region = value),
          ),
          SizedBox(height: AppSpacing.xl.h),
          AppButton(btnText: Strings.authRegisterButton, onPressed: _submit),
          SizedBox(height: AppSpacing.lg.h),
          AuthToggleLink(
            question: Strings.authHaveAccount,
            action: Strings.authLoginLink,
            onTap: () => context.goNamed(AppRoutes.loginName),
          ),
        ],
      ),
    );
  }
}
