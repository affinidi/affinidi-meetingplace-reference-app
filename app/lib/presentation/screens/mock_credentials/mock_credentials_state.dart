import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/identity/identity.dart';

part 'mock_credentials_state.freezed.dart';

/// Why the test credentials cannot be shown or imported.
enum MockCredentialsFailure {
  /// No VTA is linked.
  vtaMissing,

  /// The VTA cannot be reached, or refused.
  unreachable,
}

/// What importing a test credential came to.
enum MockCredentialImport {
  /// The VTA keeps it as valid.
  imported,

  /// The VTA took it but does not keep it as valid.
  notKept,

  /// The VTA refused it or could not be reached.
  failed,
}

@Freezed(fromJson: false, toJson: false)
abstract class MockCredentialsState with _$MockCredentialsState {
  factory MockCredentialsState({
    @Default(true) bool isLoading,

    /// The member's identities on their VTA, primary first.
    @Default(<Identity>[]) List<Identity> identities,

    /// Which identities hold each test credential: by template id, then
    /// identity DID.
    @Default(<String, Set<String>>{}) Map<String, Set<String>> holders,

    /// The template being imported, while it is.
    String? importing,
    MockCredentialsFailure? failure,
  }) = _MockCredentialsState;
}
