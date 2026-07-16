import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/shared_preferences_provider.dart';

part 'mnemonic_configured_provider.g.dart';

/// Tracks whether a mnemonic has been stored for the current wallet.
///
/// Backed by SharedPreferences so the value is correct synchronously on every
/// app launch — no async race with the router guard or SDK provider.
/// SDK-dependent services must not be initialized until this is `true`.
@Riverpod(keepAlive: true)
class MnemonicConfigured extends _$MnemonicConfigured {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(SharedPreferencesKeys.hasMnemonic.name) ?? false;
  }

  void setConfigured() {
    ref
        .read(sharedPreferencesProvider)
        .setBool(SharedPreferencesKeys.hasMnemonic.name, true);
    state = true;
  }
}
