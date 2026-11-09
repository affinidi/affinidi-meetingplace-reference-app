import '../../../l10n/app_localizations.dart';

/// Prefix of a role the community defined itself, as in `custom:coach`.
const _customRolePrefix = 'custom:';

/// A member's [role] in a community in plain words; a role the community
/// defined itself by its own name, which never reads as a built-in one.
String vtcRoleName(AppLocalizations l10n, String role) =>
    role.startsWith(_customRolePrefix)
    ? role.substring(_customRolePrefix.length)
    : l10n.vtcCommunityRoleName(role);
