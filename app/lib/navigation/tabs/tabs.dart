import 'package:flutter/material.dart';

import '../../application/services/notification_service/notification_counter_type.dart';

enum Tabs {
  contacts(serviceKey: NotificationCounterType.contacts),
  connections(serviceKey: NotificationCounterType.connections),
  identities(serviceKey: NotificationCounterType.identities),
  credentials(serviceKey: NotificationCounterType.credentials),
  settings(serviceKey: NotificationCounterType.settings);

  const Tabs({required this.serviceKey});

  final NotificationCounterType serviceKey;

  Widget get icon {
    switch (this) {
      case Tabs.connections:
        return const Icon(Icons.compare_arrows, size: 32);
      case Tabs.contacts:
        return const Icon(Icons.chat);
      case Tabs.identities:
        return const Icon(Icons.fingerprint);
      case Tabs.credentials:
        return const Icon(Icons.verified_user);
      case Tabs.settings:
        return const Icon(Icons.settings);
    }
  }
}
