import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/enum_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/locale_cubit/locale_cubit.dart';

/// Reference feature screen: reads the current locale from [LocaleCubit] and
/// writes the new one back through it, so the whole app rebuilds.
class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({super.key});

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  LanguageCode? _selected;

  @override
  Widget build(BuildContext context) {
    _selected ??= context.read<LocaleCubit>().currentLangCode;

    return Scaffold(
      appBar: AppBar(title: Text(Strings.language)),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: <Widget>[
            RadioGroup<LanguageCode>(
              groupValue: _selected,
              onChanged: (LanguageCode? value) =>
                  setState(() => _selected = value),
              child: Column(
                children: LanguageCode.values
                    .map((LanguageCode code) => _LanguageTile(code: code))
                    .toList(),
              ),
            ),
            const Spacer(),
            AppButton(
              btnText: Strings.confirm,
              onPressed: () async {
                await context.read<LocaleCubit>().changeLanguage(_selected!);
                if (context.mounted) Navigator.of(context).maybePop();
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageCode code;

  const _LanguageTile({required this.code});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(code.displayName, style: AppTextStyles.bodyLarge()),
      trailing: Radio<LanguageCode>(
        value: code,
        activeColor: context.colors.primary,
      ),
      onTap: () => RadioGroup.maybeOf<LanguageCode>(context)?.onChanged(code),
    );
  }
}
