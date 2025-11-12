import '../models/mediator/mediator.dart';

/// Repository interface for managing mediator-related operations.
///
/// This abstract interface defines the contract for mediator data access
/// and manipulation operations. Implementations of this repository should
/// handle the persistence and retrieval of mediator entities within the
/// application's domain layer.
///
/// The repository follows the Repository pattern to provide a clean
/// abstraction layer between the domain logic and data sources.
abstract interface class MediatorsRepository {
  Future<List<Mediator>> listMediators();
  Future<List<Mediator>> listCustomMediators();
  Future<void> addCustomMediator({required String did, required String name});
  Future<void> renameCustomMediator(
      {required String did, required String newName});
  Future<void> removeMediator(String did);
}
