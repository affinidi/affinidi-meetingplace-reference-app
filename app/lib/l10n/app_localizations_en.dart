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
      'contacts': 'Channels',
      'identities': 'Identities',
      'rCards': 'R-Cards',
      'credentials': 'Credentials',
      'settings': 'Settings',
      'other': 'Invalid',
    });
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
  String get contactsPanelSubtitle =>
      'Tap a channel to chat, double-tap to view details, tap and hold to delete.';

  @override
  String contactsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'any': 'Any',
      'person': 'Person',
      'group': 'Group',
      'service': 'AI Agent',
      'business': 'Business',
      'other': '',
    });
    return '$_temp0';
  }

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
  String get humanZkp => 'Human ZKP';

  @override
  String get humanZeroKnowledgeProof => 'Human Zero-Knowledge Proof';

  @override
  String get livenessCredential => 'Liveness Credential';

  @override
  String get verifiableCredentialWallet => 'Verifiable Credential wallet';

  @override
  String get noCredentialsYet => 'You don\'t have any credentials yet.';

  @override
  String get all => 'All';

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
  String get livenessCredentialRequest => 'Liveness Credential Request';

  @override
  String get livenessCheckDemoMode => 'Liveness Check (Demo Mode)';

  @override
  String get searchingForLivenessCredential =>
      'Searching for Liveness Credential...';

  @override
  String get noLivenessCredentialFound =>
      'No Liveness Credential was found.\n\nTo continue, a mock Liveness Credential will be generated locally.\nThis credential is used to demonstrate how a Zero-Knowledge Proof (ZKP) is derived.';

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
      'You can now continue to generate a Human Zero-Knowledge proof.';

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
      'You paused the Human ZKP proof request. Tap the \"+\" icon to restart it.';

  @override
  String get zkpNoticeShared =>
      'You have shared a Zero‑Knowledge Proof confirming you are human.\n*No personal data was shared.';

  @override
  String zkpNoticeReceived(String contactName) {
    return '$contactName has shared a Zero‑Knowledge Proof confirming they are human.';
  }

  @override
  String zkpNoticeRequest(String contactName) {
    return '$contactName has requested a Zero‑Knowledge Proof to confirm you are human. You can generate the proof using an existing Liveness Credential or complete a quick liveness check.';
  }

  @override
  String get zkpNoticeRequestInitiated =>
      'You have initiated a Human ZKP request.';

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
  String get voiceMessagePermissionDenied =>
      'Microphone permission is required to record voice messages.';

  @override
  String get voiceMessageRecordingFailed => 'Unable to start voice recording.';

  @override
  String get voiceMessageSendFailed => 'Unable to send voice message.';

  @override
  String get videoCallTitle => 'Group Call';

  @override
  String get videoCallJoiningCall => 'Joining call...';

  @override
  String get videoCallWaitingForParticipants => 'Waiting for participants...';

  @override
  String videoCallShowMore(num count) {
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
  String videoCallFailedToJoin(Object error) {
    return 'Failed to join: $error';
  }

  @override
  String get videoCallUnknownError => 'Unknown error';

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
  String videoCallParticipantCount(num count) {
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
  String get videoCallCancel => 'Cancel';

  @override
  String get videoCallAgain => 'Call again';

  @override
  String get videoCallGroupCallJoin => 'Join';

  @override
  String get videoCallGroupCallActive => 'Group call in progress';

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
  String get videoCallSwitchToVideoTitle => 'Switch to video call?';

  @override
  String get videoCallSwitch => 'Switch';
}
