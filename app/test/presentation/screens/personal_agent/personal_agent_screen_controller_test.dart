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
import 'package:mpx_flutter_reference_app/application/services/one_drive_service/microsoft_one_drive_auth_service.dart';
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
      bool workContextKilled = false,
    }) {
      fakePersonalAi = _RecordingPersonalAiNotifier(
        PersonalAiServiceState(
          status: PersonalAiSetupStatus.ready,
          showSetupPrompt: false,
          promptDismissed: false,
          contextProvisioned: true,
          contextUploading: false,
          setupResult: _readyWorkSetup(),
          setupResultsByContext: {'work-ai': _readyWorkSetup()},
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
              ContextRoutingState(
                contactContexts: contactContexts,
                workContextKilled: workContextKilled,
              ),
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
          AgentContext.work,
          fileName: 'context.md',
          content: 'hello',
        );

        expect(outcome.uploaded, isTrue);
        expect(fakePersonalAi.setupCallCount, 1);
      },
    );

    test('uploadRoutingContext skips setup when context is killed', () async {
      final container = makeContainer(
        contacts: [],
        contactContexts: {},
        workContextKilled: true,
      );
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );

      final outcome = await controller.uploadRoutingContext(
        AgentContext.work,
        fileName: 'context.md',
        content: 'hello',
      );

      expect(outcome.uploaded, isFalse);
      expect(fakePersonalAi.setupCallCount, 0);
    });

    test('uploadRoutingContext reuses setup when the contact exists', () async {
      final contact = FakeContacts.agentContact;
      final container = makeContainer(
        contacts: [contact],
        contactContexts: {contact.id: AgentContext.work},
      );
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );

      final outcome = await controller.uploadRoutingContext(
        AgentContext.work,
        fileName: 'context.md',
        content: 'hello',
      );

      expect(outcome.uploaded, isTrue);
      expect(fakePersonalAi.setupCallCount, 0);
    });
  });

  group('PersonalAgentScreenController – Work AI Microsoft 365', () {
    late _RecordingPersonalAiNotifier fakePersonalAi;
    late _RecordingOneDriveAuthService fakeOneDriveAuth;
    late _RecordingContextRoutingNotifier fakeContextRouting;

    ProviderContainer makeContainer(
      PersonalAgentSetupResult setupResult, {
      bool authCancelled = false,
      List<Contact> contacts = const [],
      Map<String, AgentContext> contactContexts = const {},
      bool workContextKilled = false,
    }) {
      fakePersonalAi = _RecordingPersonalAiNotifier(
        PersonalAiServiceState(
          status: PersonalAiSetupStatus.ready,
          showSetupPrompt: false,
          promptDismissed: false,
          contextProvisioned: true,
          contextUploading: false,
          setupResult: setupResult,
          setupResultsByContext: {'work-ai': setupResult},
        ),
      );
      fakeOneDriveAuth = _RecordingOneDriveAuthService(
        shouldCancel: authCancelled,
      );
      fakeContextRouting = _RecordingContextRoutingNotifier(
        const ContextRoutingState(),
      );

      final container = ProviderContainer(
        overrides: [
          identitiesServiceProvider.overrideWith(_PrimaryIdentityService.new),
          personalAiServiceProvider.overrideWith((ref) => fakePersonalAi),
          contactsServiceProvider.overrideWith(
            () => _StubContactsService(contacts),
          ),
          contextRoutingServiceProvider.overrideWith((ref) {
            fakeContextRouting = _RecordingContextRoutingNotifier(
              ContextRoutingState(
                contactContexts: contactContexts,
                workContextKilled: workContextKilled,
              ),
            );
            return fakeContextRouting;
          }),
          microsoftOneDriveAuthServiceProvider.overrideWith(
            (ref) => fakeOneDriveAuth,
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
      'does not start Agent Stream setup when Microsoft auth is cancelled',
      () async {
        final container = makeContainer(
          _incompleteWorkSetup(),
          authCancelled: true,
        );
        final controller = container.read(
          personalAgentScreenControllerProvider.notifier,
        );

        final outcome = await controller.connectWorkOneDrive();

        expect(outcome.completed, isFalse);
        expect(outcome.message, 'Microsoft 365 sign-in cancelled.');
        expect(fakeOneDriveAuth.authorizeCallCount, 1);
        expect(fakePersonalAi.setupCallCount, 0);
        expect(fakeOneDriveAuth.storeCallCount, 0);
        expect(fakeContextRouting.markContextUploadedCallCount, 0);
      },
    );

    test('does not reconnect after Work AI connection is killed', () async {
      final container = makeContainer(
        _readyWorkSetup(),
        workContextKilled: true,
      );
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );

      final outcome = await controller.connectWorkOneDrive();

      expect(outcome.completed, isFalse);
      expect(outcome.message, contains('cannot be re-connected'));
      expect(fakeOneDriveAuth.authorizeCallCount, 0);
      expect(fakePersonalAi.setupCallCount, 0);
      expect(fakeOneDriveAuth.storeCallCount, 0);
      expect(fakeContextRouting.markContextUploadedCallCount, 0);
    });

    test(
      'starts Agent Stream setup only after Microsoft auth succeeds',
      () async {
        final container = makeContainer(_incompleteWorkSetup());
        final controller = container.read(
          personalAgentScreenControllerProvider.notifier,
        );

        final outcome = await controller.connectWorkOneDrive();

        expect(outcome.completed, isFalse);
        expect(outcome.message, contains('Work AI setup is incomplete'));
        expect(fakeOneDriveAuth.authorizeCallCount, 1);
        expect(fakePersonalAi.setupCallCount, 1);
        expect(fakeOneDriveAuth.storeCallCount, 0);
        expect(fakeContextRouting.markContextUploadedCallCount, 0);
      },
    );

    test(
      'stores Microsoft auth when setup has id but offer is still pending',
      () async {
        final container = makeContainer(_offerPendingWorkSetup());
        final controller = container.read(
          personalAgentScreenControllerProvider.notifier,
        );

        final outcome = await controller.connectWorkOneDrive();

        expect(outcome.completed, isTrue);
        expect(fakeOneDriveAuth.authorizeCallCount, 1);
        expect(fakePersonalAi.setupCallCount, 1);
        expect(fakeOneDriveAuth.storeCallCount, 1);
        expect(fakeContextRouting.markContextUploadedCallCount, 1);
      },
    );

    test(
      'stores Microsoft auth when setup is pending but Work AI contact exists',
      () async {
        final contact = FakeContacts.agentContact;
        final container = makeContainer(
          _offerPendingWorkSetup(),
          contacts: [contact],
          contactContexts: {contact.id: AgentContext.work},
        );
        final controller = container.read(
          personalAgentScreenControllerProvider.notifier,
        );

        final outcome = await controller.connectWorkOneDrive();

        expect(outcome.completed, isTrue);
        expect(fakeOneDriveAuth.authorizeCallCount, 1);
        expect(fakePersonalAi.setupCallCount, 1);
        expect(fakeOneDriveAuth.storeCallCount, 1);
        expect(fakeContextRouting.markContextUploadedCallCount, 1);
      },
    );

    test(
      'stores Microsoft auth when finalized Work AI contact is unassigned',
      () async {
        final contact = FakeContacts.agentContact;
        final container = makeContainer(
          _offerPendingWorkSetup(),
          contacts: [contact],
        );
        final controller = container.read(
          personalAgentScreenControllerProvider.notifier,
        );

        final outcome = await controller.connectWorkOneDrive();

        final routingState = container.read(contextRoutingServiceProvider);
        expect(outcome.completed, isTrue);
        expect(routingState.contactContexts[contact.id], AgentContext.work);
        expect(fakeOneDriveAuth.storeCallCount, 1);
        expect(fakeContextRouting.markContextUploadedCallCount, 1);
      },
    );
  });

  group('PersonalAgentScreenController – disconnect', () {
    late _RecordingPersonalAiNotifier fakePersonalAi;

    ProviderContainer makeContainer() {
      final contact = FakeContacts.agentContact;
      fakePersonalAi = _RecordingPersonalAiNotifier(
        PersonalAiServiceState(
          status: PersonalAiSetupStatus.ready,
          showSetupPrompt: false,
          promptDismissed: false,
          contextProvisioned: true,
          contextUploading: false,
          setupResult: _readyWorkSetup(),
          setupResultsByContext: {'work-ai': _readyWorkSetup()},
        ),
      );

      final container = ProviderContainer(
        overrides: [
          identitiesServiceProvider.overrideWith(_PrimaryIdentityService.new),
          personalAiServiceProvider.overrideWith((ref) => fakePersonalAi),
          contactsServiceProvider.overrideWith(
            () => _StubContactsService([contact]),
          ),
          contextRoutingServiceProvider.overrideWith(
            (ref) => _StubContextRoutingNotifier(
              ContextRoutingState(
                contactContexts: {contact.id: AgentContext.work},
              ),
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

    test('disconnectRoutingContext clears ready state', () async {
      final container = makeContainer();
      final controller = container.read(
        personalAgentScreenControllerProvider.notifier,
      );

      await controller.disconnectRoutingContext(AgentContext.work);

      final personalAiState = container.read(personalAiServiceProvider);
      final screenState = container.read(personalAgentScreenControllerProvider);

      expect(personalAiState.isReady, isFalse);
      expect(personalAiState.status, PersonalAiSetupStatus.notConfigured);
      expect(personalAiState.setupResultsByContext, isEmpty);
      expect(personalAiState.setupResult, isNull);
      expect(screenState.isReady, isFalse);
    });
  });
}

PersonalAgentSetupResult _readyWorkSetup() {
  return const PersonalAgentSetupResult(
    holderDid: 'did:key:primary-identity',
    contextId: 'work-ai',
    contextCreated: true,
    agentDid: 'did:key:agent',
    agentCreated: true,
    profile: PersonalAgentProfile(
      agentDid: 'did:key:agent',
      displayName: 'Work AI',
      mode: PersonalAgentMode.suggestions,
    ),
    setupId: 'setup-work-1',
    setupStatus: 'ready',
    mpxConnectionCreated: true,
  );
}

PersonalAgentSetupResult _incompleteWorkSetup() {
  return const PersonalAgentSetupResult(
    holderDid: 'did:key:primary-identity',
    contextId: 'work-ai',
    contextCreated: true,
    agentDid: 'did:key:agent',
    agentCreated: true,
    profile: PersonalAgentProfile(
      agentDid: 'did:key:agent',
      displayName: 'Work AI',
      mode: PersonalAgentMode.suggestions,
    ),
    setupId: 'setup-work-1',
    setupStatus: 'cancelled',
    mpxConnectionCreated: false,
    availableInContacts: false,
  );
}

PersonalAgentSetupResult _offerPendingWorkSetup() {
  return const PersonalAgentSetupResult(
    holderDid: 'did:key:primary-identity',
    contextId: 'work-ai',
    contextCreated: true,
    agentDid: 'did:key:agent',
    agentCreated: true,
    profile: PersonalAgentProfile(
      agentDid: 'did:key:agent',
      displayName: 'Work AI',
      mode: PersonalAgentMode.suggestions,
    ),
    setupId: 'setup-work-1',
    setupStatus: 'offer_pending_acceptance',
    mpxConnectionCreated: false,
    availableInContacts: false,
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
  Future<PersonalAgentSetupResult?> waitUntilConnected({
    required String holderDid,
    String contextName = 'work-ai',
    String agentDisplayName = 'Work AI',
    int maxAttempts = 20,
    Duration pollEvery = const Duration(seconds: 1),
  }) async {
    return state.getSetupResultForContext(contextName) ?? state.setupResult;
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
  Future<void> removeSetupForContext(AgentContext target) async {
    final updatedMap = Map<String, PersonalAgentSetupResult>.from(
      state.setupResultsByContext,
    )..remove(target.setupContextName);

    state = state.copyWith(
      status: updatedMap.isEmpty
          ? PersonalAiSetupStatus.notConfigured
          : PersonalAiSetupStatus.settingUp,
      setupResultsByContext: updatedMap,
      clearSetupResult: updatedMap.isEmpty,
      setupResult: updatedMap.isEmpty ? null : updatedMap.values.first,
      contextProvisioned: updatedMap.isNotEmpty && state.contextProvisioned,
      clearErrorMessage: true,
      clearContextUploadError: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubContactsService extends ContactsService {
  _StubContactsService(this._contacts);

  final List<Contact> _contacts;
  int fetchCallCount = 0;

  @override
  ContactsServiceState build() => ContactsServiceState(contacts: _contacts);

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> fetchContacts() async {
    fetchCallCount++;
  }

  @override
  Future<void> deleteContacts(List<Contact> contacts) async {
    _contacts.removeWhere(
      (contact) => contacts.any((item) => item.id == contact.id),
    );
    state = ContactsServiceState(contacts: List<Contact>.from(_contacts));
  }

  @override
  Future<void> removeContactsWithoutLeavingChannel(
    List<Contact> contacts,
  ) async {
    _contacts.removeWhere(
      (contact) => contacts.any((item) => item.id == contact.id),
    );
    state = ContactsServiceState(contacts: List<Contact>.from(_contacts));
  }
}

class _StubContextRoutingNotifier extends StateNotifier<ContextRoutingState>
    implements ContextRoutingService {
  _StubContextRoutingNotifier(super.state);

  @override
  Future<void> assignContactContext(
    String contactId,
    AgentContext context,
  ) async {
    final next = Map<String, AgentContext>.from(state.contactContexts)
      ..[contactId] = context;
    state = state.copyWith(contactContexts: next);
  }

  @override
  Future<void> markContextUploaded({
    required AgentContext context,
    required String fileName,
  }) async {}

  @override
  Future<void> clearContext({required AgentContext context}) async {
    state = state.copyWith(
      workContextUploaded: false,
      clearWorkContextFileName: true,
      contactContexts: <String, AgentContext>{},
    );
  }

  @override
  Future<void> killContext({required AgentContext context}) async {
    state = state.copyWith(
      workContextUploaded: false,
      clearWorkContextFileName: true,
      workContextKilled: true,
      contactContexts: <String, AgentContext>{},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _RecordingContextRoutingNotifier extends _StubContextRoutingNotifier {
  _RecordingContextRoutingNotifier(super.state);

  int markContextUploadedCallCount = 0;

  @override
  Future<void> markContextUploaded({
    required AgentContext context,
    required String fileName,
  }) async {
    markContextUploadedCallCount++;
  }
}

class _RecordingOneDriveAuthService implements MicrosoftOneDriveAuthService {
  _RecordingOneDriveAuthService({this.shouldCancel = false});

  final bool shouldCancel;
  int authorizeCallCount = 0;
  int storeCallCount = 0;

  @override
  Future<MicrosoftOneDriveOAuthResult> authorize() async {
    authorizeCallCount++;
    if (shouldCancel) {
      throw const MicrosoftOneDriveAuthCancelledException();
    }
    return const MicrosoftOneDriveOAuthResult(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      clientId: 'client-id',
      tenantId: 'tenant-id',
      redirectUrl: 'app://callback',
      scopes: ['User.Read'],
    );
  }

  @override
  Future<void> storeConnection({
    required String setupId,
    required String holderDid,
    required MicrosoftOneDriveOAuthResult oauthResult,
  }) async {
    storeCallCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
