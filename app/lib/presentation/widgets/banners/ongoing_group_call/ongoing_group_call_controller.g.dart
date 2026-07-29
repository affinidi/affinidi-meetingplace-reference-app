// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ongoing_group_call_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits the ongoing group audio call banner data for [contactId], or `null`
/// when the banner must not be shown.
///
/// The banner is shown only when the local user is NOT in a call: while any
/// call is active (from the first outgoing attempt through to connected) the
/// persistent green active-call banner is used instead. It is scoped to the
/// open chat, so an ongoing call in another group is only surfaced once its
/// chat is opened.

@ProviderFor(ongoingGroupCallBanner)
const ongoingGroupCallBannerProvider = OngoingGroupCallBannerFamily._();

/// Emits the ongoing group audio call banner data for [contactId], or `null`
/// when the banner must not be shown.
///
/// The banner is shown only when the local user is NOT in a call: while any
/// call is active (from the first outgoing attempt through to connected) the
/// persistent green active-call banner is used instead. It is scoped to the
/// open chat, so an ongoing call in another group is only surfaced once its
/// chat is opened.

final class OngoingGroupCallBannerProvider
    extends
        $FunctionalProvider<
          AsyncValue<OngoingGroupCallBannerData?>,
          OngoingGroupCallBannerData?,
          Stream<OngoingGroupCallBannerData?>
        >
    with
        $FutureModifier<OngoingGroupCallBannerData?>,
        $StreamProvider<OngoingGroupCallBannerData?> {
  /// Emits the ongoing group audio call banner data for [contactId], or `null`
  /// when the banner must not be shown.
  ///
  /// The banner is shown only when the local user is NOT in a call: while any
  /// call is active (from the first outgoing attempt through to connected) the
  /// persistent green active-call banner is used instead. It is scoped to the
  /// open chat, so an ongoing call in another group is only surfaced once its
  /// chat is opened.
  const OngoingGroupCallBannerProvider._({
    required OngoingGroupCallBannerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ongoingGroupCallBannerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ongoingGroupCallBannerHash();

  @override
  String toString() {
    return r'ongoingGroupCallBannerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<OngoingGroupCallBannerData?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<OngoingGroupCallBannerData?> create(Ref ref) {
    final argument = this.argument as String;
    return ongoingGroupCallBanner(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OngoingGroupCallBannerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ongoingGroupCallBannerHash() =>
    r'1714de86c73b6386d9151a4b42d10fb6c4251e5d';

/// Emits the ongoing group audio call banner data for [contactId], or `null`
/// when the banner must not be shown.
///
/// The banner is shown only when the local user is NOT in a call: while any
/// call is active (from the first outgoing attempt through to connected) the
/// persistent green active-call banner is used instead. It is scoped to the
/// open chat, so an ongoing call in another group is only surfaced once its
/// chat is opened.

final class OngoingGroupCallBannerFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<OngoingGroupCallBannerData?>, String> {
  const OngoingGroupCallBannerFamily._()
    : super(
        retry: null,
        name: r'ongoingGroupCallBannerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Emits the ongoing group audio call banner data for [contactId], or `null`
  /// when the banner must not be shown.
  ///
  /// The banner is shown only when the local user is NOT in a call: while any
  /// call is active (from the first outgoing attempt through to connected) the
  /// persistent green active-call banner is used instead. It is scoped to the
  /// open chat, so an ongoing call in another group is only surfaced once its
  /// chat is opened.

  OngoingGroupCallBannerProvider call(String contactId) =>
      OngoingGroupCallBannerProvider._(argument: contactId, from: this);

  @override
  String toString() => r'ongoingGroupCallBannerProvider';
}
