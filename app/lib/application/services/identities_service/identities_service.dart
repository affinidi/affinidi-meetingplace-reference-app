import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/contact_card/contact_card.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../domain/repositories/identities_repository.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/identities_repository_provider.dart';
import '../../../presentation/widgets/images/compressed_image.dart';
import '../credential_service/credential_service.dart';
import '../vtc_service/vtc_service.dart';
import 'identities_service_state.dart';

part 'identities_service.g.dart';

/// Service responsible for managing identities and the current contact card.
///
/// This service provides functionality to:
/// - Load and persist identities via a repository
/// - Add, update and delete identities
/// - Resolve and manage the currently selected identity
/// - Expose the current contact card derived from the selected identity
///
/// The service initializes by loading identities and keeps the current identity
/// in sync with environment defaults and repository state.
@Riverpod(keepAlive: true)
class IdentitiesService extends _$IdentitiesService {
  static const _logKey = 'IDSVC';
  late final AppLogger _logger = ref.read(appLoggerProvider);
  IdentitiesRepository? _repository;

  @override
  IdentitiesServiceState build() {
    return IdentitiesServiceState();
  }

  Future<void>? initializing;

  /// Loads the identities kept on the phone, then refreshes the personas'
  /// details from the member's VTA in the background.
  Future<void> ensureInitialized() async {
    initializing ??= _fetchIdentities().then(
      (_) => unawaited(refreshFromVta()),
    );
    await initializing;
  }

  /// Re-reads the profile of each identity that is a VTA persona, and keeps
  /// what the VTA holds when it differs from the copy on the phone.
  ///
  /// An identity whose profile cannot be read keeps its copy: the VTA may be
  /// unreachable, or no longer linked.
  Future<void> refreshFromVta() async {
    _repository ??= await _ensureRepositoryInitialized();
    final vtc = ref.read(vtcServiceProvider);
    var changed = false;
    for (final identity in state.identities.where((i) => i.isVtaPersona)) {
      try {
        final profile = await vtc.identityProfile(
          contextId: identity.vtaContextId!,
          profileId: identity.vtaProfileId!,
        );
        final card = identity.card.withVtaProfile(profile);
        if (card == identity.card) continue;
        await _repository!.updateIdentity(identity.copyWith(card: card));
        changed = true;
      } catch (error) {
        _logger.warning(
          'Refreshing an identity from the VTA failed: ${error.runtimeType}',
          name: _logKey,
        );
      }
    }
    if (!changed || !ref.mounted) return;
    await _fetchIdentities();
    final current = state.currentIdentity;
    if (current != null) {
      state = state.copyWith(
        currentIdentity: state.getIdentityById(current.id) ?? current,
      );
    }
  }

  /// Returns the identity for [id], if it is present in the current state.
  Identity? getIdentityById(String? id) => state.getIdentityById(id);

  /// Set the current identity by its identifier.
  ///
  /// [id] - Identity id to select.
  void setCurrentIdentityById(String id) {
    final identity = state.getIdentityById(id);

    if (identity == null) {
      _resetCurrentIdentity();
      return;
    }
    state = state.copyWith(currentIdentity: identity);
    _logger.info('Current identity set to id: $id', name: _logKey);
  }

  /// Reset the current identity to an empty identity based on environment.
  ///
  /// This is used when there are no persisted identities or when the current
  /// identity was deleted.
  void _resetCurrentIdentity() {
    state = state.copyWith(currentIdentity: null);
    _logger.info('Current identity reset to empty', name: _logKey);
  }

  /// Create a new identity as a persona of the member's VTA, store a
  /// reference to it, and refresh the identities list.
  ///
  /// The VTA creates the persona DID and a profile showing [identity]'s
  /// card; the persona's keys stay on the VTA. If the identity cannot be
  /// stored here, it is deleted from the VTA again.
  ///
  /// [identity] - The Identity to add.
  ///
  /// Returns:
  /// - `Future<void>` completes when the identity is stored and the state
  ///  refreshed.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked and granted, and
  /// [MeetingPlaceVtcSDKException] when the VTA refuses or cannot be reached.
  Future<void> addIdentity(Identity identity) async {
    _repository ??= await _ensureRepositoryInitialized();

    var identityToAdd = identity;

    // The very first identity should be considered a primary identity
    if (state.identities.isEmpty) {
      identityToAdd = identity.copyWith(isPrimary: true);
    }

    final vtc = ref.read(vtcServiceProvider);
    final created = await vtc.createIdentity(identity.card.toVtaProfile());
    final persona = created.persona;
    identityToAdd = identityToAdd.copyWith(
      did: persona.did,
      card: identityToAdd.card.copyWith(did: persona.did),
      vtaContextId: persona.contextId,
      vtaProfileId: created.profileId,
    );

    try {
      await _repository!.addIdentity(identityToAdd);
    } catch (_) {
      try {
        await vtc.deleteIdentity(
          contextId: persona.contextId,
          profileId: created.profileId,
        );
      } catch (_) {
        _logger.warning('Discarding the new persona failed', name: _logKey);
      }
      rethrow;
    }
    state = state.copyWith(currentIdentity: identityToAdd);

    await _fetchIdentities();
    _logger.info('Identity added', name: _logKey);
  }

