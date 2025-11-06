import 'package:freezed_annotation/freezed_annotation.dart';

import 'notification_counter_type.dart';

part 'notification_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class NotificationServiceState with _$NotificationServiceState {
  factory NotificationServiceState({
    @Default({
      NotificationCounterType.contacts: 0,
      NotificationCounterType.connections: 0,
      NotificationCounterType.identities: 0,
    })
    Map<NotificationCounterType, int> counters,
  }) = _NotificationServiceState;
}
