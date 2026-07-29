import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/context_routing_service/context_routing_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/signing_service/signing_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/personal_agent/personal_agent_screen_controller.dart';

import '../../../mocks/fake_app_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
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
