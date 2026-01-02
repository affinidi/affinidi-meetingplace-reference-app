import 'package:copy_with_extension/copy_with_extension.dart';
import '../contact_card/contact_card.dart';

import 'contact_category.dart';
import 'contact_origin.dart';
import 'contact_status.dart';
import 'contact_type.dart';

part 'contact.g.dart';

/// Represents a persisted contact derived from channels, offers or invitations.
///
/// Responsibilities:
/// - Hold metadata required to display contact cards and drive contact-related
///  UI.
/// - Persist identifiers used to correlate channels/offers with local contacts.
/// - Track UI and processing state (badges, chat in progress, last keep-alive).
///
/// Notes on key fields:
/// - `id` - Local unique identifier for the contact record.
/// - `channelDid` - Permanent channel DID used to identify the remote party.
/// - `channelDidSha256` - SHA256 hash of the channel DID for indexing.
/// - `card` / `otherPartyCard` - Local and remote ContactCard information used
///   for display and sharing.
/// - `offerLink` - Offer mnemonic/link used to correlate published/offered
///   connections.
/// - `dateAdded` - When the contact was created locally.
/// - `type` - Contact type (person/group) derived from channel type.
/// - `status` - Contact lifecycle status (pending, active, deleted, ...).
/// - `mediatorDid` - Mediator DID associated with the contact/channel.
/// - `origin` - How the contact was created (groupOffer, individualOffer, etc.)
/// - `category` - UI/semantic category (person, organisation).
/// - `displayName` - Optional override used in lists (may be derived from
///   connection offer).
/// - `badgeCount` / `badgeUpdateInProgress` - Local unread/activity count and
///   processing flag.
/// - `currentMessageSeqNo` - Message sequence numbers for ordering.
/// - `lastKeepAliveMessage` - Timestamp of the last keep-alive message received
///   (used to show liveness).
@CopyWith()
class Contact {
  Contact({
    required this.id,
    this.channelDid,
    this.channelDidSha256,
    required this.offerLink,
    required this.card,
    required this.dateAdded,
    required this.type,
    required this.status,
    required this.mediatorDid,
    required this.origin,
    required this.category,
    this.otherPartyCard,
    this.displayName,
    this.badgeUpdateInProgress = false,
    this.badgeCount = 0,
    this.currentMessageSeqNo = 0,
    this.hasBeenOpened = false,
    this.lastKeepAliveMessage,
  });

  @CopyWithField(immutable: true)
  final String id;
  final String? channelDid;
  final String? channelDidSha256;
  final String offerLink;
  final ContactCard card;
  @CopyWithField(immutable: true)
  final DateTime dateAdded;
  final ContactType type;
  final ContactStatus status;
  final String mediatorDid;
  final ContactOrigin origin;
  final ContactCategory category;
  final ContactCard? otherPartyCard;
  final String? displayName;
  final bool badgeUpdateInProgress;
  final int badgeCount;
  final int currentMessageSeqNo;
  final bool hasBeenOpened;
  final DateTime? lastKeepAliveMessage;

  bool get isGroup => type == ContactType.group;
  bool get isIndividual => type == ContactType.individual;
}
