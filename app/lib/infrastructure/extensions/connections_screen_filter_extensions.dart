import 'package:meeting_place_core/meeting_place_core.dart';

import '../../presentation/screens/connections/connections_screen_filter.dart';

/// Map UI filter values to the corresponding set of ConnectionOfferStatus.
extension ConnectionsScreenFilterExtensions on ConnectionsScreenFilter {
  Set<ConnectionOfferStatus> get statuses {
    switch (this) {
      case ConnectionsScreenFilter.offers:
        return {ConnectionOfferStatus.published};
      case ConnectionsScreenFilter.claims:
        return {ConnectionOfferStatus.accepted};
      case ConnectionsScreenFilter.complete:
        return {
          ConnectionOfferStatus.channelInaugurated,
          ConnectionOfferStatus.finalised,
        };
      case ConnectionsScreenFilter.all:
        return ConnectionOfferStatus.values.toSet();
    }
  }
}
