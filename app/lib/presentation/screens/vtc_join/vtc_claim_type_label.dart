import '../../../l10n/app_localizations.dart';

/// What a VTA claim [type] such as `name.display` is called, or the type
/// itself when this app has no name for it, so nothing asked goes unshown.
String vtcClaimTypeLabel(AppLocalizations l10n, String type) => switch (type) {
  'name.display' => l10n.vtcClaimTypeNameDisplay,
  'name.given' => l10n.vtcClaimTypeNameGiven,
  'name.family' => l10n.vtcClaimTypeNameFamily,
  'name.legal' => l10n.vtcClaimTypeNameLegal,
  'email.personal' => l10n.vtcClaimTypeEmailPersonal,
  'email.work' => l10n.vtcClaimTypeEmailWork,
  'phone.mobile' => l10n.vtcClaimTypePhoneMobile,
  'phone.work' => l10n.vtcClaimTypePhoneWork,
  'address.country' => l10n.vtcClaimTypeAddressCountry,
  'person.birthDate' => l10n.vtcClaimTypePersonBirthDate,
  'skill.language' => l10n.vtcClaimTypeSkillLanguage,
  'account.handle' => l10n.vtcClaimTypeAccountHandle,
  _ => type,
};
