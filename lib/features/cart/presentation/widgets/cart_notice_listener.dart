import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

/// Shows the cart's one-shot notices — a failed change, a line that was
/// already gone, a store conflict — wherever the cart can be changed.
/// Never rebuilds [child].
class CartNoticeListener extends StatefulWidget {
  final Widget child;

  const CartNoticeListener({super.key, required this.child});

  @override
  State<CartNoticeListener> createState() => _CartNoticeListenerState();
}

class _CartNoticeListenerState extends State<CartNoticeListener> {
  /// One store-conflict dialog at a time; later conflicts are dropped
  /// while it's open.
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listenWhen: (CartState previous, CartState current) =>
          current is CartLoaded &&
          current.notice != null &&
          (previous is! CartLoaded || previous.notice != current.notice),
      listener: (BuildContext context, CartState state) {
        switch ((state as CartLoaded).notice!) {
          case CartActionFailed(:final failure):
            showAppSnackBar(
              context: context,
              message: failure.userMessage,
              type: ToastType.error,
            );
          case CartLineGone():
            showAppSnackBar(
              context: context,
              message: Strings.cartLineGone,
              type: ToastType.info,
            );
          case CartStoreConflict(:final request):
            _confirmReplace(context, request);
        }
      },
      child: widget.child,
    );
  }

  Future<void> _confirmReplace(
    BuildContext context,
    CartItemRequest request,
  ) async {
    if (_confirming) return;
    _confirming = true;
    final CartCubit cubit = context.read<CartCubit>();
    final bool? replace = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(Strings.cartOtherStoreTitle),
        content: Text(Strings.cartOtherStoreBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(Strings.cartOtherStoreConfirm),
          ),
        ],
      ),
    );
    _confirming = false;
    if (replace ?? false) await cubit.replaceCartWith(request);
  }
}
