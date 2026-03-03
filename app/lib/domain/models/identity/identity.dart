import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../contact_card/contact_card.dart';

part 'identity.freezed.dart';

const placeholderIdentityId = 'add-new';

/// Identity
///
/// Represents a user identity in the app. This model pairs a stable local
/// identifier with a ContactCard (the public, displayable profile).
///
/// Factory parameters:
/// - [id] - Unique identifier for the identity record.
/// - [card] - ContactCard holding the public profile information for this
///   identity.
/// - [isPrimary] - Boolean value identifying a primary identity
@freezed
abstract class Identity with _$Identity {
  const factory Identity({
    required String id,
    required String did,
    required ContactCard card,
    @Default(false) bool isPrimary,
  }) = _Identity;
}

extension IdentityExtensions on Identity {
  sdk.ContactCard toSdkContactCard() => card.toSdkContactCard();
}
