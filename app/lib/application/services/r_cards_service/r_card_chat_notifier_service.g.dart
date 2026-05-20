// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_card_chat_notifier_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rCardChatNotifierServiceHash() =>
    r'5ab53d2e481169edbcc45c5aaefe26fbd6a799fa';

/// Global service that creates chat messages for R-Cards delivered via the
/// DIDComm channel-inauguration (OOB) path.
///
/// These R-Cards arrive on [MeetingPlaceRelationshipSDK.receivedRCards] with
/// [RCard.permanentChannelDid] set (populated by
/// `RCardChannelStreamManager`). When detected, this service persists an
/// R-Card attachment message in the relevant chat so users see the
/// "R-Cards have been exchanged." notice when they open the conversation.
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
