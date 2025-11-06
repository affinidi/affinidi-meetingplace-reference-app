import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../domain/models/contacts/contact.dart';

part 'oob_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class OOBServiceState with _$OOBServiceState {
  factory OOBServiceState({
    Contact? lastAcceptedContact,
    @Default(false) bool isConnectionEstablished,
    @Default(false) bool isLoading,
    String? error,
    ConnectionOffer? currentOobOffer,
    Channel? lastConnectionChannel,
  }) = _OOBServiceState;
}
