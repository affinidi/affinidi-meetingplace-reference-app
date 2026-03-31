// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_card.dart';

@freezed
abstract class ContactCard with _$ContactCard {
  const factory ContactCard({
    required String id,
    required String did,
    required String type,
    required String firstName,
    required String displayName,
    String? lastName,
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
      email: null,
      mobile: null,
      postcode: null,
      profilePic: null,
      cardColor: null,
    );
  }
}
