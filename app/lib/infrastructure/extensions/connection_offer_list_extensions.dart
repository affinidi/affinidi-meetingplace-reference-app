import 'package:meeting_place_core/meeting_place_core.dart';

/// Small helper on `List<ConnectionOffer>` to compute UI badge counts.
extension ConnectionListExtensions on List<ConnectionOffer> {
  /// Counts offers that are not finalised (i.e., need attention).
  int get badgeCount {
    return where(
      (connection) =>
          connection.status == ConnectionOfferStatus.published ||
          connection.status == ConnectionOfferStatus.accepted,
    ).length;
  }
}
