import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/mediator_service/mediator_service.dart';
import '../../../application/services/settings_service/settings_service.dart';
import '../../../infrastructure/configuration/app_info.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/providers/app_info_provider.dart';
import '../../widgets/async_loaders/async_loading_controller.dart';
import 'settings_screen_state.dart';

part 'settings_screen_controller.g.dart';

@Riverpod(keepAlive: true)
class SettingsScreenController extends _$SettingsScreenController {
  late final scanMediatorQRLoadingController =
      AsyncLoadingController.provider('scanMediatorQRLoadingController');

  @override
  SettingsScreenState build() {
    ref.listen(
      mediatorServiceProvider.select((state) => state.mediators),
      (prev, next) {
        Future.microtask(() {
          final mediatorProvider =
              ref.read(mediatorServiceProvider.filteredMediators);
          state = state.copyWith(mediators: mediatorProvider);
        });
      },
      fireImmediately: true,
    );

    ref.listen(
      settingsServiceProvider.select((state) => state.selectedMediatorDid),
      (prev, next) {
        Future.microtask(() {
          state = state.copyWith(selectedMediatorDid: next);
        });
      },
      fireImmediately: true,
    );

    ref.listen(
      settingsServiceProvider.select(
        (state) => (state.isDebugMode, state.shouldShowMeetingPlaceQR),
      ),
      (prev, next) {
        Future.microtask(() {
          final (isDebugMode, shouldShowMeetingPlaceQR) = next;
          state = state.copyWith(
            isDebugMode: isDebugMode,
            shouldShowMeetingPlaceQR: shouldShowMeetingPlaceQR,
          );
        });
      },
      fireImmediately: true,
    );

    final numberOfTapsToUnlockDebug =
        ref.read(environmentProvider).numberOfTapsToUnlockDebug;

    final currentSettingsState = ref.read(settingsServiceProvider);

    return SettingsScreenState(
      numberOfTapsToUnlockDebug: numberOfTapsToUnlockDebug,
      selectedMediatorDid: currentSettingsState.selectedMediatorDid,
    );
  }

  Future<AppInfo>? initializing;

  Future<void> ensureInitialized() async {
    initializing ??= ref.read(appInfoProvider.future);
    final appInfo = await initializing;
    state = state.copyWith(appInfo: appInfo);
  }

  Future<void> selectMediator(String mediatorDid) async {
    final settingsService = ref.read(settingsServiceProvider.notifier);
    await settingsService.selectMediatorConfig(mediatorDid);
  }

  Future<void> removeCustomMediator(String did) async {
    final mediatorService = ref.read(mediatorServiceProvider.notifier);
    await mediatorService.removeCustomMediator(did);
  }

  Future<void> toggleDebugMode() async {
    final settingsService = ref.read(settingsServiceProvider.notifier);
    await settingsService.toggleDebugMode();
  }

  Future<void> scanMediatorQr({
    required String url,
    required String unnamedPrefix,
  }) async {
    final mediatorService = ref.read(mediatorServiceProvider.notifier);
    final did = await mediatorService.getMediatorIdByUrl(url);

    if (did == null) {
      throw AppException(
        'No mediator found at the provided URL',
        code: AppExceptionType.unableToFindMediator.name,
      );
    }

    await _addCustomMediator(did: did, unnamedPrefix: unnamedPrefix);
  }

  Future<void> renameCustomMediator({
    required String did,
    required String newName,
  }) async {
    final mediatorService = ref.read(mediatorServiceProvider.notifier);
    await mediatorService.renameCustomMediator(did: did, newName: newName);
  }

  Future<void> toggleShouldShowMeetingPlaceQR() async {
    final settingsService = ref.read(settingsServiceProvider.notifier);
    await settingsService.toggleShouldShowMeetingPlaceQR();
  }

  Future<void> _addCustomMediator({
    required String did,
    required String unnamedPrefix,
  }) async {
    final mediatorService = ref.read(mediatorServiceProvider.notifier);
    await mediatorService.addCustomMediator(
      did: did,
      unnamedPrefix: unnamedPrefix,
    );
  }
}
