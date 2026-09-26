import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/values/strings.dart';
import 'simple_app_bar.dart';

/// Stand-in for a route whose real screen isn't built yet (Update Profile,
/// Addresses, Help & Support), so navigation to it works end to end today.
/// Replace the route's builder once the screen exists.
class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(title: title, onBack: () => context.pop()),
      body: Center(
        child: Text(
          Strings.comingSoon,
          style: AppTextStyles.title(color: c.textSecondary),
        ),
      ),
    );
  }
}
