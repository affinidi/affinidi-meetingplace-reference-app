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

  /// The tab's symbol, shared by its navigation item and its section
  /// header.
  IconData get iconData => switch (this) {
    Tabs.connections => Icons.compare_arrows,
    Tabs.contacts => Icons.groups,
    Tabs.identities => Icons.fingerprint,
    Tabs.rCards => Icons.credit_card,
    Tabs.credentials => Icons.verified_user,
  };

  Widget get icon => this == Tabs.connections
      // The arrows read small at the default size.
      ? Icon(iconData, size: 32)
      : Icon(iconData);
}

enum TabTitleKey {
  connections,
  contacts,
  identities,
  rCards,
  credentials,
  settings,
}
