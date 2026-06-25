import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_service.dart';

/// Fake [IncomingCallService] for unit tests.
///
/// Records accept and decline calls without touching the plugin or state.
class FakeIncomingCallService extends IncomingCallService {
  final List<String> acceptedCallIds = [];
  final List<String> declinedCallIds = [];

  @override
  void build() {}

  @override
  void accept({required String callId}) => acceptedCallIds.add(callId);

  @override
  void decline({required String callId}) => declinedCallIds.add(callId);
}
