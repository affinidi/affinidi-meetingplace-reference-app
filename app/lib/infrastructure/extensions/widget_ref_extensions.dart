import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

/// Extension methods on [WidgetRef] for managing provider lifecycles.
extension WidgetRefExtensions on WidgetRef {
  /// Maintains the state of the provider alive for the scope of the widget.
  void keepAround(ProviderListenable<Object?> provider) {
    listen<Object?>(provider, (_, _) {
      // no-ops
    });
  }
}
