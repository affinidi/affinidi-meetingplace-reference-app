import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_card.freezed.dart';

/// Lightweight contact profile used across the app and when sharing contact
/// metadata with the SDK/UI. This model holds non-sensitive, displayable
/// information (no private keys).
///
/// Factory parameters:
/// - [id] - Unique identifier for the contact card.
/// - [firstName] - Given name.
/// - [displayName] - Full display name shown in UI.
/// - [lastName] - Optional family name.
/// - [email] - Optional primary email address.
/// - [mobile] - Optional primary mobile number.
/// - [profilePic] - Optional profile picture reference (base64).
/// - [cardColor] - Optional UI color hint for the card.
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
