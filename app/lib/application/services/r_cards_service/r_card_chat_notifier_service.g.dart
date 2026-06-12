// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_card_chat_notifier_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global service that creates chat messages for R-Cards delivered via the
/// DIDComm channel-inauguration (OOB) path.
///
/// These R-Cards arrive on
/// [MeetingPlaceCredentialsSDK.receivedRCardsOnChannel] carrying the
/// originating channel. When detected, this service persists an R-Card
/// attachment message in the relevant chat so users see the
/// "R-Cards have been exchanged." notice when they open the conversation.
///
/// VDIP-path R-Cards (explicit sends) are handled by [ChatSessionService] and
/// are intentionally NOT processed here.

@ProviderFor(RCardChatNotifierService)
const rCardChatNotifierServiceProvider = RCardChatNotifierServiceProvider._();

/// Global service that creates chat messages for R-Cards delivered via the
/// DIDComm channel-inauguration (OOB) path.
///
/// These R-Cards arrive on
/// [MeetingPlaceCredentialsSDK.receivedRCardsOnChannel] carrying the
/// originating channel. When detected, this service persists an R-Card
/// attachment message in the relevant chat so users see the
/// "R-Cards have been exchanged." notice when they open the conversation.
///
/// VDIP-path R-Cards (explicit sends) are handled by [ChatSessionService] and
/// are intentionally NOT processed here.
final class RCardChatNotifierServiceProvider
    extends $NotifierProvider<RCardChatNotifierService, void> {
  /// Global service that creates chat messages for R-Cards delivered via the
  /// DIDComm channel-inauguration (OOB) path.
  ///
  /// These R-Cards arrive on
  /// [MeetingPlaceCredentialsSDK.receivedRCardsOnChannel] carrying the
  /// originating channel. When detected, this service persists an R-Card
  /// attachment message in the relevant chat so users see the
  /// "R-Cards have been exchanged." notice when they open the conversation.
  ///
  /// VDIP-path R-Cards (explicit sends) are handled by [ChatSessionService] and
  /// are intentionally NOT processed here.
  const RCardChatNotifierServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rCardChatNotifierServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rCardChatNotifierServiceHash();

  @$internal
  @override
  RCardChatNotifierService create() => RCardChatNotifierService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$rCardChatNotifierServiceHash() =>
    r'073279be13f3f3d5547e7c4dfb5c7b44c6213321';

/// Global service that creates chat messages for R-Cards delivered via the
/// DIDComm channel-inauguration (OOB) path.
///
/// These R-Cards arrive on
/// [MeetingPlaceCredentialsSDK.receivedRCardsOnChannel] carrying the
/// originating channel. When detected, this service persists an R-Card
/// attachment message in the relevant chat so users see the
/// "R-Cards have been exchanged." notice when they open the conversation.
///
/// VDIP-path R-Cards (explicit sends) are handled by [ChatSessionService] and
/// are intentionally NOT processed here.

abstract class _$RCardChatNotifierService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
