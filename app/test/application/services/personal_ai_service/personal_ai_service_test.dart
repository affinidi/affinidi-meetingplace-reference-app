import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';
import 'package:meeting_place_vta_client/meeting_place_vta_client.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service.dart';

PersonalAgentOfferResult _offer({
  String status = 'offer_pending_acceptance',
  String? mnemonic,
  String? channelDid,
  String? channelId,
}) {
  return PersonalAgentOfferResult(
    setupId: 'setup-1',
    status: status,
    mnemonic: mnemonic,
    channelDid: channelDid,
    channelId: channelId,
  );
}

PersonalAgentSetupResult _setup({
  String status = 'offer_pending_acceptance',
  bool mpxConnectionCreated = false,
  bool availableInContacts = false,
}) {
  return PersonalAgentSetupResult(
    holderDid: 'did:key:holder',
    contextId: 'work-ai',
    contextCreated: true,
    agentDid: 'did:key:agent',
    agentCreated: true,
    profile: const PersonalAgentProfile(
      agentDid: 'did:key:agent',
      displayName: 'Work AI',
      mode: PersonalAgentMode.suggestions,
    ),
    setupId: 'setup-1',
    setupStatus: status,
    mpxConnectionCreated: mpxConnectionCreated,
    availableInContacts: availableInContacts,
  );
}

void main() {
  group('PersonalAiService.isConnectedForRestore', () {
    test('returns true when setup already reports ready', () {
      final result = PersonalAiService.isConnectedForRestore(
        setupResult: _setup(status: 'ready'),
      );

      expect(result, isTrue);
    });

    test('returns true when offer carries a connected channel', () {
      final result = PersonalAiService.isConnectedForRestore(
        setupResult: _setup(status: 'offer_pending_acceptance'),
        offer: _offer(channelDid: 'did:channel'),
      );

      expect(result, isTrue);
    });

    test('returns false for a stale pending offer without channel', () {
      final result = PersonalAiService.isConnectedForRestore(
        setupResult: _setup(status: 'offer_pending_acceptance'),
        offer: _offer(mnemonic: 'm1'),
      );

      expect(result, isFalse);
    });
  });

  group('PersonalAiService.awaitChannelAfterAccept', () {
    test('returns as soon as a new channel DID appears', () async {
      final offers = <PersonalAgentOfferResult>[
        _offer(mnemonic: 'm1'),
        _offer(mnemonic: 'm1', channelDid: 'did:new'),
      ];
      var index = 0;

      final result = await PersonalAiService.awaitChannelAfterAccept(
        acceptedMnemonic: 'm1',
        previousChannelDid: null,
        pollInterval: Duration.zero,
        fetchOffer: () async => offers[index++],
        acceptRotatedOffer: (_) async =>
            fail('should not rotate when a new channel arrives'),
      );

      expect(result.channelDid, 'did:new');
    });

    test('skips the stale channel DID and waits for a new one', () async {
      final offers = <PersonalAgentOfferResult>[
        _offer(mnemonic: 'm1', channelDid: 'did:old'),
        _offer(mnemonic: 'm1', channelDid: 'did:old'),
        _offer(mnemonic: 'm1', channelDid: 'did:new'),
      ];
      var index = 0;

      final result = await PersonalAiService.awaitChannelAfterAccept(
        acceptedMnemonic: 'm1',
        previousChannelDid: 'did:old',
        pollInterval: Duration.zero,
        fetchOffer: () async => offers[index++],
        acceptRotatedOffer: (_) async => true,
      );

      expect(result.channelDid, 'did:new');
    });

    test('re-accepts a rotated offer then returns the new channel', () async {
      final offers = <PersonalAgentOfferResult>[
        _offer(mnemonic: 'm1', channelDid: 'did:old'),
        _offer(mnemonic: 'm2'),
        _offer(mnemonic: 'm2', channelDid: 'did:new'),
      ];
      var index = 0;
      final rotated = <String>[];

      final result = await PersonalAiService.awaitChannelAfterAccept(
        acceptedMnemonic: 'm1',
        previousChannelDid: 'did:old',
        pollInterval: Duration.zero,
        fetchOffer: () async => offers[index++],
        acceptRotatedOffer: (mnemonic) async {
          rotated.add(mnemonic);
          return true;
        },
      );

      expect(rotated, ['m2']);
      expect(result.channelDid, 'did:new');
    });

    test('does not re-accept a mnemonic that was already accepted', () async {
      var calls = 0;
      final rotated = <String>[];

      final result = await PersonalAiService.awaitChannelAfterAccept(
        acceptedMnemonic: 'm1',
        previousChannelDid: null,
        maxRounds: 2,
        maxPollsPerRound: 2,
        pollInterval: Duration.zero,
        fetchOffer: () async {
          calls++;
          return _offer(mnemonic: 'm1');
        },
        acceptRotatedOffer: (mnemonic) async {
          rotated.add(mnemonic);
          return true;
        },
      );

      expect(rotated, isEmpty);
      expect(result.mnemonic, 'm1');
      expect(calls, greaterThan(0));
    });

    test('stops when re-accepting the rotated offer fails', () async {
      final offers = <PersonalAgentOfferResult>[
        _offer(mnemonic: 'm2'),
        _offer(mnemonic: 'm2'),
      ];
      var index = 0;
      var rotateCalls = 0;

      final result = await PersonalAiService.awaitChannelAfterAccept(
        acceptedMnemonic: 'm1',
        previousChannelDid: null,
        maxRounds: 3,
        maxPollsPerRound: 2,
        pollInterval: Duration.zero,
        fetchOffer: () async => offers[index++ % offers.length],
        acceptRotatedOffer: (_) async {
          rotateCalls++;
          return false;
        },
      );

      expect(rotateCalls, 1);
      expect(result.channelDid, isNull);
    });

    test('keeps polling when a fetch throws VtaClientException', () async {
      var call = 0;

      final result = await PersonalAiService.awaitChannelAfterAccept(
        acceptedMnemonic: 'm1',
        previousChannelDid: null,
        pollInterval: Duration.zero,
        fetchOffer: () async {
          call++;
          if (call == 1) {
            throw const VtaClientException('transient');
          }
          return _offer(mnemonic: 'm1', channelDid: 'did:new');
        },
        acceptRotatedOffer: (_) async => true,
      );

      expect(result.channelDid, 'did:new');
      expect(call, 2);
    });
  });
}
