import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/app_routes.dart';
import '../widgets/show_modal_bottom_sheet.dart';
import '../widgets/sign_in_required_sheet.dart';
import 'session_cubit.dart';

/// Gate for account-based features (profile, orders, parcels, checkout…).
///
/// True straight away for a signed-in customer. A guest is offered to sign
/// in: Login is *pushed*, so a successful sign-in pops back here and the
/// caller carries on with what the customer tapped. False if they decline
/// or back out.
///
/// ```dart
/// if (!await ensureSignedIn(context) || !context.mounted) return;
/// context.push(AppRoutes.notifications);
/// ```
Future<bool> ensureSignedIn(BuildContext context) async {
  if (context.read<SessionCubit>().state.isSignedIn) return true;
  final bool? wantsToSignIn = await showAppModalBottomSheet(
    context: context,
    child: const SignInRequiredSheet(),
  );
  if (wantsToSignIn != true || !context.mounted) return false;
  final bool? signedIn = await context.pushNamed<bool>(AppRoutes.loginName);
  return signedIn == true;
}
