import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

/// Extension methods on [WidgetRef] for managing provider lifecycles.
extension WidgetRefExtensions on WidgetRef {
  /// Maintains the state of the provider alive for the scope of the widget.
  void keepAround<T extends Object?>(ProviderListenable<T> provider) {
    listen<T>(provider, (_, _) {
      // no-ops
    });
  }
}
