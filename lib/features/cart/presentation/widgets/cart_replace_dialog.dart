import 'package:flutter/material.dart';

import '../../../../core/utils/values/strings.dart';

/// Asks whether to empty a cart that holds another store's items. [body]
/// says what would be added instead. True only when the customer agrees.
Future<bool> confirmCartReplace(
  BuildContext context, {
  required String body,
}) async {
  final bool? replace = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(Strings.cartOtherStoreTitle),
      content: Text(body),
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
  return replace ?? false;
}
