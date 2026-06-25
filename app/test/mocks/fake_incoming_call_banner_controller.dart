import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_service.dart'
    show IncomingCallService;
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/incoming_call/incoming_call_banner_controller.dart';

/// Fake [IncomingCallBannerController] for testing.
///
/// Records accept and dismiss calls for assertions without touching
/// [IncomingCallService].
class FakeIncomingCallBannerController extends IncomingCallBannerController {
  final List<String> acceptedCallIds = [];
  final List<String> dismissedCallIds = [];

  @override
  bool build() => false;

  @override
  void accept({required String callId}) {
    acceptedCallIds.add(callId);
    state = true;
  }

  @override
  void dismiss({required String callId}) {
    dismissedCallIds.add(callId);
    state = true;
  }

  @override
  void reset() => state = false;
}
