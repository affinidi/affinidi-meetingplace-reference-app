import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../domain/models/identity/identity.dart';

part 'vtc_findable_controller.g.dart';

/// The member's own directory card in a community, and the DID of the
/// identity they joined it with, whose name and picture the card shows.
typedef VtcFindable = ({MyDirectoryCard card, String? identityDid});

/// No retry behind the member's back: each one asks the VTA to sign, and
/// the settings ask again each time they open.
Duration? _noRetry(int retryCount, Object error) => null;

/// Whether other members of [communityDid] can find the member, read once
/// the community is opened and kept while the app runs, so its settings
/// show it at once. The settings [sync] it each time they open.
@Riverpod(keepAlive: true, retry: _noRetry)
class VtcFindableController extends _$VtcFindableController {
  var _isSyncing = false;

  /// Counts the member's changes, so a sync begun before one does not
  /// show the card as it was.
  var _changes = 0;

  VtcTrustService get _service => ref.read(vtcTrustServiceProvider);

  @override
  Future<VtcFindable> build(String communityDid) async => (
    card: await _service.directoryCard(communityDid),
    identityDid: await _service.identityDid(communityDid),
  );

  /// The identity the member joined with, as this phone holds it now.
  Identity? _joinedAs(String? identityDid) => ref
      .read(identitiesServiceProvider)
      .identities
      .where((identity) => identity.did == identityDid)
      .firstOrNull;

  /// Reads the card again, then keeps it in step with the identity the
  /// member joined with: a member who let others find them stays findable
  /// under their identity's name and picture, also on a card hidden when
  /// they joined. The card shown stays while this runs,
  /// and when it fails: it is only out of date. Nothing happens while a
  /// sync runs already.
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    final changes = _changes;
    try {
      // Read just now when first opened: no need to ask again.
      var (:card, :identityDid) = state.isLoading && !state.hasValue
          ? await future
          : await build(communityDid);
      final joinedAs = _joinedAs(identityDid);
      final name = joinedAs?.card.displayName.trim() ?? '';
      final picture = joinedAs?.card.profilePic;
      if (card.isDidVisibleToMembers) {
        var changed = false;
        if (name.isNotEmpty && card.displayName != name) {
          await _service.setDirectoryName(communityDid, name: name);
          changed = true;
        }
        if (picture != null && card.avatarSha256 == null) {
          await _service.setDirectoryPicture(communityDid, base64: picture);
          changed = true;
        }
        if (card.isHidden) {
          await _service.setFindable(communityDid, findable: true);
          changed = true;
        }
        if (changed) card = await _service.directoryCard(communityDid);
      }
      if (ref.mounted && changes == _changes) {
        state = AsyncData((card: card, identityDid: identityDid));
      }
    } on VtcTrustException catch (error, stackTrace) {
      if (ref.mounted && !state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Lets other members find the member when [findable], under the name
  /// and picture of the identity they joined with, or stops them otherwise.
  ///
  /// Throws [VtcTrustException].
  Future<void> setFindable(bool findable) async {
    _changes++;
    final identityDid = state.value?.identityDid;
    final joinedAs = _joinedAs(identityDid);
    final name = joinedAs?.card.displayName.trim() ?? '';
    final picture = joinedAs?.card.profilePic;
    if (findable && name.isNotEmpty) {
      await _service.setDirectoryName(communityDid, name: name);
    }
    if (findable && picture != null) {
      await _service.setDirectoryPicture(communityDid, base64: picture);
    }
    await _service.setFindable(communityDid, findable: findable);
    final card = await _service.directoryCard(communityDid);
    if (ref.mounted) {
      state = AsyncData((card: card, identityDid: identityDid));
    }
  }
}
