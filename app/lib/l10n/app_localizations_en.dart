// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Meeting Place';

  @override
  String tabsTitle(String tabName) {
    String _temp0 = intl.Intl.selectLogic(tabName, {
      'connections': 'Invitations',
      'contacts': 'Communities',
      'identities': 'Identities',
      'rCards': 'R-Cards',
      'credentials': 'Credentials',
      'settings': 'Settings',
      'other': 'Invalid',
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
  String get rCardsPlaceholderMessage => 'R-Cards will appear here.';

  @override
  String get publishOffer => 'Publish Invitation';

  @override
  String get publishGroupOffer => 'Publish Group Invitation';

  @override
  String get meetingPlaceBannerText =>
      'Meeting Place allows you to anonymously and privately publish an invitation to connect to you. Provide a headline and description, as well as validity details to limit how long the offer is available.';

  @override
  String get connectionOfferDetails => 'Invitation Details';

  @override
  String get createGroupChatOffer => 'Group chat';

  @override
  String get chatTransport => 'Chat transport';

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
      'The invitation will represent a group chat for multiple contacts to join and chat. You still have control over who can join the group chat.';

  @override
  String get generateRandomPhraseHelperEnabled => 'Generate a random phrase';

  @override
  String get generateRandomPhraseHelperDisabled =>
      'The custom phrase you enter will be used to uniquely identify this invitation to connect. It must be unique in the Meeting Place universe.';

  @override
  String get customPhrase => 'Custom Phrase';

  @override
  String get enterCustomPhrase => 'Enter custom phrase';

  @override
  String get customPhraseHelperText =>
      'Enter a unique custom phrase. You may use as many words as you like, separated by spaces.';

  @override
  String get chatGroupName => 'Chat group name';

  @override
  String get headline => 'Headline';

  @override
  String get description => 'Description';

  @override
  String get validityVisibilitySettings => 'Validity & Visibility Settings';

  @override
  String get searchableAtMeetingPlace => 'Searchable at meetingplace.world';

  @override
  String get searchableHelperText =>
      'When selected, the details you share in this offer will be publicly searchable at meetingplace.world';

  @override
  String get setExpiry => 'Set Expiry';

  @override
  String get setExpiryHelperEnabled =>
      'The invitation will expire at the specified date and time';

  @override
  String get setExpiryHelperDisabled =>
      'The invitation will remain valid until deleted and will not expire';

  @override
  String expiresAt(String date, String time) {
    return 'Expires: $date at $time';
  }

  @override
  String get scanCustomMediatorQrCode => 'Scan custom message server QR code';

  @override
  String get chooseMediatorHelper =>
      'Choose which message server to use for your connections. You can add custom message servers by scanning their QR code.';

  @override
  String get setMediatorName => 'Set message server name';

  @override
  String newConnectionOptionTitle(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'shareQRCode': 'Direct share QR Code',
      'scanQRCode': 'Direct scan a QR Code',
      'claimAnOffer': 'Accept Meeting Place Invitation',
      'publishAnOffer': 'Publish Meeting Place Invitation',
      'prove': 'Prove',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get setExpiryDateTime => 'Set expiry date and time';

  @override
  String get selectExpiryHelperText => 'Select when this offer should expire';

  @override
  String get changeButton => 'Change';

  @override
  String get limitNumberOfUses => 'Limit number of uses';

  @override
  String get limitUsesHelperEnabled =>
      'The invitation can only be used this many times';

  @override
  String get limitUsesHelperDisabled =>
      'The invitation can be used an unlimited number of times';

  @override
  String canBeUsedTimes(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Can be used $amount times',
      one: 'Can be used only once',
    );
    return '$_temp0';
  }

  @override
  String newConnectionOptionSubtitle(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'shareQRCode': 'Gives you complete privacy and confidentiality',
      'scanQRCode': 'Scan a QR Code with your camera',
      'claimAnOffer': 'Connect with someone through Meeting Place',
      'publishAnOffer': 'Advertise your invitation to connect on Meeting Place',
      'prove': 'Zero-knowledge proof verification',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get unableToDetectCamera => 'Unable to detect a camera';

  @override
  String get newConnectionsOptionsHeader =>
      'Select an option to create a new connection';

  @override
  String get oobQrPresentInvitationMessage =>
      'Show this QR code with someone to establish a connection';

  @override
  String get connectionsNowConnected => 'You are now connected with';

  @override
  String get connectionsPanelOobFailedTitle => 'Channel creation failed';

  @override
  String get connectionsPanelOobFailedBody =>
      'Unable to establish the connection. Please try again.';

  @override
  String connectionsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'All',
      'offers': 'Offers',
      'claims': 'Claims',
      'complete': 'Complete',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noConnections => 'No invitations in this view';

  @override
  String connectionDeleteHeading(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Delete invitations',
      one: 'Delete invitation',
    );
    return '$_temp0';
  }

  @override
  String get selectMaxUsagesHelperText =>
      'Select how many times this offer can be used';

  @override
  String get mediator => 'Message Server';

  @override
  String get mediatorHelperText =>
      'This is the message server that will be used for communication with any contact that connects via this invitation';

  @override
  String get errorLoadingMediator => 'Error loading message server';

  @override
  String get publishToMeetingPlace => 'Publish to Meeting Place';

  @override
  String connectWithFirstName(String firstName) {
    return 'Connect with $firstName!';
  }

  @override
  String firstNameChatGroup(String firstName) {
    return '$firstName\'s chat group';
  }

  @override
  String get passphraseDescription => 'Connect with me using Meeting Place!';

  @override
  String get headlineRequired => 'Headline is required';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get customPhraseRequired =>
      'Custom phrase is required when not using random phrase';

  @override
  String get expiryDateRequired =>
      'Expiry date is required when expiry is enabled';

  @override
  String get expiryDateFuture => 'Expiry date must be in the future';

  @override
  String get maxUsagesGreaterThanZero => 'Max usages must be greater than 0';

  @override
  String failedToPublishOffer(String error) {
    return 'Failed to publish invitation: $error';
  }

  @override
  String get selectMediator => 'Select Message Server';

  @override
  String connectionDeletePrompt(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other:
          'Are you sure you want to delete $amount selected invitations? You cannot undelete invitations!',
      one:
          'Are you sure you want to delete this invitation? You cannot undelete an invitation!',
      zero:
          'Are you sure you want to delete this invitation? You cannot undelete an invitation!',
    );
    return '$_temp0';
  }

  @override
  String get generalCancel => 'Cancel';

  @override
  String get generalDelete => 'Delete';

  @override
  String get generalSave => 'Save';

  @override
  String get generalDone => 'Done';

  @override
  String get connectionsPanelSubtitle =>
      'Swipe and tap to manage your invitations.';

  @override
  String get findPersonAiBusinessDescription =>
      'To connect with a person or AI Agent on Meeting Place, enter the connection phrase they have shared with you.';

  @override
  String get enterPassphrase => 'Enter passphrase';

  @override
  String get claimOfferTitle => 'Find an invitation on Meeting Place';

  @override
  String get generalSearch => 'Search';

  @override
  String get generalConnect => 'Connect';

  @override
  String contactCardFieldName(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'firstName': 'First name',
      'lastName': 'Last name',
      'email': 'Email',
      'mobile': 'Mobile',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get offerDetailsHeader => 'My Invitation Information';

  @override
  String get acceptOfferTitle => 'Invitation Request Details';

  @override
  String get offerDetailsDescription => 'Connect with me using Meeting Place!';

  @override
  String get errorOwnerCannotClaimOffer =>
      'You cannot claim this invitation because you are the owner';

  @override
  String get aliasPickerTitle => 'Connect using this selected identity';

  @override
  String get aliasPickerDescription =>
      'Identities help you keep your personal information private and in your control. You can choose to use the Primary Identity alias you have configured, or select one of your additional identity aliases for this invitation.';

  @override
  String error(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(errorCode, {
      'connection_offer_owned_by_claiming_party':
          'You cannot accept this invitation because you are the inviter!',
      'connection_offer_already_claimed_by_claiming_party':
          'You cannot accept this invitation because you already requested to connect and have an outstanding claim in progress',
      'missingMnemonic': 'Please enter an invitation passphrase to search',
      'vtaSigningUnavailable':
          'Your VTA couldn\'t be reached to sign this. Check it\'s online and try again.',
      'vtaNotLinked': 'Link your VTA to sign this.',
      'connection_offer_not_found_error':
          'The details you provided did not match any active invitations.',
      'discovery_register_offer_group_generic': 'Failed to publish invitation.',
      'missingDeviceToken': 'Unable to find device notification token',
      'offerOwnedByClaimingParty':
          'You cannot claim this invitation because you are the owner',
      'offerAlreadyClaimedByParty':
          'You cannot claim this offer because you already accepted the invitation and have an outstanding request in progress',
      'offerNotFound':
          'The details you provided did not match any active invitations.',
      'mediatorAlreadyExists':
          'Message server with the same DID already exists.',
      'mediator_get_did_error': 'No message server found at the provided URL',
      'unableToFindMediator': 'No message server found at the provided URL',
      'oobFlowTimedOut':
          'Unable to establish a connection with other party, QR code was likely already used',
      'connection_offer_expired': 'This invitation has expired',
      'connection_offer_limit_exceeded':
          'This invitation has reached its maximum number of uses',
      'register_offer_mnemonic_in_use':
          'This phrase is already in use, please choose another one',
      'invalidQrCode': 'QR-Code is not valid',
      'oob_invalid_data': 'QR-Code data is not valid',
      'oob_not_found': 'QR-Code data does not match any active invitation',
      'oob_invalid_type': 'QR-Code data not supported',
      'network_error':
          'Could not connect. Check your internet connection and try again.',
      'deleteContactFailed': 'Failed to delete contact.',
      'other': '$errorCode',
    });
    return '$_temp0';
  }

  @override
  String get offerCreated => 'Invitation Created';

  @override
  String offerExpiresAt(String formattedExpiry) {
    return 'Invitation expires at $formattedExpiry';
  }

  @override
  String get offerValidityNote =>
      'The invitation is valid until the date and time above, unless a maximum number of accesses is reached';

  @override
  String get offerUnlimitedUsages =>
      'This invitation can be used any number of times';

  @override
  String offerMaxUsages(int maxUsages) {
    String _temp0 = intl.Intl.pluralLogic(
      maxUsages,
      locale: localeName,
      other: 'This invitation can be used $maxUsages times',
      one: 'This invitation can be used 1 time',
    );
    return '$_temp0';
  }

  @override
  String get noExpirySetHelperText =>
      'No expiry date was set, so this invitation to connect does not expire';

  @override
  String get validityVisibilityDetails => 'Validity & visibility details';

  @override
  String get personalInformationShared => 'Personal information shared';

  @override
  String get myAliasProfile => 'My Alias Profile';

  @override
  String get didInformation => 'DID Information';

  @override
  String didSha256(String didSha256) {
    return '$didSha256 (SHA256)';
  }

  @override
  String get offerUsesPrimaryIdentity =>
      'This invitation uses your Primary Identity';

  @override
  String offerUsesAliasIdentity(String alias) {
    return 'This invitation uses the identity alias named \"$alias\"';
  }

  @override
  String get aliasProfileDescription =>
      'Your alias profile helps you keep your identity private and in your control.';

  @override
  String get generalOk => 'Ok';

  @override
  String get noContactsYet => 'No channels in this view';

  @override
  String get contactDeleteHeading => 'Delete channel';

  @override
  String contactDeletePrompt(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Are you sure you want to delete $amount selected channels?',
      one: 'Are you sure you want to delete this channel?',
      zero: 'Are you sure you want to delete this channel?',
    );
    return '$_temp0';
  }

  @override
  String connectedVia(String mediatorName) {
    return 'Connected via $mediatorName';
  }

  @override
  String contactAdded(String dateAdded) {
    return 'Added $dateAdded';
  }

  @override
  String get filter => 'Filter...';

  @override
  String get noContactsMatchFilter => 'No channels match your filter';

  @override
  String connectionPhrase(String phrase) {
    return 'Phrase: $phrase';
  }

  @override
  String usesIdentityViaMediator(String identity, String mediator) {
    return 'Uses your $identity identity via $mediator';
  }

  @override
  String usesIdentity(String identity) {
    return 'Uses your $identity identity to connect';
  }

  @override
  String get timeAgoJustNow => 'just now';

  @override
  String timeAgoMinute(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoMinuteWorded => 'a minute ago';

  @override
  String timeAgoHourNumeric(num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoHourWorded => 'an hour ago';

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
  String get timeAgoYesterday => 'Yesterday';

  @override
  String timeAgoWeek(num weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoLastWeek => 'Last week';

  @override
  String timeAgoSecond(num seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds ago',
      one: '1 second ago',
    );
    return '$_temp0';
  }

  @override
  String createdValidUntil(String createdTimeAgo, String validUntilDate) {
    return 'Created $createdTimeAgo, valid until $validUntilDate';
  }

  @override
  String createdValidWithoutExpiration(String createdTimeAgo) {
    return 'Created $createdTimeAgo, with no expiry date';
  }

  @override
  String get displayName => 'Display Name';

  @override
  String get generalName => 'Name';

  @override
  String get displayNameHelperText =>
      'You can change the display name for this channel. The other party will not see what you call it.';

  @override
  String get generalDid => 'DID';

  @override
  String get generalDidSha256 => 'DID (SHA256)';

  @override
  String get connectionEstablished => 'Channel established';

  @override
  String get generalMediator => 'Message Server';

  @override
  String get connectionApproach => 'Channel establishment approach';

  @override
  String get theirDetails => 'Their Details';

  @override
  String get mySharedIdentityDetails => 'My shared identity details';

  @override
  String get connectionDetails => 'Channel connection details';

  @override
  String get myIdentity => 'My identity';

  @override
  String get identitiesPanelSubtitle =>
      'Swipe left and right to review and add to your identities list, drag down to delete';

  @override
  String identitiesFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'All',
      'primary': 'Primary',
      'aliases': 'Aliases',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get identityDeleteHeading => 'Delete identity';

  @override
  String identityDeletePrompt(Object identity) {
    return 'Are you sure you want to delete identity \"$identity\"?\n\nYou cannot undelete an identity!';
  }

  @override
  String get displayNamePrimary => 'Primary Identity';

  @override
  String get displayNameAddNew => 'Add new identity';

  @override
  String get displayNameAlias => 'Identity Alias';

  @override
  String get subtitlePrimary => 'Your Primary Identity';

  @override
  String get subtitleAddNew => 'Create a new alias';

  @override
  String get subtitleAlias => 'Alias identity';

  @override
  String get notShared => 'Not shared';

  @override
  String get unknownUser => 'Unknown user';

  @override
  String get unnamed => 'Unnnamed';

  @override
  String get unnamedMediator => 'Unknown user';

  @override
  String get addNewIdentityAlias => 'Add new identity alias';

  @override
  String get identityAliasesDescription =>
      'Take control of your privacy, by creating identity aliases to represent yourself to contacts you connect with';

  @override
  String get generalReject => 'Reject';

  @override
  String get generalApprove => 'Approve';

  @override
  String get zalgoTextDetectedError =>
      'Unusual characters detected. Please remove them and try again.';

  @override
  String get chatTooLong => 'The chat message is too long';

  @override
  String get splashScreenTitle => 'Meeting Place';

  @override
  String get toProtectData =>
      'To protect your data, this application requires secure authentication to continue.';

  @override
  String get authInstructionAndroid =>
      'Go to Settings > Security > Screen lock and enable a PIN, pattern, or fingerprint.';

  @override
  String get authInstructionIos =>
      'Go to Settings > Face ID & Passcode (or Touch ID & Passcode) and set up Face ID, Touch ID, or a device passcode.';

  @override
  String get authInstructionMacos =>
      'Go to System Settings > Touch ID & Password (or Login Password) and set up Touch ID or a secure password.';

  @override
  String get authUnlockReason => 'Please unlock your device to continue';

  @override
  String chatTypeMessagePrompt(String name) {
    return 'Message to $name';
  }

  @override
  String get chatAddMessageToMediaPrompt => 'Add a message';

  @override
  String get chatTypeMessagePromptGroup => 'Message to the channel';

  @override
  String get updatePrimaryIdentity => 'Update Primary Identity';

  @override
  String get newIdentityAlias => 'New identity alias';

  @override
  String editIdentityTitle(String identityName) {
    return 'Edit identity: $identityName';
  }

  @override
  String get customiseIdentityCard => 'Customise identity card';

  @override
  String get nameTooLong => 'The name is too long';

  @override
  String get descriptionTooLong => 'The description is too long';

  @override
  String get invalidEmail => 'The email address is invalid';

  @override
  String get emailTooLong => 'The email address is too long';

  @override
  String get invalidMobileNumber => 'The mobile number is invalid';

  @override
  String get mobileTooLong => 'The mobile number is too long';

  @override
  String get aliasTooLong => 'The alias is too long';

  @override
  String get thisFieldIsRequired => 'This field is required';

  @override
  String get identityAliasPersonalDetails => 'Identity alias personal details';

  @override
  String get profilePictureChangePrompt =>
      'Tap here to change your profile picture';

  @override
  String get enterFirstName => 'Enter first name';

  @override
  String get enterLastName => 'Enter last name';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get enterMobile => 'Enter mobile';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get aliasLabel => 'Alias label';

  @override
  String get enterAliasLabel => 'Enter alias label';

  @override
  String get aliasLabelHelperText =>
      'The alias label is how you will refer to this alias when connecting. Use a descriptive name to make it easier to identify.';

  @override
  String get setupPrimaryIdentityTitle => 'Let\'s setup your Primary Identity!';

  @override
  String get setupPrimaryIdentityDescription =>
      'Your Primary Identity will be used by default when you connect with others.';

  @override
  String get primaryIdentityInformation => 'Your Primary Identity information';

  @override
  String get primaryIdentityComplete => 'My Primary Identity is complete';

  @override
  String get keepMeAnonymous => 'Keep me anonymous';

  @override
  String typingMessage(String names, int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$names are typing',
      one: '$names is typing',
    );
    return '$_temp0';
  }

  @override
  String awaitingMembersToJoin(String names, int namesCount, int othersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      othersCount,
      locale: localeName,
      other: '$othersCount others',
      one: '1 other',
    );
    String _temp1 = intl.Intl.pluralLogic(
      namesCount,
      locale: localeName,
      other: 'Awaiting $names and $_temp0 to join',
      one: 'Awaiting $names to join',
    );
    return '$_temp1';
  }

  @override
  String get unknownType => 'Unknown type';

  @override
  String get loadImageFailed => 'Failed to load image';

  @override
  String get chatRequestPermissionToJoinGroupFailed => 'Failed to join group';

  @override
  String get genWordConciergeMessage => 'Concierge message';

  @override
  String chatRequestPermissionToJoinGroup(String memberName) {
    return '$memberName wants to join the group';
  }

  @override
  String get chatEncryptionNotice =>
      'Messages and any data shared in this chat are end-to-end encrypted. Only people and agents in this chat can read them.';

  @override
  String get genWordNo => 'No';

  @override
  String get genWordLater => 'Later';

  @override
  String get genWordYes => 'Yes';

  @override
  String get chatRequestPermissionToUpdateProfileGroup =>
      'The profile details shared with this group have changed. Would you like to update all members?';

  @override
  String get chatRequestPermissionToUpdateProfile =>
      'The profile details shared with this contact have changed. Would you like to send them an update?';

  @override
  String chatStartOfConversationInitiatedByMe(String date, String time) {
    return 'You established this channel on $date at $time';
  }

  @override
  String get messageCopiedClipboard => 'Message copied to clipboard';

  @override
  String get chatMessageActionDelete => 'Delete for everyone';

  @override
  String get chatMessageActionDeleteLocal => 'Delete for me';

  @override
  String get chatMessageActionCopy => 'Copy message';

  @override
  String get chatMessageActionEdit => 'Edit message';

  @override
  String get chatMessageEditedLabel => 'edited';

  @override
  String get chatMessageEditFailed => 'Could not edit message';

  @override
  String get chatMessageEditHint => 'Message text';

  @override
  String get chatMessageEditSave => 'Save';

  @override
  String get chatMessageDeletedTombstone => 'This message was deleted';

  @override
  String get chatMessageDeletedLocallyTombstone => 'You deleted this message';

  @override
  String get chatMessageDeleteFailed => 'Could not delete message';

  @override
  String chatItemStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'queued': 'Queued',
      'delivered': 'Delivered',
      'sending': 'Sending',
      'sent': 'Sent',
      'error': 'Error',
      'groupDeleted': 'Group deleted',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get qrScannerTitle => 'Scan QR Code';

  @override
  String get qrScannerInstructions => 'Position the QR code within the frame';

  @override
  String qrScannerStatus(String status) {
    return 'Scanner Status: $status';
  }

  @override
  String get useCamera => 'Use Camera';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get qrScannerCameraPermissionHelp =>
      'Please check camera permissions and try again';

  @override
  String get qrScannerConnectionFailed => 'Connection Failed';

  @override
  String qrScannerConnectionFailedMessage(String error) {
    return 'Failed to establish connection: $error';
  }

  @override
  String get qrScannerTryAgain => 'Try Again';

  @override
  String get qrScannerTimeoutError =>
      'OOB flow acceptance timed out after 30 seconds';

  @override
  String get customMediators => 'Custom Message Servers';

  @override
  String get addCustomMediator => 'Add Custom Message Server';

  @override
  String get manageCustomMediators => 'Manage Custom Message Server';

  @override
  String get configureCustomMediatorEndpoint =>
      'Configure your own message server endpoint';

  @override
  String get noCustomMediatorsConfigured =>
      'No custom message servers configured yet';

  @override
  String customMediatorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count custom message servers configured',
      one: '1 custom message server configured',
    );
    return '$_temp0';
  }

  @override
  String addedMediatorSuccess(String name) {
    return 'Added message server \"$name\"';
  }

  @override
  String failedToAddMediator(String error) {
    return 'Failed to add message server: $error';
  }

  @override
  String get mediatorName => 'Message Server Name';

  @override
  String get mediatorDid => 'Message Server DID';

  @override
  String get myCustomMediator => 'My Custom Message Server';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get pleaseEnterDid => 'Please enter a DID';

  @override
  String get didMustStartWith => 'DID must start with \"did:\"';

  @override
  String get deleteCustomMediator => 'Delete Custom Message Server';

  @override
  String deleteCustomMediatorConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?\n\nThis action cannot be undone.';
  }

  @override
  String deletedMediatorSuccess(String name) {
    return 'Deleted message server \"$name\"';
  }

  @override
  String renamedMediatorSuccess(String name) {
    return 'Renamed message server to \"$name\"';
  }

  @override
  String failedToDeleteMediator(String error) {
    return 'Failed to delete message server: $error';
  }

  @override
  String failedToRenameMediator(String error) {
    return 'Failed to rename message server: $error';
  }

  @override
  String get generalRetry => 'Retry';

  @override
  String get generalClose => 'Close';

  @override
  String get generalAdd => 'Add';

  @override
  String get noIdentityDetected =>
      'No identity detected, please create one to continue.';

  @override
  String get connectWithPersonAiServiceBusiness =>
      'Connect with a Person or AI Agent';

  @override
  String get chatScreenTapForMemberDetails => 'Tap for member details';

  @override
  String get debugPanelTitle => 'Debug Panel';

  @override
  String get debugPanelSubtitle =>
      'View application logs and debug information';

  @override
  String get debugPanelNoLogs => 'No logs available';

  @override
  String get debugPanelLogsAppearMessage =>
      'Logs will appear here as you use the app';

  @override
  String get debugPanelClearLogs => 'Clear logs';

  @override
  String get debugPanelCopyLogs => 'Copy logs to clipboard';

  @override
  String get debugPanelAddTestLog => 'Add test log';

  @override
  String get debugPanelLogsCopied => 'Logs copied to clipboard';

  @override
  String get debugPanelShareLogs => 'Share logs';

  @override
  String get serverSettings => 'Server Settings';

  @override
  String get serverSettingsHelperText =>
      'Select the default server for messaging communication';

  @override
  String get debugSettingsTitle => 'Debug Settings';

  @override
  String get debugModeLabel => 'Debug Mode';

  @override
  String debugModeHelperText(int tapCount) {
    return 'Debug mode is enabled. Tap version info $tapCount times to toggle.';
  }

  @override
  String get settingsScreenSubtitle =>
      'Configure your app settings and preferences';

  @override
  String get versionInfoHeader => 'Application Version Info';

  @override
  String versionInfoVersion(String version) {
    return 'Version $version';
  }

  @override
  String versionInfoBuild(String buildNumber) {
    return 'Build: $buildNumber';
  }

  @override
  String get easterEggEnabled => '🎉 Easter egg unlocked! Debug mode enabled';

  @override
  String get debugModeDisabled => 'Debug mode disabled';

  @override
  String get generalCamera => 'Camera';

  @override
  String get switchCamera => 'Switch camera';

  @override
  String get generalPhoto => 'Photo';

  @override
  String get generalBalloons => 'Balloons';

  @override
  String get generalConfetti => 'Confetti';

  @override
  String get chatItemStatusError => 'Error';

  @override
  String get formValidationHeadlineRequired => 'Headline is required';

  @override
  String get formValidationDescriptionRequired => 'Description is required';

  @override
  String get formValidationCustomPhraseRequired =>
      'Custom phrase is required when not using random phrase';

  @override
  String get formValidationExpiryDateRequired =>
      'Expiry date is required when expiry is enabled';

  @override
  String get formValidationExpiryDateFuture =>
      'Expiry date must be in the future';

  @override
  String get formValidationMaxUsagesGreaterThanZero =>
      'Max usages must be greater than 0';

  @override
  String get genericPublishError => 'Failed to publish offer';

  @override
  String get groupDetails => 'Group Channel Details';

  @override
  String groupMessageInfo(String memberName, String date, String time) {
    return '$memberName on $date at $time';
  }

  @override
  String contactStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pendingApproval': 'Pending Approval',
      'pendingInauguration': 'Establishing Connection',
      'approved': 'Active Contact',
      'rejected': 'Rejected',
      'error': 'Error',
      'deleted': 'Deleted',
      'active': 'Active Channel',
      'unknown': 'Unknown',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String groupContactStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pendingApproval': 'Pending Approval',
      'pendingInauguration': 'Establishing Channel',
      'approved': 'Active Group Channel',
      'rejected': 'Rejected',
      'error': 'Error',
      'deleted': 'Deleted',
      'active': 'Active Group Channel',
      'unknown': 'Unknown',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String contactOrigin(String origin) {
    String _temp0 = intl.Intl.selectLogic(origin, {
      'directInteractive': 'Direct Interactive',
      'individualOfferPublished': 'Meeting Place Invitation Offered',
      'individualOfferRequested': 'Meeting Place Invitation Accepted',
      'groupOfferPublished': 'Meeting Place Group invitation Offered',
      'groupOfferRequested': 'Meeting Place Group Invitation Accepted',
      'unknown': 'Unknown',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get groupMembers => 'Group Members';

  @override
  String get showExited => 'Show exited';

  @override
  String get groupMemberExited => 'Exited from the group';

  @override
  String get groupNoMembersToChat =>
      'You are currently the only member of this group. You can start chatting when another member joins.';

  @override
  String get generalJoined => 'Joined';

  @override
  String get you => 'You';

  @override
  String get groupAdmin => 'Group Admin';

  @override
  String get onboardingPage1Title => 'Welcome to\nMeeting Place';

  @override
  String get onboardingPage1Desc => 'Powered by\nAffinidi Meeting Place SDK';

  @override
  String get onboardingPage2Title => 'Private & Secure';

  @override
  String get onboardingPage2Desc =>
      'Connect with others securely and privately with end-to-end encryption';

  @override
  String get onboardingPage3Title => 'Take control of your identity';

  @override
  String get onboardingPage3Desc =>
      'Protect your privacy with aliases. Prove your identity with verified credentials';

  @override
  String get onboardingPage4Title => 'Ready to Begin';

  @override
  String get onboardingPage4Desc =>
      'Let\'s set up your identity\nand get you started!';

  @override
  String get setUpMyIdentity => 'Setup my identity';

  @override
  String get revealConnectionCode => 'Reveal invitation passphrase';

  @override
  String versionInfoAppName(String appName) {
    return 'Meeting Place \"$appName\"';
  }

  @override
  String get platformNotSupported =>
      'This plugin is not supported on your current platform';

  @override
  String get generalOfferInformation => 'Invitation Information';

  @override
  String get generalOfferLink => 'Invitation Link';

  @override
  String get generalMnemonic => 'Mnemonic';

  @override
  String get generalConnectionType => 'Connection type';

  @override
  String get generalExternalRef => 'External Reference';

  @override
  String get generalGroupDid => 'Group DID';

  @override
  String get generalGroupId => 'Group Id';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String connectionStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'published': 'Created',
      'finalised': 'Completed',
      'accepted': 'Waiting',
      'channelInaugurated': 'Active',
      'deleted': 'Deleted',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get publishing => 'Publishing';

  @override
  String get loading => 'Loading';

  @override
  String get deleting => 'Deleting';

  @override
  String get showQrScannerForOffers => 'Show QR scanner for Invitations';

  @override
  String get meetingPlaceControlPlane => 'Meeting Place Control Plane';

  @override
  String get searching => 'Searching';

  @override
  String get connecting => 'Connecting';

  @override
  String get approving => 'Approving';

  @override
  String get rejecting => 'Rejecting';

  @override
  String get sending => 'Sending';

  @override
  String get connectionRequestRejected =>
      'The request to connect has been rejected';

  @override
  String get connectionRequestInProgress =>
      'Invitation acceptance in progress. It may take a few moments for the other party to respond and finalise the channel.';

  @override
  String requestToConnect(Object firstName) {
    return 'Invitation acceptance has been sent $firstName. It may take a few moments for them to respond to your request.';
  }

  @override
  String contactsDeleted(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Channels deleted',
      one: 'Channel deleted',
    );
    return '$_temp0';
  }

  @override
  String joiningGroup(String memberName) {
    return '$memberName has joined the group';
  }

  @override
  String leavingGroup(String memberName) {
    return '$memberName has left the group';
  }

  @override
  String memberRemovedFromGroup(String memberName) {
    return '$memberName has been removed';
  }

  @override
  String get concierge => 'Concierge';

  @override
  String get groupDeleted => 'This group has been deleted';

  @override
  String get creatingConnection => 'Creating connection...';

  @override
  String get generatingQrCode => 'Generating your QR code';

  @override
  String get processing => 'Processing...';

  @override
  String oobConnectedTo(String memberName) {
    return 'You are now connected to $memberName!';
  }

  @override
  String get oobChatTo => 'Chat';

  @override
  String get networkDisconnected => 'You are not connected to the network';

  @override
  String get chatNotificationsUnavailable =>
      'Push notifications aren\'t supported for chats started by scanning or sharing a QR code.';

  @override
  String get chatNotificationsUnavailableNotShared =>
      'Notifications for this chat channel are not available';

  @override
  String get chatNotificationsWhyTitle => 'Why no push notifications?';

  @override
  String get chatNotificationsWhyDescription =>
      'When you establish a connection by direct scanning or sharing a QR code, your devices connect directly without exchanging notification tokens with our servers. This means push notifications can\'t be sent when the chat is closed.';

  @override
  String get chatNotificationsWhyNote =>
      'You\'ll only see new messages when you\'re in the chat. There will be no badge updates or notifications informing you that new messages have arrived, even if the app is open.';

  @override
  String get chatNotificationsWhyButton => 'Got it';

  @override
  String get chatNotificationsWhyLink => 'Why?';

  @override
  String get meetingPlaceInvitationTitle => 'Meeting Place Invitation';

  @override
  String get shareSheetCTA_QRCode => 'Send or save QR code';

  @override
  String get cameraInstructionAndroid =>
      'Tap \"Open Settings\" below to enable camera access. If that doesn\'t work, open Settings manually:\n\nSettings > Apps > Meeting Place > Permissions > Camera > Allow only while using the app.';

  @override
  String get cameraInstructionIos =>
      'Tap \"Open Settings\" below to enable camera access. If that doesn\'t work, open Settings manually:\n\nSettings > Meeting Place > Camera and enable access for this app.';

  @override
  String get cameraInstructionMacos =>
      'Go to System Settings > Privacy & Security > Camera and allow camera access for this app.';

  @override
  String get cameraAccessDenied => 'Camera access denied or unavailable.';

  @override
  String get cameraOpenSettings => 'Open Settings';

  @override
  String get cameraNotAvailable => 'Camera not available';

  @override
  String get goBack => 'Go Back';

  @override
  String get rCardsPanelSubtitle =>
      'Relationship cards received from your contacts';

  @override
  String get rCardsEmpty =>
      'R-Cards are a modern self-updating version of vCards. Once you make your first connection, your digital business cards will appear here.';

  @override
  String rCardsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'All',
      'nonAnonymous': 'Non-anonymous',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noRCardsFoundWithFilter =>
      'No R-Cards found matching your search.';

  @override
  String get rCardDetailsTitle => 'R-Card Details';

  @override
  String get rCardSectionIdentity => 'Identity';

  @override
  String get rCardSectionMetadata => 'Credential Details';

  @override
  String get rCardFieldName => 'Name';

  @override
  String get rCardFieldEmail => 'Email';

  @override
  String get rCardFieldPhone => 'Phone';

  @override
  String get rCardFieldCompany => 'Company';

  @override
  String get rCardFieldPosition => 'Position';

  @override
  String get rCardFieldWebsite => 'Website';

  @override
  String get rCardFieldSocial => 'Social';

  @override
  String get rCardFieldSubjectDid => 'Subject DID';

  @override
  String get rCardAddNotes => 'Add notes';

  @override
  String get rCardUpdateNotes => 'Update notes';

  @override
  String get rCardNotesTitle => 'Notes';

  @override
  String get rCardNotesPlaceholder => 'Write your notes here...';

  @override
  String get rCardDeletePrompt =>
      'Are you sure you want to delete this R-Card? This action cannot be undone.';

  @override
  String rCardChatWith(String name) {
    return 'Chat with $name';
  }

  @override
  String get removeMemberDialogTitle => 'Remove member';

  @override
  String removeMemberDialogBody(String name) {
    return 'Remove $name from this group? They will no longer receive messages.';
  }

  @override
  String get rCardFieldIssuerDid => 'Issuer DID';

  @override
  String get rCardFieldReceivedAt => 'Received';

  @override
  String get rCardFieldIssuedAt => 'Issued';

  @override
  String get rCardTitle => 'R-Card';

  @override
  String get verifiableCredential => 'Verifiable Credential';

  @override
  String get verified => 'Verified';

  @override
  String get verifiableCredentialDescription =>
      'Secured digital credentials that can be verified for authenticity';

  @override
  String get secureAttachmentsTitle => 'Secure Attachments';

  @override
  String get credentialDetails => 'Credential Details';

  @override
  String get genRCard => 'R-Card';

  @override
  String get rCardPickIdentitySubtitle =>
      'Select the identity to share as an R-Card';

  @override
  String get rCardFooterSent => 'R-Card has been sent.';

  @override
  String get rCardFooterSaved => 'R-Card has been saved.';

  @override
  String get rCardFooterUpdateShared => 'R-Card update has been shared.';

  @override
  String get profileDetailsUpdateSharedGroup =>
      'Profile details update has been shared with the group.';

  @override
  String get rCardFooterUpdateSaved => 'R-Card update has been saved.';

  @override
  String get rCardsExchanged => 'R-Cards have been exchanged.';

  @override
  String get goToRCard => 'Go to R-Card';

  @override
  String get selectIdentityTitle => 'Select Identity';

  @override
  String get selectIdentityInstruction =>
      'Swipe left or right to choose the identity you want to use to generate the R‑Card';

  @override
  String get sendRCard => 'Send R-Card';

  @override
  String selectIdentityToVerifyRelationshipWithName(String name) {
    return 'Select the identity that you would like to use to verify your relationship with $name.';
  }

  @override
  String get verifiableRelationshipCredential =>
      'Verifiable Relationship Credential';

  @override
  String get vrcAbbreviation => 'VRC';

  @override
  String get vrcDetailsTitle => 'Relationship Credential';

  @override
  String get vrcSectionIssuer => 'Issuer';

  @override
  String get vrcSectionHolder => 'Issued to';

  @override
  String get vrcSectionMetadata => 'Credential Details';

  @override
  String get vrcFieldDid => 'DID';

  @override
  String get vrcFieldName => 'Name';

  @override
  String get vrcFieldIssuedAt => 'Issued On';

  @override
  String get vrcFieldVerifiedAt => 'Verified';

  @override
  String get vrcFieldTypes => 'Types';

  @override
  String get vrcDescription =>
      'This credential verifies the relationship between two parties.';

  @override
  String verifyRelationshipPrompt(String firstName) {
    return 'Verify your relationship with $firstName by issuing a Verifiable Relationship Credential (VRC). Each VRC exchange increases your trust score.';
  }

  @override
  String get generateVrc => 'Start now';

  @override
  String get generalVerify => 'Confirm';

  @override
  String get doLater => 'Do later';

  @override
  String get vrcExchangeInitiated => 'You\'ve initiated the VRC exchange.';

  @override
  String vrcRequestReceived(String name) {
    return '$name has initiated the VRC exchange.';
  }

  @override
  String get vrcDoLater =>
      'VRC exchange is paused. Tap + and select \'Verifiable Relationship Credential\' to resume.';

  @override
  String get vrcExchangeCompleted =>
      'You have successfully verified your relationship';

  @override
  String vrcVerifyPrompt(String name) {
    return 'Would you like to verify your relationship with $name? Each VRC exchange increases your trust score.';
  }

  @override
  String get vrcStartNow => 'Start Now';

  @override
  String get vrcDoLaterButton => 'Do Later';

  @override
  String get vrcYesButton => 'Yes';

  @override
  String nameSelectedIdentity(String name) {
    return '$name\'s selected identity';
  }

  @override
  String selectIdentityToVerifyRelationshipPrompt(String name) {
    return 'Swipe left or right to choose the identity you want to use to verify your relationship with $name.';
  }

  @override
  String get sendVrc => 'Send Relationship Credential';

  @override
  String trustedBy(int count) {
    return 'Trusted by $count';
  }

  @override
  String get humanZkp => 'Human Zero Knowledge Proof';

  @override
  String get humanZkpAbbreviated => 'Human ZKP';

  @override
  String get humanZeroKnowledgeProof => 'Human Zero Knowledge Proof';

  @override
  String get livenessCredential => 'Liveness Credential';

  @override
  String get verifiableCredentialWallet => 'Verifiable Credential wallet';

  @override
  String get noCredentialsYet => 'You don\'t have any credentials yet.';

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
  String get all => 'All';

  @override
  String get generatingZeroKnowledgeProof =>
      'Generating Human Zero Knowledge Proof...';

  @override
  String get cancel => 'Cancel';

  @override
  String get generateCredential => 'Generate credential';

  @override
  String get generateProof => 'Generate proof';

  @override
  String get livenessCredentialRequest => 'Liveness Credential Request';

  @override
  String get livenessCheckDemoMode => 'Liveness Check (Demo Mode)';

  @override
  String get searchingForLivenessCredential =>
      'Searching for Liveness Credential...';

  @override
  String get noLivenessCredentialFound =>
      'No Liveness Credential was found.\n\nTo continue, a mock Liveness Credential will be generated locally.\nThis credential is used to demonstrate how a Human Zero Knowledge Proof (ZKP) is derived.';

  @override
  String get livenessCheckDemoModeNote =>
      'This reference app runs in demo mode and does not perform a real liveness check.';

  @override
  String get livenessCheckInProgress => 'Liveness Check in progress...';

  @override
  String get livenessCheckSimulatedFlow =>
      'This is a simulated flow for development and demonstration purposes only.';

  @override
  String get mockLivenessCredentialGenerated =>
      'A mock Liveness Credential has been generated and securely stored under the Credentials tab.';

  @override
  String get mockLivenessCredentialNext =>
      'You can now continue to generate a Human Zero Knowledge Proof.';

  @override
  String get livenessEvidenceThresholdNotMet =>
      'Liveness check did not meet the required threshold. Please try again.';

  @override
  String get livenessCredentialSessionMissing =>
      'Your liveness credential is not available in this app session. Generate a new credential and try again.';

  @override
  String get issuedTo => 'Issued to';

  @override
  String get types => 'Types';

  @override
  String get issuer => 'Issuer';

  @override
  String get issuedOn => 'Issued on';

  @override
  String get human => 'Human';

  @override
  String get proofFlowThisContact => 'this contact';

  @override
  String get proofFlowContact => 'Contact';

  @override
  String proofFlowCheckIfHuman(String contactName) {
    return 'Check if $contactName is human using a Zero‑Knowledge Proof (ZKP) derived from a Liveness Credential.';
  }

  @override
  String get proofFlowRequestProof => 'Request proof';

  @override
  String proofFlowVerifyingProof(String contactName) {
    return 'Verifying proof from $contactName...';
  }

  @override
  String proofFlowVerificationFailed(String contactName) {
    return 'Verification failed for $contactName';
  }

  @override
  String get zkpNoticePaused =>
      'You paused a Human Zero Knowledge Proof request.';

  @override
  String zkpNoticeDeclined(String contactName) {
    return '$contactName has declined the Human Zero Knowledge Proof request. Tap the \"+\" icon to restart it.';
  }

  @override
  String get zkpNoticeShared =>
      'You have shared a Zero‑Knowledge Proof confirming you are human.\n*No personal data was shared.';

  @override
  String zkpNoticeReceived(String contactName) {
    return '$contactName has shared a Zero‑Knowledge Proof confirming they are human.';
  }

  @override
  String zkpNoticeRequest(String contactName) {
    return '$contactName has requested a Human Zero Knowledge Proof to confirm you are human. You can generate the proof using an existing Liveness Credential or complete a quick liveness check.';
  }

  @override
  String get zkpNoticeRequestInitiated =>
      'You have initiated a Human Zero Knowledge Proof request.';

  @override
  String get zkpProofAlreadyShared => 'ZKP Proof already shared';

  @override
  String get removeMemberConfirm => 'Remove';

  @override
  String get removeMemberNotSupported =>
      'Removing members isn\'t supported yet.';

  @override
  String get removeMemberSuccess => 'Member removed from group.';

  @override
  String get generalVideo => 'Video';

  @override
  String get generalVoice => 'Voice';

  @override
  String get generalDocument => 'Document';

  @override
  String get documentTapToDownload => 'Tap to download';

  @override
  String get videoLoadingError => 'Unable to play video';

  @override
  String get mediaTapToRetry => 'Tap to retry';

  @override
  String get mediaDownloadFailedTapToRetry => 'Download failed. Tap to retry';

  @override
  String attachmentTooLarge(int maxMb) {
    return 'Attachment is too large. Maximum size is $maxMb MB.';
  }

  @override
  String get unsupportedFileType => 'Unsupported file type.';

  @override
  String get voiceMessagePermissionDenied =>
      'Microphone permission is required to record voice messages.';

  @override
  String get voiceMessageRecordingFailed => 'Unable to start voice recording.';

  @override
  String get voiceMessageSendFailed => 'Unable to send voice message.';

  @override
  String get generalEmail => 'Email';

  @override
  String vrcResponderIntro(Object name) {
    return '$name has selected the following persona to verify the relationship:';
  }

  @override
  String get videoCallTitle => 'Call';

  @override
  String get videoCallJoiningCall => 'Joining call...';

  @override
  String get videoCallWaitingForParticipants => 'Waiting for participants...';

  @override
  String videoCallShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count more',
      one: 'Show 1 more',
    );
    return '$_temp0';
  }

  @override
  String get videoCallShowLess => 'Show less';

  @override
  String videoCallError(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(errorCode, {
      'channelNotFound': 'Call channel not found',
      'tokenFetchFailed': 'Failed to get call credentials',
      'connectionFailed':
          'Failed to connect to the call. Check room access or try again.',
      'groupCallPermissionDenied':
          'You do not have permission to join this group call. Check room access or ask a group admin.',
      'callInviteFailed': 'Failed to notify other participants about the call',
      'networkError': 'Network error',
      'unexpected': 'Unexpected call error',
      'other': 'Unknown error',
    });
    return '$_temp0';
  }

  @override
  String get videoCallMicToggleFailed =>
      'Couldn\'t change the microphone. Please try again.';

  @override
  String get videoCallCameraToggleFailed =>
      'Couldn\'t change the camera. Please try again.';

  @override
  String get videoCallSpeakerToggleFailed =>
      'Couldn\'t change the speaker. Please try again.';

  @override
  String get videoCallMemberNamesFailed => 'Couldn\'t load participant names.';

  @override
  String get videoCallHangUpFailed => 'Couldn\'t hang up. Please try again.';

  @override
  String videoCallParticipantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String get videoCallMute => 'Mute';

  @override
  String get videoCallUnmute => 'Unmute';

  @override
  String get videoCallEnd => 'End';

  @override
  String get videoCallMicPermissionDenied =>
      'Microphone permission denied. Enable it in Settings.';

  @override
  String get videoCallCameraPermissionDenied =>
      'Camera permission denied. Enable it in Settings.';

  @override
  String get videoCallWaitingForEncryption => 'Setting up encryption...';

  @override
  String get videoCallYou => 'You';

  @override
  String get videoCallRinging => 'Ringing';

  @override
  String get videoCallCalling => 'Calling...';

  @override
  String get videoCallCancelCall => 'Cancel';

  @override
  String get videoCallNoAnswer => 'No answer';

  @override
  String get videoCallCallDeclined => 'Call declined';

  @override
  String get videoCallCallFailed => 'Call failed';

  @override
  String get videoCallCallEnded => 'Call ended';

  @override
  String get videoCallCancel => 'Cancel';

  @override
  String get videoCallAgain => 'Call again';

  @override
  String get videoCallGroupCallJoin => 'Join';

  @override
  String get videoCallGroupCallActive => 'Group call in progress';

  @override
  String videoCallOngoingCall(int count) {
    return 'Ongoing call ($count)';
  }

  @override
  String get videoCallSwitch => 'Switch to video';

  @override
  String get videoCallSwitchToVideoTitle => 'Switch to video call';

  @override
  String incomingCallBannerIsCalling(String callerName) {
    return '$callerName is calling';
  }

  @override
  String get incomingCallBannerAccept => 'Accept';

  @override
  String get incomingCallBannerDecline => 'Decline';

  @override
  String get incomingCallBannerUnknownCaller => 'Unknown caller';

  @override
  String get incomingCallBannerAudioCall => 'MeetingPlace Audio';

  @override
  String get incomingCallBannerVideoCall => 'MeetingPlace Video';

  @override
  String get callChatItemAudioCall => 'Audio call';

  @override
  String get callChatItemVideoCall => 'Video call';

  @override
  String get callChatItemCalling => 'Calling...';

  @override
  String get callChatItemRinging => 'Ringing';

  @override
  String get callChatItemIncoming => 'Incoming call';

  @override
  String get callChatItemTapToReturn => 'Tap to return';

  @override
  String get callChatItemMissed => 'Missed';

  @override
  String get callChatItemNotAnswered => 'Not answered';

  @override
  String get callChatItemDeclined => 'Declined';

  @override
  String callChatItemGroupOngoingVideo(int count) {
    return 'Ongoing video call ($count)';
  }

  @override
  String callChatItemGroupOngoingAudio(int count) {
    return 'Ongoing audio call ($count)';
  }

  @override
  String get callChatItemYouLeft => 'You left';

  @override
  String get callLogScreenTitle => 'Call log';

  @override
  String get callLogScreenSubtitle => 'Your past audio and video calls.';

  @override
  String get callLogEmpty => 'No calls yet.';

  @override
  String callLogParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String callLogParticipantsNamesAndOthers(String names, int othersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      othersCount,
      locale: localeName,
      other: '$othersCount others',
      one: '1 other',
    );
    return '$names and $_temp0';
  }

  @override
  String get callLogInProgress => 'In progress';

  @override
  String get callLogError => 'Unable to load call log.';

  @override
  String callDurationHourFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h',
      one: '1 h',
    );
    return '$_temp0';
  }

  @override
  String callDurationMinuteFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count m',
      one: '1 m',
    );
    return '$_temp0';
  }

  @override
  String callDurationSecondFormat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count s',
      one: '1 s',
    );
    return '$_temp0';
  }

  @override
  String get groupCallWaitingForOthers => 'Waiting for others...';

  @override
  String get groupCallParticipant => 'participant';

  @override
  String get groupCallParticipants => 'participants';

  @override
  String get groupCallEndCall => 'End Call';

  @override
  String get groupCallNoParticipants => 'No participants';

  @override
  String get groupCallMute => 'Mute';

  @override
  String get groupCallLeave => 'Leave';

  @override
  String get videoCallMuted => 'Muted';

  @override
  String videoCallPeerMuted(String peerName) {
    return '$peerName is muted';
  }

  @override
  String callParticipantsConnectedCount(int count) {
    return '$count connected';
  }

  @override
  String get callParticipantsConnectedSection => 'Connected';

  @override
  String get callParticipantsNotConnectedSection => 'Not connected';

  @override
  String callParticipantCallAction(String name) {
    return 'Call $name';
  }

  @override
  String callParticipantRingingAction(String name) {
    return 'Ringing $name';
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
  String get vtcJoinDirectoryHidden =>
      'This community doesn\'t list new members in its member directory.';

  @override
  String get vtcCommunityRole => 'Your role';

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
  String get vtcJoinCopyWebsite => 'Copy website';

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
  String vtcJoinFindableNote(String name) {
    return 'Members of $name can find you to vouch for you and see the identity you joined with.';
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
  String vtcTrustVouching(String name) {
    return 'Vouching for $name…';
  }

  @override
  String vtcTrustVouchingDetail(String community) {
    return 'Your VTA signs it, then $community stores it.';
  }

  @override
  String vtcTrustWithdrawing(String name) {
    return 'Withdrawing your vouch for $name…';
  }

  @override
  String vtcTrustWithdrawingDetail(String community) {
    return '$community stops showing it to its members.';
  }

  @override
  String vtcTrustWithdrawn(String name) {
    return 'You no longer vouch for $name';
  }

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
  String vtcTrustWaitingForVouchBack(String name) {
    return 'You vouched for $name. Waiting for them to vouch back.';
  }

  @override
  String vtcTrustVouchedForEachOther(String name) {
    return 'You and $name vouched for each other';
  }

  @override
  String vtcJoinAlreadyMember(String name) {
    return 'You\'re already a member of $name.';
  }

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
  String get communityVettingTab => 'Vetting';

  @override
  String get communityMembershipTab => 'Membership';

  @override
  String get communityMembershipCredentials => 'Credentials';

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
  String get communityRoomsTab => 'Rooms';
}
