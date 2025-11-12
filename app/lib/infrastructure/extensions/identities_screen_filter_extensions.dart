import '../../domain/models/identity/identity.dart';
import '../../presentation/screens/identities/identities_screen_filter.dart';
import 'identities_extensions.dart';

/// Extension methods on [IdentitiesScreenFilter] for filtering identities.
extension IdentitiesScreenFilterExtensions on IdentitiesScreenFilter {
  /// Returns `true` if the given [identity] matches the current filter.
  bool matches(Identity identity) {
    switch (this) {
      case IdentitiesScreenFilter.all:
        return true;

      case IdentitiesScreenFilter.primary:
        return identity.isPrimary;

      case IdentitiesScreenFilter.aliases:
        return !identity.isPrimary && !identity.isPlaceholder;
    }
  }
}
