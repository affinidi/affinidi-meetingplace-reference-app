import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/mediator/mediator.dart';

part 'mediator_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class MediatorServiceState with _$MediatorServiceState {
  factory MediatorServiceState({
    @Default([]) List<Mediator> mediators,
  }) = _MediatorServiceState;
}
