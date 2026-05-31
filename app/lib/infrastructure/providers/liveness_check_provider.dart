import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

/// Optional interactive liveness provider (AWS, Azure, etc.).
///
/// When null, the app uses the demo evidence source.
final livenessCheckProviderProvider = Provider<LivenessCheckProvider?>(
  (ref) => null,
  name: 'livenessCheckProviderProvider',
);
