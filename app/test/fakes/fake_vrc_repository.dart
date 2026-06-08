import 'package:meeting_place_credentials/meeting_place_credentials.dart';

class FakeNoOpVrcRepository implements VrcRepository {
  @override
  Future<void> upsert(Vrc vrc) async {}

  @override
  Stream<List<Vrc>> watchAll() => const Stream.empty();

  @override
  Future<List<Vrc>> listAll() async => [];

  @override
  Future<Vrc?> getById(String id) async => null;

  @override
  Future<List<Vrc>> listByHolderDid(String holderDid) async => [];

  @override
  Future<int> countByHolderDid(String holderDid) async => 0;

  @override
  Future<void> deleteById(String id) async {}
}
