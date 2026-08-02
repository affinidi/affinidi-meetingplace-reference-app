import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/context_routing_service/context_routing_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/signing_service/signing_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/personal_agent/personal_agent_screen_controller.dart';

import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_identities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('PersonalAgentScreenController – auto response', () {
    late _FakeSigningNotifier fakeSigningNotifier;

    ProviderContainer makeContainer({
      required bool stepUpEnabled,
      bool shouldFail = false,
    }) {
      fakeSigningNotifier = _FakeSigningNotifier(
        stepUpEnabled: stepUpEnabled,
        shouldFail: shouldFail,
      );

      final container = ProviderContainer(
        overrides: [
          identitiesServiceProvider.overrideWith(_FakeIdentitiesService.new),
          personalAiServiceProvider.overrideWith(
            (ref) => _FakePersonalAiNotifier(),
          ),
          contactsServiceProvider.overrideWith(_FakeContactsService.new),
          contextRoutingServiceProvider.overrideWith(
            (ref) => _FakeContextRoutingNotifier(),
          ),
          signingServiceProvider.overrideWith((ref) => fakeSigningNotifier),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('loadAutoResponseState sets autoResponseEnabled to true '
        'when step-up is disabled', () async {
      final container = makeContainer(stepUpEnabled: false);
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );

      await controller.loadAutoResponseState();

      final state = container.read(personalAgentScreenControllerProvider);
      expect(state.autoResponseEnabled, isTrue);
      expect(state.autoResponseAvailable, isTrue);
    });

    test('loadAutoResponseState sets autoResponseEnabled to false '
        'when step-up is enabled', () async {
      final container = makeContainer(stepUpEnabled: true);
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );

      await controller.loadAutoResponseState();

      final state = container.read(personalAgentScreenControllerProvider);
      expect(state.autoResponseEnabled, isFalse);
    });

    test('toggleAutoResponse flips from disabled to enabled', () async {
      final container = makeContainer(stepUpEnabled: true);
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );
      await controller.loadAutoResponseState();
      expect(
        container
            .read(personalAgentScreenControllerProvider)
            .autoResponseEnabled,
        isFalse,
      );

      await controller.toggleAutoResponse();

      final state = container.read(personalAgentScreenControllerProvider);
      expect(state.autoResponseEnabled, isTrue);
      expect(state.autoResponseLoading, isFalse);
      expect(fakeSigningNotifier.lastSetStepUpEnabled, isFalse);
    });

    test(
      'toggleAutoResponse fails cleanly when VTA is not connected',
      () async {
        fakeSigningNotifier = _FakeSigningNotifier(
          stepUpEnabled: false,
          shouldFail: false,
          status: SigningServiceStatus.disconnected,
        );

        final container = ProviderContainer(
          overrides: [
            identitiesServiceProvider.overrideWith(_FakeIdentitiesService.new),
            personalAiServiceProvider.overrideWith(
              (ref) => _FakePersonalAiNotifier(),
            ),
            contactsServiceProvider.overrideWith(_FakeContactsService.new),
            contextRoutingServiceProvider.overrideWith(
              (ref) => _FakeContextRoutingNotifier(),
            ),
            signingServiceProvider.overrideWith((ref) => fakeSigningNotifier),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          personalAgentScreenControllerProvider.notifier,
        );

        await controller.toggleAutoResponse();

        final state = container.read(personalAgentScreenControllerProvider);
        expect(state.autoResponseAvailable, isFalse);
        expect(
          state.errorMessage,
          'Auto response is unavailable until VTA is connected',
        );
        expect(state.autoResponseLoading, isFalse);
        expect(fakeSigningNotifier.lastSetStepUpEnabled, isNull);
      },
    );

    test('toggleAutoResponse flips from enabled to disabled', () async {
      final container = makeContainer(stepUpEnabled: false);
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );
      await controller.loadAutoResponseState();
      expect(
        container
            .read(personalAgentScreenControllerProvider)
            .autoResponseEnabled,
        isTrue,
      );

      await controller.toggleAutoResponse();

      final state = container.read(personalAgentScreenControllerProvider);
      expect(state.autoResponseEnabled, isFalse);
      expect(state.autoResponseLoading, isFalse);
      expect(fakeSigningNotifier.lastSetStepUpEnabled, isTrue);
    });

    test('toggleAutoResponse sets errorMessage on failure', () async {
      final container = makeContainer(stepUpEnabled: false, shouldFail: true);
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );
      await controller.loadAutoResponseState();

      await controller.toggleAutoResponse();

      final state = container.read(personalAgentScreenControllerProvider);
      expect(state.autoResponseLoading, isFalse);
      expect(state.errorMessage, contains('Auto response toggle failed'));
      // Should remain in original state on failure
      expect(state.autoResponseEnabled, isTrue);
    });

    test('toggleAutoResponse sets autoResponseLoading during call', () async {
      final container = makeContainer(stepUpEnabled: true);
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );
      await controller.loadAutoResponseState();

      final loadingStates = <bool>[];
      container.listen(
        personalAgentScreenControllerProvider.select(
          (s) => s.autoResponseLoading,
        ),
        (_, loading) => loadingStates.add(loading),
      );

      await controller.toggleAutoResponse();

      expect(loadingStates, contains(true));
      expect(loadingStates.last, isFalse);
    });
  });

  group('PersonalAgentScreenController – setup reuse gate', () {
    late _RecordingPersonalAiNotifier fakePersonalAi;

    ProviderContainer makeContainer({
      required List<Contact> contacts,
      required Map<String, AgentContext> contactContexts,
    }) {
      fakePersonalAi = _RecordingPersonalAiNotifier(
        PersonalAiServiceState(
          status: PersonalAiSetupStatus.ready,
          showSetupPrompt: false,
          promptDismissed: false,
          contextProvisioned: true,
          contextUploading: false,
          setupResult: _readyPersonalSetup(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          identitiesServiceProvider.overrideWith(_PrimaryIdentityService.new),
          personalAiServiceProvider.overrideWith((ref) => fakePersonalAi),
          contactsServiceProvider.overrideWith(
            () => _StubContactsService(contacts),
          ),
          contextRoutingServiceProvider.overrideWith(
            (ref) => _StubContextRoutingNotifier(
              ContextRoutingState(contactContexts: contactContexts),
            ),
          ),
          signingServiceProvider.overrideWith(
            (ref) => _FakeSigningNotifier(stepUpEnabled: false),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test(
      'uploadRoutingContext re-runs setup when the contact is missing',
      () async {
        final container = makeContainer(contacts: [], contactContexts: {});
        final controller = container.read(
          personalAgentScreenControllerProvider.notifier,
        );

        final outcome = await controller.uploadRoutingContext(
          AgentContext.personal,
          fileName: 'context.md',
          content: 'hello',
        );

        expect(outcome.uploaded, isTrue);
        expect(fakePersonalAi.setupCallCount, 1);
      },
    );

    test('uploadRoutingContext reuses setup when the contact exists', () async {
      final contact = FakeContacts.agentContact;
      final container = makeContainer(
        contacts: [contact],
        contactContexts: {contact.id: AgentContext.personal},
      );
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );

      final outcome = await controller.uploadRoutingContext(
        AgentContext.personal,
        fileName: 'context.md',
        content: 'hello',
      );

      expect(outcome.uploaded, isTrue);
      expect(fakePersonalAi.setupCallCount, 0);
    });
  });
}

PersonalAgentSetupResult _readyPersonalSetup() {
  return const PersonalAgentSetupResult(
    holderDid: 'did:key:primary-identity',
    contextId: 'personal-ai',
    contextCreated: true,
    agentDid: 'did:key:agent',
    agentCreated: true,
    profile: PersonalAgentProfile(
      agentDid: 'did:key:agent',
      displayName: 'Personal AI',
      mode: PersonalAgentMode.suggestions,
    ),
    setupId: 'setup-personal-1',
    setupStatus: 'ready',
  );
}

// -- Fakes --

class _FakeSigningNotifier extends StateNotifier<SigningServiceState>
    implements SigningService {
  _FakeSigningNotifier({
    required this.stepUpEnabled,
    this.shouldFail = false,
    this.status = SigningServiceStatus.connected,
  }) : super(SigningServiceState(status: status));

  bool stepUpEnabled;
  final bool shouldFail;
  final SigningServiceStatus status;
  bool? lastSetStepUpEnabled;

  @override
  Future<bool> getStepUpEnabled() async => stepUpEnabled;

  @override
  Future<void> setStepUpEnabled(bool enabled) async {
    if (shouldFail) {
      throw StateError('VTA not connected');
    }
    lastSetStepUpEnabled = enabled;
    stepUpEnabled = enabled;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeIdentitiesService extends IdentitiesService {
  @override
  IdentitiesServiceState build() => IdentitiesServiceState();
}

class _FakePersonalAiNotifier extends StateNotifier<PersonalAiServiceState>
    implements PersonalAiService {
  _FakePersonalAiNotifier() : super(const PersonalAiServiceState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeContactsService extends ContactsService {
  @override
  ContactsServiceState build() => ContactsServiceState();
}

class _FakeContextRoutingNotifier extends StateNotifier<ContextRoutingState>
    implements ContextRoutingService {
  _FakeContextRoutingNotifier() : super(const ContextRoutingState());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _PrimaryIdentityService extends IdentitiesService {
  @override
  IdentitiesServiceState build() =>
      IdentitiesServiceState(currentIdentity: FakeIdentities.primaryIdentity);
}

class _RecordingPersonalAiNotifier extends StateNotifier<PersonalAiServiceState>
    implements PersonalAiService {
  _RecordingPersonalAiNotifier(super.state);

  int setupCallCount = 0;

  @override
  Future<void> setupPersonalAi({
    required String holderDid,
    String contextName = 'personal-ai',
    String agentDisplayName = 'My Personal AI',
  }) async {
    setupCallCount++;
  }

  @override
  Future<void> uploadContext({
    required String setupId,
    required String content,
    String setupContextName = 'personal-ai',
    String agentDisplayName = 'My Personal AI',
  }) async {}

  @override
  Future<void> refreshPersonalAiContactSync() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubContactsService extends ContactsService {
  _StubContactsService(this._contacts);

  final List<Contact> _contacts;

  @override
  ContactsServiceState build() => ContactsServiceState(contacts: _contacts);

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> fetchContacts() async {}
}

class _StubContextRoutingNotifier extends StateNotifier<ContextRoutingState>
    implements ContextRoutingService {
  _StubContextRoutingNotifier(super.state);

  @override
  Future<void> markContextUploaded({
    required AgentContext context,
    required String fileName,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
