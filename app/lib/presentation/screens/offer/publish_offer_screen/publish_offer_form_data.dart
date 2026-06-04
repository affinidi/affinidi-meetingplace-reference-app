import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

part 'publish_offer_form_data.freezed.dart';

@freezed
abstract class PublishOfferFormData with _$PublishOfferFormData {
  const factory PublishOfferFormData({
    required String headline,
    required String description,
    required bool isGroupOffer,
    required bool hasExpiry,
    required bool hasMaxUsages,
    required bool randomPhraseEnabled,
    required bool isSearchable,
    required String selectedMediatorDid,
    int? maxUsages,
    String? selectedMediatorName,
    DateTime? expiryDate,
    String? customPhrase,
    bool? isPhraseAvailable,
    @Default(false) bool isPhraseValidating,
    @Default(ChannelTransport.didcomm) ChannelTransport transport,
  }) = _PublishOfferFormData;
}
