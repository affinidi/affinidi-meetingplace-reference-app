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
      'contacts': 'Communitys',
      'identities': 'Identitäten',
      'rCards': 'R-Karten',
      'credentials': 'Anmeldeinformationen',
      'settings': 'Einstellungen',
      'other': 'Ungültig',
    });
    return '$_temp0';
  }

  @override
  String badgeCountSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new items',
      one: '1 new item',
    );
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
  String get switchCamera => 'Kamera wechseln';

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
  String memberRemovedFromGroup(String memberName) {
    return '$memberName wurde entfernt';
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
  String get removeMemberDialogTitle => 'Mitglied entfernen';

  @override
  String removeMemberDialogBody(String name) {
    return '$name aus dieser Gruppe entfernen? Sie erhalten keine Nachrichten mehr.';
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
    return 'Ausgewählte Identität von $name';
  }

  @override
  String selectIdentityToVerifyRelationshipPrompt(String name) {
    return 'Wischen Sie nach links oder rechts, um die Identität auszuwählen, mit der Sie Ihre Beziehung zu $name verifizieren möchten.';
  }

  @override
  String get sendVrc => 'Beziehungsnachweis senden';

  @override
  String trustedBy(int count) {
    return 'Vertraut von $count';
  }

  @override
  String get humanZkp => 'Human Zero-Knowledge-Beweis';

  @override
  String get humanZkpAbbreviated => 'Human ZKP';

  @override
  String get humanZeroKnowledgeProof => 'Human Zero-Knowledge-Beweis';

  @override
  String get livenessCredential => 'Lebendigkeit Nachweis';

  @override
  String get verifiableCredentialWallet =>
      'Verifizierbare Berechtigungs-Wallet';

  @override
  String get noCredentialsYet => 'Sie haben noch keine Anmeldeinformationen.';

  @override
  String get membershipsTab => 'Memberships';

  @override
  String get membershipCredentialsVtaMissing =>
      'Link your VTA to see your membership cards.';

  @override
  String get membershipCredentialsUnreachable =>
      'Your VTA couldn\'t be reached, so your membership cards can\'t be shown.';

  @override
  String get membershipCredentialsSaved =>
      'Your VTA couldn\'t be reached. Showing the cards saved on this phone.';

  @override
  String get membershipCredentialsNone =>
      'No membership cards yet. Join a community to get one.';

  @override
  String get membershipCredentialUnnamed => 'A community';

  @override
  String get membershipCredentialOtherIdentity =>
      'an identity not on this phone';

  @override
  String membershipCredentialAs(String identity) {
    return 'as $identity';
  }

  @override
  String membershipCredentialUntil(String date) {
    return 'until $date';
  }

  @override
  String get groupCredentialUnnamed => 'A group';

  @override
  String membershipCredentialLeft(String date) {
    return 'left $date';
  }

  @override
  String get membershipStatusChecking => 'Checking…';

  @override
  String get membershipStatusValid => 'Valid';

  @override
  String get membershipStatusRevoked => 'Revoked';

  @override
  String get membershipStatusExpired => 'Expired';

  @override
  String get membershipStatusNotRevocable => 'Can\'t be revoked';

  @override
  String get membershipStatusUnknown => 'Couldn\'t check';

  @override
  String get membershipDetailsTitle => 'Membership card';

  @override
  String get membershipOpenCommunity => 'Open community';

  @override
  String get membershipOpenWebsite => 'Visit website';

  @override
  String membershipTrailIssued(String community) {
    return 'Issued by $community';
  }

  @override
  String membershipTrailIssuedSummary(
    String identity,
    String community,
    String date,
  ) {
    return 'Your membership card for $identity, signed by $community on $date';
  }

  @override
  String membershipTrailIssuedSummaryUndated(
    String identity,
    String community,
  ) {
    return 'Your membership card for $identity, signed by $community';
  }

  @override
  String get membershipTrailMember => 'Card is for';

  @override
  String get membershipTrailValidFrom => 'Valid from';

  @override
  String get membershipTrailCardDocument => 'Your membership card';

  @override
  String get membershipTrailYourVta => 'Your VTA';

  @override
  String get membershipTrailThisPhone => 'This phone';

  @override
  String get membershipTrailKept => 'Kept on your VTA';

  @override
  String membershipTrailKeptSummary(String identity, String time) {
    return 'Your VTA holds the card for $identity · read from it at $time';
  }

  @override
  String get membershipTrailPutAway =>
      'Your VTA put the card away when you left';

  @override
  String membershipTrailLeft(String community) {
    return 'You left $community';
  }

  @override
  String membershipTrailLeftActor(String community) {
    return 'Your VTA, then $community';
  }

  @override
  String membershipTrailLeftSummary(String community, String keeps) {
    return 'Your VTA signed it as your identity · $community confirmed it and $keeps';
  }

  @override
  String get membershipTrailKeepsNothing => 'keeps nothing about you';

  @override
  String get membershipTrailKeepsNote =>
      'keeps only a note that you were a member';

  @override
  String get membershipTrailKeepsHistory => 'keeps your membership as history';

  @override
  String get membershipTrailKeepsUnknown => 'keeps what its rules say';

  @override
  String membershipTrailLeftNoReceipt(String community) {
    return '$community already counted you as no member, so there is no receipt';
  }

  @override
  String get membershipTrailLeftDocument => 'Your leave and its receipt';

  @override
  String membershipTrailChecked(String community) {
    return 'Checked with $community';
  }

  @override
  String membershipTrailCheckDirect(String community) {
    return 'This phone asked $community directly, without your VTA';
  }

  @override
  String membershipTrailChecking(String community) {
    return 'This phone is asking $community, without your VTA…';
  }

  @override
  String membershipTrailRevoked(String community, String time) {
    return '$community has revoked this card · its signed list says so, checked at $time';
  }

  @override
  String membershipTrailValid(String time) {
    return 'Still valid · checked at $time';
  }

  @override
  String membershipTrailUnreachable(String community) {
    return 'Couldn\'t reach $community';
  }

  @override
  String membershipTrailLastRevoked(String time) {
    return 'last checked at $time, it was revoked';
  }

  @override
  String membershipTrailLastValid(String time) {
    return 'last checked at $time, it was valid';
  }

  @override
  String membershipTrailNotRevocable(String community) {
    return 'This card can\'t be revoked: $community gave it no status list';
  }

  @override
  String membershipTrailExpired(String date) {
    return 'Its validity ended on $date, so it no longer holds';
  }

  @override
  String get membershipTrailCheckedNoTask =>
      'None: the community\'s status list is read over HTTPS';

  @override
  String get membershipTrailStatusList => 'Status list';

  @override
  String get membershipTrailStatusIndex => 'Place in the list';

  @override
  String get membershipTrailCheckedAt => 'Checked at';

  @override
  String membershipTrailStatusDocument(String community) {
    return '$community\'s signed status list';
  }

  @override
  String get membershipTrailStoredId => 'Kept under';

  @override
  String get membershipTrailStoredPurpose => 'Filed as';

  @override
  String get membershipTrailStoredStatus => 'Your VTA holds it as';

  @override
  String get membershipTrailStoredTypes => 'Types';

  @override
  String get membershipFlowCommunity => 'Community';

  @override
  String get all => 'Alle';

  @override
  String get generatingZeroKnowledgeProof =>
      'Generiere menschlichen Zero-Knowledge-Beweis...';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get generateCredential => 'Anmeldeinformationen generieren';

  @override
  String get generateProof => 'Beweis erzeugen';

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
      'Sie können jetzt mit der Erstellung eines Human Zero Knowledge Proof fortfahren.';

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
      'Sie haben eine Anfrage für einen Human Zero-Knowledge-Beweis pausiert.';

  @override
  String zkpNoticeDeclined(String contactName) {
    return '$contactName hat die Anfrage für einen Human Zero-Knowledge-Beweis abgelehnt. Tippen Sie auf das \"+\"-Symbol, um sie neu zu starten.';
  }

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
      'Sie haben eine Anfrage für einen Human Zero-Knowledge-Beweis gestartet.';

  @override
  String get zkpProofAlreadyShared => 'ZKP-Beweis bereits geteilt';

  @override
  String get removeMemberConfirm => 'Entfernen';

  @override
  String get removeMemberNotSupported =>
      'Das Entfernen von Mitgliedern wird noch nicht unterstützt.';

  @override
  String get removeMemberSuccess => 'Mitglied aus der Gruppe entfernt.';

  @override
  String get generalVideo => 'Video';

  @override
  String get generalVoice => 'Stimme';

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
  String get unsupportedFileType => 'Nicht unterstützter Dateityp.';

  @override
  String get voiceMessagePermissionDenied =>
      'Zum Aufnehmen von Sprachnachrichten ist Mikrofonzugriff erforderlich.';

  @override
  String get voiceMessageRecordingFailed =>
      'Sprachaufnahme kann nicht gestartet werden.';

  @override
  String get voiceMessageSendFailed =>
      'Sprachnachricht kann nicht gesendet werden.';

  @override
  String get generalEmail => 'E-Mail';

  @override
  String vrcResponderIntro(Object name) {
    return '$name hat die folgende Persona zur Verifizierung der Beziehung ausgewählt:';
  }

  @override
  String get videoCallTitle => 'Anruf';

  @override
  String get videoCallJoiningCall => 'Anruf wird beigetreten...';

  @override
  String get videoCallWaitingForParticipants => 'Warte auf Teilnehmer...';

  @override
  String videoCallShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zeige $count weitere',
      one: 'Zeige 1 weiteren',
    );
    return '$_temp0';
  }

  @override
  String get videoCallShowLess => 'Weniger anzeigen';

  @override
  String videoCallError(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(errorCode, {
      'channelNotFound': 'Anrufkanal nicht gefunden',
      'tokenFetchFailed': 'Anrufanmeldedaten konnten nicht abgerufen werden',
      'connectionFailed':
          'Verbindung zum Anruf fehlgeschlagen. Bitte Raumzugriff prüfen oder erneut versuchen.',
      'groupCallPermissionDenied':
          'Sie sind nicht berechtigt, diesem Gruppenanruf beizutreten. Bitte Raumzugriff prüfen oder einen Gruppenadministrator fragen.',
      'callInviteFailed':
          'Andere Teilnehmer konnten nicht über den Anruf benachrichtigt werden',
      'networkError': 'Netzwerkfehler',
      'unexpected': 'Unerwarteter Anruffehler',
      'other': 'Unbekannter Fehler',
    });
    return '$_temp0';
  }

  @override
  String get videoCallMicToggleFailed =>
      'Mikrofon konnte nicht geändert werden. Bitte versuchen Sie es erneut.';

  @override
  String get videoCallCameraToggleFailed =>
      'Konnte die Kamera nicht wechseln. Bitte versuchen Sie es erneut.';

  @override
  String get videoCallSpeakerToggleFailed =>
      'Lautsprecher konnte nicht geändert werden. Bitte versuchen Sie es erneut.';

  @override
  String get videoCallMemberNamesFailed =>
      'Teilnehmernamen konnten nicht geladen werden.';

  @override
  String get videoCallHangUpFailed =>
      'Auflegen nicht möglich. Bitte versuchen Sie es erneut.';

  @override
  String videoCallParticipantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmer',
      one: '1 Teilnehmer',
    );
    return '$_temp0';
  }

  @override
  String get videoCallMute => 'Stummschalten';

  @override
  String get videoCallUnmute => 'Stummschaltung aufheben';

  @override
  String get videoCallEnd => 'Beenden';

  @override
  String get videoCallMicPermissionDenied =>
      'Mikrofonberechtigung verweigert. Aktivieren Sie es in den Einstellungen.';

  @override
  String get videoCallCameraPermissionDenied =>
      'Kameraberechtigung verweigert. Aktivieren Sie es in den Einstellungen.';

  @override
  String get videoCallWaitingForEncryption =>
      'Verschlüsselung wird eingerichtet...';

  @override
  String get videoCallYou => 'Du';

  @override
  String get videoCallRinging => 'Klingelt';

  @override
  String get videoCallCalling => 'Anruf...';

  @override
  String get videoCallCancelCall => 'Abbrechen';

  @override
  String get videoCallNoAnswer => 'Keine Antwort';

  @override
  String get videoCallCallDeclined => 'Anruf abgelehnt';

  @override
  String get videoCallCallFailed => 'Anruf fehlgeschlagen';

  @override
  String get videoCallCallEnded => 'Anruf beendet';

  @override
  String get videoCallCancel => 'Abbrechen';

  @override
  String get videoCallAgain => 'Erneut anrufen';

  @override
  String get videoCallGroupCallJoin => 'Beitreten';

  @override
  String get videoCallGroupCallActive => 'Gruppenanruf läuft';

  @override
  String videoCallOngoingCall(int count) {
    return 'Laufender Anruf ($count)';
  }

  @override
  String get videoCallSwitch => 'Wechsel';

  @override
  String get videoCallSwitchToVideoTitle => 'Zu Videoanruf wechseln?';

  @override
  String incomingCallBannerIsCalling(String callerName) {
    return '$callerName ruft an';
  }

  @override
  String get incomingCallBannerAccept => 'Annehmen';

  @override
  String get incomingCallBannerDecline => 'Ablehnen';

  @override
  String get incomingCallBannerUnknownCaller => 'Unbekannter Anrufer';

  @override
  String get incomingCallBannerAudioCall => 'MeetingPlace Audio';

  @override
  String get incomingCallBannerVideoCall => 'MeetingPlace Video';

  @override
  String get callChatItemAudioCall => 'Audioanruf';

  @override
  String get callChatItemVideoCall => 'Videoanruf';

  @override
  String get callChatItemCalling => 'Anrufen...';

  @override
  String get callChatItemRinging => 'Klingelt';

  @override
  String get callChatItemIncoming => 'Eingehender Anruf';

  @override
  String get callChatItemTapToReturn => 'Zum Zurückkehren tippen';

  @override
  String get callChatItemMissed => 'Verpasst';

  @override
  String get callChatItemNotAnswered => 'Nicht beantwortet';

  @override
  String get callChatItemDeclined => 'Abgelehnt';

  @override
  String callChatItemGroupOngoingVideo(int count) {
    return 'Laufender Videoanruf ($count)';
  }

  @override
  String callChatItemGroupOngoingAudio(int count) {
    return 'Laufender Audioanruf ($count)';
  }

  @override
  String get callChatItemYouLeft => 'Du hast verlassen';

  @override
  String get callLogScreenTitle => 'Anrufliste';

  @override
  String get callLogScreenSubtitle => 'Deine letzten Audio- und Videoanrufe.';

  @override
  String get callLogEmpty => 'Noch keine Anrufe.';

  @override
  String callLogParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmer',
      one: '1 Teilnehmer',
    );
    return '$_temp0';
  }

  @override
  String callLogParticipantsNamesAndOthers(String names, int othersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      othersCount,
      locale: localeName,
      other: '$othersCount weitere',
      one: '1 weiteren',
    );
    return '$names und $_temp0';
  }

  @override
  String get callLogInProgress => 'Läuft';

  @override
  String get callLogError => 'Anrufliste konnte nicht geladen werden.';

  @override
  String callDurationHourFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Std.',
      one: '1 Std.',
    );
    return '$_temp0';
  }

  @override
  String callDurationMinuteFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Min.',
      one: '1 Min.',
    );
    return '$_temp0';
  }

  @override
  String callDurationSecondFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sek.',
      one: '1 Sek.',
    );
    return '$_temp0';
  }

  @override
  String get groupCallWaitingForOthers => 'Warte auf andere...';

  @override
  String get groupCallParticipant => 'Teilnehmer';

  @override
  String get groupCallParticipants => 'Teilnehmer';

  @override
  String get groupCallEndCall => 'Anruf beenden';

  @override
  String get groupCallNoParticipants => 'Keine Teilnehmer';

  @override
  String get groupCallMute => 'Stummschalten';

  @override
  String get groupCallLeave => 'Verlassen';

  @override
  String get videoCallMuted => 'Stummgeschaltet';

  @override
  String videoCallPeerMuted(String peerName) {
    return '$peerName ist stummgeschaltet';
  }

  @override
  String callParticipantsConnectedCount(int count) {
    return '$count verbunden';
  }

  @override
  String get callParticipantsConnectedSection => 'Verbunden';

  @override
  String get callParticipantsNotConnectedSection => 'Nicht verbunden';

  @override
  String callParticipantCallAction(String name) {
    return '$name anrufen';
  }

  @override
  String callParticipantRingingAction(String name) {
    return '$name wird angerufen';
  }

  @override
  String get linkedVtaTitle => 'Linked VTA';

  @override
  String get linkedVtaHelperText =>
      'Link your Verifiable Trust Agent (VTA) so Meeting Place can act for you with it.';

  @override
  String get linkedVtaDidLabel => 'VTA DID';

  @override
  String get linkedVtaLinkAction => 'Link';

  @override
  String get linkedVtaInvalidDid =>
      'Enter the DID of your VTA, for example did:webvh:…';

  @override
  String get linkedVtaUnreachable => 'Your VTA couldn\'t be reached.';

  @override
  String get linkedVtaAlreadyLinked =>
      'A VTA is already linked. Remove it before linking another one.';

  @override
  String get linkedVtaBadAnswer => 'Your VTA\'s answer couldn\'t be verified.';

  @override
  String get linkedVtaScreenTitle => 'Connect your VTA';

  @override
  String get linkedVtaPendingTitle => 'Add this phone to your VTA';

  @override
  String get linkedVtaManagerDidLabel => 'This phone\'s DID';

  @override
  String get linkedVtaCopyDid => 'Copy DID';

  @override
  String get linkedVtaGrantInstruction =>
      'Ask your VTA admin to grant this DID by running:';

  @override
  String get linkedVtaGrantWarning =>
      'This makes Meeting Place an admin of your VTA, able to create and use your identities (persona-holder). Only grant it to a phone you own.';

  @override
  String get linkedVtaCopyCommand => 'Copy command';

  @override
  String get linkedVtaWaiting => 'Waiting for your admin…';

  @override
  String get linkedVtaWaitingForPersonaHolder =>
      'Admin role granted. Waiting for the persona-holder capability…';

  @override
  String get linkedVtaStillTrying =>
      'Your VTA couldn\'t be reached. Still trying…';

  @override
  String get linkedVtaStoppedWaiting => 'Stopped checking after 10 minutes.';

  @override
  String get linkedVtaCheckAgain => 'Check again';

  @override
  String get linkedVtaNoDidcomm =>
      'Your VTA doesn\'t offer DIDComm, which Meeting Place uses to talk to it. Ask its admin to enable DIDComm with a mediator.';

  @override
  String get linkedVtaScanAction => 'Scan code from your VTA host';

  @override
  String get linkedVtaManualHint =>
      'Or paste the enrolment link from your VTA host, or your VTA\'s DID:';

  @override
  String get linkedVtaFieldLabel => 'Enrolment link or VTA DID';

  @override
  String get linkedVtaEnrolmentTitle => 'Compare the codes';

  @override
  String get linkedVtaEnrolmentCodeLabel => 'Code on this phone';

  @override
  String get linkedVtaEnrolmentInstruction =>
      'Your VTA host shows a code too. Your VTA admin must check that it is exactly this code before granting access.';

  @override
  String get linkedVtaEnrolmentWarning =>
      'If the codes differ, someone else\'s key was submitted: don\'t grant access, and cancel here.';

  @override
  String get linkedVtaWaitingForHost =>
      'Waiting for your admin to grant access on your VTA host…';

  @override
  String get linkedVtaOfferMalformed =>
      'This isn\'t a valid enrolment code. Scan the code your VTA host shows again.';

  @override
  String get linkedVtaOfferUnsupported =>
      'This enrolment code is from a newer version of the VTA host. Update Meeting Place, or link your VTA by its DID.';

  @override
  String get linkedVtaOfferInsecure =>
      'This enrolment code points to a host that isn\'t secured with HTTPS, so it can\'t be used.';

  @override
  String get linkedVtaOfferExpired =>
      'This enrolment code has expired. Ask your VTA host for a new one.';

  @override
  String get linkedVtaOfferUsed =>
      'This enrolment code was already used. Ask your VTA host for a new one.';

  @override
  String get linkedVtaEnrolmentRejected =>
      'Your VTA host didn\'t accept this phone. Ask it for a new enrolment code.';

  @override
  String get linkedVtaCodeMismatch =>
      'Your VTA host answered with a different code, so it didn\'t receive this phone\'s key. Ask it for a new enrolment code.';

  @override
  String get linkedVtaHostUnreachable => 'Your VTA host couldn\'t be reached.';

  @override
  String get linkedVtaEnrolmentRefused =>
      'Your VTA admin refused access for this phone.';

  @override
  String get linkedVtaEnrolmentExpired =>
      'The enrolment code expired before your VTA admin granted access. Ask your VTA host for a new one.';

  @override
  String get identityPersonaTitle => 'Persona on your VTA';

  @override
  String get identityPersonaHint =>
      'Your VTA holds this identity\'s keys. Contacts never see this DID.';

  @override
  String get identityPersonaCopyDid => 'Copy persona DID';

  @override
  String get identityVtaSaveFailed =>
      'Your VTA couldn\'t save this identity. Check it\'s reachable and try again.';

  @override
  String get identityVtaDeleteFailed =>
      'Your VTA couldn\'t delete this identity. Check it\'s reachable and try again.';

  @override
  String get identityDeleteConfirmTitle => 'Delete this identity?';

  @override
  String get identityDeleteConfirmMessage =>
      'Its persona is deleted from your VTA, and its DID can never be used again.';

  @override
  String get linkedVtaUnlinkAction => 'Remove';

  @override
  String get vtcSignInMenuTitle => 'Sign in to community';

  @override
  String get vtcSignInUseMembership => 'Use this membership';

  @override
  String get vtcSignInEnterNumber =>
      'Enter the two-digit number shown in your browser.';

  @override
  String get vtcSignInNumberLabel => 'Number';

  @override
  String get vtcSignInContinue => 'Continue';

  @override
  String get vtcSignInReviewHeading => 'Approve this sign-in?';

  @override
  String get vtcSignInSameNetwork => 'On the same network as this phone';

  @override
  String get vtcSignInOtherNetwork => 'On a different network than this phone';

  @override
  String get vtcSignInReportedNote =>
      'Reported by the community. Only that one browser session will be signed in.';

  @override
  String get vtcSignInApprove => 'Approve';

  @override
  String get vtcSignInDecline => 'Decline';

  @override
  String get vtcSignInApproved => 'You\'re signed in on that browser.';

  @override
  String get vtcSignInDeclined => 'The sign-in was declined.';

  @override
  String get vtcSignInVtaMissing =>
      'Link your VTA in Settings before signing in to a community.';

  @override
  String get vtcSignInDone => 'Done';

  @override
  String vtcSignInFailure(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'expired': 'This code has expired. Get a new one.',
      'invalid': 'This code can\'t be used.',
      'update': 'This code needs a newer version of the app.',
      'unreachable': 'This community can\'t be reached from your phone.',
      'notAMember':
          'This sign-in code is from a community you haven\'t joined.',
      'noSignIn': 'This community doesn\'t offer sign-in from the app.',
      'alreadyClaimed':
          'Another device already scanned this code. Refresh the sign-in page and scan the new code.',
      'notFound':
          'This sign-in has ended. Refresh the sign-in page and scan the new code.',
      'refused':
          'The community didn\'t accept this sign-in. Refresh the sign-in page and try again.',
      'notAnAdmin': 'This identity isn\'t an administrator of this community.',
      'badAnswer':
          'The community\'s answer couldn\'t be checked, so nothing was signed in.',
      'badNumber': 'Enter the two digits shown on the sign-in page.',
      'wrongNumber':
          'That isn\'t the number on the sign-in page. Refresh the page and scan the new code.',
      'noVaultEntry':
          'Your VTA isn\'t set up to sign in to this community yet.',
      'notEnrolledDevice':
          'This phone isn\'t registered with your VTA, so it can\'t sign in.',
      'noUvKey':
          'This phone isn\'t set up to approve sign-ins with your VTA yet.',
      'uvRequired': 'Your VTA needs your approval on this phone to sign in.',
      'uvCancelled': 'The sign-in wasn\'t approved.',
      'uvKeyLost':
          'Your Face ID or fingerprints changed, so approving sign-ins must be set up again. Unlink and link your VTA in Settings.',
      'uvUnavailable': 'This phone couldn\'t approve the sign-in.',
      'grantReplayed':
          'This approval was already used. Refresh the sign-in page and scan the new code.',
      'assertionMethodMissing':
          'Your identity in this community can\'t approve sign-ins yet.',
      'agentRefused': 'Your VTA refused this sign-in.',
      'agentNeedsUpdate':
          'Your VTA needs an update before it can sign you in to websites.',
      'agentUnreachable': 'Your VTA couldn\'t be reached.',
      'other':
          'The community didn\'t accept this sign-in. Refresh the sign-in page and try again.',
    });
    return '$_temp0';
  }

  @override
  String vtcSignInLinkProblem(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'update': 'This code needs a newer version of the app.',
      'expired': 'This code has expired. Get a new one.',
      'unreachable': 'This service can\'t be reached from your phone.',
      'other': 'This code can\'t be used.',
    });
    return '$_temp0';
  }

  @override
  String vtcSignInAudience(String audience) {
    String _temp0 = intl.Intl.selectLogic(audience, {
      'admin': 'Operator console',
      'other': 'Member portal',
    });
    return '$_temp0';
  }

  @override
  String vtcSignInTitle(String community) {
    return 'Sign in to $community';
  }

  @override
  String vtcSignInWebsite(String origin) {
    return 'Website: $origin';
  }

  @override
  String vtcSignInFoundMembership(String community) {
    return 'Your membership of $community was found on your VTA. Sign in as this identity?';
  }

  @override
  String vtcSignInTimeLeft(int seconds) {
    return '$seconds s left';
  }

  @override
  String get vtcSignInAs => 'Signing in as';

  @override
  String vtcSignInBrowser(String browser, String os) {
    return 'Browser: $browser on $os';
  }

  @override
  String vtcSignInLocation(String location) {
    return 'Location: $location';
  }

  @override
  String get linkedVtaDidNotResolved =>
      'Your VTA\'s DID couldn\'t be resolved from this phone. Check the DID, and that its host can be reached from this phone over HTTPS.';

  @override
  String get vtcJoinMenuTitle => 'Join a community';

  @override
  String get vtcJoinIntroTitle => 'Become a member of a community';

  @override
  String get vtcJoinIntro =>
      'Scan the community\'s QR code, paste its DID, or enter its join phrase. You see what it asks before anything is sent.';

  @override
  String get vtcJoinDidHint => 'Community DID or join phrase';

  @override
  String get vtcJoinScanAction => 'Scan QR code';

  @override
  String get vtcJoinPasteAction => 'Paste';

  @override
  String get vtcJoinContinueAction => 'Continue';

  @override
  String get vtcJoinMenuSubtitle =>
      'Scan a community\'s code and apply with your VTA';

  @override
  String get vtcJoinChooseIdentity => 'Join with which identity?';

  @override
  String vtcJoinShareDetails(String name) {
    return 'Share these details with $name?';
  }

  @override
  String get vtcJoinShareAction => 'Share and apply';

  @override
  String get vtcJoinCredentialMissing => 'Credential missing';

  @override
  String get mockCredentialsTitle => 'Mock credentials';

  @override
  String get mockCredentialsSubtitle => 'Test credentials for your identities';

  @override
  String get mockCredentialsNote =>
      'This phone signs these as a test issuer. Import one for an identity, then join a community whose way in asks for it and accepts any issuer.';

  @override
  String get mockCredentialsImport => 'Import';

  @override
  String get mockCredentialsChooseIdentity => 'Import for which identity?';

  @override
  String mockCredentialsHeldBy(String name) {
    return 'Held by $name';
  }

  @override
  String mockCredentialsImported(String name) {
    return 'Imported for $name';
  }

  @override
  String get mockCredentialsNotKept =>
      'Your VTA took the credential but doesn\'t keep it as valid.';

  @override
  String get mockCredentialsImportFailed =>
      'The credential couldn\'t be imported: your VTA refused it or can\'t be reached.';

  @override
  String mockCredentialsRefused(String reason) {
    return 'Your VTA refused the credential: $reason';
  }

  @override
  String get mockCredentialsNoIdentities =>
      'Create an identity on your VTA to import a credential for it.';

  @override
  String get mockCredentialsVtaMissing =>
      'Link your VTA in Settings to import test credentials.';

  @override
  String get mockCredentialsUnreachable => 'Your VTA can\'t be reached.';

  @override
  String vtcJoinWayWithCredential(String type) {
    return 'With your $type';
  }

  @override
  String vtcJoinShareCredential(String name) {
    return 'Present this credential to $name?';
  }

  @override
  String get vtcJoinCredentialIssuer => 'Issued by';

  @override
  String get vtcJoinCredentialClaimsHeading => 'What presenting it shows';

  @override
  String get vtcJoinCredentialNote =>
      'The whole credential goes with your application, which this identity signs.';

  @override
  String get vtcJoinNewIdentity => 'A new identity';

  @override
  String get vtcJoinNewIdentityHost => 'Created on your VTA for this community';

  @override
  String get vtcJoinExistingIdentity => 'Existing identity';

  @override
  String get vtcJoinUseIdentity => 'Join with this identity';

  @override
  String vtcJoinIdentityPosition(int position, int total) {
    return '$position of $total · swipe to see the others';
  }

  @override
  String vtcJoinChooseDid(String name) {
    return 'Which DID should $name see?';
  }

  @override
  String get vtcJoinNewDid => 'A new DID for this community';

  @override
  String get vtcJoinNewDidNote =>
      'Recommended: it shares this identity\'s details, but no other community can link you through it.';

  @override
  String get vtcJoinUseNewDid => 'Join with a new DID';

  @override
  String get vtcJoinIdentityDid => 'This identity\'s own DID';

  @override
  String get vtcJoinIdentityDidNote =>
      'Every community you join with it sees the same DID, so they can tell it\'s you.';

  @override
  String get vtcJoinUseIdentityDid => 'Join with this identity\'s DID';

  @override
  String get vtcJoinCredentialShowsIdentity =>
      'This way in asks for a credential, so the community sees the DID of the identity that holds it.';

  @override
  String get vtcJoinNewIdentityNote =>
      'Recommended: your VTA creates it for this community, so other communities can\'t link you through it.';

  @override
  String get vtcJoinWaysHeading => 'Ways in';

  @override
  String get vtcJoinManifestHeading => 'Manifest';

  @override
  String get vtcJoinShowManifest => 'Show the community\'s manifest';

  @override
  String vtcJoinWayKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'automatic': 'Automatic',
      'other': 'Reviewed',
    });
    return '$_temp0';
  }

  @override
  String get vtcJoinWayAutomatic => 'You become a member when you apply';

  @override
  String get vtcJoinWayReviewed => 'The administrators review your application';

  @override
  String vtcJoinWayUnsupported(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'invitation': 'Not supported yet: needs an invitation',
      'credentials': 'Not supported yet: needs credentials',
      'vetting': 'Not supported yet: needs an in-person check',
      'other': 'Not supported yet',
    });
    return '$_temp0';
  }

  @override
  String vtcJoinNoSupportedWay(String name) {
    return 'Meeting Place doesn\'t support any way into $name yet, so you can\'t apply from here.';
  }

  @override
  String get vtcJoinDetailsHeading => 'Profile details the community asks for';

  @override
  String get vtcJoinDetailsNote =>
      'You see the values from your VTA and approve sharing them before anything is sent.';

  @override
  String get vtcJoinDirectoryListed =>
      'This community lists new members in its member directory.';

  @override
  String get vtcJoinDirectoryHidden =>
      'This community doesn\'t list new members in its member directory.';

  @override
  String get vtcJoinListMe => 'List me in the member directory';

  @override
  String get vtcJoinListMeNote =>
      'If this is off, you may be listed for a moment when you join, until Meeting Place takes your card out of the directory.';

  @override
  String get vtcCommunityRole => 'Your role';

  @override
  String get vtcCommunityIdentity => 'Your identity';

  @override
  String vtcCommunityIdentityNewDid(String name) {
    return '$name, with a new DID for this community';
  }

  @override
  String vtcCommunityIdentityOwnDid(String name) {
    return '$name, with this identity\'s own DID';
  }

  @override
  String get vtcCommunitySettings => 'Community settings';

  @override
  String vtcCommunityRoleName(String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'Administrator',
      'moderator': 'Moderator',
      'issuer': 'Issuer',
      'member': 'Member',
      'vetter': 'Vetter',
      'other': '$role',
    });
    return '$_temp0';
  }

  @override
  String vtcRoleChanged(String community, String role) {
    return 'Your role in $community is now $role';
  }

  @override
  String vtcRemoved(String community) {
    return '$community removed you';
  }

  @override
  String vtcRemovedWithReason(String community, String reason) {
    return '$community removed you: $reason';
  }

  @override
  String get vtcJoinProfileHeading => 'About the community';

  @override
  String get vtcJoinWebsite => 'Website';

  @override
  String get vtcJoinContact => 'Contact';

  @override
  String vtcJoinAudience(String audience) {
    String _temp0 = intl.Intl.selectLogic(audience, {
      'admins': 'the administrators',
      'groups': 'your groups',
      'connections': 'your connections',
      'members': 'all members',
      'public': 'anyone',
      'other': 'some people',
    });
    return '$_temp0';
  }

  @override
  String get vtcJoinFieldSetByAdmins => 'Set by admins';

  @override
  String get vtcJoinExternalCards =>
      'You may publish your card beyond the community, if you choose to.';

  @override
  String get vtcJoinUnnamedCommunity => 'A community';

  @override
  String get vtcJoinThisCommunity => 'this community';

  @override
  String get vtcJoinWantsYou => 'wants you to join';

  @override
  String get vtcJoinWithVtaIdentity => 'With an identity from your VTA';

  @override
  String vtcJoinConsentHeading(String name) {
    return 'If you join, $name can:';
  }

  @override
  String vtcJoinReceivesDetail(String type) {
    return 'Receive your $type';
  }

  @override
  String get vtcClaimTypeNameDisplay => 'display name';

  @override
  String get vtcClaimTypeNameGiven => 'first name';

  @override
  String get vtcClaimTypeNameFamily => 'last name';

  @override
  String get vtcClaimTypeNameLegal => 'legal name';

  @override
  String get vtcClaimTypeEmailPersonal => 'personal email';

  @override
  String get vtcClaimTypeEmailWork => 'work email';

  @override
  String get vtcClaimTypePhoneMobile => 'mobile number';

  @override
  String get vtcClaimTypePhoneWork => 'work phone number';

  @override
  String get vtcClaimTypeAddressCountry => 'country';

  @override
  String get vtcClaimTypePersonBirthDate => 'date of birth';

  @override
  String get vtcClaimTypeSkillLanguage => 'languages';

  @override
  String get vtcClaimTypeAccountHandle => 'account handle';

  @override
  String get vtcJoinDetailRequiredNote => 'Required to apply';

  @override
  String get vtcJoinDetailOptionalNote => 'Optional';

  @override
  String vtcJoinShowsTo(String fields, String audience) {
    return 'Show your $fields to $audience';
  }

  @override
  String get vtcJoinMembershipDidField => 'membership ID';

  @override
  String vtcJoinListAnd(String rest, String last) {
    return '$rest and $last';
  }

  @override
  String get vtcJoinKeepsNotes => 'Keep notes about you';

  @override
  String get vtcJoinAdminNotesDetail =>
      'No other member sees them, and you can ask for yours.';

  @override
  String vtcJoinFieldSeenBy(String audience) {
    return 'Seen by: $audience';
  }

  @override
  String vtcJoinFieldWidenTo(String audience) {
    return 'You can widen to: $audience';
  }

  @override
  String get vtcJoinAction => 'Join';

  @override
  String vtcJoinCardRoute(String community, String identity) {
    return '$community issued your membership card to $identity, which passed it on to your VTA';
  }

  @override
  String vtcJoinJoined(String name) {
    return 'You\'re a member of $name.';
  }

  @override
  String get vtcJoinLeaveAction => 'Leave community';

  @override
  String get vtcJoinGoToCommunity => 'Go to community';

  @override
  String vtcJoinLeaveTitle(String name) {
    return 'Leave $name?';
  }

  @override
  String get vtcJoinLeaveMessage =>
      'The community ends your membership, and your VTA archives your membership card. To come back, you apply again.';

  @override
  String vtcJoinLeft(String name) {
    return 'You left $name.';
  }

  @override
  String vtcJoinPending(String name) {
    return 'Your application to $name is waiting for the community\'s decision.';
  }

  @override
  String get vtcJoinCheckAgain => 'Check again';

  @override
  String vtcIdentityCheckHeading(String name) {
    return '$name checked your identity';
  }

  @override
  String get vtcIdentityCheckHow => 'How';

  @override
  String vtcIdentityCheckMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'inPerson': 'In person',
      'video': 'By video call',
      'priorAcquaintance': 'They already knew you',
      'other': '$method',
    });
    return '$_temp0';
  }

  @override
  String get vtcIdentityCheckDocuments => 'Documents seen';

  @override
  String vtcIdentityCheckDocument(String document) {
    String _temp0 = intl.Intl.selectLogic(document, {
      'passport': 'Passport',
      'nationalId': 'National ID card',
      'other': '$document',
    });
    return '$_temp0';
  }

  @override
  String get vtcIdentityCheckConfirmed => 'Confirmed';

  @override
  String get vtcIdentityCheckLiveness => 'That you were there';

  @override
  String get vtcIdentityCheckCheckedOn => 'Checked on';

  @override
  String get vtcIdentityCheckValidUntil => 'Valid until';

  @override
  String get vtcIdentityCheckShow => 'Show the signed statement';

  @override
  String get vtcMembershipCardTitle => 'Membership card';

  @override
  String get vtcMembershipCardShow => 'Show the card';

  @override
  String get vtcMembershipCardPersonhood => 'Personhood';

  @override
  String get vtcMembershipCardMember => 'Member';

  @override
  String get vtcMembershipCardIssuedBy => 'Issued by';

  @override
  String get vtcMembershipCardValidFrom => 'Valid from';

  @override
  String get vtcMembershipCardValidUntil => 'Valid until';

  @override
  String get vtcMembershipCardKept => 'Kept on your VTA';

  @override
  String get vtcMembershipCardOnItsWay =>
      'Your membership card is on its way to your VTA';

  @override
  String get vtcMembershipCardLoading => 'Getting your membership card…';

  @override
  String get vtcJoinWithdrawAction => 'Withdraw application';

  @override
  String vtcJoinWithdrawTitle(String name) {
    return 'Withdraw your application to $name?';
  }

  @override
  String get vtcJoinWithdrawMessage =>
      'The community\'s administrators won\'t decide on it any more. You can apply again afterwards.';

  @override
  String vtcJoinWithdrawn(String name) {
    return 'You withdrew your application to $name.';
  }

  @override
  String get vtcJoinApplyAgain => 'Apply again';

  @override
  String get vtcJoinTrailHeading => 'Your application';

  @override
  String get vtcJoinTrailPresentation => 'Your credential, presented';

  @override
  String vtcJoinTrailPresentationSummary(String types) {
    return '$types · inside your signed application';
  }

  @override
  String get vtcJoinTrailHolder => 'Holder';

  @override
  String get vtcJoinTrailCredential => 'Credential';

  @override
  String get vtcJoinTrailIssuer => 'Issued by';

  @override
  String get vtcJoinTrailValidUntil => 'Valid until';

  @override
  String get vtcJoinTrailPresentationDocument => 'Your presentation';

  @override
  String get vtcTrailDoneBy => 'Done by';

  @override
  String get vtcTrailTasks => 'Trust Tasks';

  @override
  String get vtcJoinTrailVta => 'Signed by your VTA';

  @override
  String vtcJoinTrailVtaIdentity(String name) {
    return 'As your identity in $name';
  }

  @override
  String vtcJoinTrailVtaSummary(String name, String cryptosuite, String time) {
    return 'As your identity in $name · $cryptosuite · $time';
  }

  @override
  String get vtcJoinTrailCommunitySummary =>
      'Passed to its administrators · its signed answer verified';

  @override
  String vtcJoinTrailCommunity(String name) {
    return 'Received by $name';
  }

  @override
  String get vtcJoinTrailNoReceipt =>
      'Sent earlier; this phone keeps no receipt for it';

  @override
  String get vtcJoinTrailReview => 'Waiting for the administrators';

  @override
  String get vtcJoinTrailDeferred => 'Put off by the administrators for now';

  @override
  String vtcJoinTrailLastChecked(String time) {
    return 'Last checked at $time';
  }

  @override
  String vtcJoinTrailAutoCheck(int seconds) {
    return 'Checked again every $seconds seconds while this screen is open';
  }

  @override
  String get vtcJoinTrailCard => 'Membership card';

  @override
  String get vtcJoinTrailCardSummary =>
      'Issued once you\'re admitted, and kept on your VTA';

  @override
  String get vtcJoinTrailWithdrawn => 'Withdrawn, signed by your VTA';

  @override
  String vtcJoinTrailWithdrawnSummary(String name) {
    return '$name confirmed it · its signed answer verified';
  }

  @override
  String vtcJoinTrailWithdrawnNotHeld(String name) {
    return '$name no longer held it open';
  }

  @override
  String get vtcJoinTrailWithdrawnDocument => 'Your withdrawal and its receipt';

  @override
  String get vtcJoinTrailIdentity => 'Identity';

  @override
  String get vtcJoinTrailTask => 'Trust Task';

  @override
  String get vtcJoinTrailKey => 'Signing key';

  @override
  String get vtcJoinTrailCryptosuite => 'Cryptosuite';

  @override
  String get vtcJoinTrailSignedAt => 'Signed at';

  @override
  String get vtcJoinTrailRequestId => 'Request id at the community';

  @override
  String get vtcJoinTrailCheckTask => 'Last check';

  @override
  String get vtcJoinTrailCheckSignedAt => 'Last check signed by your VTA at';

  @override
  String get vtcJoinTrailCheckAnsweredAt =>
      'Last check answered and verified at';

  @override
  String get vtcJoinTrailProofPurpose => 'Proof purpose';

  @override
  String get vtcJoinTrailCheckAnswerKey => 'Key that signed the last answer';

  @override
  String get vtcJoinJsonCopy => 'Copy JSON';

  @override
  String get vtcJoinTrailShowDocument => 'Show the signed document';

  @override
  String get vtcJoinTrailSubmitDocument => 'Your signed application';

  @override
  String get vtcJoinTrailAnswerDocument => 'The community\'s signed answer';

  @override
  String get vtcJoinTrailCheckDocument => 'The community\'s last signed answer';

  @override
  String get vtcJoinTrailAnsweredBy => 'Answered by';

  @override
  String get vtcJoinTrailAnsweredAt => 'Answered at';

  @override
  String get vtcDeliveryHeading => 'How your card arrived';

  @override
  String get vtcDeliveryKeysLent => 'Keys lent by your VTA';

  @override
  String get vtcDeliveryKeysLentSummary =>
      'Held in memory only, while this screen collects the card';

  @override
  String get vtcDeliveryKeysFailed =>
      'Your VTA didn\'t lend the keys. Trying again';

  @override
  String get vtcDeliveryKeyAgreementKey => 'Key agreement key';

  @override
  String get vtcDeliverySignedIn => 'Signed in to your identity\'s inbox';

  @override
  String vtcDeliveryWaitingMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages waiting',
      one: '1 message waiting',
      zero: 'No messages waiting',
    );
    return '$_temp0';
  }

  @override
  String get vtcDeliverySignedInFailed =>
      'Couldn\'t reach the inbox. Trying again';

  @override
  String get vtcDeliveryInboxNoTask =>
      'None: the inbox is signed in to and read over DIDComm';

  @override
  String get vtcDeliveryMediator => 'Mediator';

  @override
  String vtcDeliveryPickedUp(String name) {
    return 'Card picked up from $name';
  }

  @override
  String vtcDeliveryPickedUpSummary(String name) {
    return 'Signed by $name · proof verified';
  }

  @override
  String vtcDeliveryWaiting(String name) {
    return 'Waiting for $name to deliver it';
  }

  @override
  String get vtcDeliverySentBy => 'Sent by';

  @override
  String get vtcDeliveryIssueDocument => 'The community\'s signed delivery';

  @override
  String get vtcDeliveryKept => 'Kept on your VTA';

  @override
  String get vtcDeliveryKeptSummary => 'Proof checked by your VTA';

  @override
  String get vtcDeliveryKeptInvalid =>
      'Kept, but your VTA finds it revoked or expired';

  @override
  String get vtcDeliveryKeptFailed => 'Your VTA didn\'t keep it. Trying again';

  @override
  String vtcDeliveryConfirmed(String name) {
    return 'Membership confirmed with $name';
  }

  @override
  String get vtcDeliveryConfirmedSummary =>
      'Your identity signed the card back to the community';

  @override
  String get vtcDeliveryConfirmedFailed => 'Not confirmed yet. Trying again';

  @override
  String get vtcDeliveryNext => 'Still to come';

  @override
  String vtcJoinDenied(String name) {
    return '$name didn\'t accept your application.';
  }

  @override
  String vtcJoinLastDenied(String reason) {
    return 'Your last application was turned down. The community\'s reason: $reason';
  }

  @override
  String vtcJoinDeniedWithReason(String name, String reason) {
    return '$name didn\'t accept your application. Its reason: $reason';
  }

  @override
  String get vtcJoinNeedsMore =>
      'The community needs more than Meeting Place can send, such as credentials.';

  @override
  String vtcJoinFailure(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'invalidCode': 'This isn\'t a community\'s code.',
      'phraseNotFound': 'No community goes by this phrase in Meeting Place.',
      'phraseExpired':
          'This join phrase has expired. Ask the community for its current phrase.',
      'profileMissing':
          'Your VTA has no profile for this identity, so it can\'t share the details the community asks for. Set up your profile on your VTA, then try again.',
      'detailsMissing':
          'Your VTA doesn\'t hold a detail the community requires, so nothing was sent.',
      'credentialMissing':
          'Your identity holds no credential this way in accepts that your VTA can present, so nothing was sent.',
      'vtaMissing': 'Link your VTA in Settings before joining a community.',
      'unreachable': 'The community can\'t be reached from your phone.',
      'noDidHosting':
          'Your VTA has no DID hosting server, so it can\'t create an identity the community can find.',
      'notAccepting': 'This community isn\'t accepting applications.',
      'badAnswer':
          'The community\'s answer couldn\'t be checked, so nothing was recorded.',
      'lastAdministrator':
          'You\'re this community\'s last administrator. Make another member an administrator before you leave.',
      'other': 'The community or your VTA refused the application.',
    });
    return '$_temp0';
  }

  @override
  String get vtaDetailsTitle => 'VTA details';

  @override
  String get vtaDetailsContextId => 'Context ID';

  @override
  String get vtaDetailsProfileId => 'Profile ID';

  @override
  String get vtaDetailsProfile => 'Profile';

  @override
  String get vtaDetailsCopyProfile => 'Copy profile';

  @override
  String get vtaDetailsProfileFailed =>
      'Couldn\'t read this profile from your VTA.';

  @override
  String vtaDetailsValueShortened(String start, int length) {
    return '$start… ($length characters)';
  }

  @override
  String get vtcJoinPhraseHeading => 'Join phrase';

  @override
  String vtcJoinPhraseIntro(String name) {
    return 'Let people find $name in Meeting Place by a short phrase instead of its DID. They see the community and where it is hosted before they apply.';
  }

  @override
  String get vtcJoinPhrasePublishAction => 'Publish join phrase';

  @override
  String vtcJoinPhraseDialogTitle(String name) {
    return 'Join phrase for $name';
  }

  @override
  String get vtcJoinPhraseHint => 'Phrase';

  @override
  String vtcJoinPhraseOfferDescription(String name) {
    return 'Join $name in Meeting Place';
  }

  @override
  String vtcJoinPhrasePublished(String name, String phrase) {
    return 'People find $name by entering \"$phrase\" or scanning this code in Meeting Place, until you withdraw it.';
  }

  @override
  String get vtcJoinPhraseVisibility =>
      'The phrase shows only the community\'s DID, nothing about you. Anyone can publish a phrase for any community, so people still check the community before they apply.';

  @override
  String get vtcJoinPhraseWithdrawAction => 'Withdraw phrase';

  @override
  String vtcJoinPhraseWithdrawTitle(String phrase) {
    return 'Withdraw \"$phrase\"?';
  }

  @override
  String get vtcJoinPhraseWithdrawMessage =>
      'Meeting Place stops listing the phrase, and anyone can then publish it again.';

  @override
  String vtcJoinPhraseFailure(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'taken': 'That phrase is already taken in Meeting Place. Try another.',
      'other': 'The phrase couldn\'t be published or withdrawn. Try again.',
    });
    return '$_temp0';
  }

  @override
  String get vtcFindableHeading => 'Let members find you';

  @override
  String vtcFindableIntro(String name) {
    return 'Let members of $name find you to vouch for you. They\'ll see the identity you joined with.';
  }

  @override
  String vtcFindableNotAllowed(String name) {
    return '$name doesn\'t let members show this.';
  }

  @override
  String get vtcFindableFailed => 'Couldn\'t change this. Try again.';

  @override
  String get vtcTrustHeading => 'Community trust';

  @override
  String get vtcTrustVouchInCommunity => 'Vouch in a community';

  @override
  String vtcTrustTheyVouched(String name) {
    return '$name vouched for you';
  }

  @override
  String get vtcTrustNoVouch => 'No vouches yet';

  @override
  String get vtcTrustVouch => 'Vouch';

  @override
  String get vtcTrustVouchBack => 'Vouch back';

  @override
  String get vtcTrustWithdraw => 'Withdraw';

  @override
  String get vtcTrustPickCommunity => 'Vouch in which community?';

  @override
  String vtcTrustSearchTitle(String name, String community) {
    return 'Find $name in $community';
  }

  @override
  String get vtcTrustSearchHint => 'Name';

  @override
  String get vtcTrustSearchNone => 'No members match.';

  @override
  String get vtcTrustUnnamed => 'Unnamed member';

  @override
  String vtcTrustConfirmMatchTitle(String contact) {
    return 'Is this $contact?';
  }

  @override
  String vtcTrustConfirmMatchMessage(
    String contact,
    String community,
    String member,
  ) {
    return 'Your vouches for $contact in $community will name $member.';
  }

  @override
  String get vtcTrustConfirmMatchAction => 'Yes, that\'s them';

  @override
  String vtcTrustConsentTitle(String name, String community) {
    return 'Vouch for $name in $community?';
  }

  @override
  String vtcTrustConsentMessage(String name, String community) {
    return 'This tells members of $community that you and $name know each other. You\'ll each also see what the other shares with their connections.';
  }

  @override
  String vtcTrustWithdrawTitle(String name, String community) {
    return 'Stop vouching for $name in $community?';
  }

  @override
  String get vtcTrustWithdrawMessage => 'Members will no longer see it.';

  @override
  String vtcTrustDoneTitle(String name) {
    return 'You vouched for $name';
  }

  @override
  String get vtcTrustSigned => 'Signed by your VTA';

  @override
  String vtcTrustSignedSummary(String community) {
    return 'As the identity you joined $community with.';
  }

  @override
  String vtcTrustStored(String community) {
    return 'Stored by $community';
  }

  @override
  String get vtcTrustVouchDocument => 'Signed vouch';

  @override
  String vtcTrustFailure(String reason, String community, String name) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'notMember': 'You\'re not a member of $community any more.',
      'contactNotMember': '$name isn\'t a member of $community any more.',
      'notFindable': '$name hasn\'t let members of $community find them yet.',
      'searchTooShort': 'Enter at least three letters.',
      'nameRefused': '$community doesn\'t accept this name.',
      'proofRejected': '$community didn\'t accept your VTA\'s signature.',
      'notAllowed': '$community doesn\'t allow this.',
      'tryLater': '$community is busy. Try again in a moment.',
      'vtaUnavailable':
          'Your VTA couldn\'t sign this. Try again when it\'s reachable.',
      'network': 'Couldn\'t reach $community.',
      'other': 'Something went wrong. Try again.',
    });
    return '$_temp0';
  }

  @override
  String get vtcGroupMembersOpen => 'Members';

  @override
  String vtcGroupMembersTitle(String group) {
    return 'Members of $group';
  }

  @override
  String get vtcGroupMembersNone => 'No other members to show.';

  @override
  String vtcGroupMembersUnlistedNote(String community) {
    return 'Members who chose not to be listed in the directory of $community aren\'t shown.';
  }

  @override
  String vtcDirectoryNameRefused(String community) {
    return '$community doesn\'t accept this name.';
  }

  @override
  String vtcTrustRecordDocument(String community) {
    return 'What $community keeps';
  }

  @override
  String get vtcVouchTrailYou => 'You';

  @override
  String vtcVouchTrailTheirVta(String name) {
    return '$name\'s VTA';
  }

  @override
  String vtcVouchTrailIn(String community) {
    return 'In $community.';
  }

  @override
  String vtcVouchTrailValidFrom(String community, String date) {
    return 'In $community, valid from $date.';
  }

  @override
  String get vtcVouchTrailVouchedFor => 'Vouched for';

  @override
  String vtcVouchTrailSignedByTheirVta(String name) {
    return 'Signed by $name\'s VTA';
  }

  @override
  String vtcVouchTrailSignedTheirSummary(String name, String community) {
    return 'As the identity $name joined $community with.';
  }

  @override
  String vtcVouchTrailStoredSummary(String community) {
    return 'Members of $community can see this vouch.';
  }

  @override
  String get vtcVouchTrailRecord => 'Record';

  @override
  String get vtcVouchTrailStoredAt => 'Stored at';

  @override
  String get vtcVouchTrailTheVouch => 'The vouch';

  @override
  String vtcTrustVouchedForEachOther(String name) {
    return 'You and $name vouched for each other';
  }

  @override
  String vtcMemberCredentialsTitle(String name) {
    return '$name\'s credentials';
  }

  @override
  String vtcMemberCredentialsNote(String community) {
    return 'As $community shows them to you.';
  }

  @override
  String vtcMemberCredentialsNone(String community, String name) {
    return '$community shows you none of $name\'s credentials.';
  }

  @override
  String get vtcMemberCredentialsMembership => 'Membership card';

  @override
  String get vtcMemberCredentialsRole => 'Role card';

  @override
  String vtcMemberCredentialsIssuedBy(String community) {
    return 'Issued by $community';
  }

  @override
  String get vtcMemberCredentialsAcknowledgement => 'Acknowledgement';

  @override
  String vtcMemberCredentialsAcknowledgementBound(String name) {
    return 'Signed by $name, for this membership card';
  }

  @override
  String vtcMemberCredentialsAcknowledgementStale(String name) {
    return 'Signed by $name, for an earlier membership card';
  }

  @override
  String get vtcMemberCredentialsPublicCard => 'Public card';

  @override
  String vtcMemberCredentialsSignedBy(String name) {
    return 'Signed by $name';
  }

  @override
  String vtcMemberCredentialsVouch(String issuer, String subject) {
    return '$issuer vouched for $subject';
  }

  @override
  String vtcMemberCredentialsStoredAt(String date) {
    return 'Stored $date';
  }

  @override
  String get vtcMemberCredentialsAnotherMember => 'another member';

  @override
  String vtcJoinAlreadyMember(String name) {
    return 'You\'re already a member of $name.';
  }

  @override
  String get vtcRoomsOpen => 'Rooms';

  @override
  String get vtcRoomsTitle => 'Rooms';

  @override
  String get vtcRoomsNone =>
      'No rooms yet. When a group you\'re in is given a room, it\'s offered to you here.';

  @override
  String get vtcRoomsOffersHeading => 'Offered to you';

  @override
  String get vtcRoomsMineHeading => 'Your rooms';

  @override
  String get vtcRoomsAccept => 'Accept';

  @override
  String vtcRoomsAccepted(String room) {
    return 'You\'re in $room.';
  }

  @override
  String get vtcRoomsReadWrite => 'Read and write';

  @override
  String get vtcRoomsReadOnly => 'Read only';

  @override
  String get vtcRoomsClosed => 'Not open to you now';

  @override
  String get vtcRoomsSealed =>
      'Sealed: only the room\'s members can read what\'s written here.';

  @override
  String get vtcRoomsOpenTier =>
      'Open: the community hosting this room can read what\'s written here.';

  @override
  String get vtcRoomsVtaMissing => 'Link your VTA to use rooms.';

  @override
  String get vtcRoomsFailed => 'Couldn\'t reach the room. Try again.';

  @override
  String get vtcRoomRecordsNone => 'Nothing has been written here yet.';

  @override
  String get vtcRoomRecordsNoneWriter =>
      'Nothing has been written here yet. Tap Write to add the first record.';

  @override
  String get vtcRoomReadOnlyNote =>
      'You can read this room. Only members who may write can add to it.';

  @override
  String get vtcRoomRecordUnopened =>
      'This record couldn\'t be opened or its signature didn\'t check out.';

  @override
  String get vtcRoomRecordUntitled => 'Untitled';

  @override
  String get vtcRoomRecordOutdated => 'Marked as outdated';

  @override
  String get vtcRoomRecordByYou => 'Written by you';

  @override
  String get vtcRoomRecordByMember => 'Written by another member';

  @override
  String get vtcRoomWrite => 'Write';

  @override
  String get vtcRoomWriteTitle => 'New record';

  @override
  String get vtcRoomWriteTitleLabel => 'Title';

  @override
  String get vtcRoomWriteBodyLabel => 'Text';

  @override
  String get vtcRoomWriteSend => 'Post';

  @override
  String get vtcRoomWriteCancel => 'Cancel';

  @override
  String get vtcRoomWritten => 'Posted.';

  @override
  String get vtcRoomPosting => 'Posting…';

  @override
  String get vtcRoomWriteRefused =>
      'You can only read this room, so you can\'t add to it.';

  @override
  String get vtcGroupsNone => 'You\'re not in any of this community\'s groups.';

  @override
  String get vtcGroupsVtaMissing => 'Link your VTA to see your groups.';

  @override
  String get vtcGroupsNotAMember =>
      'This phone hasn\'t confirmed your membership yet. Open the community to check, then try again.';

  @override
  String get vtcGroupsUnreachable =>
      'Your groups couldn\'t be loaded. Check your connection and try again.';

  @override
  String get vtcGroupManager => 'Manager';

  @override
  String get vtcGroupChatHeading => 'Group chat';

  @override
  String get vtcGroupChatPostingTitle => 'Who can post in this chat?';

  @override
  String get vtcGroupChatPostingEveryone => 'Everyone in the group';

  @override
  String get vtcGroupChatPostingEveryoneHint => 'Every member reads and posts.';

  @override
  String get vtcGroupChatPostingManagers => 'Only the group\'s managers';

  @override
  String get vtcGroupChatPostingManagersHint =>
      'Members only read, as in announcements.';

  @override
  String get vtcGroupChatReadOnly =>
      'Only the group\'s managers post in this chat.';

  @override
  String get vtcGroupCredential => 'Group credential';

  @override
  String vtcGroupCredentialUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get vtcGroupChatUnknown => 'This group\'s chat couldn\'t be checked.';

  @override
  String get vtcGroupChatNone => 'This group has no chat yet.';

  @override
  String get vtcGroupChatLinked => 'This group has a chat you can join.';

  @override
  String get vtcGroupChatOwned =>
      'You own this group\'s chat. Members you let in appear in it.';

  @override
  String get vtcGroupChatJoined =>
      'You asked to join this group\'s chat. You\'ll find it in your chats.';

  @override
  String get vtcGroupChatCreate => 'Create chat';

  @override
  String get vtcGroupChatJoin => 'Join chat';

  @override
  String get vtcGroupChatHidesMembers =>
      'This group hides its members, so it can\'t have a chat.';

  @override
  String get vtcGroupChatNotAManager =>
      'Only a manager of this group can create its chat.';

  @override
  String get vtcGroupChatAlreadyLinked => 'This group already has a chat.';

  @override
  String get vtcGroupChatNotLinked =>
      'This group\'s chat isn\'t linked yet. Ask one of its managers.';

  @override
  String get vtcGroupChatElsewhere =>
      'This group\'s chat is on another Meeting Place.';

  @override
  String get vtcGroupChatNotTheGroups =>
      'The linked chat isn\'t this group\'s. Ask one of its managers.';

  @override
  String get vtcGroupChatMemberNotHere =>
      'The identity that is your membership of this community isn\'t on this phone.';

  @override
  String get vtcGroupChatNoCredential =>
      'Your VTA doesn\'t have this group\'s membership credential yet. Try again later.';

  @override
  String get vtcGroupChatFailed => 'That didn\'t work. Try again.';

  @override
  String get vtcGroupChatLinkTitle => 'Publish the chat\'s link';

  @override
  String get vtcGroupChatLinkBody =>
      'Members find the chat through the group\'s DID. Ask your community\'s operator to add this service to the group\'s DID document. Until then, members can\'t find the chat.';

  @override
  String get vtcGroupChatLinkCopy => 'Copy';

  @override
  String get vtcGroupChatLinkCopyCommand => 'Copy pnm command';

  @override
  String get vtcGroupChatLinkShow => 'Show the chat\'s link';

  @override
  String get vtcGroupChatLinkCopied => 'Copied';

  @override
  String get vtcGroupChatLinkDone => 'Done';

  @override
  String get vtcOpenLoading => 'Opening the community…';

  @override
  String get vtcOpenStepFinding => 'Finding the community';

  @override
  String get vtcOpenStepRules => 'Reading what it asks of those who join';

  @override
  String get vtcOpenStepProfile => 'Reading its profile';

  @override
  String get vtcOpenStepMembership =>
      'Checking whether you already belong, here or on your VTA';

  @override
  String get vtcOpenStepCredentials =>
      'Asking your VTA which of your identities hold what it asks for';

  @override
  String vtcLeaveLoading(String name) {
    return 'Leaving $name…';
  }

  @override
  String get vtcLeaveStepCard =>
      'Reading your membership card from your VTA, to keep a record';

  @override
  String vtcLeaveStepTelling(String name) {
    return 'Telling $name you\'re leaving';
  }

  @override
  String get vtcLeaveStepArchiving => 'Archiving your card on your VTA';

  @override
  String vtcApplyLoading(String name) {
    return 'Applying to $name…';
  }

  @override
  String get vtcApplyStepIdentity => 'Getting your identity ready on your VTA';

  @override
  String vtcApplyStepSending(String name) {
    return 'Sending your application to $name';
  }

  @override
  String vtcApplyStepSendingCredential(String name) {
    return 'Sending your application and credential to $name';
  }

  @override
  String get vtcApplyStepKeeping => 'Keeping your membership card on your VTA';

  @override
  String vtcApplyStepConfirming(String name) {
    return 'Confirming your membership with $name';
  }

  @override
  String vtcCardStepFinding(String name) {
    return 'Looking on your VTA for the card $name issued you';
  }

  @override
  String get vtcCardStepReading => 'Opening your card';

  @override
  String vtcJoinVettingIntro(String name) {
    return '$name asks to meet you first. One of its vetters checks who you are, in person, and vouches for you.';
  }

  @override
  String vtcJoinVettingProgress(int have, int needed) {
    return '$have of $needed vetters vouched for you';
  }

  @override
  String vtcJoinVettingMethodNeed(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more must meet you',
      one: '1 more must meet you',
    );
    String _temp1 = intl.Intl.selectLogic(method, {
      'inPerson': 'in person',
      'video': 'over video',
      'priorAcquaintance': 'and know you already',
      'other': '',
    });
    return '$_temp0 $_temp1';
  }

  @override
  String vtcJoinVettingChecks(String claims) {
    return 'Vetters check: $claims';
  }

  @override
  String vtcJoinVettingMaxAge(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'A vouch counts for $days days',
      one: 'A vouch counts for 1 day',
    );
    return '$_temp0';
  }

  @override
  String get vtcJoinVettingNotIndependent =>
      'These vouches don\'t all count together. Ask another vetter.';

  @override
  String get vtcJoinVettersHeading => 'Your vetters';

  @override
  String vtcJoinVettingStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'requested': 'Waiting for them to answer',
      'accepted': 'Confirmed as a vetter · waiting for them to start',
      'inSession': 'Compare the match code',
      'cardSent': 'Waiting for their vouch',
      'vouched': 'Vouched for you',
      'declined': 'Declined to vouch',
      'refused': 'Couldn\'t go ahead',
      'abandoned': 'You ended the session',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String vtcJoinVettingFailure(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'otherCommunity': 'This ticket is for another community.',
      'invalidTicket':
          'The vetter didn\'t take this ticket or code. It may have expired or been used. Ask them for a new one.',
      'unavailable': 'The vetter can\'t vet you right now.',
      'notVetter':
          'This person couldn\'t show that the community made them a vetter, so nothing was shared.',
      'vetterRevoked': 'The community no longer lets this person vet.',
      'sessionExpired':
          'The session has ended. Ask the vetter to start a new one.',
      'badAnswer':
          'The vetter\'s answer couldn\'t be checked, so it was ignored.',
      'other': 'The vetter refused.',
    });
    return '$_temp0';
  }

  @override
  String get vtcJoinVettingScanAction => 'Scan a vetter\'s ticket';

  @override
  String get vtcJoinVettingCodeAction => 'Enter a vetter\'s code';

  @override
  String get vtcJoinVettingSendAction => 'Send application';

  @override
  String get vtcJoinChooseVetterTitle => 'Who are you meeting?';

  @override
  String get vtcJoinChooseVetterIntro =>
      'Pick the vetter in front of you. Names are the vetters\' own.';

  @override
  String vtcJoinNoVetters(String name) {
    return '$name lists no vetters. Scan your vetter\'s ticket instead.';
  }

  @override
  String vtcJoinVettingCodeTitle(String vetter) {
    return 'Enter $vetter\'s code';
  }

  @override
  String get vtcJoinVettingCodeIntro =>
      'Ask them to read out the code their app shows.';

  @override
  String get vtcJoinVettingCodeHint => 'Code, e.g. K7QF-2M9X';

  @override
  String vtcJoinVettingVerified(String vetter, String name, String date) {
    return '$vetter is a vetter of $name until $date.';
  }

  @override
  String get vtcJoinMatchTitle => 'Do the codes match?';

  @override
  String vtcJoinMatchIntro(String vetter) {
    return '$vetter sees a code too. Read yours out and check it\'s the same.';
  }

  @override
  String get vtcJoinMatchYes => 'They match';

  @override
  String get vtcJoinMatchNo => 'They don\'t match';

  @override
  String vtcJoinVettingCardTitle(String vetter) {
    return 'Show these details to $vetter?';
  }

  @override
  String vtcJoinVettingCardNote(String vetter) {
    return 'Only $vetter sees these. They check them against your ID, and the community gets their vouch, not your details.';
  }

  @override
  String get vtcJoinVettingCardDecline => 'Don\'t share';

  @override
  String get vtcJoinMatchCodeHeading => 'Your match code';

  @override
  String get vtcJoinVettingCardHeading => 'Details for your vetter';

  @override
  String get vtcVetterStart => 'Vet applicants';

  @override
  String vtcVetterTitle(String name) {
    return 'Vetting for $name';
  }

  @override
  String get vtcVetterDetailsTitle => 'Check the applicant';

  @override
  String get vtcVetterIntro =>
      'Show your ticket to someone who wants to join. You\'ll check their details in person.';

  @override
  String vtcVetterNotVetter(String name) {
    return 'You can\'t vet for $name right now: your vetter card has expired or been withdrawn.';
  }

  @override
  String get vtcVetterTicketHeading => 'Your vetting ticket';

  @override
  String get vtcVetterTicketCodeHint => 'Or read out this code';

  @override
  String vtcVetterTicketValid(String time) {
    return 'Good for one applicant, until $time.';
  }

  @override
  String get vtcVetterNewTicket => 'New ticket';

  @override
  String get vtcVetterShowTicket => 'Show a vetting ticket';

  @override
  String get vtcVetterMatchIntro =>
      'The applicant sees a code too. Ask them to read theirs out and check it\'s the same.';

  @override
  String get vtcVetterCardWaiting => 'Waiting for the applicant\'s details…';

  @override
  String get vtcVetterCardHeading => 'Applicant\'s details';

  @override
  String get vtcVetterCardIntro =>
      'Check these details against their ID document, with them in front of you.';

  @override
  String get vtcVetterDocumentHeading => 'Document you checked';

  @override
  String vtcVetterDocument(String document) {
    String _temp0 = intl.Intl.selectLogic(document, {
      'passport': 'Passport',
      'nationalId': 'National ID card',
      'driverLicence': 'Driving licence',
      'other': '$document',
    });
    return '$_temp0';
  }

  @override
  String get vtcVetterCheckedInPerson =>
      'I checked these details against the document, with the applicant in front of me.';

  @override
  String get vtcVetterIssue => 'Vouch for them';

  @override
  String get vtcVetterDecline => 'Decline';

  @override
  String get vtcVetterIssuedHeading => 'Statements you issued';

  @override
  String vtcVetterIssuedLine(String date, String until) {
    return 'Issued $date, valid until $until';
  }

  @override
  String get vtcVetterIssuedNone => 'None yet.';

  @override
  String vtcVetterFailure(String failure) {
    String _temp0 = intl.Intl.selectLogic(failure, {
      'notVetter': 'Your vetter card is no longer valid.',
      'other': 'Something went wrong. Check your connection and try again.',
    });
    return '$_temp0';
  }

  @override
  String onboardingStepOf(int step, int total, String title) {
    return 'Step $step of $total · $title';
  }

  @override
  String get vtcVetterResume => 'Continue vetting';

  @override
  String vtcVettingFlowStep(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'ticket': 'Show your ticket',
      'match': 'Compare codes',
      'details': 'Check their details',
      'other': 'Done',
    });
    return '$_temp0';
  }

  @override
  String vtcVetterOutcome(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'issued': 'You vouched for them. They now hold your statement.',
      'declined': 'You declined to vouch for them.',
      'other': 'The applicant ended the session.',
    });
    return '$_temp0';
  }

  @override
  String get vtcVetterBackToDesk => 'Back to the desk';

  @override
  String vtcApplicantStep(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'meet': 'Meet a vetter',
      'ticket': 'Ask the vetter',
      'match': 'Compare codes',
      'details': 'Share your details',
      'other': 'Done',
    });
    return '$_temp0';
  }

  @override
  String vtcApplicantListingVetters(String name) {
    return 'Getting $name\'s vetters';
  }

  @override
  String get vtcApplicantUnlocking => 'Getting your identity ready';

  @override
  String vtcApplicantSendingRequest(String vetter) {
    return 'Sending your request to $vetter';
  }

  @override
  String vtcApplicantWaitingSession(String vetter) {
    return 'Waiting for $vetter to open a session';
  }

  @override
  String get vtcApplicantPreparing =>
      'Getting the details they check from your VTA';

  @override
  String get vtcApplicantRecording => 'Recording what you share on your VTA';

  @override
  String vtcApplicantSendingDetails(String vetter) {
    return 'Sending your details to $vetter';
  }

  @override
  String vtcApplicantWaitingCheck(String vetter) {
    return 'Waiting for $vetter to check your details';
  }

  @override
  String vtcApplicantOutcome(String status, String vetter) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'vouched': '$vetter vouched for you',
      'declined': '$vetter declined to vouch for you',
      'refused': '$vetter couldn\'t take your request',
      'unanswered': 'No answer from $vetter. Ask them for a new ticket.',
      'other': 'You ended the session with $vetter',
    });
    return '$_temp0';
  }

  @override
  String vtcApplicantVettingComplete(String name) {
    return 'All the vetters $name asks for vouched for you. You can join now.';
  }

  @override
  String get vtcApplicantJoinAction => 'Join community';

  @override
  String get vtcApplicantBackToOverview => 'Back to the overview';

  @override
  String get vtcVetterCardTitle => 'Vetter card';

  @override
  String get vtcVetterCardHolder => 'Vetter';

  @override
  String get vtcVetterStepCard => 'Checking your vetter card is still valid';

  @override
  String get vtcVetterApplicantFound => 'An applicant scanned your ticket';

  @override
  String get vtcVetterStepSession => 'Opening a session with them';

  @override
  String get vtcBackgroundHeading => 'In the background';

  @override
  String get vtcVetterStepTicket => 'Creating your ticket';

  @override
  String vtcVetterStepRequirements(String name) {
    return 'Getting what $name asks you to check';
  }

  @override
  String get vtcVetterCheckFailed =>
      'Couldn\'t check your vetter card, so vetting isn\'t offered. Try again later.';

  @override
  String vtcVetterRequirementsHeading(String name) {
    return 'What $name asks you to check';
  }

  @override
  String vtcVetterRequirementsDocuments(String documents) {
    return 'Accepted documents: $documents';
  }

  @override
  String get vtcVetterRequirementsInPerson =>
      'Check each detail against an ID document, with the applicant in front of you.';

  @override
  String get vtcJoinVettingStopAction => 'Stop vetting';

  @override
  String vtcJoinVettingStopTitle(String name) {
    return 'Stop vetting for $name?';
  }

  @override
  String get vtcJoinVettingStopMessage =>
      'The vetters\' statements and open requests on this phone are forgotten. You can start again from the community\'s page.';

  @override
  String vtcJoinVettingDetailsMissing(String identity, String details) {
    return '$identity has no $details on your VTA, so nothing was sent. Add them to its profile, or stop vetting and choose another identity.';
  }

  @override
  String vtcJoinApplyingIdentityNamed(String name) {
    return 'Your identity $name';
  }

  @override
  String get vtcJoinApplyingIdentityCreated =>
      'The identity your VTA created for this community';

  @override
  String vtcJoinVetterListedAs(String name) {
    return 'Listed as $name';
  }

  @override
  String get vtcVetterProfileTitle => 'Your vetter profile';

  @override
  String get vtcVetterProfileOpen => 'Your vetter profile';

  @override
  String vtcVetterProfileIntro(String name) {
    return 'People applying to $name who look for a vetter see what you write here, as your own words. Nobody checks it.';
  }

  @override
  String get vtcVetterProfileListed => 'List me for applicants';

  @override
  String get vtcVetterProfileListedNote =>
      'Off keeps your profile with the community but out of its list.';

  @override
  String get vtcVetterProfileStoredListed =>
      'Your profile is in the community\'s list.';

  @override
  String get vtcVetterProfileStoredHidden =>
      'The community keeps your profile, but doesn\'t list it.';

  @override
  String get vtcVetterProfileDisplayName => 'Name to be listed under';

  @override
  String get vtcVetterProfileLanguages => 'Languages you vet in, e.g. en, de';

  @override
  String get vtcVetterProfileCountry => 'Country code, e.g. DE';

  @override
  String get vtcVetterProfileCity => 'City (needs a country)';

  @override
  String get vtcVetterProfileContactHint =>
      'How applicants get a ticket from you';

  @override
  String get vtcVetterProfileAvailability => 'When you\'re available';

  @override
  String get vtcVetterProfileMethodsHeading => 'How you vet';

  @override
  String vtcVetterProfileMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'inPerson': 'In person',
      'video': 'On a video call',
      'priorAcquaintance': 'People I already know',
      'other': '$method',
    });
    return '$_temp0';
  }

  @override
  String get vtcVetterProfileDocumentsHeading => 'Documents you accept';

  @override
  String get vtcVetterProfileNoDocument => 'None: I know the person';

  @override
  String get vtcVetterProfilePublish => 'Publish';

  @override
  String vtcVetterProfileInvalid(String reason) {
    return 'The community would refuse this profile ($reason).';
  }

  @override
  String get vtcVetterProfileNeeded =>
      'Applicants can\'t find you yet. Set up your vetter profile so they know how to reach you.';

  @override
  String get vtcVetterProfileSetUp => 'Set up your vetter profile';

  @override
  String get vtcVetterUnnamed => 'Unnamed vetter';

  @override
  String vtcVetterDetailsMethods(String methods) {
    return 'How they vet: $methods';
  }

  @override
  String vtcVetterDetailsMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'inPerson': 'in person',
      'video': 'on a video call',
      'priorAcquaintance': 'people they already know',
      'other': '$method',
    });
    return '$_temp0';
  }

  @override
  String vtcVetterDetailsLanguages(String languages) {
    return 'Languages: $languages';
  }

  @override
  String vtcVetterDetailsPlace(String place) {
    return 'Where: $place';
  }

  @override
  String vtcVetterDetailsDocuments(String documents) {
    return 'Documents: $documents';
  }

  @override
  String get vtcVetterDetailsNoDocument => 'none, they know you';

  @override
  String vtcVetterDetailsAvailability(String availability) {
    return 'Available: $availability';
  }

  @override
  String vtcVetterDetailsContactHint(String hint) {
    return 'Getting a ticket: $hint';
  }

  @override
  String vtcVetterDetailsEvents(String events) {
    return 'Events: $events';
  }

  @override
  String vtcVetterDetailsDid(String did) {
    return 'DID: $did';
  }

  @override
  String get communitiesSubtitle => 'Tap a community to see its channels.';

  @override
  String get communitiesNone => 'You have not joined a community yet.';

  @override
  String get communitiesJoinHint =>
      'Scan or enter a community\'s code to join it and chat with its members.';

  @override
  String get communityPending => 'Pending';

  @override
  String get communityChannelsTab => 'Channels';

  @override
  String get communityInfoTab => 'Info';

  @override
  String get communityVettingTab => 'Vetting';

  @override
  String get communityMembershipTab => 'Membership';

  @override
  String get communityInfoUnavailable =>
      'The community\'s profile can\'t be read right now.';

  @override
  String get communityDidLabel => 'Community DID';

  @override
  String get communityMembersTab => 'Members';

  @override
  String get communityGroupsTab => 'Groups';

  @override
  String communityMembersPrompt(String community) {
    return 'Search the directory of $community to find others.';
  }
}
