import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// What a [MeetingPlaceVtcSDKException] may be logged as.
extension VtcExceptionLogging on MeetingPlaceVtcSDKException {
  /// Its code, and the reason a VTA or host gave when it refused, such as
  /// `refused (rooms/records/put:epochBehind)`: protocol codes only, never
  /// the message, which may name a DID.
  String get logCode =>
      refusalCode == null ? code.name : '${code.name} ($refusalCode)';
}
