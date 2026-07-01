import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/services/authentication_service/authentication_service.dart';
import '../../application/services/connections_service/connections_service.dart';
import '../../application/services/contacts_connections_service/contacts_connections_service.dart';
import '../../application/services/contacts_service/contacts_service.dart';
import '../../application/services/control_plane_service/control_plane_service.dart';
import '../../application/services/incoming_call_service/incoming_call_service.dart';
import '../../application/services/network_connectivity_service/network_connectivity_service.dart';
import '../../application/services/r_cards_service/r_card_chat_notifier_service.dart';
import '../../application/services/settings_service/settings_service.dart';
import '../../application/services/vrc_service/vrc_service.dart';
import '../../infrastructure/providers/app_badge_provider.dart';
import '../../infrastructure/providers/audio_video_call_plugin_provider.dart';
import '../../infrastructure/providers/credentials_sdk_provider.dart';

part 'app_controller.g.dart';

@Riverpod(keepAlive: true)
class AppController extends _$AppController with WidgetsBindingObserver {
  AppController() : super();

  @override
  void build() {
    ref.read(incomingCallServiceProvider);

    ref.listen(
      authenticationServiceProvider.select((state) => state.isAuthenticated),
      (prev, next) async {
        if (!next) {
          final sdk = ref.read(credentialsSdkProvider).asData?.value;
          await sdk?.closeCredentialStreams();
          return;
        }
        if (next) {
          ref.read(controlPlaneServiceProvider);
          ref.read(rCardChatNotifierServiceProvider);
          ref.read(vrcServiceProvider);
          await ref.read(contactsServiceProvider.notifier).ensureInitialized();
          await ref
              .read(connectionsServiceProvider.notifier)
              .ensureInitialized();
          ref.read(contactsConnectionsServiceProvider);
        }
      },
      fireImmediately: true,
    );

    ref.read(settingsServiceProvider);
    ref.read(networkConnectivityServiceProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(appBadgeServiceProvider).clearBadge());
    }
    if (state == AppLifecycleState.detached) {
      final plugin = ref.read(audioVideoCallPluginProvider).value;
      if (plugin is MeetingPlaceLiveKitCallPlugin) {
        unawaited(plugin.leaveCurrentCall());
      }
    }
  }
}
