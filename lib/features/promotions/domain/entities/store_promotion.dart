import 'package:equatable/equatable.dart';

/// A featured store's banner on Home. Tapping it opens the store in the app
/// by [storeId] — never a URL from the response.
class StorePromotion extends Equatable {
  final int id;
  final int storeId;

  /// Shown in place of the banner when there's none or it fails to load.
  final String? storeName;

  /// Absolute http(s) URL of the phone banner (designed at 4:5); null when
  /// the admin uploaded none. Never null together with [storeName].
  final String? bannerUrl;

  /// Absolute http(s) URL; null when the store has no video.
  final String? videoUrl;

  const StorePromotion({
    required this.id,
    required this.storeId,
    this.storeName,
    this.bannerUrl,
    this.videoUrl,
  });

  bool get hasVideo => videoUrl != null;

  @override
  List<Object?> get props => [id, storeId, storeName, bannerUrl, videoUrl];
}
