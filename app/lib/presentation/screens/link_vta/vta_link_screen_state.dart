import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../application/services/vtc_service/vta_link_service.dart';

part 'vta_link_screen_state.freezed.dart';

/// What a view of the VTA link shows: the link, and the member's last
/// action on it.
@Freezed(fromJson: false, toJson: false)
abstract class VtaLinkScreenState with _$VtaLinkScreenState {
  factory VtaLinkScreenState({
    @Default(VtaLinkState()) VtaLinkState link,
    @Default(false) bool isBusy,
    VtaLinkFailure? failure,
  }) = _VtaLinkScreenState;
}
