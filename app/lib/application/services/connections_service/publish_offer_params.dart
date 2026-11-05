import 'package:meeting_place_core/meeting_place_core.dart';

class PublishOfferParams {
  const PublishOfferParams({
    required this.headline,
    required this.description,
    required this.isGroupOffer,
    required this.selectedMediatorDid,
    required this.transport,
    this.expiryDate,
    this.maxUsages,
    this.score,
    this.customPhrase,
    this.groupDid,
  });

  final String headline;
  final String description;
  final bool isGroupOffer;
  final String selectedMediatorDid;
  final DateTime? expiryDate;
  final int? maxUsages;
  final int? score;
  final String? customPhrase;
  final ChannelTransport transport;

  /// For a group offer, the DID the group is known by when it is held
  /// elsewhere, such as a community group's; null for a new one.
  final String? groupDid;
}
