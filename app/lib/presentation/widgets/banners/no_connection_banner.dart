import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/authentication_service/authentication_service.dart';
import '../../../application/services/control_plane_service/control_plane_service.dart';
import '../../../application/services/network_connectivity_service/network_connectivity_service.dart';
import '../../../application/services/settings_service/settings_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/firebase_messaging/firebase_initialization.dart';
import '../../../infrastructure/providers/firebase_initialization_provider.dart';

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
    final firebaseError = ref.watch(firebaseInitializationErrorProvider);

    // Show banner only when user is authenticated
    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    // Show banner only when user is onBoarded
    if (!alreadyOnboarded) {
      return const SizedBox.shrink();
    }

    final hasFailedToRegisterDeviceToken = ref.watch(controlPlaneServiceProvider
        .select((state) => state.isDeviceTokenRegistered == false));

    // Determine the error message to display
    String? errorMessage;
    if (firebaseError != null) {
      errorMessage = switch (firebaseError) {
        FirebaseInitError.configurationError =>
          context.l10n.firebaseConfigurationError,
        FirebaseInitError.initializationFailed =>
          context.l10n.firebaseInitializationError,
      };
    } else if (!provider.isConnected || hasFailedToRegisterDeviceToken) {
      errorMessage = context.l10n.networkDisconnected;
    }

    // Show banner only if there's an error message
    if (errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: context.mediaQuery.size.width,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: context.colorScheme.error,
      child: Text(
        errorMessage,
        style: context.textTheme.labelMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
