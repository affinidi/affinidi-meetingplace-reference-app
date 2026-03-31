import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_card.freezed.dart';

@freezed
abstract class ContactCard with _$ContactCard {
  const factory ContactCard({
    required String id,
    required String did,
    required String type,
    required String firstName,
    required String displayName,
    String? lastName,
    String? organization,
    String? website,
    String? email,
    String? mobile,
    String? postcode,
    String? profilePic,
    String? cardColor,
  }) = _ContactCard;

  factory ContactCard.empty() {
    return const ContactCard(
      id: '0',
      did: '',
      type: '',
      firstName: '',
      displayName: '',
      lastName: null,
      organization: null,
      website: null,
      email: null,
      mobile: null,
      postcode: null,
      profilePic: null,
      cardColor: null,
    );
  }
}
