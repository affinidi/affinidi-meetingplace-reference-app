import 'package:meeting_place_credentials/meeting_place_credentials.dart';

class FakeNoOpRCardRepository implements RCardRepository {
  @override
  Future<void> upsert(RCard rCard) async {}

  @override
  Stream<List<RCard>> watchAll() => const Stream.empty();

  @override
  Future<List<RCard>> listAll() async => [];

  @override
  Future<RCard?> getBySubjectDid(String subjectDid) async => null;

  @override
  Future<void> deleteBySubjectDid(String subjectDid) async {}

  @override
  Future<void> updateNotes(String subjectDid, String? notes) async {}
}
