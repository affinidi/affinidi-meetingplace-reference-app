import 'package:meeting_place_core/meeting_place_core.dart';

class PublishOfferRequest {
  const PublishOfferRequest({
    required this.headline,
    required this.description,
    required this.isGroupOffer,
    required this.selectedMediatorDid,
    required this.transport,
    this.expiryDate,
    this.maxUsages,
    this.score,
    this.customPhrase,
    this.contextKey,
  });

  final String headline;
  final String description;
  final bool isGroupOffer;
  final String selectedMediatorDid;
  final DateTime? expiryDate;
  final int? maxUsages;
  final int? score;
  final String? customPhrase;
  final String? contextKey;
  final ChannelTransport transport;
}
