import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vta_link_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'vta_link_screen_state.dart';

part 'vta_link_screen_controller.g.dart';

/// Drives a view of the VTA link, on the link screen or in the settings:
/// turns the member's taps into link actions and their outcome into what the
/// view shows. Logs the type of a failure only; never a DID or key.
@riverpod
class VtaLinkScreenController extends _$VtaLinkScreenController {
  late final VtaLinkService _service = ref.read(
    vtaLinkServiceProvider.notifier,
  );

  @override
  VtaLinkScreenState build() {
    ref.listen(
      vtaLinkServiceProvider,
      (_, link) => state = state.copyWith(link: link),
    );
    return VtaLinkScreenState(link: ref.read(vtaLinkServiceProvider));
  }

  /// Starts linking the VTA [vtaDid].
  Future<void> link(String vtaDid) => _run(() => _service.link(vtaDid));

  /// Checks for the grant again, after the phone stopped checking.
  Future<void> checkAgain() => _service.checkAgain();

  /// Cancels a pending link or removes the active one.
  Future<void> remove() => _run(_service.remove);

  Future<void> _run(Future<void> Function() action) async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, failure: null);
    try {
      await action();
    } on InvalidVtaDidException catch (error) {
      _fail(error);
    } on VtaAlreadyLinkedException catch (error) {
      _fail(error);
    } on MeetingPlaceVtcSDKException catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .error(
            'VTA link step failed: ${error.code.name}',
            stackTrace: stackTrace,
            name: 'VtaLinkScreenController',
          );
      _fail(error);
    } finally {
      if (ref.mounted) state = state.copyWith(isBusy: false);
    }
  }

  void _fail(Object error) {
    if (!ref.mounted) return;
    state = state.copyWith(failure: VtaLinkFailure.of(error));
  }
}
