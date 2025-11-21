import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import 'identities_service_state.dart';

part 'identities_service.g.dart';

@Riverpod(keepAlive: true)
class IdentitiesService extends _$IdentitiesService {
  static const _logKey = 'IDSVC';
  late final AppLogger _logger = ref.read(appLoggerProvider);

  @override
  IdentitiesServiceState build() {
    return IdentitiesServiceState();
  }

  Future<void>? initializing;
  Future<void> ensureInitialized() async {
    initializing ??= _fetchIdentities();
    await initializing;
  }

  void setCurrentIdentityById(String id) {
    final identity = state.getIdentityById(id);
    if (identity == null) {
      _resetCurrentIdentity();
      return;
    }
    state = state.copyWith(currentIdentity: identity);
    _logger.info('Current identity set to id: $id', name: _logKey);
  }

  void _resetCurrentIdentity() {
    state = state.copyWith(currentIdentity: null);
    _logger.info('Current identity reset to empty', name: _logKey);
  }

  Future<void> addIdentity(Identity identity) async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    final isFirst = state.identities.isEmpty;
    final created = await sdk.createIdentity(
      card: ContactCard(
        id: identity.id,
        firstName: identity.card.firstName,
        displayName: identity.card.displayName,
        lastName: identity.card.lastName,
        email: identity.card.email,
        mobile: identity.card.mobile,
        profilePic: identity.card.profilePic,
        cardColor: identity.card.cardColor,
      ),
      isPrimary: isFirst || identity.isPrimary,
    );
    state = state.copyWith(currentIdentity: created);
    await _fetchIdentities();
    _logger.info('Identity added', name: _logKey);
  }

  Future<void> updateIdentity(Identity identity) async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    await sdk.updateIdentity(identity);
    await _fetchIdentities();
    _logger.info('Identity updated', name: _logKey);
  }

  Future<void> deleteIdentity(String id) async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    await sdk.deleteIdentity(id);
    await _fetchIdentities();
    _logger.info('Identity deleted', name: _logKey);
    if (state.currentIdentity?.id == id) {
      _resetCurrentIdentity();
    }
  }

  Future<void> _fetchIdentities() async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    final identities = await sdk.listIdentities();
    state = state.copyWith(identities: identities);
  }
}

extension IdentitiesServiceSelectors
    on NotifierProvider<IdentitiesService, IdentitiesServiceState> {
  ProviderListenable<Identity?> get currentIdentityOrPrimary {
    return select((state) =>
        state.currentIdentity ??
        state.identities.firstWhereOrNull((identity) => identity.isPrimary));
  }
}
