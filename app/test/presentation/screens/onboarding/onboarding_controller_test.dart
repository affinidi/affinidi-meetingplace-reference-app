import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/settings_service/settings_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vta_link_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/onboarding/onboarding_screen/onboarding_controller.dart';

import '../../../fakes/fake_settings_service.dart';

final _steps = <String>[];

class _RecordingSettingsService extends FakeSettingsService {
  @override
  Future<void> setAlreadyOnboarded(bool value) async {
    _steps.add('onboarded');
    state = state.copyWith(alreadyOnboarded: value);
  }
}

class _RecordingVtaLinkService extends VtaLinkService {
  @override
  VtaLinkState build() => const VtaLinkState(status: VtaLinkStatus.active);

  @override
  Future<void> forgetLeftover() async {
    _steps.add('forgotten');
    state = const VtaLinkState(status: VtaLinkStatus.unlinked);
  }
}

void main() {
  setUp(_steps.clear);

  test('finishing onboarding forgets a leftover VTA link first', () async {
    final container = ProviderContainer(
      overrides: [
        settingsServiceProvider.overrideWith(_RecordingSettingsService.new),
        vtaLinkServiceProvider.overrideWith(_RecordingVtaLinkService.new),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(onboardingControllerProvider.notifier)
        .onFinishOnboarding();

    expect(_steps, ['forgotten', 'onboarded']);
    expect(container.read(settingsServiceProvider).alreadyOnboarded, isTrue);
    expect(
      container.read(vtaLinkServiceProvider).status,
      VtaLinkStatus.unlinked,
    );
  });
}
