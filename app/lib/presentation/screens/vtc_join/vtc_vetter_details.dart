import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../l10n/app_localizations.dart';

/// What [vetter] published about themselves, a line each, then the DID
/// [vetterDid] their requests go to: for a tooltip on their name. Only the
/// DID when the community's listing was not read.
String vtcVetterDetails(
  AppLocalizations l10n,
  String vetterDid,
  ListedVetter? vetter,
) => [
  if (vetter != null) ...[
    if (vetter.methods.isNotEmpty)
      l10n.vtcVetterDetailsMethods(
        vetter.methods
            .map((method) => l10n.vtcVetterDetailsMethod(method.name))
            .join(', '),
      ),
    if (vetter.languages.isNotEmpty)
      l10n.vtcVetterDetailsLanguages(vetter.languages.join(', ')),
    if (vetter.place case final place?) l10n.vtcVetterDetailsPlace(place),
    if (vetter.acceptsDocumentation.isNotEmpty)
      l10n.vtcVetterDetailsDocuments(
        vetter.acceptsDocumentation
            .map(
              (document) => document == 'none'
                  ? l10n.vtcVetterDetailsNoDocument
                  : l10n.vtcVetterDocument(document),
            )
            .join(', '),
      ),
    if (vetter.availability case final availability?)
      l10n.vtcVetterDetailsAvailability(availability),
    if (vetter.contactHint case final contactHint?)
      l10n.vtcVetterDetailsContactHint(contactHint),
    if (vetter.events.isNotEmpty)
      l10n.vtcVetterDetailsEvents(vetter.events.join(', ')),
  ],
  l10n.vtcVetterDetailsDid(vetterDid),
].join('\n');
