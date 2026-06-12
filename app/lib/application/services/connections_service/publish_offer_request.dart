class PublishOfferRequest {
  const PublishOfferRequest({
    required this.headline,
    required this.description,
    required this.isGroupOffer,
    required this.selectedMediatorDid,
    this.expiryDate,
    this.maxUsages,
    this.score,
    this.customPhrase,
  });

  final String headline;
  final String description;
  final bool isGroupOffer;
  final String selectedMediatorDid;
  final DateTime? expiryDate;
  final int? maxUsages;
  final int? score;
  final String? customPhrase;
}
