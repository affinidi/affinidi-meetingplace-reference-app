import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_card.freezed.dart';

/// Lightweight contact profile used across the app and when sharing contact
/// metadata with the SDK/UI. This model holds non-sensitive, displayable
/// information (no private keys).
///
/// Factory parameters:
/// - [id] - Unique identifier for the contact card.
/// - [displayName] - Full display name shown in UI.
/// - [personaFields] - Centralized identity/persona field values keyed by
/// field id.
/// - [profilePic] - Optional profile picture reference (base64).
/// - [cardColor] - Optional UI color hint for the card.
@freezed
abstract class ContactCard with _$ContactCard {
  const factory ContactCard({
    required String id,
    required String did,
    required String type,
    required String displayName,
    @Default(<String, String>{}) Map<String, String> personaFields,
    String? profilePic,
    String? cardColor,
  }) = _ContactCard;

  factory ContactCard.empty() {
    return const ContactCard(
      id: '0',
      did: '',
      type: '',
      displayName: '',
      personaFields: <String, String>{},
      profilePic: null,
      cardColor: null,
    );
  }
}
