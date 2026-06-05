import 'package:flutter/material.dart';

import '../../application/services/notification_service/notification_counter_type.dart';

enum Tabs {
  contacts(serviceKey: NotificationCounterType.contacts),
  connections(serviceKey: NotificationCounterType.connections),
  identities(serviceKey: NotificationCounterType.identities),
  rCards(serviceKey: NotificationCounterType.rCards),
  credentials(serviceKey: NotificationCounterType.credentials);

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
      case Tabs.rCards:
        return const Icon(Icons.credit_card);
      case Tabs.credentials:
        return const Icon(Icons.verified_user);
    }
  }
}

enum TabTitleKey {
  connections,
  contacts,
  identities,
  rCards,
  credentials,
  settings,
}
