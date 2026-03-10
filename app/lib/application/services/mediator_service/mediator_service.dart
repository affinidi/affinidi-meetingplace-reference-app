import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/mediator/mediator.dart';
import '../../../domain/models/mediator/mediator_status.dart';
import '../../../domain/repositories/mediators_repository.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/mediators_repository_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import 'mediator_service_state.dart';

part 'mediator_service.g.dart';

/// Service to manage mediators: loading, adding, renaming, and removing.
///
/// This service provides a centralized interface for mediator operations
/// including fetching default and custom mediators, adding new custom
/// mediators with auto-generated names, renaming existing mediators,
/// removing mediators, resolving mediator DIDs from URLs, and finding
/// mediators by creation time and DID.
///
/// The service maintains state through Riverpod and persists custom
/// mediators using a repository layer with secure storage backing.
@Riverpod(keepAlive: true)
class MediatorService extends _$MediatorService {
  MediatorService() : super();
  static const _logKey = 'MEDIATORSVC';
  late final AppLogger _logger = ref.read(appLoggerProvider);

  MediatorsRepository? _repository;

  @override
  MediatorServiceState build() {
    _logger.info('MediatorService initializing', name: _logKey);

    Future(() async {
      await _fetchMediators();
      _logger.info('MediatorService initial load completed', name: _logKey);
    });

    return MediatorServiceState();
  }

  /// Load available mediators: default list followed by custom stored
  ///  mediators.
  ///
  /// Fetches default mediators from the mediator repository and then loads any
  /// user-saved custom mediators from secure storage.
  Future<void> _fetchMediators() async {
    _logger.info('Loading available mediators', name: _logKey);

    try {
      _repository ??= await _ensureRepositoryInitialized();
      _logger.info('Mediator repository initialized', name: _logKey);

      final mediator = await _repository?.listMediators() ?? [];
      _logger.info('Loaded ${mediator.length} mediators', name: _logKey);

      state = state.copyWith(mediators: mediator);
      _logger.info('Mediator state updated', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to load available mediators',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Adds a new **custom mediator** via the repository.
  ///
  /// - If a mediator with the same [did] already exists in memory, an
  ///   [AppExceptionType.mediatorAlreadyExists] is thrown (fail-fast).
  /// - The mediator will be automatically assigned a unique label
  ///   of the form `"{unnamedPrefix} n"` if none exists yet.
  /// - The naming ensures no collision with existing mediator names.
  ///
  /// [did] - The DID of the mediator to add.
  /// [unnamedPrefix] - The prefix to use for auto-generated names (e.g.,
  ///  "Unnamed").
  Future<void> addCustomMediator({
    required String did,
    required String unnamedPrefix,
  }) async {
    _logger.info('Adding custom mediator: $did', name: _logKey);

    try {
      _repository ??= await _ensureRepositoryInitialized();
      final customMediators = await _repository?.listCustomMediators() ?? [];

      // Auto-generate a unique "{unnamedPrefix} X" label
      final existingNames = customMediators
          .map((mediator) => mediator.mediatorName)
          .toSet();
      var counter = 1;
      String name;
      do {
        name = '$unnamedPrefix $counter';
        counter++;
      } while (existingNames.contains(name));

      await _repository?.addCustomMediator(name: name, did: did);
      await _fetchMediators();

      _logger.info('Custom mediator added: $did (name: $name)', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to add custom mediator: $did',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Add a custom mediator and persist it to secure storage.
  ///
  /// Updates the in-memory custom mediators map, writes it to secure
  /// storage, and updates provider state.
  ///
  /// [did] - Mediator DID to store.
  Future<void> renameCustomMediator({
    required String did,
    required String newName,
  }) async {
    _logger.info('Renaming custom mediator: $did -> $newName', name: _logKey);

    try {
      _repository ??= await _ensureRepositoryInitialized();
      await _repository!.renameCustomMediator(did: did, newName: newName);

      await _fetchMediators();
      _logger.info('Renamed mediator $did to $newName', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to rename mediator: $did',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Remove a custom mediator and persist the change.
  ///
  /// Removes [did] from the custom mediators map, updates state and secure
  ///  storage.
  ///
  /// [did] - Mediator DID to remove.
  Future<void> removeCustomMediator(String did) async {
    _logger.info('Removing custom mediator: $did', name: _logKey);

    try {
      _repository ??= await _ensureRepositoryInitialized();
      await _repository?.removeMediator(did);
      await _fetchMediators();

      _logger.info('Removed custom mediator: $did', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to remove custom mediator: $did',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Get the mediator ID (DID) associated with a given URL.
  ///
  /// [url] - The URL to resolve to a mediator DID.
  /// Returns:
  /// - `Future<String?>` which completes with the mediator DID if found,
  ///   or `null` if not found or on error.
  Future<String?> getMediatorIdByUrl(String url) async {
    _logger.info('Resolving mediator DID from URL: $url', name: _logKey);

    try {
      var sanitizedUrl = url;
      if (sanitizedUrl.startsWith('did:web:')) {
        sanitizedUrl = sanitizedUrl.replaceFirst('did:web:', 'https://');
      }

      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      final value = await sdk.getMediatorDidFromUrl(url);

      _logger.info(
        'Resolved mediator DID: $value for URL: $url',
        name: _logKey,
      );
      return value;
    } catch (error, stackTrace) {
      _logger.error(
        'Error getting mediator ID from URL: $url',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return null;
    }
  }

  /// Find the mediator with the nearest creation time before the given date/time
  /// with the same DID.
  ///
  /// Searches through in-memory mediators for the one with the same DID
  /// that was created closest to (but before) the given dateTime.
  ///
  /// [dateTime] - The reference date/time to find mediator before.
  /// [did] - The mediator DID to match.
  /// Returns:
  /// - `Mediator?` the nearest mediator if found, or `null` if not found.
  Mediator? findNearestMediatorBefore({
    required DateTime dateTime,
    required String did,
  }) {
    try {
      // Filter mediators by DID and created before dateTime
      final matchingMediators = state.mediators
          .where(
            (mediator) =>
                mediator.mediatorDid == did &&
                mediator.createdTime != null &&
                mediator.createdTime!.isBefore(dateTime),
          )
          .toList();

      if (matchingMediators.isEmpty) {
        _logger.info(
          'No mediator found before $dateTime for DID: $did',
          name: _logKey,
        );
        return null;
      }

      // Sort by createdTime descending to get the nearest one
      matchingMediators.sort(
        (a, b) => b.createdTime!.compareTo(a.createdTime!),
      );
      final mediator = matchingMediators.first;
      return mediator;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to find nearest mediator before $dateTime for DID: $did',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Ensure the mediators repository is initialized and available.
  Future<MediatorsRepository> _ensureRepositoryInitialized() async =>
      await ref.read(mediatorsRepositoryProvider.future);
}

extension MediatorServiceProviderSelectors
    on NotifierProvider<MediatorService, MediatorServiceState> {
  ProviderListenable<List<Mediator>> get filteredMediators => select((state) {
    return state.mediators
        .where((mediator) => mediator.status != MediatorStatus.deleted)
        .toList();
  });
}
