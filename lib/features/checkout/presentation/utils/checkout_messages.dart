import '../../../../core/error/failures.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/order_request.dart';
import '../../domain/repos/checkout_repository.dart';
import '../cubit/checkout_state.dart';

extension CheckoutNoticeMessage on CheckoutNotice {
  /// Known refusals get our own wording (the guide says to branch on the
  /// code, not the message); any other refusal shows the server's message.
  String get message => switch (this) {
    CheckoutIncomplete(:final CheckoutIssue issue) => switch (issue) {
      CheckoutIssue.emptyCart => Strings.checkoutEmptyCart,
      CheckoutIssue.unknownStore => Strings.checkoutUnknownStore,
      CheckoutIssue.noAddress => Strings.checkoutNoAddress,
      CheckoutIssue.addressWithoutLocation =>
        Strings.checkoutAddressWithoutLocation,
    },
    CheckoutFailed(
      failure: ForbiddenFailure(code: OrderRefusalCode.coordinates),
    ) =>
      Strings.checkoutOutOfCoverage,
    CheckoutFailed(
      failure: ForbiddenFailure(code: OrderRefusalCode.orderAmount),
    ) =>
      Strings.checkoutCodLimit,
    CheckoutFailed(:final Failure failure) => failure.userMessage,
  };
}
