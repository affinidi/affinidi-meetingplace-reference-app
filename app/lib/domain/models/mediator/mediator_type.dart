/// Represents the different types of mediators available in the system.
///
/// A mediator acts as an intermediary component that facilitates
/// communication and coordination between different parts of the
/// application or external services. This enum defines the various
/// mediator implementations that can be used.
enum MediatorType {
  local(1),
  custom(2);

  const MediatorType(this.value);

  final int value;
}
