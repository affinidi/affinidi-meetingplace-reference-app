import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/identity/identity.dart';
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
