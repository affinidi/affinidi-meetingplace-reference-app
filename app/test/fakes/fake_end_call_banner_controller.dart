import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_state.dart';

class FakeEndCallBannerController extends EndCallBannerController {
  FakeEndCallBannerController(this._initial);

  final EndCallBannerState? _initial;

  @override
  EndCallBannerState? build() => _initial;

  @override
  void dismiss() => state = null;

  @override
  void onSwipeUp() {
    if (state != null) {
      state = state!.copyWith(slideOutOffset: 1.0);
    }
    dismiss();
  }
}
