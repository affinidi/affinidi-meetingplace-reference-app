import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vta_enrolment_offer.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/vta_enrolment_client.dart';

import '../../fakes/fake_vta_host.dart';

void main() {
  final now = DateTime.now();
  late FakeVtaHost host;
  late VtaEnrolmentClient client;
  late VtaEnrolmentOffer offer;
  late Ed25519DidKeySigner manager;

  Matcher failsWith(VtaEnrolmentProblem problem) => throwsA(
    isA<VtaEnrolmentException>().having((e) => e.problem, 'problem', problem),
  );

  setUp(() {
    host = FakeVtaHost(vtaDid: 'did:webvh:QmVta:vta.example');
    client = VtaEnrolmentClient(dio: Dio()..httpClientAdapter = host);
    offer = VtaEnrolmentOffer.parse(
      host.link(expiresAt: now.add(const Duration(minutes: 5))),
      now: now,
    );
    manager = Ed25519DidKeySigner.generate();
  });

  group('VtaEnrolmentClient', () {
    test('submits the DID with a proof the host verifies', () async {
      final code = await client.submit(offer, manager, now: now);

      expect(host.did, manager.did);
      expect(host.state, 'submitted');
      expect(code, vtaEnrolmentCode(FakeVtaHost.nonce, manager.did));
    });

    test('refuses a host that answers another code', () async {
      host.answerCode = 'AAAA-AAAA';

      await expectLater(
        client.submit(offer, manager, now: now),
        failsWith(VtaEnrolmentProblem.codeMismatch),
      );
    });

    test('refuses an offer that was already used', () async {
      await client.submit(offer, manager, now: now);

      await expectLater(
        client.submit(offer, Ed25519DidKeySigner.generate(), now: now),
        failsWith(VtaEnrolmentProblem.alreadyUsed),
      );
    });

    for (final (status, problem) in [
      (410, VtaEnrolmentProblem.expired),
      (404, VtaEnrolmentProblem.alreadyUsed),
      (400, VtaEnrolmentProblem.rejected),
      (401, VtaEnrolmentProblem.rejected),
      (302, VtaEnrolmentProblem.rejected),
      (502, VtaEnrolmentProblem.unreachable),
    ]) {
      test('reads HTTP $status from submit as ${problem.name}', () async {
        host.submitStatus = status;

        await expectLater(
          client.submit(offer, manager, now: now),
          failsWith(problem),
        );
      });
    }

    test('says when the host cannot be reached', () async {
      host.isDown = true;

      await expectLater(
        client.submit(offer, manager, now: now),
        failsWith(VtaEnrolmentProblem.unreachable),
      );
      await expectLater(
        client.status(offer.url),
        failsWith(VtaEnrolmentProblem.unreachable),
      );
    });

    test('reads the status', () async {
      for (final status in VtaEnrolmentStatus.values) {
        host.state = status.name;
        expect(await client.status(offer.url), status);
      }
    });

    test('refuses an unknown status', () async {
      host.state = 'maybe';

      await expectLater(
        client.status(offer.url),
        failsWith(VtaEnrolmentProblem.unreachable),
      );
    });

    test('reaches no plain HTTP host unless allowed', () async {
      await expectLater(
        client.status('http://host.example/api/offers/n'),
        failsWith(VtaEnrolmentProblem.rejected),
      );
    });
  });
}
