import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../../domain/models/contacts/contact.dart';
import '../../../../domain/models/identity/identity.dart';

part 'connection_details_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ConnectionDetailsScreenState
    with _$ConnectionDetailsScreenState {
  ConnectionDetailsScreenState._();

  factory ConnectionDetailsScreenState({
    Contact? contact,
    Channel? channel,
    ConnectionOffer? connection,
    Identity? identity,
    Group? group,
    @Default(<String, int>{}) Map<String, int> memberPowerLevels,
    @Default(false) bool showDeletedMembers,
    @Default('') String mediatorName,
    @Default(false) bool isDebugMode,
    @Default(false) bool showMnemonic,
    @Default(false) bool showQrIcon,
    @Default(false) bool showQrView,
  }) = _ConnectionDetailsScreenState;
}
