/// Drops order status events that are older than one already seen.
///
/// The API guide: "ignore any with a lower `status_version` than you have".
/// An equal version is dropped too — the same change arrives once on
/// `private-customer.{id}` and again on `private-order.{id}`, and the second
/// copy would only trigger a duplicate refetch.
class StatusVersionGate {
  final Map<int, int> _latest = <int, int>{};

  /// Whether an event for [orderId] at [version] should be acted on. One
  /// without a version can't be ordered, so it's always admitted.
  bool admit(int orderId, int? version) {
    if (version == null) return true;
    final int? seen = _latest[orderId];
    if (seen != null && version <= seen) return false;
    _latest[orderId] = version;
    return true;
  }

  /// A new session starts from scratch.
  void reset() => _latest.clear();
}
