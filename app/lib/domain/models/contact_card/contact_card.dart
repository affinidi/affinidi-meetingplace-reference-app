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
    String? email,
    String? mobile,
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
      profilePic: null,
      cardColor: null,
    );
  }
}
