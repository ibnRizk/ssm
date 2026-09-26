import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Search box for the stores list. Typing is debounced so the backend sees
/// one search per pause, not one per keystroke; submitting searches at once.
class StoresSearchField extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const StoresSearchField({super.key, required this.onSearch});

  @override
  State<StoresSearchField> createState() => _StoresSearchFieldState();
}

class _StoresSearchFieldState extends State<StoresSearchField> {
  static const Duration _debounce = Duration(milliseconds: 400);

  final TextEditingController _controller = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => widget.onSearch(value));
  }

  void _submit(String value) {
    _timer?.cancel();
    widget.onSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      onSubmitted: _submit,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.body(color: c.textPrimary),
      decoration: InputDecoration(
        hintText: Strings.homeSearchHint,
        hintStyle: AppTextStyles.body(color: c.textHint),
        prefixIcon: Icon(
          Icons.search,
          color: c.textSecondary,
          size: AppSizes.icon.r,
        ),
        filled: true,
        fillColor: c.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: c.primary),
        ),
      ),
    );
  }
}
