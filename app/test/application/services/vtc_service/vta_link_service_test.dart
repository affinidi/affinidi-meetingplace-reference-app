import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vta_link_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vta_enrolment_offer.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/vta_enrolment_client.dart';

import '../../../fakes/fake_vta.dart';
import '../../../fakes/fake_vta_host.dart';

const _timing = VtaLinkTiming(
  interval: Duration(milliseconds: 20),
  window: Duration(milliseconds: 300),
);

const _adminOnly = {
  'roles': ['admin'],
  'capabilities': ['vault-read'],
};

void main() {
  late FakeVta vta;
  late FakeVtaHost host;

  ProviderContainer container() {
    final container = ProviderContainer(
      overrides: [
        vtcServiceProvider.overrideWithValue(
          VtcService(
            sdk: vta.sdk(),
            repository: SecureStorageVtcRepository(),
            userVerificationKey: UserVerificationKey(
              FakeUserVerificationKeyStorage(),
            ),
            enrolmentClient: VtaEnrolmentClient(
              dio: Dio()..httpClientAdapter = host,
            ),
            platform: 'ios',
          ),
        ),
        vtaLinkTimingProvider.overrideWithValue(_timing),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<VtaLinkState> loaded(ProviderContainer container) async {
    await container.read(vtaLinkServiceProvider.notifier).ensureLoaded();
    return container.read(vtaLinkServiceProvider);
  }

  /// Waits, in real time, until [test] holds for the link state.
  Future<void> until(
    ProviderContainer container,
    bool Function(VtaLinkState state) test,
  ) async {
    // Generous: other test files load the machine while this one polls.
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (!test(container.read(vtaLinkServiceProvider))) {
      if (DateTime.now().isAfter(deadline)) fail('state never matched');
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  int whoAmICount() =>
      vta.received.where((r) => r['type'] == VtaTask.whoAmI).length;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/vta_link_controller_test.log'),
    );
  });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    vta = FakeVta()..answers[VtaTask.whoAmI] = _adminOnly;
    host = FakeVtaHost(vtaDid: vta.did);
  });

  group('VtaLinkService', () {
    test('is unlinked when nothing is stored', () async {
      final state = await loaded(container());

      expect(state.status, VtaLinkStatus.unlinked);
    });

    test('refuses text that is not a DID, staying unlinked', () async {
      final c = container();
      await loaded(c);

      final error = await c
          .read(vtaLinkServiceProvider.notifier)
          .link('my agent')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(VtaLinkFailure.of(error!), VtaLinkFailure.invalidDid);
      expect(c.read(vtaLinkServiceProvider).status, VtaLinkStatus.unlinked);
    });

    test('refuses a VTA DID that does not resolve, staying unlinked', () async {
      final c = container();
      await loaded(c);

      final error = await c
          .read(vtaLinkServiceProvider.notifier)
          .link('did:webvh:QmMissing:vta.example')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(VtaLinkFailure.of(error!), VtaLinkFailure.didNotResolved);
      expect(c.read(vtaLinkServiceProvider).status, VtaLinkStatus.unlinked);
    });

    test('waits for the grant, then becomes active on its own', () async {
      final c = container();
      await loaded(c);

      await c.read(vtaLinkServiceProvider.notifier).link(vta.did);

      final pending = c.read(vtaLinkServiceProvider);
      expect(pending.status, VtaLinkStatus.pending);
      expect(pending.isPolling, isTrue);
      expect(pending.managerDid, startsWith('did:key:'));
      expect(
        pending.grantCommand,
        contains('--role admin --capabilities persona-holder'),
      );

      await until(c, (state) => state.isAdminOnly);

      vta.answers[VtaTask.whoAmI] = {
        'roles': ['admin'],
        'capabilities': ['persona-holder'],
      };
      await until(c, (state) => state.status == VtaLinkStatus.active);
      expect(c.read(vtaLinkServiceProvider).isPolling, isFalse);
    });

    test('stops after the window, then checks again by hand', () async {
      final c = container();
      await loaded(c);
      await c.read(vtaLinkServiceProvider.notifier).link(vta.did);

      await until(c, (state) => state.hasTimedOut);
      expect(c.read(vtaLinkServiceProvider).isPolling, isFalse);
      final checks = whoAmICount();
      await Future<void>.delayed(_timing.interval * 3);
      expect(whoAmICount(), checks);

      vta.answers.remove(VtaTask.whoAmI);
      vta.answers[VtaTask.whoAmI] = {
        'roles': ['admin'],
        'capabilities': ['persona-holder'],
      };
      await c.read(vtaLinkServiceProvider.notifier).checkAgain();

      expect(c.read(vtaLinkServiceProvider).status, VtaLinkStatus.active);
    });

    test('pauses while the app is in the background', () async {
      final c = container();
      await loaded(c);
      final controller = c.read(vtaLinkServiceProvider.notifier);
      await controller.link(vta.did);

      controller.setInBackground(true);
      await Future<void>.delayed(_timing.interval * 2);
      final checks = whoAmICount();
      await Future<void>.delayed(_timing.interval * 4);
      expect(whoAmICount(), checks);

      controller.setInBackground(false);
      await until(c, (_) => whoAmICount() > checks);
    });

    test('keeps waiting while the VTA cannot be reached', () async {
      final c = container();
      await loaded(c);
      await c.read(vtaLinkServiceProvider.notifier).link(vta.did);

      vta.isDown = true;
      await until(
        c,
        (state) => state.checkFailure == VtaLinkFailure.unreachable,
      );
      expect(c.read(vtaLinkServiceProvider).status, VtaLinkStatus.pending);

      vta.isDown = false;
      await until(
        c,
        (state) => state.checkFailure == null && state.isAdminOnly,
      );
    });

    test('resumes a pending link after a restart', () async {
      final first = container();
      await loaded(first);
      await first.read(vtaLinkServiceProvider.notifier).link(vta.did);
      final managerDid = first.read(vtaLinkServiceProvider).managerDid;
      first.dispose();

      final restarted = container();
      final state = await loaded(restarted);

      expect(state.status, VtaLinkStatus.pending);
      expect(state.managerDid, managerDid);
      expect(state.isPolling, isTrue);
    });

    test('removing the link forgets it', () async {
      final c = container();
      await loaded(c);
      final controller = c.read(vtaLinkServiceProvider.notifier);
      await controller.link(vta.did);

      await controller.remove();

      expect(c.read(vtaLinkServiceProvider).status, VtaLinkStatus.unlinked);
      expect(await c.read(vtcServiceProvider).linkedVta(), isNull);
      expect(c.read(vtaLinkServiceProvider).isPolling, isFalse);
    });
  });

  group('VtaLinkService enrolment', () {
    const granted = {
      'roles': ['admin'],
      'capabilities': ['persona-holder'],
    };

    String link({Duration lifetime = const Duration(minutes: 5)}) =>
        host.link(expiresAt: DateTime.now().add(lifetime));

    void notOnTheAccessList() =>
        vta.refusals[VtaTask.whoAmI] = {'code': 'auth/whoami:notAuthorized'};

    test('submits a new key and shows the code the host shows', () async {
      final c = container();
      await loaded(c);

      await c.read(vtaLinkServiceProvider.notifier).link(link());

      final pending = c.read(vtaLinkServiceProvider);
      expect(pending.status, VtaLinkStatus.pending);
      expect(pending.isEnrolment, isTrue);
      expect(pending.vtaDid, vta.did);
      expect(pending.managerDid, startsWith('did:key:'));
      expect(host.did, pending.managerDid);
      expect(
        pending.enrolmentCode,
        vtaEnrolmentCode(FakeVtaHost.nonce, pending.managerDid!),
      );
      await until(c, (_) => host.statusReads > 0);
    });

    test('becomes active once granted, and stays so after a restart', () async {
      notOnTheAccessList();
      final first = container();
      await loaded(first);
      await first.read(vtaLinkServiceProvider.notifier).link(link());

      host.state = 'granted';
      vta.refusals.remove(VtaTask.whoAmI);
      vta.answers[VtaTask.whoAmI] = granted;
      await until(first, (state) => state.status == VtaLinkStatus.active);
      expect(first.read(vtaLinkServiceProvider).enrolmentCode, isNull);
      first.dispose();

      final restarted = container();
      final state = await loaded(restarted);
      expect(state.status, VtaLinkStatus.active);
      expect(state.isEnrolment, isFalse);
      expect(
        (await restarted.read(vtcServiceProvider).linkedVta())?.enrolment,
        isNull,
      );
    });

    test('waits for the VTA, not the host, to grant', () async {
      notOnTheAccessList();
      final c = container();
      await loaded(c);
      await c.read(vtaLinkServiceProvider.notifier).link(link());

      host.state = 'granted';
      final reads = host.statusReads;
      await until(c, (_) => host.statusReads > reads + 1);

      expect(c.read(vtaLinkServiceProvider).status, VtaLinkStatus.pending);
    });

    test('forgets the link when the admin refuses it', () async {
      final c = container();
      await loaded(c);
      await c.read(vtaLinkServiceProvider.notifier).link(link());

      host.state = 'refused';
      await until(c, (state) => state.status == VtaLinkStatus.unlinked);

      expect(
        c.read(vtaLinkServiceProvider).enrolmentOutcome,
        VtaEnrolmentOutcome.refused,
      );
      expect(await c.read(vtcServiceProvider).linkedVta(), isNull);
    });

    test('forgets the link when the host says the offer expired', () async {
      final c = container();
      await loaded(c);
      await c.read(vtaLinkServiceProvider.notifier).link(link());

      host.state = 'expired';
      await until(c, (state) => state.status == VtaLinkStatus.unlinked);

      expect(
        c.read(vtaLinkServiceProvider).enrolmentOutcome,
        VtaEnrolmentOutcome.expired,
      );
    });

    test('ends as expired past the expiry when the host is away', () async {
      notOnTheAccessList();
      final c = container();
      await loaded(c);
      await c
          .read(vtaLinkServiceProvider.notifier)
          .link(link(lifetime: const Duration(seconds: 2)));
      host.isDown = true;

      await Future<void>.delayed(const Duration(milliseconds: 2100));
      await c.read(vtaLinkServiceProvider.notifier).checkAgain();
      await until(c, (state) => state.status == VtaLinkStatus.unlinked);

      expect(
        c.read(vtaLinkServiceProvider).enrolmentOutcome,
        VtaEnrolmentOutcome.expired,
      );
    });

    test('refuses an offer that cannot be read, staying unlinked', () async {
      final c = container();
      await loaded(c);

      final error = await c
          .read(vtaLinkServiceProvider.notifier)
          .link('keyring://vta/enrol?o=bm90IGpzb24')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(VtaLinkFailure.of(error!), VtaLinkFailure.offerMalformed);
      expect(c.read(vtaLinkServiceProvider).status, VtaLinkStatus.unlinked);
      expect(host.did, isNull);
    });

    test('stores nothing when the host answers another code', () async {
      host.answerCode = 'AAAA-AAAA';
      final c = container();
      await loaded(c);

      final error = await c
          .read(vtaLinkServiceProvider.notifier)
          .link(link())
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(VtaLinkFailure.of(error!), VtaLinkFailure.codeMismatch);
      expect(await c.read(vtcServiceProvider).linkedVta(), isNull);
    });
  });
}
