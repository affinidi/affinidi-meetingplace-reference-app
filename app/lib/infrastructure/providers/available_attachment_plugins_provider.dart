import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// A Riverpod provider that supplies the list of available [AttachmentPlugin]s.
///
/// Can be overridden to register custom attachment plugins for the app.
/// By default, returns an empty list.
final availableAttachmentPluginsProvider =
    Provider<List<AttachmentPlugin>>((ref) => []);
