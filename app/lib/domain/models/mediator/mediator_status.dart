/// Represents the current status of a mediator in the system.
///
/// This enum defines the possible states that a mediator can be in,
/// allowing the application to track and respond to different mediator
/// conditions appropriately.
enum MediatorStatus {
  deleted(0),
  active(1);

  const MediatorStatus(this.value);

  final int value;
}
