import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// Provides the [MeetingPlaceVtcSDK] for Verifiable Trust Community (VTC)
/// features, such as signing in to a community's portal.
///
/// Kept alive so the DID resolver and HTTPS transport are shared app-wide.
final vtcSdkProvider = Provider<MeetingPlaceVtcSDK>(
  (ref) => MeetingPlaceVtcSDK(),
  name: 'vtcSdkProvider',
);
