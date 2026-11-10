import 'package:flutter/material.dart';

import '../../application/services/notification_service/notification_counter_type.dart';
import '../../presentation/themes/tokens/mc_icons.dart';

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
    Tabs.connections => McIcons.connections,
    Tabs.contacts => McIcons.communities,
    Tabs.identities => McIcons.identities,
    Tabs.rCards => McIcons.rCards,
    Tabs.credentials => McIcons.credentials,
  };

  Widget get icon => Icon(iconData);

  /// Whether the bottom navigation offers the tab. R-Cards keeps its
  /// branch, as chat still opens an r-card's details through it.
  bool get isInNavigationBar => this != Tabs.rCards;
}

enum TabTitleKey {
  connections,
  contacts,
  identities,
  rCards,
  credentials,
  settings,
}
