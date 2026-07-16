import 'package:meeting_place_matrix/meeting_place_matrix.dart'
    show CallMediaType;
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/incoming_call/incoming_call_banner_controller.dart';

/// Fake [IncomingCallBannerController] for testing.
///
/// Records accept, acceptRecall, and dismiss calls for assertions.
class FakeIncomingCallBannerController extends IncomingCallBannerController {
  final List<String> acceptedCallIds = [];
  final List<String> dismissedCallIds = [];

  @override
  bool build() => false;

  @override
  void accept({
    required String callId,
    required String otherPartyChannelDid,
    required CallMediaType mediaType,
    required String? contactId,
  }) {
    acceptedCallIds.add(callId);
    state = true;
  }

  @override
  void acceptRecall({
    required String callId,
    required String contactId,
    required bool isAudioOnly,
  }) {
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
