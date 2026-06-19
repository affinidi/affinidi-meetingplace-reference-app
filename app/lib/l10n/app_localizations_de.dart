// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Treffpunkt';

  @override
  String tabsTitle(String tabName) {
    String _temp0 = intl.Intl.selectLogic(tabName, {
      'connections': 'Einladungen',
      'contacts': 'Kanäle',
      'identities': 'Identitäten',
      'rCards': 'R-Karten',
      'credentials': 'Anmeldeinformationen',
      'settings': 'Einstellungen',
      'other': 'Ungültig',
    });
    return '$_temp0';
  }

  @override
  String get rCardsPlaceholderMessage => 'R-Cards werden hier angezeigt.';

  @override
  String get publishOffer => 'Einladung veröffentlichen';

  @override
  String get publishGroupOffer => 'Gruppeneinladung veröffentlichen';

  @override
  String get meetingPlaceBannerText =>
      'Meeting Place ermöglicht es Ihnen, anonym und privat eine Einladung zu veröffentlichen, um sich mit Ihnen zu verbinden. Geben Sie eine Überschrift und eine Beschreibung sowie Details zur Gültigkeit an, um die Verfügbarkeit des Angebots zu begrenzen.';

  @override
  String get connectionOfferDetails => 'Details zur Einladung';

  @override
  String get createGroupChatOffer => 'Gruppenchat';

  @override
  String get chatTransport => 'Chat-Übertragung';

  @override
  String transportLabel(String transport) {
    String _temp0 = intl.Intl.selectLogic(transport, {
      'didcomm': 'DIDComm',
      'matrix': 'Matrix',
      'other': '$transport',
    });
    return '$_temp0';
  }

  @override
  String get groupOfferHelperText =>
      'Die Einladung stellt einen Gruppenchat dar, an dem mehrere Kontakte teilnehmen und chatten können. Sie haben weiterhin die Kontrolle darüber, wer dem Gruppenchat beitreten kann.';

  @override
  String get generateRandomPhraseHelperEnabled =>
      'Generieren einer zufälligen Phrase';

  @override
  String get generateRandomPhraseHelperDisabled =>
      'Die von Ihnen eingegebene benutzerdefinierte Phrase wird verwendet, um diese Einladung zur Verbindung eindeutig zu identifizieren. Es muss einzigartig im Meeting Place-Universum sein.';

  @override
  String get customPhrase => 'Benutzerdefinierte Phrase';

  @override
  String get enterCustomPhrase => 'Benutzerdefinierte Phrase eingeben';

  @override
  String get customPhraseHelperText =>
      'Geben Sie eine eindeutige benutzerdefinierte Phrase ein. Sie können so viele Wörter verwenden, wie Sie möchten, getrennt durch Leerzeichen.';

  @override
  String get chatGroupName => 'Name der Chat-Gruppe';

  @override
  String get headline => 'Schlagzeile';

  @override
  String get description => 'Beschreibung';

  @override
  String get validityVisibilitySettings =>
      'Gültigkeits- und Sichtbarkeitseinstellungen';

  @override
  String get searchableAtMeetingPlace => 'Durchsuchbar bei meetingplace.world';

  @override
  String get searchableHelperText =>
      'Wenn diese Option ausgewählt ist, können die Details, die Sie in diesem Angebot teilen, unter meetingplace.world';

  @override
  String get setExpiry => 'Ablauf festlegen';

  @override
  String get setExpiryHelperEnabled =>
      'Die Einladung läuft zum angegebenen Datum und zur angegebenen Uhrzeit ab';

  @override
  String get setExpiryHelperDisabled =>
      'Die Einladung bleibt gültig, bis sie gelöscht wird, und läuft nicht ab';

  @override
  String expiresAt(String date, String time) {
    return 'Läuft ab: $date um $time';
  }

  @override
  String get scanCustomMediatorQrCode =>
      'Scannen Sie den QR-Code des benutzerdefinierten Nachrichtenservers';

  @override
  String get chooseMediatorHelper =>
      'Wählen Sie aus, welcher Message-Server für Ihre Verbindungen verwendet werden soll. Sie können benutzerdefinierte Nachrichtenserver hinzufügen, indem Sie deren QR-Code scannen.';

  @override
  String get setMediatorName => 'Festlegen des Namens des Nachrichtenservers';

  @override
  String newConnectionOptionTitle(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'shareQRCode': 'Direktes Teilen des QR-Codes',
      'scanQRCode': 'Direktes Scannen eines QR-Codes',
      'claimAnOffer': 'Einladung zum Treffpunkt annehmen',
      'publishAnOffer': 'Einladung zum Treffpunkt veröffentlichen',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get setExpiryDateTime =>
      'Festlegen des Ablaufdatums und der Ablaufzeit';

  @override
  String get selectExpiryHelperText =>
      'Wählen Sie aus, wann dieses Angebot ablaufen soll';

  @override
  String get changeButton => 'Veränderung';

  @override
  String get limitNumberOfUses => 'Begrenzen Sie die Anzahl der Verwendungen';

  @override
  String get limitUsesHelperEnabled =>
      'Die Einladung kann nur so oft verwendet werden';

  @override
  String get limitUsesHelperDisabled =>
      'Die Einladung kann unbegrenzt oft verwendet werden';

  @override
  String canBeUsedTimes(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Kann $amount Mal verwendet werden',
      one: 'Kann nur einmal verwendet werden',
    );
    return '$_temp0';
  }

  @override
  String newConnectionOptionSubtitle(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'shareQRCode':
          'Bietet Ihnen vollständige Privatsphäre und Vertraulichkeit',
      'scanQRCode': 'Scannen Sie einen QR-Code mit Ihrer Kamera',
      'claimAnOffer': 'Verbinden Sie sich mit jemandem über Meeting Place',
      'publishAnOffer':
          'Werben Sie für Ihre Einladung zur Verbindung auf Meeting Place',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get unableToDetectCamera => 'Eine Kamera kann nicht erkannt werden';

  @override
  String get newConnectionsOptionsHeader =>
      'Wählen Sie eine Option aus, um eine neue Verbindung zu erstellen';

  @override
  String get oobQrPresentInvitationMessage =>
      'Zeigen Sie diesen QR-Code mit jemandem, um eine Verbindung herzustellen';

  @override
  String get connectionsNowConnected => 'Sie sind nun verbunden mit';

  @override
  String get connectionsPanelOobFailedTitle => 'Fehler bei der Kanalerstellung';

  @override
  String get connectionsPanelOobFailedBody =>
      'Die Verbindung kann nicht hergestellt werden. Bitte versuchen Sie es erneut.';

  @override
  String connectionsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Alle',
      'offers': 'Angebote',
      'claims': 'Ansprüche',
      'complete': 'Abgeschlossen',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noConnections => 'Keine Verbindungen in dieser Ansicht';

  @override
  String connectionDeleteHeading(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Einladungen löschen',
      one: 'Einladung löschen',
    );
    return '$_temp0';
  }

  @override
  String get selectMaxUsagesHelperText =>
      'Wählen Sie aus, wie oft dieses Angebot genutzt werden kann';

  @override
  String get mediator => 'Message-Server';

  @override
  String get mediatorHelperText =>
      'Dies ist der Nachrichtenserver, der für die Kommunikation mit jedem Kontakt verwendet wird, der sich über dieses Angebot verbindet';

  @override
  String get errorLoadingMediator => 'Fehler beim Laden des Meldungsservers';

  @override
  String get publishToMeetingPlace => 'Auf Meeting Place veröffentlichen';

  @override
  String connectWithFirstName(String firstName) {
    return 'Verbinden Sie sich mit $firstName!';
  }

  @override
  String firstNameChatGroup(String firstName) {
    return ' Chatgruppe von$firstName';
  }

  @override
  String get passphraseDescription =>
      'Verbinden Sie sich mit mir über Meeting Place!';

  @override
  String get headlineRequired => 'Überschrift ist erforderlich';

  @override
  String get descriptionRequired => 'Beschreibung ist erforderlich';

  @override
  String get customPhraseRequired =>
      'Benutzerdefinierte Phrase ist erforderlich, wenn keine zufällige Phrase verwendet wird';

  @override
  String get expiryDateRequired =>
      'Das Ablaufdatum ist erforderlich, wenn der Ablauf aktiviert ist';

  @override
  String get expiryDateFuture => 'Das Ablaufdatum muss in der Zukunft liegen';

  @override
  String get maxUsagesGreaterThanZero =>
      'Die maximale Nutzung muss größer als 0 sein.';

  @override
  String failedToPublishOffer(String error) {
    return 'Einladung konnte nicht veröffentlicht werden: $error';
  }

  @override
  String get selectMediator => 'Message-Server auswählen';

  @override
  String connectionDeletePrompt(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other:
          'Sind Sie sicher, dass Sie $amount ausgewählte Einladungen löschen möchten? Sie können Einladungen nicht wiederherstellen!',
      one:
          'Sind Sie sicher, dass Sie diese Einladung löschen möchten? Sie können eine Einladung nicht wiederherstellen!',
      zero:
          'Sind Sie sicher, dass Sie diese Einladung löschen möchten? Sie können eine Einladung nicht wiederherstellen!',
    );
    return '$_temp0';
  }

  @override
  String get generalCancel => 'Abbrechen';

  @override
  String get generalDelete => 'Löschen';

  @override
  String get generalSave => 'Speichern';

  @override
  String get generalDone => 'Fertig';

  @override
  String get connectionsPanelSubtitle =>
      'Wischen und tippen Sie, um Ihre Einladungen zu verwalten und Kanäle zum Chatten mit Ihren Kontakten einzurichten';

  @override
  String get findPersonAiBusinessDescription =>
      'Um sich mit einer Person oder einem KI-Agenten auf Meeting Place zu verbinden, geben Sie die Verbindungsphrase ein, die sie mit Ihnen geteilt haben.';

  @override
  String get enterPassphrase => 'Passphrase eingeben';

  @override
  String get claimOfferTitle => 'Eine Einladung auf Meeting Place finden';

  @override
  String get generalSearch => 'Suchen';

  @override
  String get generalConnect => 'Verbinden';

  @override
  String contactCardFieldName(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'firstName': 'Vorname',
      'lastName': 'Nachname',
      'email': 'E-Mail',
      'mobile': 'Mobil',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get offerDetailsHeader => 'Meine Einladungsinformationen';

  @override
  String get acceptOfferTitle => 'Details zur Einladungsanfrage';

  @override
  String get offerDetailsDescription =>
      'Verbinden Sie sich mit mir über Meeting Place!';

  @override
  String get errorOwnerCannotClaimOffer =>
      'Sie können diese Einladung nicht beanspruchen, da Sie der Eigentümer sind';

  @override
  String get aliasPickerTitle =>
      'Verbindung mit dieser ausgewählten Identität herstellen';

  @override
  String get aliasPickerDescription =>
      'Identitäten helfen Ihnen, Ihre persönlichen Daten privat und unter Ihrer Kontrolle zu halten. Sie können den von Ihnen konfigurierten Alias für die primäre Identität verwenden oder einen Ihrer zusätzlichen Identitätsaliase für diese Einladung auswählen.';

  @override
  String error(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(errorCode, {
      'connection_offer_owned_by_claiming_party':
          'Sie können diese Einladung nicht annehmen, da Sie der Einladende sind!',
      'connection_offer_already_claimed_by_claiming_party':
          'Sie können diese Einladung nicht annehmen, da Sie bereits eine Verbindungsanfrage gestellt haben und eine ausstehende Forderung in Bearbeitung ist',
      'missingMnemonic':
          'Bitte geben Sie ein Einladungspasswort ein, um zu suchen',
      'connection_offer_not_found_error':
          'Die von Ihnen angegebenen Details stimmen mit keiner aktiven Einladung überein.',
      'discovery_register_offer_group_generic':
          'Einladung konnte nicht veröffentlicht werden.',
      'missingDeviceToken':
          'Benachrichtigungstoken für das Gerät konnte nicht gefunden werden',
      'offerOwnedByClaimingParty':
          'Sie können diese Einladung nicht beanspruchen, da Sie der Eigentümer sind',
      'offerAlreadyClaimedByParty':
          'Sie können dieses Angebot nicht beanspruchen, da Sie die Einladung bereits angenommen haben und eine ausstehende Anfrage in Bearbeitung ist',
      'offerNotFound':
          'Die von Ihnen angegebenen Details stimmen mit keiner aktiven Einladung überein.',
      'mediatorAlreadyExists':
          'Nachrichtendienst mit derselben DID existiert bereits.',
      'mediator_get_did_error':
          'Kein Nachrichtendienst unter der angegebenen URL gefunden',
      'unableToFindMediator':
          'Kein Nachrichtendienst unter der angegebenen URL gefunden',
      'oobFlowTimedOut':
          'Verbindung zur anderen Partei konnte nicht hergestellt werden, der QR-Code wurde wahrscheinlich bereits verwendet',
      'connection_offer_expired': 'Diese Einladung ist abgelaufen',
      'connection_offer_limit_exceeded':
          'Diese Einladung hat die maximale Anzahl von Verwendungen erreicht',
      'register_offer_mnemonic_in_use':
          'Dieser Satz wird bereits verwendet, bitte wählen Sie einen anderen',
      'invalidQrCode': 'QR-Code ist ungültig',
      'oob_invalid_data': 'QR-Code-Daten sind ungültig',
      'oob_not_found':
          'QR-Code-Daten stimmen mit keiner aktiven Einladung überein',
      'oob_invalid_type': 'QR-Code-Daten werden nicht unterstützt',
      'network_error':
          'Verbindung konnte nicht hergestellt werden. Überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.',
      'deleteContactFailed':
          'Kontakt konnte nicht gelöscht werden. Bitte versuchen Sie es erneut.',
      'other': '$errorCode',
    });
    return '$_temp0';
  }

  @override
  String get offerCreated => 'Einladung erstellt';

  @override
  String offerExpiresAt(String formattedExpiry) {
    return 'Die Einladung endet um $formattedExpiry';
  }

  @override
  String get offerValidityNote =>
      'Die Einladung ist bis zu dem oben genannten Datum und der oben genannten Uhrzeit gültig, es sei denn, es wird eine maximale Anzahl von Zugriffen erreicht';

  @override
  String get offerUnlimitedUsages =>
      'Diese Einladung kann beliebig oft verwendet werden';

  @override
  String offerMaxUsages(int maxUsages) {
    String _temp0 = intl.Intl.pluralLogic(
      maxUsages,
      locale: localeName,
      other: 'Diese Einladung kann $maxUsages Mal verwendet werden',
      one: 'Diese Einladung kann 1 Mal verwendet werden',
    );
    return '$_temp0';
  }

  @override
  String get noExpirySetHelperText =>
      'Es wurde kein Ablaufdatum festgelegt, sodass diese Einladung zur Verbindung nicht abläuft';

  @override
  String get validityVisibilityDetails =>
      'Details zur Gültigkeit und Sichtbarkeit';

  @override
  String get personalInformationShared => 'Geteilte personenbezogene Daten';

  @override
  String get myAliasProfile => 'Mein Alias-Profil';

  @override
  String get didInformation => 'DID-Informationen';

  @override
  String didSha256(String didSha256) {
    return '$didSha256 (SHA256)';
  }

  @override
  String get offerUsesPrimaryIdentity =>
      'Diese Einladung verwendet Ihre primäre Identität';

  @override
  String offerUsesAliasIdentity(String alias) {
    return 'Diese Einladung verwendet den Identitätsalias mit dem Namen \"$alias\"';
  }

  @override
  String get aliasProfileDescription =>
      'Ihr Alias-Profil hilft Ihnen, Ihre Identität privat und unter Kontrolle zu halten.';

  @override
  String get generalOk => 'Okay';

  @override
  String get contactsPanelSubtitle =>
      'Tippen Sie auf einen Kontakt, um zu chatten, doppeltippen Sie, um Details anzuzeigen, tippen und halten Sie ihn gedrückt, um ihn zu löschen.';

  @override
  String contactsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'any': 'Beliebig',
      'person': 'Person',
      'group': 'Gruppe',
      'service': 'KI-Agent',
      'business': 'Unternehmen',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noContactsYet => 'Keine Kontakte in dieser Ansicht';

  @override
  String get contactDeleteHeading => 'Kontakt löschen';

  @override
  String contactDeletePrompt(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Möchten Sie wirklich $amount ausgewählte Kanäle löschen?',
      one: 'Möchten Sie diesen Kanal wirklich löschen?',
      zero: 'Möchten Sie diesen Kanal wirklich löschen?',
    );
    return '$_temp0';
  }

  @override
  String connectedVia(String mediatorName) {
    return 'Verbunden über $mediatorName';
  }

  @override
  String contactAdded(String dateAdded) {
    return 'Hinzugefügte $dateAdded';
  }

  @override
  String get filter => 'Filter...';

  @override
  String get noContactsMatchFilter =>
      'Es gibt keine Kontakte, die mit Ihrem Filter übereinstimmen';

  @override
  String connectionPhrase(String phrase) {
    return 'Phrase: $phrase';
  }

  @override
  String usesIdentityViaMediator(String identity, String mediator) {
    return 'Verwendet Ihre $identity Identität über $mediator';
  }

  @override
  String usesIdentity(String identity) {
    return 'Verwendet Ihre $identity-Identität zur Verbindung';
  }

  @override
  String get timeAgoJustNow => 'Gerade';

  @override
  String timeAgoMinute(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'vor $minutes Minuten',
      one: 'vor 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoMinuteWorded => 'Vor einer Minute';

  @override
  String timeAgoHourNumeric(num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'vor $hours Stunden',
      one: 'vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoHourWorded => 'Vor einer Stunde';

  @override
  String timeAgoDay(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoYesterday => 'Gestern';

  @override
  String timeAgoWeek(num weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'vor $weeks Wochen',
      one: 'vor 1 Woche',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoLastWeek => 'Letzte Woche';

  @override
  String timeAgoSecond(num seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'vor $seconds Sekunden',
      one: 'vor 1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String createdValidUntil(String createdTimeAgo, String validUntilDate) {
    return 'Angelegt $createdTimeAgo, gültig bis $validUntilDate';
  }

  @override
  String createdValidWithoutExpiration(String createdTimeAgo) {
    return 'Erstellt ${createdTimeAgo}ohne Ablaufdatum';
  }

  @override
  String get displayName => 'Anzeigename';

  @override
  String get generalName => 'Name';

  @override
  String get displayNameHelperText =>
      'Sie können den Anzeigenamen für diesen Kontakt ändern. Der anderen Partei wird dieser Name nicht angezeigt.';

  @override
  String get generalDid => 'TAT';

  @override
  String get generalDidSha256 => 'DIS (SHA256)';

  @override
  String get connectionEstablished => 'Kanal eingerichtet';

  @override
  String get generalMediator => 'Message-Server';

  @override
  String get connectionApproach => 'Ansatz zur Kanaleinrichtung';

  @override
  String get theirDetails => 'Ihre Details';

  @override
  String get mySharedIdentityDetails =>
      'Details zu meiner gemeinsamen Identität';

  @override
  String get connectionDetails => 'Details zur Kanalverbindung';

  @override
  String get myIdentity => 'Meine Identität';

  @override
  String get identitiesPanelSubtitle =>
      'Wischen Sie nach links und rechts, um Ihre Identitätsliste zu überprüfen und hinzuzufügen, ziehen Sie sie zum Löschen nach unten ';

  @override
  String identitiesFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Alle',
      'primary': 'Primär',
      'aliases': 'Aliase',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get identityDeleteHeading => 'Identität löschen';

  @override
  String identityDeletePrompt(Object identity) {
    return 'Sind Sie sicher, dass Sie die Identität \"$identity\" löschen möchten?\n\nSie können eine Identität nicht wiederherstellen!';
  }

  @override
  String get displayNamePrimary => 'Primäre Identität';

  @override
  String get displayNameAddNew => 'Neue Identität hinzufügen';

  @override
  String get displayNameAlias => 'Identitäts-Alias';

  @override
  String get subtitlePrimary => 'Ihre primäre Identität';

  @override
  String get subtitleAddNew => 'Erstellen eines neuen Alias';

  @override
  String get subtitleAlias => 'Alias-Identität';

  @override
  String get notShared => 'Nicht geteilt';

  @override
  String get unknownUser => 'Unbekannter Benutzer';

  @override
  String get unnamed => 'Unnnamed';

  @override
  String get unnamedMediator => 'Unbekannter Benutzer';

  @override
  String get addNewIdentityAlias => 'Hinzufügen eines neuen Identitätsalias';

  @override
  String get identityAliasesDescription =>
      'Übernehmen Sie die Kontrolle über Ihre Privatsphäre, indem Sie Identitätsaliase erstellen, um sich gegenüber Kontakten, mit denen Sie sich verbinden, zu repräsentieren';

  @override
  String get generalReject => 'Ablehnen';

  @override
  String get generalApprove => 'Billigen';

  @override
  String get zalgoTextDetectedError =>
      'Ungewöhnliche Zeichen erkannt. Bitte entfernen Sie sie und versuchen Sie es erneut.';

  @override
  String get chatTooLong => 'Die Chat-Nachricht ist zu lang';

  @override
  String get splashScreenTitle => 'Treffpunkt';

  @override
  String get toProtectData =>
      'Um Ihre Daten zu schützen, erfordert diese Anwendung eine sichere Authentifizierung, um fortzufahren.';

  @override
  String get authInstructionAndroid =>
      'Gehen Sie zu Einstellungen > Sicherheit > Bildschirmsperre und aktivieren Sie eine PIN, ein Muster oder einen Fingerabdruck.';

  @override
  String get authInstructionIos =>
      'Gehe zu \"Einstellungen\" > \"Face ID & Code\" (oder \"Touch ID & Code\") und richte Face ID, Touch ID oder einen Geräte-Code ein.';

  @override
  String get authInstructionMacos =>
      'Gehen Sie zu den Systemeinstellungen > Touch ID & Passwort (oder Anmeldepasswort) und richten Sie Touch ID oder ein sicheres Passwort ein.';

  @override
  String get authUnlockReason =>
      'Bitte entsperren Sie Ihr Gerät, um fortzufahren';

  @override
  String chatTypeMessagePrompt(String name) {
    return 'Nachricht an $name';
  }

  @override
  String get chatAddMessageToMediaPrompt => 'Eine Nachricht hinzufügen';

  @override
  String get chatTypeMessagePromptGroup => 'Nachricht an den Kanal';

  @override
  String get updatePrimaryIdentity => 'Aktualisieren der primären Identität';

  @override
  String get newIdentityAlias => 'Neuer Identitätsalias';

  @override
  String editIdentityTitle(String identityName) {
    return 'Identität bearbeiten: $identityName';
  }

  @override
  String get customiseIdentityCard => 'Personalausweis anpassen';

  @override
  String get nameTooLong => 'Der Name ist zu lang';

  @override
  String get descriptionTooLong => 'Die Beschreibung ist zu lang';

  @override
  String get invalidEmail => 'Die E-Mail-Adresse ist ungültig';

  @override
  String get emailTooLong => 'Die E-Mail-Adresse ist zu lang';

  @override
  String get invalidMobileNumber => 'Die Handynummer ist ungültig';

  @override
  String get mobileTooLong => 'Die Handynummer ist zu lang';

  @override
  String get aliasTooLong => 'Der Alias ist zu lang';

  @override
  String get thisFieldIsRequired => 'Dieses Feld ist ein Pflichtfeld';

  @override
  String get identityAliasPersonalDetails =>
      'Identitätsalias persönliche Daten';

  @override
  String get profilePictureChangePrompt =>
      'Tippen Sie hier, um Ihr Profilbild zu ändern';

  @override
  String get enterFirstName => 'Geben Sie den Vornamen ein';

  @override
  String get enterLastName => 'Nachname eingeben';

  @override
  String get enterEmail => 'E-Mail-Adresse eingeben';

  @override
  String get enterMobile => 'Hier kommt das Handy ins Spiel';

  @override
  String get anonymous => 'Anonym';

  @override
  String get aliasLabel => 'Alias-Beschriftung';

  @override
  String get enterAliasLabel => 'Alias-Label eingeben';

  @override
  String get aliasLabelHelperText =>
      'Die Alias-Beschriftung ist die Art und Weise, wie Sie beim Herstellen einer Verbindung auf diesen Alias verweisen. Verwenden Sie einen aussagekräftigen Namen, um die Identifizierung zu erleichtern.';

  @override
  String get setupPrimaryIdentityTitle =>
      'Lassen Sie uns Ihre primäre Identität einrichten!';

  @override
  String get setupPrimaryIdentityDescription =>
      'Ihre primäre Identität wird standardmäßig verwendet, wenn Sie sich mit anderen verbinden.';

  @override
  String get primaryIdentityInformation =>
      'Ihre primären Identitätsinformationen';

  @override
  String get primaryIdentityComplete =>
      'Meine primäre Identität ist vollständig';

  @override
  String get keepMeAnonymous => 'Anonym bleiben';

  @override
  String typingMessage(String names, int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$names tippen',
      one: '$names tippt',
    );
    return '$_temp0';
  }

  @override
  String awaitingMembersToJoin(String names, int namesCount, int othersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      othersCount,
      locale: localeName,
      other: '$othersCount weitere',
      one: '1 weiteren',
    );
    String _temp1 = intl.Intl.pluralLogic(
      namesCount,
      locale: localeName,
      other: 'Warten auf $names und $_temp0 zum Beitreten',
      one: 'Warten auf $names, die beitreten',
    );
    return '$_temp1';
  }

  @override
  String get unknownType => 'Unbekannter Typ';

  @override
  String get loadImageFailed => 'Bild konnte nicht geladen werden';

  @override
  String get chatRequestPermissionToJoinGroupFailed =>
      'Fehler beim Beitritt zur Gruppe';

  @override
  String get genWordConciergeMessage => 'Nachricht des Concierges';

  @override
  String chatRequestPermissionToJoinGroup(String memberName) {
    return '$memberName möchte der Gruppe beitreten';
  }

  @override
  String get chatEncryptionNotice =>
      'Nachrichten und alle in diesem Chat geteilten Daten sind Ende-zu-Ende verschlüsselt. Nur Personen und Agenten in diesem Chat können sie lesen.';

  @override
  String get genWordNo => 'Nein';

  @override
  String get genWordLater => 'Später';

  @override
  String get genWordYes => 'Ja';

  @override
  String get chatRequestPermissionToUpdateProfileGroup =>
      'Die Profildetails, die für diese Gruppe freigegeben wurden, haben sich geändert. Möchten Sie alle Mitglieder auf dem Laufenden halten?';

  @override
  String get chatRequestPermissionToUpdateProfile =>
      'Die Profildetails, die für diesen Kontakt freigegeben wurden, haben sich geändert. Möchten Sie ihnen ein Update senden?';

  @override
  String chatStartOfConversationInitiatedByMe(String date, String time) {
    return 'Sie haben diesen Kanal am $date bei ${time}eingerichtet. ';
  }

  @override
  String get messageCopiedClipboard =>
      'Nachricht in die Zwischenablage kopiert';

  @override
  String get chatMessageActionDelete => 'Für alle löschen';

  @override
  String get chatMessageActionDeleteLocal => 'Für mich löschen';

  @override
  String get chatMessageActionCopy => 'Nachricht kopieren';

  @override
  String get chatMessageActionEdit => 'Nachricht bearbeiten';

  @override
  String get chatMessageEditedLabel => 'bearbeitet';

  @override
  String get chatMessageEditFailed =>
      'Nachricht konnte nicht bearbeitet werden';

  @override
  String get chatMessageEditHint => 'Nachrichtentext';

  @override
  String get chatMessageEditSave => 'Speichern';

  @override
  String get chatMessageDeletedTombstone => 'Diese Nachricht wurde gelöscht';

  @override
  String get chatMessageDeletedLocallyTombstone =>
      'Du hast diese Nachricht gelöscht';

  @override
  String get chatMessageDeleteFailed =>
      'Nachricht konnte nicht gelöscht werden';

  @override
  String chatItemStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'queued': 'In Warteschlange',
      'delivered': 'Zugestellt',
      'sending': 'Senden',
      'sent': 'Gesendet',
      'error': 'Fehler',
      'groupDeleted': 'Gruppe gelöscht',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get qrScannerTitle => 'QR-Code scannen';

  @override
  String get qrScannerInstructions =>
      'Positionieren Sie den QR-Code innerhalb des Rahmens';

  @override
  String qrScannerStatus(String status) {
    return 'Status des Scanners: $status';
  }

  @override
  String get useCamera => 'Kamera verwenden';

  @override
  String get chooseFromGallery => 'Wählen Sie aus der Galerie';

  @override
  String get qrScannerCameraPermissionHelp =>
      'Bitte überprüfen Sie die Kameraberechtigungen und versuchen Sie es erneut';

  @override
  String get qrScannerConnectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String qrScannerConnectionFailedMessage(String error) {
    return 'Verbindung konnte nicht hergestellt werden: $error';
  }

  @override
  String get qrScannerTryAgain => 'Wiederholen';

  @override
  String get qrScannerTimeoutError =>
      'Zeitüberschreitung bei der Annahme des OOB-Flusses nach 30 Sekunden';

  @override
  String get customMediators => 'Benutzerdefinierte Nachrichtenserver';

  @override
  String get addCustomMediator =>
      'Hinzufügen eines benutzerdefinierten Nachrichtenservers';

  @override
  String get manageCustomMediators =>
      'Verwalten von benutzerdefinierten Nachrichtenservern';

  @override
  String get configureCustomMediatorEndpoint =>
      'Konfigurieren eines eigenen Nachrichtenserver-Endpunkts';

  @override
  String get noCustomMediatorsConfigured =>
      'Es sind noch keine benutzerdefinierten Nachrichtenserver konfiguriert';

  @override
  String customMediatorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count benutzerdefinierte Nachrichtendienste konfiguriert',
      one: '1 benutzerdefinierter Nachrichtendienst konfiguriert',
    );
    return '$_temp0';
  }

  @override
  String addedMediatorSuccess(String name) {
    return 'Message-Server \"$name\" hinzugefügt';
  }

  @override
  String failedToAddMediator(String error) {
    return 'Fehler beim Hinzufügen des Nachrichtenservers: $error';
  }

  @override
  String get mediatorName => 'Name des Message-Servers';

  @override
  String get mediatorDid => 'DID des Nachrichtenservers';

  @override
  String get myCustomMediator => 'Mein benutzerdefinierter Nachrichtenserver';

  @override
  String get pleaseEnterName => 'Bitte geben Sie einen Namen ein';

  @override
  String get pleaseEnterDid => 'Bitte geben Sie eine DID ein';

  @override
  String get didMustStartWith => 'DID muss mit \"did:\" beginnen.';

  @override
  String get deleteCustomMediator =>
      'Benutzerdefinierten Message-Server löschen';

  @override
  String deleteCustomMediatorConfirm(String name) {
    return 'Sind Sie sicher, dass Sie \"$name\" löschen möchten?\n\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String deletedMediatorSuccess(String name) {
    return 'Gelöschter Message-Server \"$name\"';
  }

  @override
  String renamedMediatorSuccess(String name) {
    return 'Umbenennung des Message-Servers in \"$name\"';
  }

  @override
  String failedToDeleteMediator(String error) {
    return 'Fehler beim Löschen des Nachrichtenservers: $error';
  }

  @override
  String failedToRenameMediator(String error) {
    return 'Fehler beim Umbenennen des Nachrichtenservers: $error';
  }

  @override
  String get generalRetry => 'Wiederholen';

  @override
  String get generalClose => 'Schließen';

  @override
  String get generalAdd => 'Hinzufügen';

  @override
  String get noIdentityDetected =>
      'Keine Identität erkannt, bitte erstellen Sie eine, um fortzufahren.';

  @override
  String get connectWithPersonAiServiceBusiness =>
      'Verbinden Sie sich mit einer Person oder einem KI-Agenten';

  @override
  String get chatScreenTapForMemberDetails =>
      'Tippen Sie hier, um die Details der Mitglieder anzuzeigen.';

  @override
  String get debugPanelTitle => 'Bereich \"Debuggen\"';

  @override
  String get debugPanelSubtitle =>
      'Anzeigen von Anwendungsprotokollen und Debuginformationen';

  @override
  String get debugPanelNoLogs => 'Keine Protokolle verfügbar';

  @override
  String get debugPanelLogsAppearMessage =>
      'Hier werden Protokolle angezeigt, wenn Sie die App verwenden';

  @override
  String get debugPanelClearLogs => 'Protokolle löschen';

  @override
  String get debugPanelCopyLogs =>
      'Kopieren von Protokollen in die Zwischenablage';

  @override
  String get debugPanelAddTestLog => 'Hinzufügen eines Testprotokolls';

  @override
  String get debugPanelLogsCopied =>
      'Protokolle, die in die Zwischenablage kopiert werden';

  @override
  String get debugPanelShareLogs => 'Protokolle teilen';

  @override
  String get serverSettings => 'Server-Einstellungen';

  @override
  String get serverSettingsHelperText =>
      'Wählen Sie den Standardserver für die Messaging-Kommunikation aus';

  @override
  String get debugSettingsTitle => 'Debug-Einstellungen';

  @override
  String get debugModeLabel => 'Debug-Modus';

  @override
  String debugModeHelperText(int tapCount) {
    return 'Der Debug-Modus ist aktiviert. Tippen Sie $tapCount Mal auf Versionsinformationen, um umzuschalten.';
  }

  @override
  String get settingsScreenSubtitle =>
      'Konfigurieren Sie Ihre App-Einstellungen und -Einstellungen';

  @override
  String get versionInfoHeader => 'Version des Treffpunkts';

  @override
  String versionInfoVersion(String version) {
    return 'Version $version';
  }

  @override
  String versionInfoBuild(String buildNumber) {
    return 'Baujahr: $buildNumber';
  }

  @override
  String get easterEggEnabled =>
      '🎉 Easter Egg freigeschaltet! Debug-Modus aktiviert';

  @override
  String get debugModeDisabled => 'Debug-Modus deaktiviert';

  @override
  String get generalCamera => 'Kamera';

  @override
  String get generalPhoto => 'Foto';

  @override
  String get generalBalloons => 'Ballone';

  @override
  String get generalConfetti => 'Konfetti';

  @override
  String get chatItemStatusError => 'Fehler';

  @override
  String get formValidationHeadlineRequired => 'Überschrift ist erforderlich';

  @override
  String get formValidationDescriptionRequired =>
      'Beschreibung ist erforderlich';

  @override
  String get formValidationCustomPhraseRequired =>
      'Benutzerdefinierte Phrase ist erforderlich, wenn keine zufällige Phrase verwendet wird';

  @override
  String get formValidationExpiryDateRequired =>
      'Das Ablaufdatum ist erforderlich, wenn der Ablauf aktiviert ist';

  @override
  String get formValidationExpiryDateFuture =>
      'Das Ablaufdatum muss in der Zukunft liegen';

  @override
  String get formValidationMaxUsagesGreaterThanZero =>
      'Die maximale Nutzung muss größer als 0 sein.';

  @override
  String get genericPublishError => 'Fehler beim Veröffentlichen des Angebots';

  @override
  String get groupDetails => 'Details zum Gruppenkanal';

  @override
  String groupMessageInfo(String memberName, String date, String time) {
    return '$memberName auf $date bei $time';
  }

  @override
  String contactStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pendingApproval': 'Ausstehende Genehmigung',
      'pendingInauguration': 'Verbindung wird hergestellt',
      'approved': 'Aktiver Kontakt',
      'rejected': 'Abgelehnt',
      'error': 'Fehler',
      'deleted': 'Gelöscht',
      'active': 'Aktiver Kanal',
      'unknown': 'Unbekannt',
      'other': 'Unbekannt',
    });
    return '$_temp0';
  }

  @override
  String groupContactStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pendingApproval': 'Ausstehende Genehmigung',
      'pendingInauguration': 'Kanal wird eingerichtet',
      'approved': 'Aktiver Gruppenkanal',
      'rejected': 'Abgelehnt',
      'error': 'Fehler',
      'deleted': 'Gelöscht',
      'active': 'Aktiver Gruppenkanal',
      'unknown': 'Unbekannt',
      'other': 'Unbekannt',
    });
    return '$_temp0';
  }

  @override
  String contactOrigin(String origin) {
    String _temp0 = intl.Intl.selectLogic(origin, {
      'directInteractive': 'Direkt Interaktiv',
      'individualOfferPublished': 'Einladung zum Treffpunkt angeboten',
      'individualOfferRequested': 'Einladung zum Treffpunkt akzeptiert',
      'groupOfferPublished': 'Gruppeneinladung zum Treffpunkt angeboten',
      'groupOfferRequested': 'Gruppeneinladung zum Treffpunkt akzeptiert',
      'unknown': 'Unbekannt',
      'other': 'Unbekannt',
    });
    return '$_temp0';
  }

  @override
  String get groupMembers => 'Gruppenmitglieder';

  @override
  String get showExited => 'Beendet anzeigen';

  @override
  String get groupMemberExited => 'Aus der Gruppe verlassen';

  @override
  String get groupNoMembersToChat =>
      'Sie sind derzeit das einzige Mitglied dieser Gruppe. Sie können mit dem Chatten beginnen, wenn ein anderes Mitglied beitritt.';

  @override
  String get generalJoined => 'Angegliedert';

  @override
  String get you => 'Du';

  @override
  String get groupAdmin => 'Gruppen-Admin';

  @override
  String get onboardingPage1Title => 'Herzlich Willkommen bei\nTreffpunkt';

  @override
  String get onboardingPage1Desc => 'Powered by\nAffinidi Messaging';

  @override
  String get onboardingPage2Title => 'Privat & Sicher';

  @override
  String get onboardingPage2Desc =>
      'Verbinden Sie sich sicher und privat mit anderen durch Ende-zu-Ende-Verschlüsselung';

  @override
  String get onboardingPage3Title =>
      'Übernehmen Sie die Kontrolle über Ihre Identität';

  @override
  String get onboardingPage3Desc =>
      'Schützen Sie Ihre Privatsphäre mit Aliasnamen. Weisen Sie Ihre Identität mit verifizierten Anmeldeinformationen nach';

  @override
  String get onboardingPage4Title => 'Bereit zu beginnen';

  @override
  String get onboardingPage4Desc =>
      'Richten Sie Ihre Identität ein\nund legen Sie los!';

  @override
  String get setUpMyIdentity => 'Meine Identität einrichten';

  @override
  String get revealConnectionCode => 'Passphrase für Einladung anzeigen';

  @override
  String versionInfoAppName(String appName) {
    return 'Meeting Place \"$appName\"';
  }

  @override
  String get platformNotSupported =>
      'Dieses Plugin wird auf Ihrer aktuellen Plattform nicht unterstützt';

  @override
  String get generalOfferInformation => 'Informationen zur Einladung';

  @override
  String get generalOfferLink => 'Einladungs-Link';

  @override
  String get generalMnemonic => 'Mnemonisch';

  @override
  String get generalConnectionType => 'Verbindungsart';

  @override
  String get generalExternalRef => 'Externe Referenz';

  @override
  String get generalGroupDid => 'Gruppe DID';

  @override
  String get generalGroupId => 'Gruppen-ID';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String connectionStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'published': 'Erstellt',
      'finalised': 'Abgeschlossen',
      'accepted': 'Wartend',
      'channelInaugurated': 'Aktiv',
      'deleted': 'Gelöscht',
      'other': 'Unbekannt',
    });
    return '$_temp0';
  }

  @override
  String get publishing => 'Veröffentlichen';

  @override
  String get loading => 'Laden';

  @override
  String get deleting => 'Löschen';

  @override
  String get showQrScannerForOffers => 'QR-Scanner für Einladungen anzeigen';

  @override
  String get meetingPlaceControlPlane => 'Steuerungsebene für Treffpunkte';

  @override
  String get searching => 'Suche';

  @override
  String get connecting => 'Verbindend';

  @override
  String get approving => 'Beifällig';

  @override
  String get rejecting => 'Zurückweisend';

  @override
  String get sending => 'Entsendung';

  @override
  String get connectionRequestRejected =>
      'Die Verbindungsanforderung wurde abgelehnt';

  @override
  String get connectionRequestInProgress =>
      'Die Annahme der Einladung ist in Bearbeitung. Es kann einige Augenblicke dauern, bis die andere Partei antwortet und den Kanal fertigstellt.';

  @override
  String requestToConnect(Object firstName) {
    return 'Die Annahme der Einladung wurde ${firstName}gesendet. Es kann einige Augenblicke dauern, bis sie auf Ihre Anfrage antworten.';
  }

  @override
  String contactsDeleted(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Kanäle gelöscht',
      one: 'Kanal gelöscht',
    );
    return '$_temp0';
  }

  @override
  String joiningGroup(String memberName) {
    return '$memberName ist der Gruppe beigetreten';
  }

  @override
  String leavingGroup(String memberName) {
    return '$memberName hat die Gruppe verlassen';
  }

  @override
  String get concierge => 'Hausmeister';

  @override
  String get groupDeleted => 'Diese Gruppe wurde gelöscht';

  @override
  String get creatingConnection => 'Verbindung wird hergestellt...';

  @override
  String get generatingQrCode => 'Generiere deinen QR-Code';

  @override
  String get processing => 'Verarbeitung...';

  @override
  String oobConnectedTo(String memberName) {
    return 'Sie sind jetzt mit $memberName verbunden!';
  }

  @override
  String get oobChatTo => 'Chat';

  @override
  String get networkDisconnected => 'Sie sind nicht mit dem Netzwerk verbunden';

  @override
  String get chatNotificationsUnavailable =>
      'Chat-Benachrichtigungen sind für direkte Verbindungen nicht verfügbar';

  @override
  String get chatNotificationsUnavailableNotShared =>
      'Benachrichtigungen für diesen Chat-Kanal sind nicht verfügbar';

  @override
  String get chatNotificationsWhyTitle =>
      'Warum keine Push-Benachrichtigungen?';

  @override
  String get chatNotificationsWhyDescription =>
      'Wenn Sie eine Verbindung durch direktes Scannen oder Teilen eines QR-Codes herstellen, verbinden sich Ihre Geräte direkt, ohne Benachrichtigungstoken mit unseren Servern auszutauschen. Das bedeutet, dass Push-Benachrichtigungen nicht gesendet werden können, wenn der Chat geschlossen ist.';

  @override
  String get chatNotificationsWhyNote =>
      'Sie sehen neue Nachrichten nur, wenn Sie sich im Chat befinden. Es wird keine Abzeichenaktualisierungen oder Benachrichtigungen geben, die Sie darüber informieren, dass neue Nachrichten eingegangen sind, selbst wenn die App geöffnet ist.';

  @override
  String get chatNotificationsWhyButton => 'Verstanden';

  @override
  String get chatNotificationsWhyLink => 'Warum?';

  @override
  String get meetingPlaceInvitationTitle => 'Einladung zum Treffpunkt';

  @override
  String get shareSheetCTA_QRCode => 'QR-Code senden oder speichern';

  @override
  String get cameraInstructionAndroid =>
      'Tippen Sie unten auf \"Einstellungen öffnen\", um den Kamerazugriff zu aktivieren. Wenn das nicht funktioniert, öffnen Sie die Einstellungen manuell:\n\nEinstellungen > Apps > Meeting Place > Berechtigungen > Kamera > Nur während der Nutzung der App erlauben.';

  @override
  String get cameraInstructionIos =>
      'Tippen Sie unten auf \"Einstellungen öffnen\", um den Kamerazugriff zu aktivieren. Wenn das nicht funktioniert, öffnen Sie die Einstellungen manuell:\n\nEinstellungen > Meeting Place > Kamera und aktivieren Sie den Zugriff für diese App.';

  @override
  String get cameraInstructionMacos =>
      'Gehen Sie zu Systemeinstellungen > Datenschutz & Sicherheit > Kamera und erlauben Sie den Kamerazugriff für diese App.';

  @override
  String get cameraAccessDenied =>
      'Kamerazugriff verweigert oder nicht verfügbar.';

  @override
  String get cameraOpenSettings => 'Einstellungen öffnen';

  @override
  String get cameraNotAvailable => 'Kamera nicht verfügbar';

  @override
  String get goBack => 'Zurück gehen';

  @override
  String get rCardsPanelSubtitle => 'Beziehungskarten von Ihren Kontakten';

  @override
  String get rCardsEmpty =>
      'R-Karten sind eine moderne, selbstaktualisierende Version von vCards. Sobald Sie Ihre erste Verbindung herstellen, erscheinen Ihre digitalen Visitenkarten hier.';

  @override
  String rCardsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Alle',
      'nonAnonymous': 'Nicht-anonym',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noRCardsFoundWithFilter =>
      'Keine R-Karten gefunden, die Ihrer Suche entsprechen.';

  @override
  String get rCardDetailsTitle => 'R-Karten Details';

  @override
  String get rCardSectionIdentity => 'Identität';

  @override
  String get rCardSectionMetadata => 'Credential-Details';

  @override
  String get rCardFieldName => 'Name';

  @override
  String get rCardFieldEmail => 'E-Mail';

  @override
  String get rCardFieldPhone => 'Telefon';

  @override
  String get rCardFieldCompany => 'Unternehmen';

  @override
  String get rCardFieldPosition => 'Position';

  @override
  String get rCardFieldWebsite => 'Website';

  @override
  String get rCardFieldSocial => 'Sozial';

  @override
  String get rCardFieldSubjectDid => 'Subjekt-DID';

  @override
  String get rCardAddNotes => 'Notizen hinzufügen';

  @override
  String get rCardUpdateNotes => 'Notizen aktualisieren';

  @override
  String get rCardNotesTitle => 'Notizen';

  @override
  String get rCardNotesPlaceholder => 'Schreiben Sie hier Ihre Notizen...';

  @override
  String get rCardDeletePrompt =>
      'Möchten Sie diese R-Karte wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String rCardChatWith(String name) {
    return 'Chat mit $name';
  }

  @override
  String get removeMemberDialogTitle => 'Remove member';

  @override
  String removeMemberDialogBody(String name) {
    return 'Remove $name from this group? They will no longer receive messages.';
  }

  @override
  String get rCardFieldIssuerDid => 'Aussteller-DID';

  @override
  String get rCardFieldReceivedAt => 'Empfangen';

  @override
  String get rCardFieldIssuedAt => 'Ausgestellt';

  @override
  String get rCardTitle => 'R-Karte';

  @override
  String get verifiableCredential => 'Überprüfbarer Nachweis';

  @override
  String get verified => 'Verifiziert';

  @override
  String get verifiableCredentialDescription =>
      'Gesicherte digitale Nachweise, die auf Echtheit überprüft werden können';

  @override
  String get secureAttachmentsTitle => 'Sichere Anhänge';

  @override
  String get credentialDetails => 'Nachweisdetails';

  @override
  String get genRCard => 'R-Karte';

  @override
  String get rCardPickIdentitySubtitle =>
      'Wähle die Identität aus, die als R-Karte geteilt werden soll';

  @override
  String get rCardFooterSent => 'R-Karte wurde gesendet.';

  @override
  String get rCardFooterSaved => 'R-Karte wurde gespeichert.';

  @override
  String get rCardFooterUpdateShared => 'R-Karten-Update wurde geteilt.';

  @override
  String get profileDetailsUpdateSharedGroup =>
      'Profildetails-Update wurde mit der Gruppe geteilt.';

  @override
  String get rCardFooterUpdateSaved => 'R-Karten-Update wurde gespeichert.';

  @override
  String get rCardsExchanged => 'R-Karten ausgetauscht';

  @override
  String get goToRCard => 'Zur R-Karte';

  @override
  String get selectIdentityTitle => 'Identität auswählen';

  @override
  String get selectIdentityInstruction =>
      'Wische links oder rechts, um die Identität auszuwählen, die du für die R‑Karte verwenden möchtest';

  @override
  String get sendRCard => 'R-Karte senden';

  @override
  String selectIdentityToVerifyRelationshipWithName(String name) {
    return 'Wähle die Identität aus, die du verwenden möchtest, um deine Beziehung mit $name zu bestätigen';
  }

  @override
  String get verifiableRelationshipCredential =>
      'Überprüfbarer Beziehungsnachweis';

  @override
  String get vrcAbbreviation => 'VRC';

  @override
  String get vrcDetailsTitle => 'Beziehungsnachweis';

  @override
  String get vrcSectionIssuer => 'Aussteller';

  @override
  String get vrcSectionHolder => 'Ausgestellt an';

  @override
  String get vrcSectionMetadata => 'Nachweisdetails';

  @override
  String get vrcFieldDid => 'DID';

  @override
  String get vrcFieldName => 'Name';

  @override
  String get vrcFieldIssuedAt => 'Ausgestellt am';

  @override
  String get vrcFieldVerifiedAt => 'Verifiziert';

  @override
  String get vrcFieldTypes => 'Typen';

  @override
  String get vrcDescription =>
      'Dieser Nachweis bestätigt die Beziehung zwischen zwei Parteien.';

  @override
  String verifyRelationshipPrompt(String firstName) {
    return 'Bestätige deine Beziehung mit $firstName, indem du eine Verifiable Relationship Credential (VRC) ausstellst. Jeder VRC-Austausch erhöht deinen Vertrauenswert.';
  }

  @override
  String get generateVrc => 'Jetzt starten';

  @override
  String get generalVerify => 'Bestätigen';

  @override
  String get doLater => 'Später';

  @override
  String get vrcExchangeInitiated => 'Du hast den VRC-Austausch eingeleitet.';

  @override
  String vrcRequestReceived(String name) {
    return '$name hat den VRC-Austausch eingeleitet.';
  }

  @override
  String get vrcDoLater =>
      'VRC-Austausch pausiert. Tippe auf + und wähle \'Überprüfbarer Beziehungsnachweis\' um fortzufahren.';

  @override
  String get vrcExchangeCompleted =>
      'Du hast deine Beziehung erfolgreich verifiziert';

  @override
  String vrcVerifyPrompt(String name) {
    return 'Möchtest du deine Beziehung mit $name verifizieren? Jeder VRC-Austausch erhöht deinen Vertrauensscore.';
  }

  @override
  String get vrcStartNow => 'Jetzt starten';

  @override
  String get vrcDoLaterButton => 'Später';

  @override
  String get vrcYesButton => 'Ja';

  @override
  String nameSelectedIdentity(String name) {
    return '$name\'s selected identity';
  }

  @override
  String selectIdentityToVerifyRelationshipPrompt(String name) {
    return 'Swipe left or right to choose the identity you want to use to verify your relationship with $name.';
  }

  @override
  String get sendVrc => 'Beziehungsnachweis senden';

  @override
  String trustedBy(int count) {
    return 'Trusted by $count';
  }

  @override
  String get humanZkp => 'Human ZKP';

  @override
  String get humanZeroKnowledgeProof => 'Human Zero-Knowledge-Beweis';

  @override
  String get livenessCredential => 'Liveness Credential';

  @override
  String get verifiableCredentialWallet => 'Verifiable Credential wallet';

  @override
  String get noCredentialsYet => 'You don\'t have any credentials yet.';

  @override
  String get all => 'Alle';

  @override
  String get generatingZeroKnowledgeProof =>
      'Generating Zero-Knowledge Proof...';

  @override
  String get cancel => 'Cancel';

  @override
  String get generateCredential => 'Generate credential';

  @override
  String get generateProof => 'Generate proof';

  @override
  String get livenessCredentialRequest =>
      'Anforderung eines Liveness-Nachweises';

  @override
  String get livenessCheckDemoMode => 'Liveness-Prüfung (Demo-Modus)';

  @override
  String get searchingForLivenessCredential =>
      'Suche nach Liveness-Nachweis...';

  @override
  String get noLivenessCredentialFound =>
      'Es wurde kein Liveness-Nachweis gefunden.\n\nZum Fortfahren wird lokal ein simulierter Liveness-Nachweis generiert.\nDieser Nachweis dient zur Demonstration, wie ein Zero-Knowledge-Beweis (ZKP) abgeleitet wird.';

  @override
  String get livenessCheckDemoModeNote =>
      'Diese Referenz-App läuft im Demo-Modus und führt keine echte Liveness-Prüfung durch.';

  @override
  String get livenessCheckInProgress => 'Liveness-Prüfung läuft...';

  @override
  String get livenessCheckSimulatedFlow =>
      'Dies ist ein simulierter Ablauf nur für Entwicklungs- und Demonstrationszwecke.';

  @override
  String get mockLivenessCredentialGenerated =>
      'Ein simulierter Liveness-Nachweis wurde generiert und sicher unter dem Tab Anmeldeinformationen gespeichert.\nSie können jetzt fortfahren, um einen menschlichen Zero-Knowledge-Beweis zu generieren.';

  @override
  String get mockLivenessCredentialNext =>
      'You can now continue to generate a Human Zero-Knowledge proof.';

  @override
  String get livenessEvidenceThresholdNotMet =>
      'Die Liveness-Prüfung hat den erforderlichen Schwellenwert nicht erreicht. Bitte versuchen Sie es erneut.';

  @override
  String get livenessCredentialSessionMissing =>
      'Ihr Liveness-Nachweis ist in dieser App-Sitzung nicht verfügbar. Generieren Sie einen neuen Nachweis und versuchen Sie es erneut.';

  @override
  String get issuedTo => 'Ausgestellt an';

  @override
  String get types => 'Typen';

  @override
  String get issuer => 'Aussteller';

  @override
  String get issuedOn => 'Ausgestellt am';

  @override
  String get human => 'Mensch';

  @override
  String get proofFlowThisContact => 'dieser Kontakt';

  @override
  String get proofFlowContact => 'Kontakt';

  @override
  String proofFlowCheckIfHuman(String contactName) {
    return 'Überprüfe, ob $contactName ein Mensch ist, mithilfe eines Zero-Knowledge-Beweises (ZKP), der aus einem Liveness-Nachweis abgeleitet wurde.';
  }

  @override
  String get proofFlowRequestProof => 'Beweis anfordern';

  @override
  String proofFlowVerifyingProof(String contactName) {
    return 'Beweis von $contactName wird überprüft...';
  }

  @override
  String proofFlowVerificationFailed(String contactName) {
    return 'Überprüfung für $contactName fehlgeschlagen';
  }

  @override
  String get zkpNoticePaused =>
      'Sie haben die Human-ZKP-Beweisanforderung pausiert. Tippen Sie auf das \"+\"-Symbol, um sie neu zu starten.';

  @override
  String get zkpNoticeShared =>
      'Sie haben einen Zero‑Knowledge-Beweis geteilt, der bestätigt, dass Sie ein Mensch sind.\n*Es wurden keine persönlichen Daten geteilt.';

  @override
  String zkpNoticeReceived(String contactName) {
    return '$contactName hat einen Zero‑Knowledge-Beweis geteilt, der bestätigt, dass sie/er ein Mensch ist.';
  }

  @override
  String zkpNoticeRequest(String contactName) {
    return '$contactName hat einen Zero‑Knowledge-Beweis angefordert, um zu bestätigen, dass Sie ein Mensch sind.\nSie können den Beweis mithilfe einer vorhandenen Liveness-Berechtigung generieren oder eine schnelle Liveness-Prüfung durchführen.';
  }

  @override
  String get zkpNoticeRequestInitiated =>
      'Sie haben eine Human-ZKP-Anfrage gestartet.';

  @override
  String get zkpProofAlreadyShared => 'ZKP-Beweis bereits geteilt';

  @override
  String get removeMemberConfirm => 'Remove';

  @override
  String get removeMemberNotSupported =>
      'Removing members isn\'t supported yet.';

  @override
  String get generalVideo => 'Video';

  @override
  String get generalDocument => 'Dokument';

  @override
  String get documentTapToDownload => 'Zum Herunterladen tippen';

  @override
  String get videoLoadingError => 'Video kann nicht abgespielt werden';

  @override
  String get mediaTapToRetry => 'Zum Wiederholen tippen';

  @override
  String get mediaDownloadFailedTapToRetry =>
      'Download fehlgeschlagen. Zum Wiederholen tippen';

  @override
  String attachmentTooLarge(int maxMb) {
    return 'Anhang ist zu groß. Maximale Größe: $maxMb MB.';
  }

  @override
  String get voiceMessagePermissionDenied =>
      'Zum Aufnehmen von Sprachnachrichten ist Mikrofonzugriff erforderlich.';

  @override
  String get voiceMessageRecordingFailed =>
      'Sprachaufnahme kann nicht gestartet werden.';

  @override
  String get voiceMessageSendFailed =>
      'Sprachnachricht kann nicht gesendet werden.';
}