  /// Update an existing identity and refresh the identities list.
  ///
  /// A persona's VTA profile is updated first; the phone keeps a copy.
  ///
  /// [identity] - The Identity to update.
  Future<void> updateIdentity(Identity identity) async {
    _repository ??= await _ensureRepositoryInitialized();
    if (identity.isVtaPersona) {
      await ref
          .read(vtcServiceProvider)
          .updateIdentity(
            contextId: identity.vtaContextId!,
            personaDid: identity.did,
            profileId: identity.vtaProfileId!,
            profile: identity.card.toVtaProfile(),
          );
    }
    await _repository!.updateIdentity(identity);
    await _fetchIdentities();
    _logger.info('Identity updated', name: _logKey);
  }

  /// Delete an identity by id and refresh the identities list.
  ///
  /// A persona is deleted from the VTA first: its profile is retired and its
  /// DID can never be used again. Nothing is removed from the phone when the
  /// VTA refuses.
  ///
  /// If the deleted identity was the current identity, a default selection
  ///  is applied.
  ///
  /// [id] - Identifier of the identity to remove.
  Future<void> deleteIdentity(String id) async {
    _repository ??= await _ensureRepositoryInitialized();
    final identity = state.getIdentityById(id);
    if (identity != null && identity.isVtaPersona) {
      await ref
          .read(vtcServiceProvider)
          .deleteIdentity(
            contextId: identity.vtaContextId!,
            profileId: identity.vtaProfileId!,
          );
    }
    await _repository!.deleteIdentity(id);
    await ref
        .read(credentialServiceProvider.notifier)
        .deleteCredentialForIdentity(id);
    await _fetchIdentities();
    _logger.info('Identity deleted', name: _logKey);

    if (state.currentIdentity?.id == id) {
      _resetCurrentIdentity();
    }
  }

  /// Fetch identities from the repository and update provider state.
  Future<void> _fetchIdentities() async {
    _repository ??= await _ensureRepositoryInitialized();
    final identities = await _repository!.listIdentities();
    state = state.copyWith(identities: identities);
  }

  /// Ensure the identities repository is initialized and return it.
  ///
  /// Returns:
  /// - `Future<IdentitiesRepository>` the initialized repository instance.
  Future<IdentitiesRepository> _ensureRepositoryInitialized() async =>
      await ref.read(identitiesRepositoryProvider.future);
}

/// Longest side, in pixels, of the picture thumbnail kept on the VTA.
const _vtaThumbnailSize = 256;

extension on ContactCard {
  /// The card's details as the VTA profile an identity's persona wears. The
  /// picture goes as a thumbnail; the colour stays on the phone.
  VtaProfile toVtaProfile() => VtaProfile(
    displayName: displayName,
    firstName: firstName,
    lastName: lastName,
    email: email,
    mobile: mobile,
    thumbnail: switch (profilePic) {
      final picture? when picture.trim().isNotEmpty => thumbnailFromBase64(
        picture,
        imageSize: _vtaThumbnailSize,
        maxLength: VtaProfile.maxThumbnailLength,
      ),
      _ => null,
    },
  );

  /// The card showing [profile]'s details. The colour stays as it is, and so
  /// does a picture the phone has: the VTA holds only a thumbnail of it. The
  /// thumbnail fills in a picture the phone lacks, as after a restore.
  ContactCard withVtaProfile(VtaProfile profile) => copyWith(
    displayName: profile.displayName,
    firstName: profile.firstName,
    lastName: profile.lastName,
    email: profile.email,
    mobile: profile.mobile,
    profilePic: switch (profilePic) {
      final picture? when picture.trim().isNotEmpty => picture,
      _ => profile.thumbnail ?? profilePic,
    },
  );
}

extension IdentitiesServiceSelectors on IdentitiesServiceProvider {
  ProviderListenable<Identity?> get currentIdentityOrPrimary {
    return select(
      (state) =>
          state.currentIdentity ??
          state.identities.firstWhereOrNull((identity) => identity.isPrimary),
    );
  }
}
