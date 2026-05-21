// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_card_chat_notifier_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rCardChatNotifierServiceHash() =>
    r'c28c82489d74525cb05ff1e0ba4bd9cc6fbf9138';

/// Global service that creates chat messages for R-Cards delivered via the
/// DIDComm channel-inauguration (OOB) path.
///
/// Listens on [MeetingPlaceRelationshipSDK.receivedRCardsOnChannel], which
/// surfaces the originating channel alongside each parsed R-Card. This
/// channel context is used to:
///   • skip group channels (R-Cards are individual-only),
///   • build the stable chat message ID, and
///   • set the sender DID correctly.
///
/// VDIP-path R-Cards (explicit sends) are handled by [ChatSessionService] and
/// are intentionally NOT processed here.
///
/// Copied from [RCardChatNotifierService].
@ProviderFor(RCardChatNotifierService)
final rCardChatNotifierServiceProvider =
    NotifierProvider<RCardChatNotifierService, void>.internal(
      RCardChatNotifierService.new,
      name: r'rCardChatNotifierServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rCardChatNotifierServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RCardChatNotifierService = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
