import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/extensions/connection_offer_list_extensions.dart';
import '../../../infrastructure/extensions/contact_list_extensions.dart';
import '../connections_service/connections_service.dart';
import '../contacts_service/contacts_service.dart';
import 'notification_counter_type.dart';
import 'notification_service_state.dart';

part 'notification_service.g.dart';

/// Service responsible for tracking notification counters for app features.
///
/// This service:
/// - Observes contacts and connections providers for badge counts.
/// - Maintains per-type counters (contacts, connections) in state.
/// - Exposes counter state via the provider for UI to display aggregated
///  counts.
@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  NotificationService() : super();

  bool _isDisposed = false;

  @override
  NotificationServiceState build() {
    ref.onDispose(() {
      _isDisposed = true;
    });

    ref.listen(
      contactsServiceProvider.select((state) => state.contacts),
      (previous, next) {
        Future.microtask(() {
          if (_isDisposed) return;

          _updateCounter(
            NotificationCounterType.contacts,
            next.badgeCount,
          );
        });
      },
      fireImmediately: true,
    );

    ref.listen(
      connectionsServiceProvider.select((state) => state.connections),
      (previous, next) {
        Future.microtask(() {
          if (_isDisposed) return;

          _updateCounter(
            NotificationCounterType.connections,
            next.badgeCount,
          );
        });
      },
      fireImmediately: true,
    );

    return NotificationServiceState();
  }

  /// Update the counter for a given notification type.
  ///
  /// Updates the in-memory counters map and writes the new map to provider
  ///  state.
  ///
  /// [type] - The notification counter type to update (e.g., contacts,
  ///  connections).
  /// [amount] - The new counter value to set.
  void _updateCounter(NotificationCounterType type, int amount) {
    final counters = Map<NotificationCounterType, int>.from(state.counters);
    counters[type] = amount;
    state = state.copyWith(counters: counters);
  }
}
