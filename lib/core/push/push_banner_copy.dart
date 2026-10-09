import 'notification_target.dart';
import 'push_payload.dart';

/// The title and body a push banner shows.
///
/// Pushes carry no text, so a banner needs generic copy per target. It's
/// here rather than in `lang/*.json` on purpose: a push that arrives while
/// the app is in the background or killed is handled in a separate isolate
/// where `AppLocalizations` (and `'key'.tr`) were never set up. The same
/// copy is used in the foreground so a banner reads the same either way.
/// The inbox shows the server's own translated text.
class PushBannerCopy {
  final String title;
  final String body;

  const PushBannerCopy({required this.title, required this.body});

  /// [languageCode] is `ar` or `en`; anything else reads as Arabic, the
  /// app's default (see `AppSharedPreferences.getLanguageCode`).
  factory PushBannerCopy.forPayload(
    PushPayload payload, {
    required String languageCode,
  }) {
    final bool en = languageCode == 'en';
    final _Copy generic = switch (payload.target) {
      OrderTarget(:final int orderId) =>
        en
            ? _Copy('Order update', 'There is an update on order #$orderId.')
            : _Copy(
                'تحديث على طلبك',
                'يوجد تحديث جديد على الطلب رقم $orderId.',
              ),
      ParcelsTarget() || C2cParcelTarget() =>
        en
            ? const _Copy('Parcel update', 'There is an update on your parcel.')
            : const _Copy('تحديث على شحنتك', 'يوجد تحديث جديد على شحنتك.'),
      SubscriptionsTarget() =>
        en
            ? const _Copy(
                'Subscription update',
                'There is an update on your delivery subscription.',
              )
            : const _Copy(
                'تحديث على اشتراكك',
                'يوجد تحديث على اشتراك التوصيل.',
              ),
      InboxTarget() =>
        en
            ? const _Copy('New notification', 'Tap to view it.')
            : const _Copy('إشعار جديد', 'اضغط لعرض التفاصيل.'),
    };
    return PushBannerCopy(
      title: payload.title ?? generic.title,
      body: payload.body ?? generic.body,
    );
  }
}

class _Copy {
  final String title;
  final String body;

  const _Copy(this.title, this.body);
}
