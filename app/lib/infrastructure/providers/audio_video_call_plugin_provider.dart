import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

/// Supplies the active [AudioVideoCallPlugin].
///
/// Returns `null` by default — the UI hides the call button when no plugin
/// is registered. Override in `main.dart` to enable calling:
///
/// ```dart
/// audioVideoCallPluginProvider.overrideWith((ref) async {
///   final sdk = await ref.watch(meetingPlaceSdkProvider.future);
///   return MeetingPlaceLiveKitPlugin(
///     sdk: sdk,
///     livekitServiceUrl: Uri.parse(
///       ref.read(environmentProvider).livekitServiceUrl,
///     ),
///   );
/// }),
/// ```
final audioVideoCallPluginProvider = FutureProvider<AudioVideoCallPlugin?>(
  (ref) async => null,
);
