import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/contact_card/contact_card.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../domain/repositories/identities_repository.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/identities_repository_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
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
  Future<void> ensureInitialized() async {
    initializing ??= _fetchIdentities();
    await initializing;
  }

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
    _logger.info(
      'Current identity set to id: $id',
      name: _logKey,
    );
  }

  /// Reset the current identity to an empty identity based on environment.
  ///
  /// This is used when there are no persisted identities or when the current
  /// identity was deleted.
  void _resetCurrentIdentity() {
    state = state.copyWith(currentIdentity: null);
    _logger.info(
      'Current identity reset to empty',
      name: _logKey,
    );
  }

  /// Persist a new identity and refresh the identities list.
  ///
  /// [identity] - The Identity to add.
  ///
  /// Returns:
  /// - `Future<void>` completes when the identity is stored and the state
  ///  refreshed.
  Future<void> addIdentity(Identity identity) async {
    _repository ??= await _ensureRepositoryInitialized();

    var identityToAdd = identity;

    // The very first identity should be considered a primary identity
    if (state.identities.isEmpty) {
      identityToAdd = identity.copyWith(isPrimary: true);
    }

    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    final didManager = await sdk.generateDid();
    final didDoc = await didManager.getDidDocument();

    identityToAdd = identityToAdd.copyWith(did: didDoc.id);

    await _repository!.addIdentity(identityToAdd);
    state = state.copyWith(currentIdentity: identityToAdd);

    await _fetchIdentities();
    _logger.info(
      'Identity added',
      name: _logKey,
    );
  }

  /// Update an existing identity and refresh the identities list.
  ///
  /// [identity] - The Identity to update.
  Future<void> updateIdentity(Identity identity) async {
    _repository ??= await _ensureRepositoryInitialized();
    await _repository!.updateIdentity(identity);
    await _fetchIdentities();
    _logger.info(
      'Identity updated',
      name: _logKey,
    );
  }

  /// Delete an identity by id and refresh the identities list.
  ///
  /// If the deleted identity was the current identity, a default selection
  ///  is applied.
  ///
  /// [id] - Identifier of the identity to remove.
  Future<void> deleteIdentity(String id) async {
    _repository ??= await _ensureRepositoryInitialized();
    await _repository!.deleteIdentity(id);
    await _fetchIdentities();
    _logger.info(
      'Identity deleted',
      name: _logKey,
    );

    if (state.currentIdentity?.id == id) {
      _resetCurrentIdentity();
    }
  }

  /// Fetch identities from the repository and update provider state.
  Future<void> _fetchIdentities() async {
    _repository ??= await _ensureRepositoryInitialized();
    final identities = await _repository!.listIdentities();
    state = state.copyWith(
      identities: identities,
    );
  }

  /// Ensure the identities repository is initialized and return it.
  ///
  /// Returns:
  /// - `Future<IdentitiesRepository>` the initialized repository instance.
  Future<IdentitiesRepository> _ensureRepositoryInitialized() async =>
      await ref.read(identitiesRepositoryProvider.future);
}

extension IdentitiesServiceSelectors
    on NotifierProvider<IdentitiesService, IdentitiesServiceState> {
  ProviderListenable<Identity?> get currentIdentityOrPrimary {
    return select((state) =>
        state.currentIdentity ??
        state.identities.firstWhereOrNull((identity) => identity.isPrimary));
  }
}
