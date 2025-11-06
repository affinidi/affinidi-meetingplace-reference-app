import 'package:freezed_annotation/freezed_annotation.dart';

import 'mediator_status.dart';
import 'mediator_type.dart';

part 'mediator.freezed.dart';

/// Abstract base class for implementing the Mediator pattern.
///
/// The Mediator pattern defines how a set of objects interact with each
/// other. Instead of objects communicating directly, they communicate
/// through the mediator, promoting loose coupling and centralized control
/// of complex communications.
///
/// This class uses the freezed package (indicated by the `_$Mediator` mixin)
/// to provide immutable data structures and code generation capabilities.
///
/// Subclasses should implement the specific mediation logic for their domain.
@Freezed(fromJson: false, toJson: false)
abstract class Mediator with _$Mediator {
  const factory Mediator({
    required String id,
    required String mediatorName,
    required String mediatorDid,
    required MediatorType type,
    @Default(MediatorStatus.active) MediatorStatus status,
    @Default(null) DateTime? createdTime,
  }) = _Mediator;
}
