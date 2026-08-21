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
/// - `missedCallCount` - Unread missed calls contributing to `badgeCount`.
///   Tracked separately because missed calls are not represented in the
///   channel sequence number, so they must survive the seqNo-derived badge
///   recompute. Cleared together with `badgeCount` when the chat is opened.
/// - `pendingMissedCallAt` - When a missed incoming call was recorded but its
///   chat item has not yet been reconciled to `missed`. Durable so the receiver
///   can heal the item on the next chat open (or via the stream) even after an
///   app restart. Cleared once the item is marked missed.
/// - `pendingMissedCallId` - Transport call ID for the missed incoming call
///   awaiting reconciliation. Used to match the correct call chat item without
///   relying on local wall-clock time.
/// - `pendingMissedCallMissId` - Per-call episode id used as the missed-call
///   badge dedup key. Distinct from `pendingMissedCallId` (the transport call
///   id): the badge is counted per episode, so recovery must replay the credit
///   under this id, not the transport id. Durable so a badge credit that failed
///   at record time can be replayed on reconciliation, even after an app
///   restart. Cleared with the rest of the marker once the item is healed.
/// - `lastCreditedMissId` - The episode id (`pendingMissedCallMissId`) whose
///   missed-call badge credit has already landed. Whether a credit is still
///   owed is *derived*, never stored separately: owed ==
///   `pendingMissedCallMissId != null && pendingMissedCallMissId !=
///   lastCreditedMissId`. Recording the credited id in the same write that
///   increments the badge makes credited-ness monotonic (an id stays credited
///   once credited), so it cannot desync across a restart the way a mutable
///   "owed" flag could. Survives marker clears so a re-heal never re-credits.
/// - `activeIncomingCallId` - Transport call ID for an incoming call whose
///   banner is currently (or was last) shown. Set when the banner appears;
///   cleared on accept, decline, cancel, timeout, or successful crash-recovery
///   heal. Used to reconstruct the missed-call marker if the app crashes while
///   the banner is visible before `_markCallAsMissed` runs.
/// - `supersededCallIds` - Ids of this device's own outgoing calls lost to
///   glare (the peer's simultaneous call won): each call's transport call id
///   and, once known, its local chat-item id. Their history rows are hidden so
///   one connected call shows exactly one entry, even when the redaction cannot
///   be delivered or leaves a tombstone (whose call id is wiped, hence the
///   chat-item id). Append-only and durable, so the row stays hidden across
///   restart and re-sync.
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
    this.missedCallCount = 0,
    this.pendingMissedCallAt,
    this.pendingMissedCallId,
    this.pendingMissedCallMissId,
    this.lastCreditedMissId,
    this.activeIncomingCallId,
    this.supersededCallIds = const [],
    this.hasBeenOpened = false,
    this.lastKeepAliveMessage,
    this.notificationBannerDismissed = false,
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
  final int missedCallCount;
  final DateTime? pendingMissedCallAt;
  final String? pendingMissedCallId;
  final String? pendingMissedCallMissId;
  final String? lastCreditedMissId;
  final String? activeIncomingCallId;
  final List<String> supersededCallIds;
  final bool hasBeenOpened;
  final DateTime? lastKeepAliveMessage;
  final bool notificationBannerDismissed;

  bool get isGroup => type == ContactType.group;
  bool get isIndividual => type == ContactType.individual;
}
