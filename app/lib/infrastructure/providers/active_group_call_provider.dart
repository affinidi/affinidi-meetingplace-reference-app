import 'package:flutter_riverpod/legacy.dart';

/// The channel DID of the currently active group call, or null when no
/// group call is in progress.
///
/// Written by AudioVideoCallScreenController when a group call becomes
/// active or ends. Read by GroupCallJoinBanner inside the group chat screen.
final activeGroupCallProvider = StateProvider<String?>((ref) => null);
