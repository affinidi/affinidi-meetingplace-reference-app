import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

part 'oob_share_qr_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class OobShareQrState with _$OobShareQrState {
  factory OobShareQrState({
    String? qrData,
    Channel? latestChannel,
  }) = _OobShareQrState;
}
