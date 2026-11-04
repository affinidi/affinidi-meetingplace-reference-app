import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/credential_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/repositories/identities_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/identities_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';

import '../../../fakes/fake_vta.dart';
import '../../../mocks/fake_app_logger.dart';

const _personaDid = 'did:webvh:QmP:dids.example:ada';

String _picture({required int size}) =>
    base64Encode(img.encodeJpg(img.Image(width: size, height: size)));

void main() {
  late FakeVta vta;
  late _MemoryIdentitiesRepository repository;
  late ProviderContainer container;

  IdentitiesService service() =>
      container.read(identitiesServiceProvider.notifier);

  List<Object?> sent() => vta.received.map((r) => r['type']).toList();

  Map<String, dynamic> payloadOf(String type) =>
      vta.received.lastWhere((r) => r['type'] == type)['payload']
          as Map<String, dynamic>;

  Identity newIdentity() => const Identity(
    id: 'id-1',
    did: '',
    card: ContactCard(
      id: 'id-1',
      did: '',
      type: 'individual',
      firstName: 'Ada',
      displayName: 'Ada L',
      email: 'ada@example.com',
    ),
  );

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    vta = FakeVta()
      ..answers[VtaTask.serversList] = {
        'servers': [
          {'id': 'dids'},
        ],
      }
      ..answers[VtaTask.didsCreate] = {
        'did': _personaDid,
        'contextId': 'mpx-1',
        'signingKeyId': '$_personaDid#key-0',
      }
      ..answers[VtaTask.profileCompose] = {
        'profileId': '01PROFILE',
        'scope': 'local',
        'version': 1,
      };
    final vtc = VtcService(
      sdk: vta.sdk(),
      repository: SecureStorageVtcRepository(),
      userVerificationKey: UserVerificationKey(
        FakeUserVerificationKeyStorage(),
      ),
      platform: 'ios',
    );
    await vtc.startLink(vta.did);
    await vtc.checkGrant();
    vta.received.clear();

    repository = _MemoryIdentitiesRepository();
    container = ProviderContainer(
      overrides: [
        appLoggerProvider.overrideWithValue(FakeAppLogger()),
        vtcServiceProvider.overrideWithValue(vtc),
        identitiesRepositoryProvider.overrideWith((ref) async => repository),
        credentialServiceProvider.overrideWith(_FakeCredentialService.new),
      ],
    );
    addTearDown(container.dispose);
  });

  group('IdentitiesService with a linked VTA', () {
    test('creates the identity as a persona and keeps references', () async {
      await service().addIdentity(newIdentity());

      final stored = repository.identities.single;
      expect(stored.did, _personaDid);
      expect(stored.card.did, _personaDid);
      expect(stored.vtaContextId, 'mpx-1');
      expect(stored.vtaProfileId, '01PROFILE');
      expect(stored.isPrimary, isTrue);
      expect(stored.isVtaPersona, isTrue);
      final claims = payloadOf(VtaTask.profileCompose)['claims'] as List;
      expect(claims.map((claim) => (claim as Map)['type']), [
        'name.display',
        'name.given',
        'email.personal',
      ]);
    });

    test('creates nothing when the VTA refuses', () async {
      vta.refusals[VtaTask.profileCompose] = {
        'code': 'persona/profile/compose:noPersonaHere',
      };

      await expectLater(
        service().addIdentity(newIdentity()),
        throwsA(isA<MeetingPlaceVtcSDKException>()),
      );

      expect(repository.identities, isEmpty);
      expect(sent().last, VtaTask.contextsDelete);
    });

    test('deletes the persona when the phone cannot keep it', () async {
      repository.failAdd = true;

      await expectLater(
        service().addIdentity(newIdentity()),
        throwsA(isA<StateError>()),
      );

      expect(sent().sublist(sent().length - 2), [
        VtaTask.profileRetire,
        VtaTask.contextsDelete,
      ]);
    });

    test('updates the VTA profile, then the copy on the phone', () async {
      await service().addIdentity(newIdentity());
      final stored = repository.identities.single;

      await service().updateIdentity(
        stored.copyWith(card: stored.card.copyWith(displayName: 'Ada 2')),
      );

      final entries = payloadOf(VtaTask.localProfilePut)['entries'] as List;
      expect(((entries.first as Map)['inline'] as Map)['value'], 'Ada 2');
      expect(repository.identities.single.card.displayName, 'Ada 2');
    });

    test('deletes the persona on the VTA, then the identity', () async {
      await service().addIdentity(newIdentity());

      await service().deleteIdentity('id-1');

      expect(payloadOf(VtaTask.contextsDelete), {'id': 'mpx-1', 'force': true});
      expect(repository.identities, isEmpty);
    });

    test('takes in a profile changed on the VTA', () async {
      await service().addIdentity(newIdentity());
      vta.answers[VtaTask.localProfileGet] = {
        'profile': {
          'profileId': '01PROFILE',
          'name': 'Meeting Place identity',
          'version': 3,
          'entries': [
            {
              'slot': 'displayName',
              'inline': {
                'type': 'name.display',
                'valueType': 'string',
                'value': 'Ada Lovelace',
              },
            },
            {
              'inline': {
                'type': 'name.given',
                'valueType': 'string',
                'value': 'Ada',
              },
            },
          ],
        },
      };

      await service().refreshFromVta();

      final card = repository.identities.single.card;
      expect(card.displayName, 'Ada Lovelace');
      expect(card.email, isNull);
      expect(
        container
            .read(identitiesServiceProvider)
            .currentIdentity
            ?.card
            .displayName,
        'Ada Lovelace',
      );
    });

    test('sends a thumbnail of the picture to the VTA', () async {
      final identity = newIdentity();
      await service().addIdentity(
        identity.copyWith(
          card: identity.card.copyWith(profilePic: _picture(size: 1024)),
        ),
      );

      final claims = payloadOf(VtaTask.profileCompose)['claims'] as List;
      final thumbnail =
          claims.cast<Map>().singleWhere(
                (claim) => claim['type'] == 'x:photo.thumbnail',
              )['value']
              as String;
      final image = img.decodeImage(base64Decode(thumbnail))!;
      expect(image.width, 256);
      expect(
        thumbnail.length,
        lessThanOrEqualTo(VtaProfile.maxThumbnailLength),
      );
      expect(
        repository.identities.single.card.profilePic,
        isNot(thumbnail),
        reason: 'the phone keeps the full picture',
      );
    });

    group('reading a thumbnail from the VTA', () {
      final thumbnail = _picture(size: 64);

      setUp(() {
        vta.answers[VtaTask.localProfileGet] = {
          'profile': {
            'entries': [
              {
                'slot': 'displayName',
                'inline': {
                  'type': 'name.display',
                  'valueType': 'string',
                  'value': 'Ada L',
                },
              },
              {
                'inline': {
                  'type': 'name.given',
                  'valueType': 'string',
                  'value': 'Ada',
                },
              },
              {
                'inline': {
                  'type': 'email.personal',
                  'valueType': 'string',
                  'value': 'ada@example.com',
                },
              },
              {
                'slot': 'avatar',
                'inline': {
                  'type': 'x:photo.thumbnail',
                  'valueType': 'string',
                  'value': thumbnail,
                },
              },
            ],
          },
        };
      });

      test('fills in a picture the phone lacks', () async {
        await service().addIdentity(newIdentity());

        await service().refreshFromVta();

        expect(repository.identities.single.card.profilePic, thumbnail);
      });

      test('keeps the picture the phone has', () async {
        final picture = _picture(size: 512);
        final identity = newIdentity();
        await service().addIdentity(
          identity.copyWith(card: identity.card.copyWith(profilePic: picture)),
        );

        await service().refreshFromVta();

        expect(repository.identities.single.card.profilePic, picture);
      });
    });

    test('keeps the copy when the VTA cannot be reached', () async {
      await service().addIdentity(newIdentity());
      vta.isDown = true;

      await service().refreshFromVta();

      expect(repository.identities.single.card.displayName, 'Ada L');
    });

    test('keeps the identity when the VTA cannot delete it', () async {
      await service().addIdentity(newIdentity());
      vta.refusals[VtaTask.contextsDelete] = {
        'code': 'vta/contexts/delete:hostCleanupFailed',
      };

      await expectLater(
        service().deleteIdentity('id-1'),
        throwsA(isA<MeetingPlaceVtcSDKException>()),
      );

      expect(repository.identities, hasLength(1));
    });
  });
}

class _MemoryIdentitiesRepository implements IdentitiesRepository {
  final List<Identity> identities = [];
  bool failAdd = false;

  @override
  Future<List<Identity>> listIdentities() async => List.of(identities);

  @override
  Future<Identity> addIdentity(Identity identity) async {
    if (failAdd) throw StateError('disk full');
    identities.add(identity);
    return identity;
  }

  @override
  Future<void> updateIdentity(Identity identity) async {
    final index = identities.indexWhere((i) => i.id == identity.id);
    identities[index] = identity;
  }

  @override
  Future<void> deleteIdentity(String id) async =>
      identities.removeWhere((i) => i.id == id);
}

class _FakeCredentialService extends CredentialService {
  _FakeCredentialService(Ref ref) : super(ref: ref);

  @override
  Future<void> deleteCredentialForIdentity(String identityId) async {}
}
