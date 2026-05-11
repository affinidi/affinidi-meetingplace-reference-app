import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension methods on [WidgetRef] for managing provider lifecycles.
extension WidgetRefExtensions on WidgetRef {
  /// Maintains the state of the provider alive for the scope of the widget.
  void keepAround<T>(ProviderListenable<T> provider) {
    listen<T>(provider, (_, _) {
      // no-ops
    });
  }
}
