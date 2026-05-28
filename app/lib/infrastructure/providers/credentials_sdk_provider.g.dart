// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_sdk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the `MeetingPlaceCredentialsSDK` instance backed by the
/// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
///
/// Injects the [RCardRepository] from [rCardsRepositoryProvider]
/// so that every incoming R-Card is automatically persisted in the local
/// encrypted database.
///
/// Keep-alive ensures the credentials SDK is initialized once and shared
/// across the app lifetime.

@ProviderFor(credentialsSdk)
final credentialsSdkProvider = CredentialsSdkProvider._();

/// Provides the `MeetingPlaceCredentialsSDK` instance backed by the
/// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
///
/// Injects the [RCardRepository] from [rCardsRepositoryProvider]
/// so that every incoming R-Card is automatically persisted in the local
/// encrypted database.
///
/// Keep-alive ensures the credentials SDK is initialized once and shared
/// across the app lifetime.

final class CredentialsSdkProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeetingPlaceCredentialsSDK>,
          MeetingPlaceCredentialsSDK,
          FutureOr<MeetingPlaceCredentialsSDK>
        >
    with
        $FutureModifier<MeetingPlaceCredentialsSDK>,
        $FutureProvider<MeetingPlaceCredentialsSDK> {
  /// Provides the `MeetingPlaceCredentialsSDK` instance backed by the
  /// `MeetingPlaceCoreSDK` from `meetingPlaceSdkProvider`.
  ///
  /// Injects the [RCardRepository] from [rCardsRepositoryProvider]
  /// so that every incoming R-Card is automatically persisted in the local
  /// encrypted database.
  ///
  /// Keep-alive ensures the credentials SDK is initialized once and shared
  /// across the app lifetime.
  CredentialsSdkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialsSdkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialsSdkHash();

  @$internal
  @override
  $FutureProviderElement<MeetingPlaceCredentialsSDK> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MeetingPlaceCredentialsSDK> create(Ref ref) {
    return credentialsSdk(ref);
  }
}

String _$credentialsSdkHash() => r'b4c10d0ca19b632768b91bcfc80ad5f797475895';
