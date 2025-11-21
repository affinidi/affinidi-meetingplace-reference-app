import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'publish_offer_form_data.dart';

part 'publish_offer_screen_state.freezed.dart';

@freezed
abstract class PublishOfferScreenState with _$PublishOfferScreenState {
  const PublishOfferScreenState._();

  const factory PublishOfferScreenState({
    required PublishOfferFormData formData,
    @Default({}) Map<String, String> availableMediators,
    @Default([]) List<Identity> identities,
    Identity? selectedIdentity,
  }) = _PublishOfferScreenState;
}
