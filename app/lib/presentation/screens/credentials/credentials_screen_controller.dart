import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'credentials_screen_state.dart';

final credentialsScreenControllerProvider =
    StateNotifierProvider<CredentialsScreenController, CredentialsScreenState>(
      (ref) => CredentialsScreenController(),
    );

class CredentialsScreenController
    extends StateNotifier<CredentialsScreenState> {
  CredentialsScreenController() : super(const CredentialsScreenState());

  /// Save a credential (temporarily for this session)
  void saveCredential() {
    state = state.copyWith(hasCredentials: true);
  }

  /// Delete the credential
  void deleteCredential() {
    state = state.copyWith(hasCredentials: false);
  }
}
