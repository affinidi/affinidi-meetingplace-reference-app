import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/authentication_service/authentication_service.dart';
import '../../../application/services/control_plane_service/control_plane_service.dart';
import '../../../application/services/network_connectivity_service/network_connectivity_service.dart';
import '../../../application/services/settings_service/settings_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';

class NoConnectionBanner extends ConsumerWidget {
  const NoConnectionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(networkConnectivityServiceProvider);
    final isAuthenticated = ref.watch(
      authenticationServiceProvider.select((s) => s.isAuthenticated),
    );
    final alreadyOnboarded = ref.watch(
      settingsServiceProvider.select((s) => s.alreadyOnboarded),
    );

    // Show banner only when user is authenticated
    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    // Show banner only when user is onBoarded
    if (!alreadyOnboarded) {
      return const SizedBox.shrink();
    }

    final hasFailedToRegisterDeviceToken = ref.watch(
      controlPlaneServiceProvider
          .select((state) => state.isDeviceTokenRegistered == false),
    );

    // Show banner only when user is not connected to network
    // or unable to register a push token
    if (provider.isConnected && !hasFailedToRegisterDeviceToken) {
      return const SizedBox.shrink();
    }

    return Container(
      width: context.mediaQuery.size.width,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: context.colorScheme.error,
      child: Text(
        context.l10n.networkDisconnected,
        style: context.textTheme.labelMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
