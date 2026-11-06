import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Meeting Place'**
  String get appName;

  /// No description provided for @tabsTitle.
  ///
  /// In en, this message translates to:
  /// **'{tabName, select, connections{Invitations} contacts{Channels} identities{Identities} rCards{R-Cards} credentials{Credentials} settings{Settings} other{Invalid}}'**
  String tabsTitle(String tabName);

  /// No description provided for @rCardsPlaceholderMessage.
  ///
  /// In en, this message translates to:
  /// **'R-Cards will appear here.'**
  String get rCardsPlaceholderMessage;

  /// No description provided for @publishOffer.
  ///
  /// In en, this message translates to:
  /// **'Publish Invitation'**
  String get publishOffer;

  /// No description provided for @publishGroupOffer.
  ///
  /// In en, this message translates to:
  /// **'Publish Group Invitation'**
  String get publishGroupOffer;

  /// No description provided for @meetingPlaceBannerText.
  ///
  /// In en, this message translates to:
  /// **'Meeting Place allows you to anonymously and privately publish an invitation to connect to you. Provide a headline and description, as well as validity details to limit how long the offer is available.'**
  String get meetingPlaceBannerText;

  /// No description provided for @connectionOfferDetails.
  ///
  /// In en, this message translates to:
  /// **'Invitation Details'**
  String get connectionOfferDetails;

  /// No description provided for @createGroupChatOffer.
  ///
  /// In en, this message translates to:
  /// **'Group chat'**
  String get createGroupChatOffer;

  /// No description provided for @chatTransport.
  ///
  /// In en, this message translates to:
  /// **'Chat transport'**
  String get chatTransport;

  /// No description provided for @transportLabel.
  ///
  /// In en, this message translates to:
  /// **'{transport, select, didcomm{DIDComm} matrix{Matrix} other{{transport}}}'**
  String transportLabel(String transport);

  /// No description provided for @groupOfferHelperText.
  ///
  /// In en, this message translates to:
  /// **'The invitation will represent a group chat for multiple contacts to join and chat. You still have control over who can join the group chat.'**
  String get groupOfferHelperText;

  /// No description provided for @generateRandomPhraseHelperEnabled.
  ///
  /// In en, this message translates to:
  /// **'Generate a random phrase'**
  String get generateRandomPhraseHelperEnabled;

  /// No description provided for @generateRandomPhraseHelperDisabled.
  ///
  /// In en, this message translates to:
  /// **'The custom phrase you enter will be used to uniquely identify this invitation to connect. It must be unique in the Meeting Place universe.'**
  String get generateRandomPhraseHelperDisabled;

  /// No description provided for @customPhrase.
  ///
  /// In en, this message translates to:
  /// **'Custom Phrase'**
  String get customPhrase;

  /// No description provided for @enterCustomPhrase.
  ///
  /// In en, this message translates to:
  /// **'Enter custom phrase'**
  String get enterCustomPhrase;

  /// No description provided for @customPhraseHelperText.
  ///
  /// In en, this message translates to:
  /// **'Enter a unique custom phrase. You may use as many words as you like, separated by spaces.'**
  String get customPhraseHelperText;

  /// No description provided for @chatGroupName.
  ///
  /// In en, this message translates to:
  /// **'Chat group name'**
  String get chatGroupName;

  /// No description provided for @headline.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get headline;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @validityVisibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Validity & Visibility Settings'**
  String get validityVisibilitySettings;

  /// No description provided for @searchableAtMeetingPlace.
  ///
  /// In en, this message translates to:
  /// **'Searchable at meetingplace.world'**
  String get searchableAtMeetingPlace;

  /// No description provided for @searchableHelperText.
  ///
  /// In en, this message translates to:
  /// **'When selected, the details you share in this offer will be publicly searchable at meetingplace.world'**
  String get searchableHelperText;

  /// No description provided for @setExpiry.
  ///
  /// In en, this message translates to:
  /// **'Set Expiry'**
  String get setExpiry;

  /// No description provided for @setExpiryHelperEnabled.
  ///
  /// In en, this message translates to:
  /// **'The invitation will expire at the specified date and time'**
  String get setExpiryHelperEnabled;

  /// No description provided for @setExpiryHelperDisabled.
  ///
  /// In en, this message translates to:
  /// **'The invitation will remain valid until deleted and will not expire'**
  String get setExpiryHelperDisabled;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date} at {time}'**
  String expiresAt(String date, String time);

  /// No description provided for @scanCustomMediatorQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan custom message server QR code'**
  String get scanCustomMediatorQrCode;

  /// No description provided for @chooseMediatorHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose which message server to use for your connections. You can add custom message servers by scanning their QR code.'**
  String get chooseMediatorHelper;

  /// No description provided for @setMediatorName.
  ///
  /// In en, this message translates to:
  /// **'Set message server name'**
  String get setMediatorName;

  /// No description provided for @newConnectionOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'{option, select, shareQRCode{Direct share QR Code} scanQRCode{Direct scan a QR Code} claimAnOffer{Accept Meeting Place Invitation} publishAnOffer{Publish Meeting Place Invitation} prove{Prove} other{}}'**
  String newConnectionOptionTitle(String option);

  /// No description provided for @setExpiryDateTime.
  ///
  /// In en, this message translates to:
  /// **'Set expiry date and time'**
  String get setExpiryDateTime;

  /// No description provided for @selectExpiryHelperText.
  ///
  /// In en, this message translates to:
  /// **'Select when this offer should expire'**
  String get selectExpiryHelperText;

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @limitNumberOfUses.
  ///
  /// In en, this message translates to:
  /// **'Limit number of uses'**
  String get limitNumberOfUses;

  /// No description provided for @limitUsesHelperEnabled.
  ///
  /// In en, this message translates to:
  /// **'The invitation can only be used this many times'**
  String get limitUsesHelperEnabled;

  /// No description provided for @limitUsesHelperDisabled.
  ///
  /// In en, this message translates to:
  /// **'The invitation can be used an unlimited number of times'**
  String get limitUsesHelperDisabled;

  /// No description provided for @canBeUsedTimes.
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, =1{Can be used only once} other{Can be used {amount} times}}'**
  String canBeUsedTimes(int amount);

  /// No description provided for @newConnectionOptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{option, select, shareQRCode{Gives you complete privacy and confidentiality} scanQRCode{Scan a QR Code with your camera} claimAnOffer{Connect with someone through Meeting Place} publishAnOffer{Advertise your invitation to connect on Meeting Place} prove{Zero-knowledge proof verification} other{}}'**
  String newConnectionOptionSubtitle(String option);

  /// No description provided for @unableToDetectCamera.
  ///
  /// In en, this message translates to:
  /// **'Unable to detect a camera'**
  String get unableToDetectCamera;

  /// No description provided for @newConnectionsOptionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Select an option to create a new connection'**
  String get newConnectionsOptionsHeader;

  /// No description provided for @oobQrPresentInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'Show this QR code with someone to establish a connection'**
  String get oobQrPresentInvitationMessage;

  /// No description provided for @connectionsNowConnected.
  ///
  /// In en, this message translates to:
  /// **'You are now connected with'**
  String get connectionsNowConnected;

  /// No description provided for @connectionsPanelOobFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Channel creation failed'**
  String get connectionsPanelOobFailedTitle;

  /// No description provided for @connectionsPanelOobFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Unable to establish the connection. Please try again.'**
  String get connectionsPanelOobFailedBody;

  /// No description provided for @connectionsFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'{filter, select, all{All} offers{Offers} claims{Claims} complete{Complete} other{}}'**
  String connectionsFilterLabel(String filter);

  /// No description provided for @noConnections.
  ///
  /// In en, this message translates to:
  /// **'No invitations in this view'**
  String get noConnections;

  /// No description provided for @connectionDeleteHeading.
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, =1{Delete invitation} other{Delete invitations}}'**
  String connectionDeleteHeading(int amount);

  /// No description provided for @selectMaxUsagesHelperText.
  ///
  /// In en, this message translates to:
  /// **'Select how many times this offer can be used'**
  String get selectMaxUsagesHelperText;

  /// No description provided for @mediator.
  ///
  /// In en, this message translates to:
  /// **'Message Server'**
  String get mediator;

  /// No description provided for @mediatorHelperText.
  ///
  /// In en, this message translates to:
  /// **'This is the message server that will be used for communication with any contact that connects via this invitation'**
  String get mediatorHelperText;

  /// No description provided for @errorLoadingMediator.
  ///
  /// In en, this message translates to:
  /// **'Error loading message server'**
  String get errorLoadingMediator;

  /// No description provided for @publishToMeetingPlace.
  ///
  /// In en, this message translates to:
  /// **'Publish to Meeting Place'**
  String get publishToMeetingPlace;

  /// No description provided for @connectWithFirstName.
  ///
  /// In en, this message translates to:
  /// **'Connect with {firstName}!'**
  String connectWithFirstName(String firstName);

  /// No description provided for @firstNameChatGroup.
  ///
  /// In en, this message translates to:
  /// **'{firstName}\'s chat group'**
  String firstNameChatGroup(String firstName);

  /// No description provided for @passphraseDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect with me using Meeting Place!'**
  String get passphraseDescription;

  /// No description provided for @headlineRequired.
  ///
  /// In en, this message translates to:
  /// **'Headline is required'**
  String get headlineRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @customPhraseRequired.
  ///
  /// In en, this message translates to:
  /// **'Custom phrase is required when not using random phrase'**
  String get customPhraseRequired;

  /// No description provided for @expiryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry date is required when expiry is enabled'**
  String get expiryDateRequired;

  /// No description provided for @expiryDateFuture.
  ///
  /// In en, this message translates to:
  /// **'Expiry date must be in the future'**
  String get expiryDateFuture;

  /// No description provided for @maxUsagesGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Max usages must be greater than 0'**
  String get maxUsagesGreaterThanZero;

  /// No description provided for @failedToPublishOffer.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish invitation: {error}'**
  String failedToPublishOffer(String error);

  /// Label for selecting a mediator
  ///
  /// In en, this message translates to:
  /// **'Select Message Server'**
  String get selectMediator;

  /// No description provided for @connectionDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, =0{Are you sure you want to delete this invitation? You cannot undelete an invitation!} =1{Are you sure you want to delete this invitation? You cannot undelete an invitation!} other{Are you sure you want to delete {amount} selected invitations? You cannot undelete invitations!}}'**
  String connectionDeletePrompt(int amount);

  /// No description provided for @generalCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get generalCancel;

  /// No description provided for @generalDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get generalDelete;

  /// No description provided for @generalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get generalSave;

  /// No description provided for @generalDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get generalDone;

  /// Byline for connections panel heading
  ///
  /// In en, this message translates to:
  /// **'Swipe and tap to manage your invitations.'**
  String get connectionsPanelSubtitle;

  /// No description provided for @findPersonAiBusinessDescription.
  ///
  /// In en, this message translates to:
  /// **'To connect with a person or AI Agent on Meeting Place, enter the connection phrase they have shared with you.'**
  String get findPersonAiBusinessDescription;

  /// No description provided for @enterPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Enter passphrase'**
  String get enterPassphrase;

  /// No description provided for @claimOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Find an invitation on Meeting Place'**
  String get claimOfferTitle;

  /// No description provided for @generalSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get generalSearch;

  /// No description provided for @generalConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get generalConnect;

  /// No description provided for @contactCardFieldName.
  ///
  /// In en, this message translates to:
  /// **'{field, select, firstName{First name} lastName{Last name} email{Email} mobile{Mobile} other{}}'**
  String contactCardFieldName(String field);

  /// No description provided for @offerDetailsHeader.
  ///
  /// In en, this message translates to:
  /// **'My Invitation Information'**
  String get offerDetailsHeader;

  /// No description provided for @acceptOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation Request Details'**
  String get acceptOfferTitle;

  /// No description provided for @offerDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect with me using Meeting Place!'**
  String get offerDetailsDescription;

  /// No description provided for @errorOwnerCannotClaimOffer.
  ///
  /// In en, this message translates to:
  /// **'You cannot claim this invitation because you are the owner'**
  String get errorOwnerCannotClaimOffer;

  /// No description provided for @aliasPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect using this selected identity'**
  String get aliasPickerTitle;

  /// No description provided for @aliasPickerDescription.
  ///
  /// In en, this message translates to:
  /// **'Identities help you keep your personal information private and in your control. You can choose to use the Primary Identity alias you have configured, or select one of your additional identity aliases for this invitation.'**
  String get aliasPickerDescription;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'{errorCode, select, connection_offer_owned_by_claiming_party{You cannot accept this invitation because you are the inviter!} connection_offer_already_claimed_by_claiming_party{You cannot accept this invitation because you already requested to connect and have an outstanding claim in progress} missingMnemonic{Please enter an invitation passphrase to search} vtaSigningUnavailable{Your VTA couldn\'t be reached to sign this. Check it\'s online and try again.} vtaNotLinked{Link your VTA to sign this.} connection_offer_not_found_error{The details you provided did not match any active invitations.} discovery_register_offer_group_generic{Failed to publish invitation.} missingDeviceToken{Unable to find device notification token} offerOwnedByClaimingParty{You cannot claim this invitation because you are the owner} offerAlreadyClaimedByParty{You cannot claim this offer because you already accepted the invitation and have an outstanding request in progress} offerNotFound{The details you provided did not match any active invitations.} mediatorAlreadyExists{Message server with the same DID already exists.} mediator_get_did_error{No message server found at the provided URL} unableToFindMediator{No message server found at the provided URL} oobFlowTimedOut{Unable to establish a connection with other party, QR code was likely already used} connection_offer_expired{This invitation has expired} connection_offer_limit_exceeded{This invitation has reached its maximum number of uses} register_offer_mnemonic_in_use{This phrase is already in use, please choose another one} invalidQrCode{QR-Code is not valid} oob_invalid_data{QR-Code data is not valid} oob_not_found{QR-Code data does not match any active invitation} oob_invalid_type{QR-Code data not supported} network_error{Could not connect. Check your internet connection and try again.} deleteContactFailed{Failed to delete contact.} other{{errorCode}}}'**
  String error(String errorCode);

  /// No description provided for @offerCreated.
  ///
  /// In en, this message translates to:
  /// **'Invitation Created'**
  String get offerCreated;

  /// No description provided for @offerExpiresAt.
  ///
  /// In en, this message translates to:
  /// **'Invitation expires at {formattedExpiry}'**
  String offerExpiresAt(String formattedExpiry);

  /// No description provided for @offerValidityNote.
  ///
  /// In en, this message translates to:
  /// **'The invitation is valid until the date and time above, unless a maximum number of accesses is reached'**
  String get offerValidityNote;

  /// No description provided for @offerUnlimitedUsages.
  ///
  /// In en, this message translates to:
  /// **'This invitation can be used any number of times'**
  String get offerUnlimitedUsages;

  /// No description provided for @offerMaxUsages.
  ///
  /// In en, this message translates to:
  /// **'{maxUsages, plural, =1{This invitation can be used 1 time} other{This invitation can be used {maxUsages} times}}'**
  String offerMaxUsages(int maxUsages);

  /// No description provided for @noExpirySetHelperText.
  ///
  /// In en, this message translates to:
  /// **'No expiry date was set, so this invitation to connect does not expire'**
  String get noExpirySetHelperText;

  /// No description provided for @validityVisibilityDetails.
  ///
  /// In en, this message translates to:
  /// **'Validity & visibility details'**
  String get validityVisibilityDetails;

  /// No description provided for @personalInformationShared.
  ///
  /// In en, this message translates to:
  /// **'Personal information shared'**
  String get personalInformationShared;

  /// No description provided for @myAliasProfile.
  ///
  /// In en, this message translates to:
  /// **'My Alias Profile'**
  String get myAliasProfile;

  /// No description provided for @didInformation.
  ///
  /// In en, this message translates to:
  /// **'DID Information'**
  String get didInformation;

  /// No description provided for @didSha256.
  ///
  /// In en, this message translates to:
  /// **'{didSha256} (SHA256)'**
  String didSha256(String didSha256);

  /// No description provided for @offerUsesPrimaryIdentity.
  ///
  /// In en, this message translates to:
  /// **'This invitation uses your Primary Identity'**
  String get offerUsesPrimaryIdentity;

  /// No description provided for @offerUsesAliasIdentity.
  ///
  /// In en, this message translates to:
  /// **'This invitation uses the identity alias named \"{alias}\"'**
  String offerUsesAliasIdentity(String alias);

  /// No description provided for @aliasProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Your alias profile helps you keep your identity private and in your control.'**
  String get aliasProfileDescription;

  /// No description provided for @generalOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get generalOk;

  /// No description provided for @contactsPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a channel to chat, double-tap to view details, tap and hold to delete.'**
  String get contactsPanelSubtitle;

  /// No description provided for @contactsFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'{filter, select, any{Any} person{Person} group{Group} service{AI Agent} business{Business} other{}}'**
  String contactsFilterLabel(String filter);

  /// No description provided for @noContactsYet.
  ///
  /// In en, this message translates to:
  /// **'No channels in this view'**
  String get noContactsYet;

  /// No description provided for @contactDeleteHeading.
  ///
  /// In en, this message translates to:
  /// **'Delete channel'**
  String get contactDeleteHeading;

  /// No description provided for @contactDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, =0{Are you sure you want to delete this channel?} =1{Are you sure you want to delete this channel?} other{Are you sure you want to delete {amount} selected channels?}}'**
  String contactDeletePrompt(int amount);

  /// No description provided for @connectedVia.
  ///
  /// In en, this message translates to:
  /// **'Connected via {mediatorName}'**
  String connectedVia(String mediatorName);

  /// No description provided for @contactAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {dateAdded}'**
  String contactAdded(String dateAdded);

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter...'**
  String get filter;

  /// No description provided for @noContactsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No channels match your filter'**
  String get noContactsMatchFilter;

  /// No description provided for @connectionPhrase.
  ///
  /// In en, this message translates to:
  /// **'Phrase: {phrase}'**
  String connectionPhrase(String phrase);

  /// No description provided for @usesIdentityViaMediator.
  ///
  /// In en, this message translates to:
  /// **'Uses your {identity} identity via {mediator}'**
  String usesIdentityViaMediator(String identity, String mediator);

  /// No description provided for @usesIdentity.
  ///
  /// In en, this message translates to:
  /// **'Uses your {identity} identity to connect'**
  String usesIdentity(String identity);

  /// No description provided for @timeAgoJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeAgoJustNow;

  /// No description provided for @timeAgoMinute.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute ago} other{{minutes} minutes ago}}'**
  String timeAgoMinute(num minutes);

  /// No description provided for @timeAgoMinuteWorded.
  ///
  /// In en, this message translates to:
  /// **'a minute ago'**
  String get timeAgoMinuteWorded;

  /// No description provided for @timeAgoHourNumeric.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour ago} other{{hours} hours ago}}'**
  String timeAgoHourNumeric(num hours);

  /// No description provided for @timeAgoHourWorded.
  ///
  /// In en, this message translates to:
  /// **'an hour ago'**
  String get timeAgoHourWorded;

  /// No description provided for @timeAgoDay.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day ago} other{{days} days ago}}'**
  String timeAgoDay(num days);

  /// No description provided for @timeAgoYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeAgoYesterday;

  /// No description provided for @timeAgoWeek.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week ago} other{{weeks} weeks ago}}'**
  String timeAgoWeek(num weeks);

  /// No description provided for @timeAgoLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get timeAgoLastWeek;

  /// No description provided for @timeAgoSecond.
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{1 second ago} other{{seconds} seconds ago}}'**
  String timeAgoSecond(num seconds);

  /// No description provided for @createdValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Created {createdTimeAgo}, valid until {validUntilDate}'**
  String createdValidUntil(String createdTimeAgo, String validUntilDate);

  /// No description provided for @createdValidWithoutExpiration.
  ///
  /// In en, this message translates to:
  /// **'Created {createdTimeAgo}, with no expiry date'**
  String createdValidWithoutExpiration(String createdTimeAgo);

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @generalName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get generalName;

  /// No description provided for @displayNameHelperText.
  ///
  /// In en, this message translates to:
  /// **'You can change the display name for this channel. The other party will not see what you call it.'**
  String get displayNameHelperText;

  /// No description provided for @generalDid.
  ///
  /// In en, this message translates to:
  /// **'DID'**
  String get generalDid;

  /// No description provided for @generalDidSha256.
  ///
  /// In en, this message translates to:
  /// **'DID (SHA256)'**
  String get generalDidSha256;

  /// No description provided for @connectionEstablished.
  ///
  /// In en, this message translates to:
  /// **'Channel established'**
  String get connectionEstablished;

  /// No description provided for @generalMediator.
  ///
  /// In en, this message translates to:
  /// **'Message Server'**
  String get generalMediator;

  /// No description provided for @connectionApproach.
  ///
  /// In en, this message translates to:
  /// **'Channel establishment approach'**
  String get connectionApproach;

  /// No description provided for @theirDetails.
  ///
  /// In en, this message translates to:
  /// **'Their Details'**
  String get theirDetails;

  /// No description provided for @mySharedIdentityDetails.
  ///
  /// In en, this message translates to:
  /// **'My shared identity details'**
  String get mySharedIdentityDetails;

  /// No description provided for @connectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Channel connection details'**
  String get connectionDetails;

  /// No description provided for @myIdentity.
  ///
  /// In en, this message translates to:
  /// **'My identity'**
  String get myIdentity;

  /// No description provided for @identitiesPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe left and right to review and add to your identities list, drag down to delete'**
  String get identitiesPanelSubtitle;

  /// No description provided for @identitiesFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'{filter, select, all{All} primary{Primary} aliases{Aliases} other{}}'**
  String identitiesFilterLabel(String filter);

  /// No description provided for @identityDeleteHeading.
  ///
  /// In en, this message translates to:
  /// **'Delete identity'**
  String get identityDeleteHeading;

  /// No description provided for @identityDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete identity \"{identity}\"?\n\nYou cannot undelete an identity!'**
  String identityDeletePrompt(Object identity);

  /// No description provided for @displayNamePrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary Identity'**
  String get displayNamePrimary;

  /// No description provided for @displayNameAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add new identity'**
  String get displayNameAddNew;

  /// No description provided for @displayNameAlias.
  ///
  /// In en, this message translates to:
  /// **'Identity Alias'**
  String get displayNameAlias;

  /// No description provided for @subtitlePrimary.
  ///
  /// In en, this message translates to:
  /// **'Your Primary Identity'**
  String get subtitlePrimary;

  /// No description provided for @subtitleAddNew.
  ///
  /// In en, this message translates to:
  /// **'Create a new alias'**
  String get subtitleAddNew;

  /// No description provided for @subtitleAlias.
  ///
  /// In en, this message translates to:
  /// **'Alias identity'**
  String get subtitleAlias;

  /// No description provided for @notShared.
  ///
  /// In en, this message translates to:
  /// **'Not shared'**
  String get notShared;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get unknownUser;

  /// No description provided for @unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnnamed'**
  String get unnamed;

  /// No description provided for @unnamedMediator.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get unnamedMediator;

  /// No description provided for @addNewIdentityAlias.
  ///
  /// In en, this message translates to:
  /// **'Add new identity alias'**
  String get addNewIdentityAlias;

  /// No description provided for @identityAliasesDescription.
  ///
  /// In en, this message translates to:
  /// **'Take control of your privacy, by creating identity aliases to represent yourself to contacts you connect with'**
  String get identityAliasesDescription;

  /// No description provided for @generalReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get generalReject;

  /// No description provided for @generalApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get generalApprove;

  /// No description provided for @zalgoTextDetectedError.
  ///
  /// In en, this message translates to:
  /// **'Unusual characters detected. Please remove them and try again.'**
  String get zalgoTextDetectedError;

  /// No description provided for @chatTooLong.
  ///
  /// In en, this message translates to:
  /// **'The chat message is too long'**
  String get chatTooLong;

  /// No description provided for @splashScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting Place'**
  String get splashScreenTitle;

  /// No description provided for @toProtectData.
  ///
  /// In en, this message translates to:
  /// **'To protect your data, this application requires secure authentication to continue.'**
  String get toProtectData;

  /// Instruction for Android users on how to enable secure authentication
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Security > Screen lock and enable a PIN, pattern, or fingerprint.'**
  String get authInstructionAndroid;

  /// Instruction for iOS users on how to enable secure authentication
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Face ID & Passcode (or Touch ID & Passcode) and set up Face ID, Touch ID, or a device passcode.'**
  String get authInstructionIos;

  /// Instruction for macOS users on how to enable secure authentication
  ///
  /// In en, this message translates to:
  /// **'Go to System Settings > Touch ID & Password (or Login Password) and set up Touch ID or a secure password.'**
  String get authInstructionMacos;

  /// No description provided for @authUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Please unlock your device to continue'**
  String get authUnlockReason;

  /// No description provided for @chatTypeMessagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Message to {name}'**
  String chatTypeMessagePrompt(String name);

  /// No description provided for @chatAddMessageToMediaPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a message'**
  String get chatAddMessageToMediaPrompt;

  /// No description provided for @chatTypeMessagePromptGroup.
  ///
  /// In en, this message translates to:
  /// **'Message to the channel'**
  String get chatTypeMessagePromptGroup;

  /// No description provided for @updatePrimaryIdentity.
  ///
  /// In en, this message translates to:
  /// **'Update Primary Identity'**
  String get updatePrimaryIdentity;

  /// No description provided for @newIdentityAlias.
  ///
  /// In en, this message translates to:
  /// **'New identity alias'**
  String get newIdentityAlias;

  /// No description provided for @editIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit identity: {identityName}'**
  String editIdentityTitle(String identityName);

  /// No description provided for @customiseIdentityCard.
  ///
  /// In en, this message translates to:
  /// **'Customise identity card'**
  String get customiseIdentityCard;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'The name is too long'**
  String get nameTooLong;

  /// No description provided for @descriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'The description is too long'**
  String get descriptionTooLong;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid'**
  String get invalidEmail;

  /// No description provided for @emailTooLong.
  ///
  /// In en, this message translates to:
  /// **'The email address is too long'**
  String get emailTooLong;

  /// No description provided for @invalidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'The mobile number is invalid'**
  String get invalidMobileNumber;

  /// No description provided for @mobileTooLong.
  ///
  /// In en, this message translates to:
  /// **'The mobile number is too long'**
  String get mobileTooLong;

  /// No description provided for @aliasTooLong.
  ///
  /// In en, this message translates to:
  /// **'The alias is too long'**
  String get aliasTooLong;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @identityAliasPersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Identity alias personal details'**
  String get identityAliasPersonalDetails;

  /// No description provided for @profilePictureChangePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap here to change your profile picture'**
  String get profilePictureChangePrompt;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get enterLastName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @enterMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile'**
  String get enterMobile;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @aliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Alias label'**
  String get aliasLabel;

  /// No description provided for @enterAliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter alias label'**
  String get enterAliasLabel;

  /// No description provided for @aliasLabelHelperText.
  ///
  /// In en, this message translates to:
  /// **'The alias label is how you will refer to this alias when connecting. Use a descriptive name to make it easier to identify.'**
  String get aliasLabelHelperText;

  /// No description provided for @setupPrimaryIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s setup your Primary Identity!'**
  String get setupPrimaryIdentityTitle;

  /// No description provided for @setupPrimaryIdentityDescription.
  ///
  /// In en, this message translates to:
  /// **'Your Primary Identity will be used by default when you connect with others.'**
  String get setupPrimaryIdentityDescription;

  /// No description provided for @primaryIdentityInformation.
  ///
  /// In en, this message translates to:
  /// **'Your Primary Identity information'**
  String get primaryIdentityInformation;

  /// No description provided for @primaryIdentityComplete.
  ///
  /// In en, this message translates to:
  /// **'My Primary Identity is complete'**
  String get primaryIdentityComplete;

  /// No description provided for @keepMeAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Keep me anonymous'**
  String get keepMeAnonymous;

  /// No description provided for @typingMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, =1{{names} is typing} other{{names} are typing}}'**
  String typingMessage(String names, int amount);

  /// No description provided for @awaitingMembersToJoin.
  ///
  /// In en, this message translates to:
  /// **'{namesCount, plural, =1{Awaiting {names} to join} other{Awaiting {names} and {othersCount, plural, =1{1 other} other{{othersCount} others}} to join}}'**
  String awaitingMembersToJoin(String names, int namesCount, int othersCount);

  /// No description provided for @unknownType.
  ///
  /// In en, this message translates to:
  /// **'Unknown type'**
  String get unknownType;

  /// No description provided for @loadImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get loadImageFailed;

  /// No description provided for @chatRequestPermissionToJoinGroupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to join group'**
  String get chatRequestPermissionToJoinGroupFailed;

  /// The wording for concierge message
  ///
  /// In en, this message translates to:
  /// **'Concierge message'**
  String get genWordConciergeMessage;

  /// No description provided for @chatRequestPermissionToJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'{memberName} wants to join the group'**
  String chatRequestPermissionToJoinGroup(String memberName);

  /// Encryption security notice displayed at the top of every chat
  ///
  /// In en, this message translates to:
  /// **'Messages and any data shared in this chat are end-to-end encrypted. Only people and agents in this chat can read them.'**
  String get chatEncryptionNotice;

  /// The word for No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get genWordNo;

  /// Phrase for later
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get genWordLater;

  /// The word for Yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get genWordYes;

  /// No description provided for @chatRequestPermissionToUpdateProfileGroup.
  ///
  /// In en, this message translates to:
  /// **'The profile details shared with this group have changed. Would you like to update all members?'**
  String get chatRequestPermissionToUpdateProfileGroup;

  /// No description provided for @chatRequestPermissionToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'The profile details shared with this contact have changed. Would you like to send them an update?'**
  String get chatRequestPermissionToUpdateProfile;

  /// No description provided for @chatStartOfConversationInitiatedByMe.
  ///
  /// In en, this message translates to:
  /// **'You established this channel on {date} at {time}'**
  String chatStartOfConversationInitiatedByMe(String date, String time);

  /// No description provided for @messageCopiedClipboard.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get messageCopiedClipboard;

  /// No description provided for @chatMessageActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get chatMessageActionDelete;

  /// No description provided for @chatMessageActionDeleteLocal.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get chatMessageActionDeleteLocal;

  /// No description provided for @chatMessageActionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get chatMessageActionCopy;

  /// No description provided for @chatMessageActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get chatMessageActionEdit;

  /// No description provided for @chatMessageEditedLabel.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get chatMessageEditedLabel;

  /// No description provided for @chatMessageEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not edit message'**
  String get chatMessageEditFailed;

  /// No description provided for @chatMessageEditHint.
  ///
  /// In en, this message translates to:
  /// **'Message text'**
  String get chatMessageEditHint;

  /// No description provided for @chatMessageEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get chatMessageEditSave;

  /// No description provided for @chatMessageDeletedTombstone.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get chatMessageDeletedTombstone;

  /// No description provided for @chatMessageDeletedLocallyTombstone.
  ///
  /// In en, this message translates to:
  /// **'You deleted this message'**
  String get chatMessageDeletedLocallyTombstone;

  /// No description provided for @chatMessageDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete message'**
  String get chatMessageDeleteFailed;

  /// No description provided for @chatItemStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, queued{Queued} delivered{Delivered} sending{Sending} sent{Sent} error{Error} groupDeleted{Group deleted} other{}}'**
  String chatItemStatus(String status);

  /// No description provided for @qrScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get qrScannerTitle;

  /// No description provided for @qrScannerInstructions.
  ///
  /// In en, this message translates to:
  /// **'Position the QR code within the frame'**
  String get qrScannerInstructions;

  /// No description provided for @qrScannerStatus.
  ///
  /// In en, this message translates to:
  /// **'Scanner Status: {status}'**
  String qrScannerStatus(String status);

  /// No description provided for @useCamera.
  ///
  /// In en, this message translates to:
  /// **'Use Camera'**
  String get useCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @qrScannerCameraPermissionHelp.
  ///
  /// In en, this message translates to:
  /// **'Please check camera permissions and try again'**
  String get qrScannerCameraPermissionHelp;

  /// No description provided for @qrScannerConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get qrScannerConnectionFailed;

  /// No description provided for @qrScannerConnectionFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to establish connection: {error}'**
  String qrScannerConnectionFailedMessage(String error);

  /// No description provided for @qrScannerTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get qrScannerTryAgain;

  /// No description provided for @qrScannerTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'OOB flow acceptance timed out after 30 seconds'**
  String get qrScannerTimeoutError;

  /// No description provided for @customMediators.
  ///
  /// In en, this message translates to:
  /// **'Custom Message Servers'**
  String get customMediators;

  /// No description provided for @addCustomMediator.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Message Server'**
  String get addCustomMediator;

  /// No description provided for @manageCustomMediators.
  ///
  /// In en, this message translates to:
  /// **'Manage Custom Message Server'**
  String get manageCustomMediators;

  /// No description provided for @configureCustomMediatorEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Configure your own message server endpoint'**
  String get configureCustomMediatorEndpoint;

  /// No description provided for @noCustomMediatorsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No custom message servers configured yet'**
  String get noCustomMediatorsConfigured;

  /// No description provided for @customMediatorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 custom message server configured} other{{count} custom message servers configured}}'**
  String customMediatorsCount(int count);

  /// No description provided for @addedMediatorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added message server \"{name}\"'**
  String addedMediatorSuccess(String name);

  /// No description provided for @failedToAddMediator.
  ///
  /// In en, this message translates to:
  /// **'Failed to add message server: {error}'**
  String failedToAddMediator(String error);

  /// No description provided for @mediatorName.
  ///
  /// In en, this message translates to:
  /// **'Message Server Name'**
  String get mediatorName;

  /// No description provided for @mediatorDid.
  ///
  /// In en, this message translates to:
  /// **'Message Server DID'**
  String get mediatorDid;

  /// No description provided for @myCustomMediator.
  ///
  /// In en, this message translates to:
  /// **'My Custom Message Server'**
  String get myCustomMediator;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterDid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a DID'**
  String get pleaseEnterDid;

  /// No description provided for @didMustStartWith.
  ///
  /// In en, this message translates to:
  /// **'DID must start with \"did:\"'**
  String get didMustStartWith;

  /// No description provided for @deleteCustomMediator.
  ///
  /// In en, this message translates to:
  /// **'Delete Custom Message Server'**
  String get deleteCustomMediator;

  /// No description provided for @deleteCustomMediatorConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?\n\nThis action cannot be undone.'**
  String deleteCustomMediatorConfirm(String name);

  /// No description provided for @deletedMediatorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted message server \"{name}\"'**
  String deletedMediatorSuccess(String name);

  /// No description provided for @renamedMediatorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Renamed message server to \"{name}\"'**
  String renamedMediatorSuccess(String name);

  /// No description provided for @failedToDeleteMediator.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete message server: {error}'**
  String failedToDeleteMediator(String error);

  /// No description provided for @failedToRenameMediator.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename message server: {error}'**
  String failedToRenameMediator(String error);

  /// No description provided for @generalRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get generalRetry;

  /// No description provided for @generalClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get generalClose;

  /// No description provided for @generalAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get generalAdd;

  /// No description provided for @noIdentityDetected.
  ///
  /// In en, this message translates to:
  /// **'No identity detected, please create one to continue.'**
  String get noIdentityDetected;

  /// No description provided for @connectWithPersonAiServiceBusiness.
  ///
  /// In en, this message translates to:
  /// **'Connect with a Person or AI Agent'**
  String get connectWithPersonAiServiceBusiness;

  /// No description provided for @chatScreenTapForMemberDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for member details'**
  String get chatScreenTapForMemberDetails;

  /// No description provided for @debugPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug Panel'**
  String get debugPanelTitle;

  /// No description provided for @debugPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View application logs and debug information'**
  String get debugPanelSubtitle;

  /// No description provided for @debugPanelNoLogs.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get debugPanelNoLogs;

  /// No description provided for @debugPanelLogsAppearMessage.
  ///
  /// In en, this message translates to:
  /// **'Logs will appear here as you use the app'**
  String get debugPanelLogsAppearMessage;

  /// No description provided for @debugPanelClearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear logs'**
  String get debugPanelClearLogs;

  /// No description provided for @debugPanelCopyLogs.
  ///
  /// In en, this message translates to:
  /// **'Copy logs to clipboard'**
  String get debugPanelCopyLogs;

  /// No description provided for @debugPanelAddTestLog.
  ///
  /// In en, this message translates to:
  /// **'Add test log'**
  String get debugPanelAddTestLog;

  /// No description provided for @debugPanelLogsCopied.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get debugPanelLogsCopied;

  /// No description provided for @debugPanelShareLogs.
  ///
  /// In en, this message translates to:
  /// **'Share logs'**
  String get debugPanelShareLogs;

  /// No description provided for @serverSettings.
  ///
  /// In en, this message translates to:
  /// **'Server Settings'**
  String get serverSettings;

  /// No description provided for @serverSettingsHelperText.
  ///
  /// In en, this message translates to:
  /// **'Select the default server for messaging communication'**
  String get serverSettingsHelperText;

  /// No description provided for @debugSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug Settings'**
  String get debugSettingsTitle;

  /// No description provided for @debugModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode'**
  String get debugModeLabel;

  /// No description provided for @debugModeHelperText.
  ///
  /// In en, this message translates to:
  /// **'Debug mode is enabled. Tap version info {tapCount} times to toggle.'**
  String debugModeHelperText(int tapCount);

  /// No description provided for @settingsScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure your app settings and preferences'**
  String get settingsScreenSubtitle;

  /// No description provided for @versionInfoHeader.
  ///
  /// In en, this message translates to:
  /// **'Application Version Info'**
  String get versionInfoHeader;

  /// No description provided for @versionInfoVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionInfoVersion(String version);

  /// No description provided for @versionInfoBuild.
  ///
  /// In en, this message translates to:
  /// **'Build: {buildNumber}'**
  String versionInfoBuild(String buildNumber);

  /// No description provided for @easterEggEnabled.
  ///
  /// In en, this message translates to:
  /// **'🎉 Easter egg unlocked! Debug mode enabled'**
  String get easterEggEnabled;

  /// No description provided for @debugModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Debug mode disabled'**
  String get debugModeDisabled;

  /// No description provided for @generalCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get generalCamera;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCamera;

  /// No description provided for @generalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get generalPhoto;

  /// No description provided for @generalBalloons.
  ///
  /// In en, this message translates to:
  /// **'Balloons'**
  String get generalBalloons;

  /// No description provided for @generalConfetti.
  ///
  /// In en, this message translates to:
  /// **'Confetti'**
  String get generalConfetti;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get chatItemStatusError;

  /// No description provided for @formValidationHeadlineRequired.
  ///
  /// In en, this message translates to:
  /// **'Headline is required'**
  String get formValidationHeadlineRequired;

  /// No description provided for @formValidationDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get formValidationDescriptionRequired;

  /// No description provided for @formValidationCustomPhraseRequired.
  ///
  /// In en, this message translates to:
  /// **'Custom phrase is required when not using random phrase'**
  String get formValidationCustomPhraseRequired;

  /// No description provided for @formValidationExpiryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry date is required when expiry is enabled'**
  String get formValidationExpiryDateRequired;

  /// No description provided for @formValidationExpiryDateFuture.
  ///
  /// In en, this message translates to:
  /// **'Expiry date must be in the future'**
  String get formValidationExpiryDateFuture;

  /// No description provided for @formValidationMaxUsagesGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Max usages must be greater than 0'**
  String get formValidationMaxUsagesGreaterThanZero;

  /// No description provided for @genericPublishError.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish offer'**
  String get genericPublishError;

  /// No description provided for @groupDetails.
  ///
  /// In en, this message translates to:
  /// **'Group Channel Details'**
  String get groupDetails;

  /// No description provided for @groupMessageInfo.
  ///
  /// In en, this message translates to:
  /// **'{memberName} on {date} at {time}'**
  String groupMessageInfo(String memberName, String date, String time);

  /// No description provided for @contactStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, pendingApproval{Pending Approval} pendingInauguration{Establishing Connection} approved{Active Contact} rejected{Rejected} error{Error} deleted{Deleted} active{Active Channel} unknown{Unknown} other{Unknown}}'**
  String contactStatus(String status);

  /// No description provided for @groupContactStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, pendingApproval{Pending Approval} pendingInauguration{Establishing Channel} approved{Active Group Channel} rejected{Rejected} error{Error} deleted{Deleted} active{Active Group Channel} unknown{Unknown} other{Unknown}}'**
  String groupContactStatus(String status);

  /// No description provided for @contactOrigin.
  ///
  /// In en, this message translates to:
  /// **'{origin, select, directInteractive{Direct Interactive} individualOfferPublished{Meeting Place Invitation Offered} individualOfferRequested{Meeting Place Invitation Accepted} groupOfferPublished{Meeting Place Group invitation Offered} groupOfferRequested{Meeting Place Group Invitation Accepted} unknown{Unknown} other{Unknown}}'**
  String contactOrigin(String origin);

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Group Members'**
  String get groupMembers;

  /// No description provided for @showExited.
  ///
  /// In en, this message translates to:
  /// **'Show exited'**
  String get showExited;

  /// No description provided for @groupMemberExited.
  ///
  /// In en, this message translates to:
  /// **'Exited from the group'**
  String get groupMemberExited;

  /// No description provided for @groupNoMembersToChat.
  ///
  /// In en, this message translates to:
  /// **'You are currently the only member of this group. You can start chatting when another member joins.'**
  String get groupNoMembersToChat;

  /// No description provided for @generalJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get generalJoined;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @groupAdmin.
  ///
  /// In en, this message translates to:
  /// **'Group Admin'**
  String get groupAdmin;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nMeeting Place'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Desc.
  ///
  /// In en, this message translates to:
  /// **'Powered by\nAffinidi Meeting Place SDK'**
  String get onboardingPage1Desc;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Private & Secure'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Desc.
  ///
  /// In en, this message translates to:
  /// **'Connect with others securely and privately with end-to-end encryption'**
  String get onboardingPage2Desc;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Take control of your identity'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Desc.
  ///
  /// In en, this message translates to:
  /// **'Protect your privacy with aliases. Prove your identity with verified credentials'**
  String get onboardingPage3Desc;

  /// No description provided for @onboardingPage4Title.
  ///
  /// In en, this message translates to:
  /// **'Ready to Begin'**
  String get onboardingPage4Title;

  /// No description provided for @onboardingPage4Desc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your identity\nand get you started!'**
  String get onboardingPage4Desc;

  /// No description provided for @setUpMyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Setup my identity'**
  String get setUpMyIdentity;

  /// No description provided for @revealConnectionCode.
  ///
  /// In en, this message translates to:
  /// **'Reveal invitation passphrase'**
  String get revealConnectionCode;

  /// No description provided for @versionInfoAppName.
  ///
  /// In en, this message translates to:
  /// **'Meeting Place \"{appName}\"'**
  String versionInfoAppName(String appName);

  /// No description provided for @platformNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This plugin is not supported on your current platform'**
  String get platformNotSupported;

  /// No description provided for @generalOfferInformation.
  ///
  /// In en, this message translates to:
  /// **'Invitation Information'**
  String get generalOfferInformation;

  /// No description provided for @generalOfferLink.
  ///
  /// In en, this message translates to:
  /// **'Invitation Link'**
  String get generalOfferLink;

  /// No description provided for @generalMnemonic.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic'**
  String get generalMnemonic;

  /// No description provided for @generalConnectionType.
  ///
  /// In en, this message translates to:
  /// **'Connection type'**
  String get generalConnectionType;

  /// No description provided for @generalExternalRef.
  ///
  /// In en, this message translates to:
  /// **'External Reference'**
  String get generalExternalRef;

  /// No description provided for @generalGroupDid.
  ///
  /// In en, this message translates to:
  /// **'Group DID'**
  String get generalGroupDid;

  /// No description provided for @generalGroupId.
  ///
  /// In en, this message translates to:
  /// **'Group Id'**
  String get generalGroupId;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Localized connection offer status
  ///
  /// In en, this message translates to:
  /// **'{status, select, published{Created} finalised{Completed} accepted{Waiting} channelInaugurated{Active} deleted{Deleted} other{Unknown}}'**
  String connectionStatus(String status);

  /// No description provided for @publishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing'**
  String get publishing;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting'**
  String get deleting;

  /// No description provided for @showQrScannerForOffers.
  ///
  /// In en, this message translates to:
  /// **'Show QR scanner for Invitations'**
  String get showQrScannerForOffers;

  /// No description provided for @meetingPlaceControlPlane.
  ///
  /// In en, this message translates to:
  /// **'Meeting Place Control Plane'**
  String get meetingPlaceControlPlane;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get searching;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @approving.
  ///
  /// In en, this message translates to:
  /// **'Approving'**
  String get approving;

  /// No description provided for @rejecting.
  ///
  /// In en, this message translates to:
  /// **'Rejecting'**
  String get rejecting;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get sending;

  /// No description provided for @connectionRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'The request to connect has been rejected'**
  String get connectionRequestRejected;

  /// No description provided for @connectionRequestInProgress.
  ///
  /// In en, this message translates to:
  /// **'Invitation acceptance in progress. It may take a few moments for the other party to respond and finalise the channel.'**
  String get connectionRequestInProgress;

  /// No description provided for @requestToConnect.
  ///
  /// In en, this message translates to:
  /// **'Invitation acceptance has been sent {firstName}. It may take a few moments for them to respond to your request.'**
  String requestToConnect(Object firstName);

  /// No description provided for @contactsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, =1{Channel deleted} other{Channels deleted}}'**
  String contactsDeleted(int amount);

  /// No description provided for @joiningGroup.
  ///
  /// In en, this message translates to:
  /// **'{memberName} has joined the group'**
  String joiningGroup(String memberName);

  /// No description provided for @leavingGroup.
  ///
  /// In en, this message translates to:
  /// **'{memberName} has left the group'**
  String leavingGroup(String memberName);

  /// No description provided for @memberRemovedFromGroup.
  ///
  /// In en, this message translates to:
  /// **'{memberName} has been removed'**
  String memberRemovedFromGroup(String memberName);

  /// No description provided for @concierge.
  ///
  /// In en, this message translates to:
  /// **'Concierge'**
  String get concierge;

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'This group has been deleted'**
  String get groupDeleted;

  /// No description provided for @creatingConnection.
  ///
  /// In en, this message translates to:
  /// **'Creating connection...'**
  String get creatingConnection;

  /// No description provided for @generatingQrCode.
  ///
  /// In en, this message translates to:
  /// **'Generating your QR code'**
  String get generatingQrCode;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @oobConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'You are now connected to {memberName}!'**
  String oobConnectedTo(String memberName);

  /// No description provided for @oobChatTo.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get oobChatTo;

  /// No description provided for @networkDisconnected.
  ///
  /// In en, this message translates to:
  /// **'You are not connected to the network'**
  String get networkDisconnected;

  /// No description provided for @chatNotificationsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Push notifications aren\'t supported for chats started by scanning or sharing a QR code.'**
  String get chatNotificationsUnavailable;

  /// No description provided for @chatNotificationsUnavailableNotShared.
  ///
  /// In en, this message translates to:
  /// **'Notifications for this chat channel are not available'**
  String get chatNotificationsUnavailableNotShared;

  /// No description provided for @chatNotificationsWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why no push notifications?'**
  String get chatNotificationsWhyTitle;

  /// No description provided for @chatNotificationsWhyDescription.
  ///
  /// In en, this message translates to:
  /// **'When you establish a connection by direct scanning or sharing a QR code, your devices connect directly without exchanging notification tokens with our servers. This means push notifications can\'t be sent when the chat is closed.'**
  String get chatNotificationsWhyDescription;

  /// No description provided for @chatNotificationsWhyNote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll only see new messages when you\'re in the chat. There will be no badge updates or notifications informing you that new messages have arrived, even if the app is open.'**
  String get chatNotificationsWhyNote;

  /// No description provided for @chatNotificationsWhyButton.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get chatNotificationsWhyButton;

  /// No description provided for @chatNotificationsWhyLink.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get chatNotificationsWhyLink;

  /// No description provided for @meetingPlaceInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting Place Invitation'**
  String get meetingPlaceInvitationTitle;

  /// No description provided for @shareSheetCTA_QRCode.
  ///
  /// In en, this message translates to:
  /// **'Send or save QR code'**
  String get shareSheetCTA_QRCode;

  /// No description provided for @cameraInstructionAndroid.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Open Settings\" below to enable camera access. If that doesn\'t work, open Settings manually:\n\nSettings > Apps > Meeting Place > Permissions > Camera > Allow only while using the app.'**
  String get cameraInstructionAndroid;

  /// No description provided for @cameraInstructionIos.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Open Settings\" below to enable camera access. If that doesn\'t work, open Settings manually:\n\nSettings > Meeting Place > Camera and enable access for this app.'**
  String get cameraInstructionIos;

  /// No description provided for @cameraInstructionMacos.
  ///
  /// In en, this message translates to:
  /// **'Go to System Settings > Privacy & Security > Camera and allow camera access for this app.'**
  String get cameraInstructionMacos;

  /// No description provided for @cameraAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access denied or unavailable.'**
  String get cameraAccessDenied;

  /// No description provided for @cameraOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get cameraOpenSettings;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera not available'**
  String get cameraNotAvailable;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @rCardsPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Relationship cards received from your contacts'**
  String get rCardsPanelSubtitle;

  /// No description provided for @rCardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'R-Cards are a modern self-updating version of vCards. Once you make your first connection, your digital business cards will appear here.'**
  String get rCardsEmpty;

  /// No description provided for @rCardsFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'{filter, select, all{All} nonAnonymous{Non-anonymous} other{}}'**
  String rCardsFilterLabel(String filter);

  /// No description provided for @noRCardsFoundWithFilter.
  ///
  /// In en, this message translates to:
  /// **'No R-Cards found matching your search.'**
  String get noRCardsFoundWithFilter;

  /// No description provided for @rCardDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'R-Card Details'**
  String get rCardDetailsTitle;

  /// No description provided for @rCardSectionIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get rCardSectionIdentity;

  /// No description provided for @rCardSectionMetadata.
  ///
  /// In en, this message translates to:
  /// **'Credential Details'**
  String get rCardSectionMetadata;

  /// No description provided for @rCardFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get rCardFieldName;

  /// No description provided for @rCardFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get rCardFieldEmail;

  /// No description provided for @rCardFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get rCardFieldPhone;

  /// No description provided for @rCardFieldCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get rCardFieldCompany;

  /// No description provided for @rCardFieldPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get rCardFieldPosition;

  /// No description provided for @rCardFieldWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get rCardFieldWebsite;

  /// No description provided for @rCardFieldSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get rCardFieldSocial;

  /// No description provided for @rCardFieldSubjectDid.
  ///
  /// In en, this message translates to:
  /// **'Subject DID'**
  String get rCardFieldSubjectDid;

  /// No description provided for @rCardAddNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes'**
  String get rCardAddNotes;

  /// No description provided for @rCardUpdateNotes.
  ///
  /// In en, this message translates to:
  /// **'Update notes'**
  String get rCardUpdateNotes;

  /// No description provided for @rCardNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get rCardNotesTitle;

  /// No description provided for @rCardNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write your notes here...'**
  String get rCardNotesPlaceholder;

  /// No description provided for @rCardDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this R-Card? This action cannot be undone.'**
  String get rCardDeletePrompt;

  /// No description provided for @rCardChatWith.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String rCardChatWith(String name);

  /// No description provided for @removeMemberDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMemberDialogTitle;

  /// No description provided for @removeMemberDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this group? They will no longer receive messages.'**
  String removeMemberDialogBody(String name);

  /// No description provided for @rCardFieldIssuerDid.
  ///
  /// In en, this message translates to:
  /// **'Issuer DID'**
  String get rCardFieldIssuerDid;

  /// No description provided for @rCardFieldReceivedAt.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get rCardFieldReceivedAt;

  /// No description provided for @rCardFieldIssuedAt.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get rCardFieldIssuedAt;

  /// No description provided for @rCardTitle.
  ///
  /// In en, this message translates to:
  /// **'R-Card'**
  String get rCardTitle;

  /// No description provided for @verifiableCredential.
  ///
  /// In en, this message translates to:
  /// **'Verifiable Credential'**
  String get verifiableCredential;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @verifiableCredentialDescription.
  ///
  /// In en, this message translates to:
  /// **'Secured digital credentials that can be verified for authenticity'**
  String get verifiableCredentialDescription;

  /// No description provided for @secureAttachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Attachments'**
  String get secureAttachmentsTitle;

  /// No description provided for @credentialDetails.
  ///
  /// In en, this message translates to:
  /// **'Credential Details'**
  String get credentialDetails;

  /// No description provided for @genRCard.
  ///
  /// In en, this message translates to:
  /// **'R-Card'**
  String get genRCard;

  /// No description provided for @rCardPickIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the identity to share as an R-Card'**
  String get rCardPickIdentitySubtitle;

  /// No description provided for @rCardFooterSent.
  ///
  /// In en, this message translates to:
  /// **'R-Card has been sent.'**
  String get rCardFooterSent;

  /// No description provided for @rCardFooterSaved.
  ///
  /// In en, this message translates to:
  /// **'R-Card has been saved.'**
  String get rCardFooterSaved;

  /// No description provided for @rCardFooterUpdateShared.
  ///
  /// In en, this message translates to:
  /// **'R-Card update has been shared.'**
  String get rCardFooterUpdateShared;

  /// No description provided for @profileDetailsUpdateSharedGroup.
  ///
  /// In en, this message translates to:
  /// **'Profile details update has been shared with the group.'**
  String get profileDetailsUpdateSharedGroup;

  /// No description provided for @rCardFooterUpdateSaved.
  ///
  /// In en, this message translates to:
  /// **'R-Card update has been saved.'**
  String get rCardFooterUpdateSaved;

  /// No description provided for @rCardsExchanged.
  ///
  /// In en, this message translates to:
  /// **'R-Cards have been exchanged.'**
  String get rCardsExchanged;

  /// No description provided for @goToRCard.
  ///
  /// In en, this message translates to:
  /// **'Go to R-Card'**
  String get goToRCard;

  /// No description provided for @selectIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Identity'**
  String get selectIdentityTitle;

  /// No description provided for @selectIdentityInstruction.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to choose the identity you want to use to generate the R‑Card'**
  String get selectIdentityInstruction;

  /// No description provided for @sendRCard.
  ///
  /// In en, this message translates to:
  /// **'Send R-Card'**
  String get sendRCard;

  /// No description provided for @selectIdentityToVerifyRelationshipWithName.
  ///
  /// In en, this message translates to:
  /// **'Select the identity that you would like to use to verify your relationship with {name}.'**
  String selectIdentityToVerifyRelationshipWithName(String name);

  /// No description provided for @verifiableRelationshipCredential.
  ///
  /// In en, this message translates to:
  /// **'Verifiable Relationship Credential'**
  String get verifiableRelationshipCredential;

  /// No description provided for @vrcAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'VRC'**
  String get vrcAbbreviation;

  /// No description provided for @vrcDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Relationship Credential'**
  String get vrcDetailsTitle;

  /// No description provided for @vrcSectionIssuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get vrcSectionIssuer;

  /// No description provided for @vrcSectionHolder.
  ///
  /// In en, this message translates to:
  /// **'Issued to'**
  String get vrcSectionHolder;

  /// No description provided for @vrcSectionMetadata.
  ///
  /// In en, this message translates to:
  /// **'Credential Details'**
  String get vrcSectionMetadata;

  /// No description provided for @vrcFieldDid.
  ///
  /// In en, this message translates to:
  /// **'DID'**
  String get vrcFieldDid;

  /// No description provided for @vrcFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get vrcFieldName;

  /// No description provided for @vrcFieldIssuedAt.
  ///
  /// In en, this message translates to:
  /// **'Issued On'**
  String get vrcFieldIssuedAt;

  /// No description provided for @vrcFieldVerifiedAt.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get vrcFieldVerifiedAt;

  /// No description provided for @vrcFieldTypes.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get vrcFieldTypes;

  /// No description provided for @vrcDescription.
  ///
  /// In en, this message translates to:
  /// **'This credential verifies the relationship between two parties.'**
  String get vrcDescription;

  /// No description provided for @verifyRelationshipPrompt.
  ///
  /// In en, this message translates to:
  /// **'Verify your relationship with {firstName} by issuing a Verifiable Relationship Credential (VRC). Each VRC exchange increases your trust score.'**
  String verifyRelationshipPrompt(String firstName);

  /// No description provided for @generateVrc.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get generateVrc;

  /// No description provided for @generalVerify.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get generalVerify;

  /// No description provided for @doLater.
  ///
  /// In en, this message translates to:
  /// **'Do later'**
  String get doLater;

  /// No description provided for @vrcExchangeInitiated.
  ///
  /// In en, this message translates to:
  /// **'You\'ve initiated the VRC exchange.'**
  String get vrcExchangeInitiated;

  /// No description provided for @vrcRequestReceived.
  ///
  /// In en, this message translates to:
  /// **'{name} has initiated the VRC exchange.'**
  String vrcRequestReceived(String name);

  /// No description provided for @vrcDoLater.
  ///
  /// In en, this message translates to:
  /// **'VRC exchange is paused. Tap + and select \'Verifiable Relationship Credential\' to resume.'**
  String get vrcDoLater;

  /// No description provided for @vrcExchangeCompleted.
  ///
  /// In en, this message translates to:
  /// **'You have successfully verified your relationship'**
  String get vrcExchangeCompleted;

  /// No description provided for @vrcVerifyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to verify your relationship with {name}? Each VRC exchange increases your trust score.'**
  String vrcVerifyPrompt(String name);

  /// No description provided for @vrcStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get vrcStartNow;

  /// No description provided for @vrcDoLaterButton.
  ///
  /// In en, this message translates to:
  /// **'Do Later'**
  String get vrcDoLaterButton;

  /// No description provided for @vrcYesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get vrcYesButton;

  /// No description provided for @nameSelectedIdentity.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s selected identity'**
  String nameSelectedIdentity(String name);

  /// No description provided for @selectIdentityToVerifyRelationshipPrompt.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to choose the identity you want to use to verify your relationship with {name}.'**
  String selectIdentityToVerifyRelationshipPrompt(String name);

  /// No description provided for @sendVrc.
  ///
  /// In en, this message translates to:
  /// **'Send Relationship Credential'**
  String get sendVrc;

  /// No description provided for @trustedBy.
  ///
  /// In en, this message translates to:
  /// **'Trusted by {count}'**
  String trustedBy(int count);

  /// No description provided for @humanZkp.
  ///
  /// In en, this message translates to:
  /// **'Human Zero Knowledge Proof'**
  String get humanZkp;

  /// No description provided for @humanZkpAbbreviated.
  ///
  /// In en, this message translates to:
  /// **'Human ZKP'**
  String get humanZkpAbbreviated;

  /// No description provided for @humanZeroKnowledgeProof.
  ///
  /// In en, this message translates to:
  /// **'Human Zero Knowledge Proof'**
  String get humanZeroKnowledgeProof;

  /// No description provided for @livenessCredential.
  ///
  /// In en, this message translates to:
  /// **'Liveness Credential'**
  String get livenessCredential;

  /// No description provided for @verifiableCredentialWallet.
  ///
  /// In en, this message translates to:
  /// **'Verifiable Credential wallet'**
  String get verifiableCredentialWallet;

  /// No description provided for @noCredentialsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any credentials yet.'**
  String get noCredentialsYet;

  /// Credentials tab listing the member's community membership cards
  ///
  /// In en, this message translates to:
  /// **'Memberships'**
  String get membershipsTab;

  /// Shown instead of membership cards when no VTA is linked
  ///
  /// In en, this message translates to:
  /// **'Link your VTA to see your membership cards.'**
  String get membershipCredentialsVtaMissing;

  /// Shown instead of membership cards when the VTA cannot be reached
  ///
  /// In en, this message translates to:
  /// **'Your VTA couldn\'t be reached, so your membership cards can\'t be shown.'**
  String get membershipCredentialsUnreachable;

  /// Shown when the member holds no membership card
  ///
  /// In en, this message translates to:
  /// **'No membership cards yet. Join a community to get one.'**
  String get membershipCredentialsNone;

  /// Stands for a community whose name is not known
  ///
  /// In en, this message translates to:
  /// **'A community'**
  String get membershipCredentialUnnamed;

  /// Stands for an identity of the member that this phone does not hold
  ///
  /// In en, this message translates to:
  /// **'an identity not on this phone'**
  String get membershipCredentialOtherIdentity;

  /// Which identity of the member a membership card is for
  ///
  /// In en, this message translates to:
  /// **'as {identity}'**
  String membershipCredentialAs(String identity);

  /// When a membership card stops holding
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String membershipCredentialUntil(String date);

  /// When the member left the community of a membership card
  ///
  /// In en, this message translates to:
  /// **'left {date}'**
  String membershipCredentialLeft(String date);

  /// Status chip while the phone asks the community about a card
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get membershipStatusChecking;

  /// Status chip: the community still holds the card
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get membershipStatusValid;

  /// Status chip: the community revoked the card
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get membershipStatusRevoked;

  /// Status chip: the card's validity ended
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get membershipStatusExpired;

  /// Status chip: the community gave the card no status list
  ///
  /// In en, this message translates to:
  /// **'Can\'t be revoked'**
  String get membershipStatusNotRevocable;

  /// Status chip: the community's status list could not be read
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check'**
  String get membershipStatusUnknown;

  /// Title of a membership card's details
  ///
  /// In en, this message translates to:
  /// **'Membership card'**
  String get membershipDetailsTitle;

  /// Button under a membership card's trail: opens the community in this app
  ///
  /// In en, this message translates to:
  /// **'Open community'**
  String get membershipOpenCommunity;

  /// Button under a membership card's trail: opens the community's website in the browser
  ///
  /// In en, this message translates to:
  /// **'Visit website'**
  String get membershipOpenWebsite;

  /// Trail step: the community issued the membership card
  ///
  /// In en, this message translates to:
  /// **'Issued by {community}'**
  String membershipTrailIssued(String community);

  /// Trail step summary: for which identity and when the community signed the card
  ///
  /// In en, this message translates to:
  /// **'Your membership card for {identity}, signed by {community} on {date}'**
  String membershipTrailIssuedSummary(
    String identity,
    String community,
    String date,
  );

  /// Trail step summary: for which identity the community signed the card, when the card gives no date
  ///
  /// In en, this message translates to:
  /// **'Your membership card for {identity}, signed by {community}'**
  String membershipTrailIssuedSummaryUndated(String identity, String community);

  /// Trail detail: the identity the membership card is for
  ///
  /// In en, this message translates to:
  /// **'Card is for'**
  String get membershipTrailMember;

  /// Trail detail: when the membership card starts to hold
  ///
  /// In en, this message translates to:
  /// **'Valid from'**
  String get membershipTrailValidFrom;

  /// Title of the sheet that shows the membership card in full
  ///
  /// In en, this message translates to:
  /// **'Your membership card'**
  String get membershipTrailCardDocument;

  /// Who did a trail step: the member's VTA
  ///
  /// In en, this message translates to:
  /// **'Your VTA'**
  String get membershipTrailYourVta;

  /// Who did a trail step: this phone, without the VTA
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get membershipTrailThisPhone;

  /// Trail step: the member's VTA keeps the membership card
  ///
  /// In en, this message translates to:
  /// **'Kept on your VTA'**
  String get membershipTrailKept;

  /// Trail step summary: the VTA holds the card, and when this screen read it from there
  ///
  /// In en, this message translates to:
  /// **'Your VTA holds the card for {identity} · read from it at {time}'**
  String membershipTrailKeptSummary(String identity, String time);

  /// Trail step summary: the VTA archived the card when the member left
  ///
  /// In en, this message translates to:
  /// **'Your VTA put the card away when you left'**
  String get membershipTrailPutAway;

  /// Trail step: the member left the community
  ///
  /// In en, this message translates to:
  /// **'You left {community}'**
  String membershipTrailLeft(String community);

  /// Who did the leave step: the VTA signed, then the community answered
  ///
  /// In en, this message translates to:
  /// **'Your VTA, then {community}'**
  String membershipTrailLeftActor(String community);

  /// Trail step summary: the VTA signed the leave, and the community confirmed it and says what it keeps
  ///
  /// In en, this message translates to:
  /// **'Your VTA signed it as your identity · {community} confirmed it and {keeps}'**
  String membershipTrailLeftSummary(String community, String keeps);

  /// What the community keeps after the member left: nothing
  ///
  /// In en, this message translates to:
  /// **'keeps nothing about you'**
  String get membershipTrailKeepsNothing;

  /// What the community keeps after the member left: a tombstone
  ///
  /// In en, this message translates to:
  /// **'keeps only a note that you were a member'**
  String get membershipTrailKeepsNote;

  /// What the community keeps after the member left: the historical record
  ///
  /// In en, this message translates to:
  /// **'keeps your membership as history'**
  String get membershipTrailKeepsHistory;

  /// What the community keeps after the member left, when its answer names something unknown
  ///
  /// In en, this message translates to:
  /// **'keeps what its rules say'**
  String get membershipTrailKeepsUnknown;

  /// Trail step summary when the community already counted the member as no member
  ///
  /// In en, this message translates to:
  /// **'{community} already counted you as no member, so there is no receipt'**
  String membershipTrailLeftNoReceipt(String community);

  /// Title of the sheet that shows the signed leave request and the community's answer
  ///
  /// In en, this message translates to:
  /// **'Your leave and its receipt'**
  String get membershipTrailLeftDocument;

  /// Trail step: this phone asked the community whether the card still holds
  ///
  /// In en, this message translates to:
  /// **'Checked with {community}'**
  String membershipTrailChecked(String community);

  /// Trail step summary start: this phone, not the VTA, asked the community
  ///
  /// In en, this message translates to:
  /// **'This phone asked {community} directly, without your VTA'**
  String membershipTrailCheckDirect(String community);

  /// Trail step summary while this phone asks the community
  ///
  /// In en, this message translates to:
  /// **'This phone is asking {community}, without your VTA…'**
  String membershipTrailChecking(String community);

  /// Trail step summary: the community's signed status list shows the card revoked
  ///
  /// In en, this message translates to:
  /// **'{community} has revoked this card · its signed list says so, checked at {time}'**
  String membershipTrailRevoked(String community, String time);

  /// Trail step summary: the community's signed status list shows the card valid
  ///
  /// In en, this message translates to:
  /// **'Still valid · checked at {time}'**
  String membershipTrailValid(String time);

  /// Trail step summary: the community's status list could not be read
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {community}'**
  String membershipTrailUnreachable(String community);

  /// Trail step summary: what the last list read showed, revoked
  ///
  /// In en, this message translates to:
  /// **'last checked at {time}, it was revoked'**
  String membershipTrailLastRevoked(String time);

  /// Trail step summary: what the last list read showed, valid
  ///
  /// In en, this message translates to:
  /// **'last checked at {time}, it was valid'**
  String membershipTrailLastValid(String time);

  /// Trail step summary: the card names no status list
  ///
  /// In en, this message translates to:
  /// **'This card can\'t be revoked: {community} gave it no status list'**
  String membershipTrailNotRevocable(String community);

  /// Trail step summary: the card expired, so it was not checked
  ///
  /// In en, this message translates to:
  /// **'Its validity ended on {date}, so it no longer holds'**
  String membershipTrailExpired(String date);

  /// Trail detail: where the community publishes its status list
  ///
  /// In en, this message translates to:
  /// **'Status list'**
  String get membershipTrailStatusList;

  /// Trail detail: the card's place in the community's status list
  ///
  /// In en, this message translates to:
  /// **'Place in the list'**
  String get membershipTrailStatusIndex;

  /// Trail detail: when this phone read the status list
  ///
  /// In en, this message translates to:
  /// **'Checked at'**
  String get membershipTrailCheckedAt;

  /// Title of the sheet that shows the community's signed status list
  ///
  /// In en, this message translates to:
  /// **'{community}\'s signed status list'**
  String membershipTrailStatusDocument(String community);

  /// Trail detail: the id under which the VTA keeps the card
  ///
  /// In en, this message translates to:
  /// **'Kept under'**
  String get membershipTrailStoredId;

  /// Trail detail: what the VTA files the card under, e.g. membership
  ///
  /// In en, this message translates to:
  /// **'Filed as'**
  String get membershipTrailStoredPurpose;

  /// Trail detail: whether the VTA holds the card valid, as it last read
  ///
  /// In en, this message translates to:
  /// **'Your VTA holds it as'**
  String get membershipTrailStoredStatus;

  /// Trail detail: the card's credential types, as the VTA records them
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get membershipTrailStoredTypes;

  /// Diagram party: the community, named generally
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get membershipFlowCommunity;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @generatingZeroKnowledgeProof.
  ///
  /// In en, this message translates to:
  /// **'Generating Human Zero Knowledge Proof...'**
  String get generatingZeroKnowledgeProof;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @generateCredential.
  ///
  /// In en, this message translates to:
  /// **'Generate credential'**
  String get generateCredential;

  /// No description provided for @generateProof.
  ///
  /// In en, this message translates to:
  /// **'Generate proof'**
  String get generateProof;

  /// No description provided for @livenessCredentialRequest.
  ///
  /// In en, this message translates to:
  /// **'Liveness Credential Request'**
  String get livenessCredentialRequest;

  /// No description provided for @livenessCheckDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Liveness Check (Demo Mode)'**
  String get livenessCheckDemoMode;

  /// No description provided for @searchingForLivenessCredential.
  ///
  /// In en, this message translates to:
  /// **'Searching for Liveness Credential...'**
  String get searchingForLivenessCredential;

  /// No description provided for @noLivenessCredentialFound.
  ///
  /// In en, this message translates to:
  /// **'No Liveness Credential was found.\n\nTo continue, a mock Liveness Credential will be generated locally.\nThis credential is used to demonstrate how a Human Zero Knowledge Proof (ZKP) is derived.'**
  String get noLivenessCredentialFound;

  /// No description provided for @livenessCheckDemoModeNote.
  ///
  /// In en, this message translates to:
  /// **'This reference app runs in demo mode and does not perform a real liveness check.'**
  String get livenessCheckDemoModeNote;

  /// No description provided for @livenessCheckInProgress.
  ///
  /// In en, this message translates to:
  /// **'Liveness Check in progress...'**
  String get livenessCheckInProgress;

  /// No description provided for @livenessCheckSimulatedFlow.
  ///
  /// In en, this message translates to:
  /// **'This is a simulated flow for development and demonstration purposes only.'**
  String get livenessCheckSimulatedFlow;

  /// No description provided for @mockLivenessCredentialGenerated.
  ///
  /// In en, this message translates to:
  /// **'A mock Liveness Credential has been generated and securely stored under the Credentials tab.'**
  String get mockLivenessCredentialGenerated;

  /// No description provided for @mockLivenessCredentialNext.
  ///
  /// In en, this message translates to:
  /// **'You can now continue to generate a Human Zero Knowledge Proof.'**
  String get mockLivenessCredentialNext;

  /// No description provided for @livenessEvidenceThresholdNotMet.
  ///
  /// In en, this message translates to:
  /// **'Liveness check did not meet the required threshold. Please try again.'**
  String get livenessEvidenceThresholdNotMet;

  /// No description provided for @livenessCredentialSessionMissing.
  ///
  /// In en, this message translates to:
  /// **'Your liveness credential is not available in this app session. Generate a new credential and try again.'**
  String get livenessCredentialSessionMissing;

  /// No description provided for @issuedTo.
  ///
  /// In en, this message translates to:
  /// **'Issued to'**
  String get issuedTo;

  /// No description provided for @types.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get types;

  /// No description provided for @issuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuer;

  /// No description provided for @issuedOn.
  ///
  /// In en, this message translates to:
  /// **'Issued on'**
  String get issuedOn;

  /// No description provided for @human.
  ///
  /// In en, this message translates to:
  /// **'Human'**
  String get human;

  /// No description provided for @proofFlowThisContact.
  ///
  /// In en, this message translates to:
  /// **'this contact'**
  String get proofFlowThisContact;

  /// No description provided for @proofFlowContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get proofFlowContact;

  /// No description provided for @proofFlowCheckIfHuman.
  ///
  /// In en, this message translates to:
  /// **'Check if {contactName} is human using a Zero‑Knowledge Proof (ZKP) derived from a Liveness Credential.'**
  String proofFlowCheckIfHuman(String contactName);

  /// No description provided for @proofFlowRequestProof.
  ///
  /// In en, this message translates to:
  /// **'Request proof'**
  String get proofFlowRequestProof;

  /// No description provided for @proofFlowVerifyingProof.
  ///
  /// In en, this message translates to:
  /// **'Verifying proof from {contactName}...'**
  String proofFlowVerifyingProof(String contactName);

  /// No description provided for @proofFlowVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed for {contactName}'**
  String proofFlowVerificationFailed(String contactName);

  /// No description provided for @zkpNoticePaused.
  ///
  /// In en, this message translates to:
  /// **'You paused a Human Zero Knowledge Proof request.'**
  String get zkpNoticePaused;

  /// No description provided for @zkpNoticeDeclined.
  ///
  /// In en, this message translates to:
  /// **'{contactName} has declined the Human Zero Knowledge Proof request. Tap the \"+\" icon to restart it.'**
  String zkpNoticeDeclined(String contactName);

  /// No description provided for @zkpNoticeShared.
  ///
  /// In en, this message translates to:
  /// **'You have shared a Zero‑Knowledge Proof confirming you are human.\n*No personal data was shared.'**
  String get zkpNoticeShared;

  /// No description provided for @zkpNoticeReceived.
  ///
  /// In en, this message translates to:
  /// **'{contactName} has shared a Zero‑Knowledge Proof confirming they are human.'**
  String zkpNoticeReceived(String contactName);

  /// No description provided for @zkpNoticeRequest.
  ///
  /// In en, this message translates to:
  /// **'{contactName} has requested a Human Zero Knowledge Proof to confirm you are human. You can generate the proof using an existing Liveness Credential or complete a quick liveness check.'**
  String zkpNoticeRequest(String contactName);

  /// No description provided for @zkpNoticeRequestInitiated.
  ///
  /// In en, this message translates to:
  /// **'You have initiated a Human Zero Knowledge Proof request.'**
  String get zkpNoticeRequestInitiated;

  /// No description provided for @zkpProofAlreadyShared.
  ///
  /// In en, this message translates to:
  /// **'ZKP Proof already shared'**
  String get zkpProofAlreadyShared;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMemberConfirm;

  /// No description provided for @removeMemberNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Removing members isn\'t supported yet.'**
  String get removeMemberNotSupported;

  /// No description provided for @removeMemberSuccess.
  ///
  /// In en, this message translates to:
  /// **'Member removed from group.'**
  String get removeMemberSuccess;

  /// Label for the video attachment plugin
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get generalVideo;

  /// Label for the voice message attachment plugin
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get generalVoice;

  /// Label for the document attachment plugin
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get generalDocument;

  /// Hint shown on document attachment before download
  ///
  /// In en, this message translates to:
  /// **'Tap to download'**
  String get documentTapToDownload;

  /// Error shown when video cannot be played
  ///
  /// In en, this message translates to:
  /// **'Unable to play video'**
  String get videoLoadingError;

  /// Action label shown over a failed media attachment download, prompting the user to retry
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get mediaTapToRetry;

  /// Status label shown on a document attachment when its download fails, prompting the user to retry
  ///
  /// In en, this message translates to:
  /// **'Download failed. Tap to retry'**
  String get mediaDownloadFailedTapToRetry;

  /// Snackbar shown when a picked attachment exceeds the byte-size cap
  ///
  /// In en, this message translates to:
  /// **'Attachment is too large. Maximum size is {maxMb} MB.'**
  String attachmentTooLarge(int maxMb);

  /// Snackbar shown when the picker returns a file that is not an allowed image or video type
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type.'**
  String get unsupportedFileType;

  /// Snackbar shown when voice-message recording cannot start because microphone permission is denied
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record voice messages.'**
  String get voiceMessagePermissionDenied;

  /// Snackbar shown when voice-message recording fails to start
  ///
  /// In en, this message translates to:
  /// **'Unable to start voice recording.'**
  String get voiceMessageRecordingFailed;

  /// Snackbar shown when a recorded voice message could not be sent
  ///
  /// In en, this message translates to:
  /// **'Unable to send voice message.'**
  String get voiceMessageSendFailed;

  /// No description provided for @generalEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get generalEmail;

  /// No description provided for @vrcResponderIntro.
  ///
  /// In en, this message translates to:
  /// **'{name} has selected the following persona to verify the relationship:'**
  String vrcResponderIntro(Object name);

  /// No description provided for @videoCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get videoCallTitle;

  /// No description provided for @videoCallJoiningCall.
  ///
  /// In en, this message translates to:
  /// **'Joining call...'**
  String get videoCallJoiningCall;

  /// No description provided for @videoCallWaitingForParticipants.
  ///
  /// In en, this message translates to:
  /// **'Waiting for participants...'**
  String get videoCallWaitingForParticipants;

  /// No description provided for @videoCallShowMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 more} other{Show {count} more}}'**
  String videoCallShowMore(int count);

  /// No description provided for @videoCallShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get videoCallShowLess;

  /// No description provided for @videoCallError.
  ///
  /// In en, this message translates to:
  /// **'{errorCode, select, channelNotFound{Call channel not found} tokenFetchFailed{Failed to get call credentials} connectionFailed{Failed to connect to the call. Check room access or try again.} groupCallPermissionDenied{You do not have permission to join this group call. Check room access or ask a group admin.} callInviteFailed{Failed to notify other participants about the call} networkError{Network error} unexpected{Unexpected call error} other{Unknown error}}'**
  String videoCallError(String errorCode);

  /// No description provided for @videoCallMicToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change the microphone. Please try again.'**
  String get videoCallMicToggleFailed;

  /// No description provided for @videoCallCameraToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change the camera. Please try again.'**
  String get videoCallCameraToggleFailed;

  /// No description provided for @videoCallSpeakerToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change the speaker. Please try again.'**
  String get videoCallSpeakerToggleFailed;

  /// No description provided for @videoCallMemberNamesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load participant names.'**
  String get videoCallMemberNamesFailed;

  /// No description provided for @videoCallHangUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t hang up. Please try again.'**
  String get videoCallHangUpFailed;

  /// No description provided for @videoCallParticipantCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String videoCallParticipantCount(int count);

  /// No description provided for @videoCallMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get videoCallMute;

  /// No description provided for @videoCallUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get videoCallUnmute;

  /// No description provided for @videoCallEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get videoCallEnd;

  /// No description provided for @videoCallMicPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied. Enable it in Settings.'**
  String get videoCallMicPermissionDenied;

  /// No description provided for @videoCallCameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied. Enable it in Settings.'**
  String get videoCallCameraPermissionDenied;

  /// No description provided for @videoCallWaitingForEncryption.
  ///
  /// In en, this message translates to:
  /// **'Setting up encryption...'**
  String get videoCallWaitingForEncryption;

  /// No description provided for @videoCallYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get videoCallYou;

  /// No description provided for @videoCallRinging.
  ///
  /// In en, this message translates to:
  /// **'Ringing'**
  String get videoCallRinging;

  /// No description provided for @videoCallCalling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get videoCallCalling;

  /// No description provided for @videoCallCancelCall.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get videoCallCancelCall;

  /// No description provided for @videoCallNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get videoCallNoAnswer;

  /// No description provided for @videoCallCallDeclined.
  ///
  /// In en, this message translates to:
  /// **'Call declined'**
  String get videoCallCallDeclined;

  /// No description provided for @videoCallCallFailed.
  ///
  /// In en, this message translates to:
  /// **'Call failed'**
  String get videoCallCallFailed;

  /// No description provided for @videoCallCallEnded.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get videoCallCallEnded;

  /// No description provided for @videoCallCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get videoCallCancel;

  /// No description provided for @videoCallAgain.
  ///
  /// In en, this message translates to:
  /// **'Call again'**
  String get videoCallAgain;

  /// No description provided for @videoCallGroupCallJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get videoCallGroupCallJoin;

  /// No description provided for @videoCallGroupCallActive.
  ///
  /// In en, this message translates to:
  /// **'Group call in progress'**
  String get videoCallGroupCallActive;

  /// No description provided for @videoCallOngoingCall.
  ///
  /// In en, this message translates to:
  /// **'Ongoing call ({count})'**
  String videoCallOngoingCall(int count);

  /// No description provided for @videoCallSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch to video'**
  String get videoCallSwitch;

  /// No description provided for @videoCallSwitchToVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to video call'**
  String get videoCallSwitchToVideoTitle;

  /// No description provided for @incomingCallBannerIsCalling.
  ///
  /// In en, this message translates to:
  /// **'{callerName} is calling'**
  String incomingCallBannerIsCalling(String callerName);

  /// No description provided for @incomingCallBannerAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get incomingCallBannerAccept;

  /// No description provided for @incomingCallBannerDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get incomingCallBannerDecline;

  /// No description provided for @incomingCallBannerUnknownCaller.
  ///
  /// In en, this message translates to:
  /// **'Unknown caller'**
  String get incomingCallBannerUnknownCaller;

  /// No description provided for @incomingCallBannerAudioCall.
  ///
  /// In en, this message translates to:
  /// **'MeetingPlace Audio'**
  String get incomingCallBannerAudioCall;

  /// No description provided for @incomingCallBannerVideoCall.
  ///
  /// In en, this message translates to:
  /// **'MeetingPlace Video'**
  String get incomingCallBannerVideoCall;

  /// No description provided for @callChatItemAudioCall.
  ///
  /// In en, this message translates to:
  /// **'Audio call'**
  String get callChatItemAudioCall;

  /// No description provided for @callChatItemVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get callChatItemVideoCall;

  /// No description provided for @callChatItemCalling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get callChatItemCalling;

  /// No description provided for @callChatItemRinging.
  ///
  /// In en, this message translates to:
  /// **'Ringing'**
  String get callChatItemRinging;

  /// No description provided for @callChatItemIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get callChatItemIncoming;

  /// No description provided for @callChatItemTapToReturn.
  ///
  /// In en, this message translates to:
  /// **'Tap to return'**
  String get callChatItemTapToReturn;

  /// No description provided for @callChatItemMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get callChatItemMissed;

  /// No description provided for @callChatItemNotAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get callChatItemNotAnswered;

  /// No description provided for @callChatItemDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get callChatItemDeclined;

  /// No description provided for @callChatItemGroupOngoingVideo.
  ///
  /// In en, this message translates to:
  /// **'Ongoing video call ({count})'**
  String callChatItemGroupOngoingVideo(int count);

  /// No description provided for @callChatItemGroupOngoingAudio.
  ///
  /// In en, this message translates to:
  /// **'Ongoing audio call ({count})'**
  String callChatItemGroupOngoingAudio(int count);

  /// No description provided for @callChatItemYouLeft.
  ///
  /// In en, this message translates to:
  /// **'You left'**
  String get callChatItemYouLeft;

  /// No description provided for @callLogScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Call log'**
  String get callLogScreenTitle;

  /// No description provided for @callLogScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your past audio and video calls.'**
  String get callLogScreenSubtitle;

  /// No description provided for @callLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No calls yet.'**
  String get callLogEmpty;

  /// No description provided for @callLogParticipantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String callLogParticipantsCount(int count);

  /// Participants label for a group call log entry when only some participant DIDs resolved to a known contact
  ///
  /// In en, this message translates to:
  /// **'{names} and {othersCount, plural, =1{1 other} other{{othersCount} others}}'**
  String callLogParticipantsNamesAndOthers(String names, int othersCount);

  /// Status text shown in the Call log for a call that is still ongoing
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get callLogInProgress;

  /// Message shown in the Call log screen when loading past calls fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load call log.'**
  String get callLogError;

  /// No description provided for @callDurationHourFormat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 h} other{{count} h}}'**
  String callDurationHourFormat(int count);

  /// No description provided for @callDurationMinuteFormat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 m} other{{count} m}}'**
  String callDurationMinuteFormat(int count);

  /// No description provided for @callDurationSecondFormat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 s} other{{count} s}}'**
  String callDurationSecondFormat(int count);

  /// No description provided for @groupCallWaitingForOthers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for others...'**
  String get groupCallWaitingForOthers;

  /// No description provided for @groupCallParticipant.
  ///
  /// In en, this message translates to:
  /// **'participant'**
  String get groupCallParticipant;

  /// No description provided for @groupCallParticipants.
  ///
  /// In en, this message translates to:
  /// **'participants'**
  String get groupCallParticipants;

  /// No description provided for @groupCallEndCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get groupCallEndCall;

  /// No description provided for @groupCallNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'No participants'**
  String get groupCallNoParticipants;

  /// No description provided for @groupCallMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get groupCallMute;

  /// No description provided for @groupCallLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get groupCallLeave;

  /// No description provided for @videoCallMuted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get videoCallMuted;

  /// No description provided for @videoCallPeerMuted.
  ///
  /// In en, this message translates to:
  /// **'{peerName} is muted'**
  String videoCallPeerMuted(String peerName);

  /// No description provided for @callParticipantsConnectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} connected'**
  String callParticipantsConnectedCount(int count);

  /// No description provided for @callParticipantsConnectedSection.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get callParticipantsConnectedSection;

  /// No description provided for @callParticipantsNotConnectedSection.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get callParticipantsNotConnectedSection;

  /// No description provided for @callParticipantCallAction.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String callParticipantCallAction(String name);

  /// No description provided for @callParticipantRingingAction.
  ///
  /// In en, this message translates to:
  /// **'Ringing {name}'**
  String callParticipantRingingAction(String name);

  /// No description provided for @linkedVtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked VTA'**
  String get linkedVtaTitle;

  /// No description provided for @linkedVtaHelperText.
  ///
  /// In en, this message translates to:
  /// **'Link your Verifiable Trust Agent (VTA) so Meeting Place can act for you with it.'**
  String get linkedVtaHelperText;

  /// No description provided for @linkedVtaDidLabel.
  ///
  /// In en, this message translates to:
  /// **'VTA DID'**
  String get linkedVtaDidLabel;

  /// No description provided for @linkedVtaLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get linkedVtaLinkAction;

  /// No description provided for @linkedVtaInvalidDid.
  ///
  /// In en, this message translates to:
  /// **'Enter the DID of your VTA, for example did:webvh:…'**
  String get linkedVtaInvalidDid;

  /// No description provided for @linkedVtaUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Your VTA couldn\'t be reached.'**
  String get linkedVtaUnreachable;

  /// No description provided for @linkedVtaAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'A VTA is already linked. Remove it before linking another one.'**
  String get linkedVtaAlreadyLinked;

  /// No description provided for @linkedVtaBadAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your VTA\'s answer couldn\'t be verified.'**
  String get linkedVtaBadAnswer;

  /// No description provided for @linkedVtaScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your VTA'**
  String get linkedVtaScreenTitle;

  /// No description provided for @linkedVtaPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Add this phone to your VTA'**
  String get linkedVtaPendingTitle;

  /// No description provided for @linkedVtaManagerDidLabel.
  ///
  /// In en, this message translates to:
  /// **'This phone\'s DID'**
  String get linkedVtaManagerDidLabel;

  /// No description provided for @linkedVtaCopyDid.
  ///
  /// In en, this message translates to:
  /// **'Copy DID'**
  String get linkedVtaCopyDid;

  /// No description provided for @linkedVtaGrantInstruction.
  ///
  /// In en, this message translates to:
  /// **'Ask your VTA admin to grant this DID by running:'**
  String get linkedVtaGrantInstruction;

  /// No description provided for @linkedVtaGrantWarning.
  ///
  /// In en, this message translates to:
  /// **'This makes Meeting Place an admin of your VTA, able to create and use your identities (persona-holder). Only grant it to a phone you own.'**
  String get linkedVtaGrantWarning;

  /// No description provided for @linkedVtaCopyCommand.
  ///
  /// In en, this message translates to:
  /// **'Copy command'**
  String get linkedVtaCopyCommand;

  /// No description provided for @linkedVtaWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your admin…'**
  String get linkedVtaWaiting;

  /// No description provided for @linkedVtaWaitingForPersonaHolder.
  ///
  /// In en, this message translates to:
  /// **'Admin role granted. Waiting for the persona-holder capability…'**
  String get linkedVtaWaitingForPersonaHolder;

  /// No description provided for @linkedVtaStillTrying.
  ///
  /// In en, this message translates to:
  /// **'Your VTA couldn\'t be reached. Still trying…'**
  String get linkedVtaStillTrying;

  /// No description provided for @linkedVtaStoppedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Stopped checking after 10 minutes.'**
  String get linkedVtaStoppedWaiting;

  /// No description provided for @linkedVtaCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get linkedVtaCheckAgain;

  /// No description provided for @linkedVtaNoDidcomm.
  ///
  /// In en, this message translates to:
  /// **'Your VTA doesn\'t offer DIDComm, which Meeting Place uses to talk to it. Ask its admin to enable DIDComm with a mediator.'**
  String get linkedVtaNoDidcomm;

  /// No description provided for @linkedVtaScanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan code from your VTA host'**
  String get linkedVtaScanAction;

  /// No description provided for @linkedVtaManualHint.
  ///
  /// In en, this message translates to:
  /// **'Or paste the enrolment link from your VTA host, or your VTA\'s DID:'**
  String get linkedVtaManualHint;

  /// No description provided for @linkedVtaFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Enrolment link or VTA DID'**
  String get linkedVtaFieldLabel;

  /// No description provided for @linkedVtaEnrolmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare the codes'**
  String get linkedVtaEnrolmentTitle;

  /// No description provided for @linkedVtaEnrolmentCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code on this phone'**
  String get linkedVtaEnrolmentCodeLabel;

  /// No description provided for @linkedVtaEnrolmentInstruction.
  ///
  /// In en, this message translates to:
  /// **'Your VTA host shows a code too. Your VTA admin must check that it is exactly this code before granting access.'**
  String get linkedVtaEnrolmentInstruction;

  /// No description provided for @linkedVtaEnrolmentWarning.
  ///
  /// In en, this message translates to:
  /// **'If the codes differ, someone else\'s key was submitted: don\'t grant access, and cancel here.'**
  String get linkedVtaEnrolmentWarning;

  /// No description provided for @linkedVtaWaitingForHost.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your admin to grant access on your VTA host…'**
  String get linkedVtaWaitingForHost;

  /// No description provided for @linkedVtaOfferMalformed.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a valid enrolment code. Scan the code your VTA host shows again.'**
  String get linkedVtaOfferMalformed;

  /// No description provided for @linkedVtaOfferUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This enrolment code is from a newer version of the VTA host. Update Meeting Place, or link your VTA by its DID.'**
  String get linkedVtaOfferUnsupported;

  /// No description provided for @linkedVtaOfferInsecure.
  ///
  /// In en, this message translates to:
  /// **'This enrolment code points to a host that isn\'t secured with HTTPS, so it can\'t be used.'**
  String get linkedVtaOfferInsecure;

  /// No description provided for @linkedVtaOfferExpired.
  ///
  /// In en, this message translates to:
  /// **'This enrolment code has expired. Ask your VTA host for a new one.'**
  String get linkedVtaOfferExpired;

  /// No description provided for @linkedVtaOfferUsed.
  ///
  /// In en, this message translates to:
  /// **'This enrolment code was already used. Ask your VTA host for a new one.'**
  String get linkedVtaOfferUsed;

  /// No description provided for @linkedVtaEnrolmentRejected.
  ///
  /// In en, this message translates to:
  /// **'Your VTA host didn\'t accept this phone. Ask it for a new enrolment code.'**
  String get linkedVtaEnrolmentRejected;

  /// No description provided for @linkedVtaCodeMismatch.
  ///
  /// In en, this message translates to:
  /// **'Your VTA host answered with a different code, so it didn\'t receive this phone\'s key. Ask it for a new enrolment code.'**
  String get linkedVtaCodeMismatch;

  /// No description provided for @linkedVtaHostUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Your VTA host couldn\'t be reached.'**
  String get linkedVtaHostUnreachable;

  /// No description provided for @linkedVtaEnrolmentRefused.
  ///
  /// In en, this message translates to:
  /// **'Your VTA admin refused access for this phone.'**
  String get linkedVtaEnrolmentRefused;

  /// No description provided for @linkedVtaEnrolmentExpired.
  ///
  /// In en, this message translates to:
  /// **'The enrolment code expired before your VTA admin granted access. Ask your VTA host for a new one.'**
  String get linkedVtaEnrolmentExpired;

  /// No description provided for @identityPersonaTitle.
  ///
  /// In en, this message translates to:
  /// **'Persona on your VTA'**
  String get identityPersonaTitle;

  /// No description provided for @identityPersonaHint.
  ///
  /// In en, this message translates to:
  /// **'Your VTA holds this identity\'s keys. Contacts never see this DID.'**
  String get identityPersonaHint;

  /// No description provided for @identityPersonaCopyDid.
  ///
  /// In en, this message translates to:
  /// **'Copy persona DID'**
  String get identityPersonaCopyDid;

  /// No description provided for @identityVtaSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Your VTA couldn\'t save this identity. Check it\'s reachable and try again.'**
  String get identityVtaSaveFailed;

  /// No description provided for @identityVtaDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Your VTA couldn\'t delete this identity. Check it\'s reachable and try again.'**
  String get identityVtaDeleteFailed;

  /// No description provided for @identityDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this identity?'**
  String get identityDeleteConfirmTitle;

  /// No description provided for @identityDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Its persona is deleted from your VTA, and its DID can never be used again.'**
  String get identityDeleteConfirmMessage;

  /// No description provided for @linkedVtaUnlinkAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get linkedVtaUnlinkAction;

  /// No description provided for @vtcSignInMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to community'**
  String get vtcSignInMenuTitle;

  /// No description provided for @vtcSignInMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Approve a sign-in code from your community\'s website'**
  String get vtcSignInMenuSubtitle;

  /// No description provided for @vtcSignInUseMembership.
  ///
  /// In en, this message translates to:
  /// **'Use this membership'**
  String get vtcSignInUseMembership;

  /// No description provided for @vtcSignInEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the two-digit number shown in your browser.'**
  String get vtcSignInEnterNumber;

  /// No description provided for @vtcSignInNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get vtcSignInNumberLabel;

  /// No description provided for @vtcSignInContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get vtcSignInContinue;

  /// No description provided for @vtcSignInReviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Approve this sign-in?'**
  String get vtcSignInReviewHeading;

  /// No description provided for @vtcSignInSameNetwork.
  ///
  /// In en, this message translates to:
  /// **'On the same network as this phone'**
  String get vtcSignInSameNetwork;

  /// No description provided for @vtcSignInOtherNetwork.
  ///
  /// In en, this message translates to:
  /// **'On a different network than this phone'**
  String get vtcSignInOtherNetwork;

  /// No description provided for @vtcSignInReportedNote.
  ///
  /// In en, this message translates to:
  /// **'Reported by the community. Only that one browser session will be signed in.'**
  String get vtcSignInReportedNote;

  /// No description provided for @vtcSignInApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get vtcSignInApprove;

  /// No description provided for @vtcSignInDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get vtcSignInDecline;

  /// No description provided for @vtcSignInApproved.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in on that browser.'**
  String get vtcSignInApproved;

  /// No description provided for @vtcSignInDeclined.
  ///
  /// In en, this message translates to:
  /// **'The sign-in was declined.'**
  String get vtcSignInDeclined;

  /// No description provided for @vtcSignInVtaMissing.
  ///
  /// In en, this message translates to:
  /// **'Link your VTA in Settings before signing in to a community.'**
  String get vtcSignInVtaMissing;

  /// No description provided for @vtcSignInDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get vtcSignInDone;

  /// Why a community sign-in could not go ahead
  ///
  /// In en, this message translates to:
  /// **'{reason, select, expired{This code has expired. Get a new one.} invalid{This code can\'t be used.} update{This code needs a newer version of the app.} unreachable{This community can\'t be reached from your phone.} notAMember{This sign-in code is from a community you haven\'t joined.} noSignIn{This community doesn\'t offer sign-in from the app.} alreadyClaimed{Another device already scanned this code. Refresh the sign-in page and scan the new code.} notFound{This sign-in has ended. Refresh the sign-in page and scan the new code.} refused{The community didn\'t accept this sign-in. Refresh the sign-in page and try again.} notAnAdmin{This identity isn\'t an administrator of this community.} badAnswer{The community\'s answer couldn\'t be checked, so nothing was signed in.} badNumber{Enter the two digits shown on the sign-in page.} wrongNumber{That isn\'t the number on the sign-in page. Refresh the page and scan the new code.} noVaultEntry{Your VTA isn\'t set up to sign in to this community yet.} notEnrolledDevice{This phone isn\'t registered with your VTA, so it can\'t sign in.} noUvKey{This phone isn\'t set up to approve sign-ins with your VTA yet.} uvRequired{Your VTA needs your approval on this phone to sign in.} uvCancelled{The sign-in wasn\'t approved.} uvKeyLost{Your Face ID or fingerprints changed, so approving sign-ins must be set up again. Unlink and link your VTA in Settings.} uvUnavailable{This phone couldn\'t approve the sign-in.} grantReplayed{This approval was already used. Refresh the sign-in page and scan the new code.} assertionMethodMissing{Your identity in this community can\'t approve sign-ins yet.} agentRefused{Your VTA refused this sign-in.} agentNeedsUpdate{Your VTA needs an update before it can sign you in to websites.} agentUnreachable{Your VTA couldn\'t be reached.} other{The community didn\'t accept this sign-in. Refresh the sign-in page and try again.}}'**
  String vtcSignInFailure(String reason);

  /// Why a scanned code cannot be used
  ///
  /// In en, this message translates to:
  /// **'{problem, select, update{This code needs a newer version of the app.} expired{This code has expired. Get a new one.} unreachable{This service can\'t be reached from your phone.} other{This code can\'t be used.}}'**
  String vtcSignInLinkProblem(String problem);

  /// Which page of the community the browser signs in to
  ///
  /// In en, this message translates to:
  /// **'{audience, select, admin{Operator console} other{Member portal}}'**
  String vtcSignInAudience(String audience);

  /// Heading of a community sign-in
  ///
  /// In en, this message translates to:
  /// **'Sign in to {community}'**
  String vtcSignInTitle(String community);

  /// The website being signed in to
  ///
  /// In en, this message translates to:
  /// **'Website: {origin}'**
  String vtcSignInWebsite(String origin);

  /// Asks to use a membership found on the VTA, above the identity card it signs in as
  ///
  /// In en, this message translates to:
  /// **'Your membership of {community} was found on your VTA. Sign in as this identity?'**
  String vtcSignInFoundMembership(String community);

  /// Seconds left to decide on a sign-in
  ///
  /// In en, this message translates to:
  /// **'{seconds} s left'**
  String vtcSignInTimeLeft(int seconds);

  /// Heading above the identity card being signed in
  ///
  /// In en, this message translates to:
  /// **'Signing in as'**
  String get vtcSignInAs;

  /// The browser asking to sign in, as reported
  ///
  /// In en, this message translates to:
  /// **'Browser: {browser} on {os}'**
  String vtcSignInBrowser(String browser, String os);

  /// Approximate location of the browser, as reported
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String vtcSignInLocation(String location);

  /// No description provided for @linkedVtaDidNotResolved.
  ///
  /// In en, this message translates to:
  /// **'Your VTA\'s DID couldn\'t be resolved from this phone. Check the DID, and that its host can be reached from this phone over HTTPS.'**
  String get linkedVtaDidNotResolved;

  /// No description provided for @vtcJoinMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a community'**
  String get vtcJoinMenuTitle;

  /// No description provided for @vtcJoinIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Become a member of a community'**
  String get vtcJoinIntroTitle;

  /// No description provided for @vtcJoinIntro.
  ///
  /// In en, this message translates to:
  /// **'Scan the community\'s QR code, paste its DID, or enter its join phrase. You see what it asks before anything is sent.'**
  String get vtcJoinIntro;

  /// No description provided for @vtcJoinDidHint.
  ///
  /// In en, this message translates to:
  /// **'Community DID or join phrase'**
  String get vtcJoinDidHint;

  /// No description provided for @vtcJoinScanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get vtcJoinScanAction;

  /// No description provided for @vtcJoinPasteAction.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get vtcJoinPasteAction;

  /// No description provided for @vtcJoinContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get vtcJoinContinueAction;

  /// No description provided for @vtcJoinMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a community\'s code and apply with your VTA'**
  String get vtcJoinMenuSubtitle;

  /// No description provided for @vtcJoinChooseIdentity.
  ///
  /// In en, this message translates to:
  /// **'Join with which identity?'**
  String get vtcJoinChooseIdentity;

  /// Asks to approve sharing the listed profile details with the community
  ///
  /// In en, this message translates to:
  /// **'Share these details with {name}?'**
  String vtcJoinShareDetails(String name);

  /// No description provided for @vtcJoinShareAction.
  ///
  /// In en, this message translates to:
  /// **'Share and apply'**
  String get vtcJoinShareAction;

  /// No description provided for @vtcJoinCredentialMissing.
  ///
  /// In en, this message translates to:
  /// **'Credential missing'**
  String get vtcJoinCredentialMissing;

  /// No description provided for @mockCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mock credentials'**
  String get mockCredentialsTitle;

  /// No description provided for @mockCredentialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test credentials for your identities'**
  String get mockCredentialsSubtitle;

  /// No description provided for @mockCredentialsNote.
  ///
  /// In en, this message translates to:
  /// **'This phone signs these as a test issuer. Import one for an identity, then join a community whose way in asks for it and accepts any issuer.'**
  String get mockCredentialsNote;

  /// No description provided for @mockCredentialsImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get mockCredentialsImport;

  /// No description provided for @mockCredentialsChooseIdentity.
  ///
  /// In en, this message translates to:
  /// **'Import for which identity?'**
  String get mockCredentialsChooseIdentity;

  /// No description provided for @mockCredentialsHeldBy.
  ///
  /// In en, this message translates to:
  /// **'Held by {name}'**
  String mockCredentialsHeldBy(String name);

  /// No description provided for @mockCredentialsImported.
  ///
  /// In en, this message translates to:
  /// **'Imported for {name}'**
  String mockCredentialsImported(String name);

  /// No description provided for @mockCredentialsNotKept.
  ///
  /// In en, this message translates to:
  /// **'Your VTA took the credential but doesn\'t keep it as valid.'**
  String get mockCredentialsNotKept;

  /// No description provided for @mockCredentialsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'The credential couldn\'t be imported: your VTA refused it or can\'t be reached.'**
  String get mockCredentialsImportFailed;

  /// No description provided for @mockCredentialsRefused.
  ///
  /// In en, this message translates to:
  /// **'Your VTA refused the credential: {reason}'**
  String mockCredentialsRefused(String reason);

  /// No description provided for @mockCredentialsNoIdentities.
  ///
  /// In en, this message translates to:
  /// **'Create an identity on your VTA to import a credential for it.'**
  String get mockCredentialsNoIdentities;

  /// No description provided for @mockCredentialsVtaMissing.
  ///
  /// In en, this message translates to:
  /// **'Link your VTA in Settings to import test credentials.'**
  String get mockCredentialsVtaMissing;

  /// No description provided for @mockCredentialsUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Your VTA can\'t be reached.'**
  String get mockCredentialsUnreachable;

  /// No description provided for @vtcJoinWayWithCredential.
  ///
  /// In en, this message translates to:
  /// **'With your {type}'**
  String vtcJoinWayWithCredential(String type);

  /// No description provided for @vtcJoinShareCredential.
  ///
  /// In en, this message translates to:
  /// **'Present this credential to {name}?'**
  String vtcJoinShareCredential(String name);

  /// No description provided for @vtcJoinCredentialIssuer.
  ///
  /// In en, this message translates to:
  /// **'Issued by'**
  String get vtcJoinCredentialIssuer;

  /// No description provided for @vtcJoinCredentialClaimsHeading.
  ///
  /// In en, this message translates to:
  /// **'What presenting it shows'**
  String get vtcJoinCredentialClaimsHeading;

  /// No description provided for @vtcJoinCredentialNote.
  ///
  /// In en, this message translates to:
  /// **'The whole credential goes with your application, which this identity signs.'**
  String get vtcJoinCredentialNote;

  /// No description provided for @vtcJoinNewIdentity.
  ///
  /// In en, this message translates to:
  /// **'A new identity'**
  String get vtcJoinNewIdentity;

  /// No description provided for @vtcJoinNewIdentityHost.
  ///
  /// In en, this message translates to:
  /// **'Created on your VTA for this community'**
  String get vtcJoinNewIdentityHost;

  /// No description provided for @vtcJoinExistingIdentity.
  ///
  /// In en, this message translates to:
  /// **'Existing identity'**
  String get vtcJoinExistingIdentity;

  /// No description provided for @vtcJoinUseIdentity.
  ///
  /// In en, this message translates to:
  /// **'Join with this identity'**
  String get vtcJoinUseIdentity;

  /// No description provided for @vtcJoinIdentityPosition.
  ///
  /// In en, this message translates to:
  /// **'{position} of {total} · swipe to see the others'**
  String vtcJoinIdentityPosition(int position, int total);

  /// No description provided for @vtcJoinNewIdentityNote.
  ///
  /// In en, this message translates to:
  /// **'Recommended: your VTA creates it for this community, so other communities can\'t link you through it.'**
  String get vtcJoinNewIdentityNote;

  /// No description provided for @vtcJoinWaysHeading.
  ///
  /// In en, this message translates to:
  /// **'Ways in'**
  String get vtcJoinWaysHeading;

  /// Title of the dialog showing the community's join manifest as it sent it
  ///
  /// In en, this message translates to:
  /// **'Manifest'**
  String get vtcJoinManifestHeading;

  /// No description provided for @vtcJoinShowManifest.
  ///
  /// In en, this message translates to:
  /// **'Show the community\'s manifest'**
  String get vtcJoinShowManifest;

  /// No description provided for @vtcJoinWayAutomatic.
  ///
  /// In en, this message translates to:
  /// **'You become a member when you apply'**
  String get vtcJoinWayAutomatic;

  /// No description provided for @vtcJoinWayReviewed.
  ///
  /// In en, this message translates to:
  /// **'The administrators review your application'**
  String get vtcJoinWayReviewed;

  /// A way into a community this app cannot apply under yet
  ///
  /// In en, this message translates to:
  /// **'{reason, select, invitation{Not supported yet: needs an invitation} credentials{Not supported yet: needs credentials} vetting{Not supported yet: needs an in-person check} other{Not supported yet}}'**
  String vtcJoinWayUnsupported(String reason);

  /// No way into the community is supported; nothing is sent
  ///
  /// In en, this message translates to:
  /// **'Meeting Place doesn\'t support any way into {name} yet, so you can\'t apply from here.'**
  String vtcJoinNoSupportedWay(String name);

  /// No description provided for @vtcJoinDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Profile details the community asks for'**
  String get vtcJoinDetailsHeading;

  /// No description provided for @vtcJoinDetailsNote.
  ///
  /// In en, this message translates to:
  /// **'You see the values from your VTA and approve sharing them before anything is sent.'**
  String get vtcJoinDetailsNote;

  /// No description provided for @vtcJoinDirectoryListed.
  ///
  /// In en, this message translates to:
  /// **'This community lists new members in its member directory.'**
  String get vtcJoinDirectoryListed;

  /// No description provided for @vtcJoinDirectoryHidden.
  ///
  /// In en, this message translates to:
  /// **'This community doesn\'t list new members in its member directory.'**
  String get vtcJoinDirectoryHidden;

  /// No description provided for @vtcJoinListMe.
  ///
  /// In en, this message translates to:
  /// **'List me in the member directory'**
  String get vtcJoinListMe;

  /// No description provided for @vtcJoinListMeNote.
  ///
  /// In en, this message translates to:
  /// **'If this is off, you may be listed for a moment when you join, until Meeting Place takes your card out of the directory.'**
  String get vtcJoinListMeNote;

  /// Label of the member's role in a community on its page
  ///
  /// In en, this message translates to:
  /// **'Your role'**
  String get vtcCommunityRole;

  /// Tooltip of the button next to the member's role that opens the community's settings, such as its join phrase
  ///
  /// In en, this message translates to:
  /// **'Community settings'**
  String get vtcCommunitySettings;

  /// The member's role in a community; a role the community defined itself is shown by its own name
  ///
  /// In en, this message translates to:
  /// **'{role, select, admin{Administrator} moderator{Moderator} issuer{Issuer} member{Member} vetter{Vetter} other{{role}}}'**
  String vtcCommunityRoleName(String role);

  /// No description provided for @vtcJoinProfileHeading.
  ///
  /// In en, this message translates to:
  /// **'About the community'**
  String get vtcJoinProfileHeading;

  /// No description provided for @vtcJoinWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get vtcJoinWebsite;

  /// No description provided for @vtcJoinContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get vtcJoinContact;

  /// No description provided for @vtcJoinAudience.
  ///
  /// In en, this message translates to:
  /// **'{audience, select, admins{the administrators} groups{your groups} connections{your connections} members{all members} public{anyone} other{some people}}'**
  String vtcJoinAudience(String audience);

  /// No description provided for @vtcJoinFieldSetByAdmins.
  ///
  /// In en, this message translates to:
  /// **'Set by admins'**
  String get vtcJoinFieldSetByAdmins;

  /// No description provided for @vtcJoinExternalCards.
  ///
  /// In en, this message translates to:
  /// **'You may publish your card beyond the community, if you choose to.'**
  String get vtcJoinExternalCards;

  /// No description provided for @vtcJoinUnnamedCommunity.
  ///
  /// In en, this message translates to:
  /// **'A community'**
  String get vtcJoinUnnamedCommunity;

  /// No description provided for @vtcJoinThisCommunity.
  ///
  /// In en, this message translates to:
  /// **'this community'**
  String get vtcJoinThisCommunity;

  /// No description provided for @vtcJoinWantsYou.
  ///
  /// In en, this message translates to:
  /// **'wants you to join'**
  String get vtcJoinWantsYou;

  /// No description provided for @vtcJoinWithVtaIdentity.
  ///
  /// In en, this message translates to:
  /// **'With an identity from your VTA'**
  String get vtcJoinWithVtaIdentity;

  /// No description provided for @vtcJoinConsentHeading.
  ///
  /// In en, this message translates to:
  /// **'If you join, {name} can:'**
  String vtcJoinConsentHeading(String name);

  /// No description provided for @vtcJoinReceivesDetail.
  ///
  /// In en, this message translates to:
  /// **'Receive your {type}'**
  String vtcJoinReceivesDetail(String type);

  /// No description provided for @vtcClaimTypeNameDisplay.
  ///
  /// In en, this message translates to:
  /// **'display name'**
  String get vtcClaimTypeNameDisplay;

  /// No description provided for @vtcClaimTypeNameGiven.
  ///
  /// In en, this message translates to:
  /// **'first name'**
  String get vtcClaimTypeNameGiven;

  /// No description provided for @vtcClaimTypeNameFamily.
  ///
  /// In en, this message translates to:
  /// **'last name'**
  String get vtcClaimTypeNameFamily;

  /// No description provided for @vtcClaimTypeNameLegal.
  ///
  /// In en, this message translates to:
  /// **'legal name'**
  String get vtcClaimTypeNameLegal;

  /// No description provided for @vtcClaimTypeEmailPersonal.
  ///
  /// In en, this message translates to:
  /// **'personal email'**
  String get vtcClaimTypeEmailPersonal;

  /// No description provided for @vtcClaimTypeEmailWork.
  ///
  /// In en, this message translates to:
  /// **'work email'**
  String get vtcClaimTypeEmailWork;

  /// No description provided for @vtcClaimTypePhoneMobile.
  ///
  /// In en, this message translates to:
  /// **'mobile number'**
  String get vtcClaimTypePhoneMobile;

  /// No description provided for @vtcClaimTypePhoneWork.
  ///
  /// In en, this message translates to:
  /// **'work phone number'**
  String get vtcClaimTypePhoneWork;

  /// No description provided for @vtcClaimTypeAddressCountry.
  ///
  /// In en, this message translates to:
  /// **'country'**
  String get vtcClaimTypeAddressCountry;

  /// No description provided for @vtcClaimTypePersonBirthDate.
  ///
  /// In en, this message translates to:
  /// **'date of birth'**
  String get vtcClaimTypePersonBirthDate;

  /// No description provided for @vtcClaimTypeSkillLanguage.
  ///
  /// In en, this message translates to:
  /// **'languages'**
  String get vtcClaimTypeSkillLanguage;

  /// No description provided for @vtcClaimTypeAccountHandle.
  ///
  /// In en, this message translates to:
  /// **'account handle'**
  String get vtcClaimTypeAccountHandle;

  /// No description provided for @vtcJoinDetailRequiredNote.
  ///
  /// In en, this message translates to:
  /// **'Required to apply'**
  String get vtcJoinDetailRequiredNote;

  /// No description provided for @vtcJoinDetailOptionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get vtcJoinDetailOptionalNote;

  /// No description provided for @vtcJoinShowsTo.
  ///
  /// In en, this message translates to:
  /// **'Show your {fields} to {audience}'**
  String vtcJoinShowsTo(String fields, String audience);

  /// No description provided for @vtcJoinMembershipDidField.
  ///
  /// In en, this message translates to:
  /// **'membership ID'**
  String get vtcJoinMembershipDidField;

  /// The last item of a list joined to the others, as in 'name, team and role'
  ///
  /// In en, this message translates to:
  /// **'{rest} and {last}'**
  String vtcJoinListAnd(String rest, String last);

  /// No description provided for @vtcJoinKeepsNotes.
  ///
  /// In en, this message translates to:
  /// **'Keep notes about you'**
  String get vtcJoinKeepsNotes;

  /// No description provided for @vtcJoinAdminNotesDetail.
  ///
  /// In en, this message translates to:
  /// **'No other member sees them, and you can ask for yours.'**
  String get vtcJoinAdminNotesDetail;

  /// Who sees a directory field once the member joins
  ///
  /// In en, this message translates to:
  /// **'Seen by: {audience}'**
  String vtcJoinFieldSeenBy(String audience);

  /// The widest audience the member may later show a directory field to
  ///
  /// In en, this message translates to:
  /// **'You can widen to: {audience}'**
  String vtcJoinFieldWidenTo(String audience);

  /// No description provided for @vtcJoinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get vtcJoinAction;

  /// Under the diagram of a new member's card: from the community to the identity, then to the VTA
  ///
  /// In en, this message translates to:
  /// **'{community} issued your membership card to {identity}, which passed it on to your VTA'**
  String vtcJoinCardRoute(String community, String identity);

  /// The application to the named community was accepted
  ///
  /// In en, this message translates to:
  /// **'You\'re a member of {name}.'**
  String vtcJoinJoined(String name);

  /// No description provided for @vtcJoinLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave community'**
  String get vtcJoinLeaveAction;

  /// Asks the member to confirm leaving a community
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String vtcJoinLeaveTitle(String name);

  /// No description provided for @vtcJoinLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'The community ends your membership, and your VTA archives your membership card. To come back, you apply again.'**
  String get vtcJoinLeaveMessage;

  /// The member left a community
  ///
  /// In en, this message translates to:
  /// **'You left {name}.'**
  String vtcJoinLeft(String name);

  /// An application to the named community is open
  ///
  /// In en, this message translates to:
  /// **'Your application to {name} is waiting for the community\'s decision.'**
  String vtcJoinPending(String name);

  /// No description provided for @vtcJoinCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get vtcJoinCheckAgain;

  /// Title of the community's own identity check of the member, a vetted/1 statement their VTA holds
  ///
  /// In en, this message translates to:
  /// **'{name} checked your identity'**
  String vtcIdentityCheckHeading(String name);

  /// No description provided for @vtcIdentityCheckHow.
  ///
  /// In en, this message translates to:
  /// **'How'**
  String get vtcIdentityCheckHow;

  /// How the community checked the member's identity; an unknown method shows as sent
  ///
  /// In en, this message translates to:
  /// **'{method, select, inPerson{In person} video{By video call} priorAcquaintance{They already knew you} other{{method}}}'**
  String vtcIdentityCheckMethod(String method);

  /// No description provided for @vtcIdentityCheckDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents seen'**
  String get vtcIdentityCheckDocuments;

  /// A document the community relied on; an unknown one shows as sent
  ///
  /// In en, this message translates to:
  /// **'{document, select, passport{Passport} nationalId{National ID card} other{{document}}}'**
  String vtcIdentityCheckDocument(String document);

  /// No description provided for @vtcIdentityCheckConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get vtcIdentityCheckConfirmed;

  /// No description provided for @vtcIdentityCheckLiveness.
  ///
  /// In en, this message translates to:
  /// **'That you were there'**
  String get vtcIdentityCheckLiveness;

  /// No description provided for @vtcIdentityCheckCheckedOn.
  ///
  /// In en, this message translates to:
  /// **'Checked on'**
  String get vtcIdentityCheckCheckedOn;

  /// No description provided for @vtcIdentityCheckValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get vtcIdentityCheckValidUntil;

  /// No description provided for @vtcIdentityCheckShow.
  ///
  /// In en, this message translates to:
  /// **'Show the signed statement'**
  String get vtcIdentityCheckShow;

  /// Title of the membership card a community issued, shown once the member is admitted
  ///
  /// In en, this message translates to:
  /// **'Membership card'**
  String get vtcMembershipCardTitle;

  /// Tooltip of the icon that shows the membership card in full
  ///
  /// In en, this message translates to:
  /// **'Show the card'**
  String get vtcMembershipCardShow;

  /// Chip on the membership card when it states the member proved personhood
  ///
  /// In en, this message translates to:
  /// **'Personhood'**
  String get vtcMembershipCardPersonhood;

  /// Label of the identity the membership card is about
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get vtcMembershipCardMember;

  /// Label of the community DID that issued the membership card
  ///
  /// In en, this message translates to:
  /// **'Issued by'**
  String get vtcMembershipCardIssuedBy;

  /// Label of when the membership card starts to hold
  ///
  /// In en, this message translates to:
  /// **'Valid from'**
  String get vtcMembershipCardValidFrom;

  /// Label of when the membership card stops holding
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get vtcMembershipCardValidUntil;

  /// Note that the membership card is kept on the member's VTA
  ///
  /// In en, this message translates to:
  /// **'Kept on your VTA'**
  String get vtcMembershipCardKept;

  /// Shown on the joined screen until the member's VTA holds the membership card
  ///
  /// In en, this message translates to:
  /// **'Your membership card is on its way to your VTA'**
  String get vtcMembershipCardOnItsWay;

  /// Shown with a spinner on the community page while the phone reads the membership card from the member's VTA or collects it from the community
  ///
  /// In en, this message translates to:
  /// **'Getting your membership card…'**
  String get vtcMembershipCardLoading;

  /// Button that withdraws the open application to a community
  ///
  /// In en, this message translates to:
  /// **'Withdraw application'**
  String get vtcJoinWithdrawAction;

  /// Asks the member to confirm withdrawing their application to a community
  ///
  /// In en, this message translates to:
  /// **'Withdraw your application to {name}?'**
  String vtcJoinWithdrawTitle(String name);

  /// Explains what withdrawing an application does
  ///
  /// In en, this message translates to:
  /// **'The community\'s administrators won\'t decide on it any more. You can apply again afterwards.'**
  String get vtcJoinWithdrawMessage;

  /// The member withdrew their application to the named community
  ///
  /// In en, this message translates to:
  /// **'You withdrew your application to {name}.'**
  String vtcJoinWithdrawn(String name);

  /// Button that goes back to the community's requirements to apply again
  ///
  /// In en, this message translates to:
  /// **'Apply again'**
  String get vtcJoinApplyAgain;

  /// Heading of the card that shows the path an open application took
  ///
  /// In en, this message translates to:
  /// **'Your application'**
  String get vtcJoinTrailHeading;

  /// Trail step: the application carries a presentation of the member's credentials
  ///
  /// In en, this message translates to:
  /// **'Your credential, presented'**
  String get vtcJoinTrailPresentation;

  /// Trail step summary: the types of the credentials presented, which the signed application carries
  ///
  /// In en, this message translates to:
  /// **'{types} · inside your signed application'**
  String vtcJoinTrailPresentationSummary(String types);

  /// Trail detail: the identity that presents the credentials
  ///
  /// In en, this message translates to:
  /// **'Holder'**
  String get vtcJoinTrailHolder;

  /// Trail detail: the types of a credential presented
  ///
  /// In en, this message translates to:
  /// **'Credential'**
  String get vtcJoinTrailCredential;

  /// Trail detail: the DID that issued a credential presented
  ///
  /// In en, this message translates to:
  /// **'Issued by'**
  String get vtcJoinTrailIssuer;

  /// Trail detail: when a credential presented stops holding
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get vtcJoinTrailValidUntil;

  /// Title of the sheet that shows the presentation the application carries
  ///
  /// In en, this message translates to:
  /// **'Your presentation'**
  String get vtcJoinTrailPresentationDocument;

  /// Trail detail: who did a step, such as the member's VTA, the community or this phone
  ///
  /// In en, this message translates to:
  /// **'Done by'**
  String get vtcTrailDoneBy;

  /// Trail step: the member's VTA signed the application
  ///
  /// In en, this message translates to:
  /// **'Signed by your VTA'**
  String get vtcJoinTrailVta;

  /// Trail step summary: the identity the VTA signed the application as
  ///
  /// In en, this message translates to:
  /// **'As your identity in {name}'**
  String vtcJoinTrailVtaIdentity(String name);

  /// Trail step summary: as which identity, how and when the VTA signed
  ///
  /// In en, this message translates to:
  /// **'As your identity in {name} · {cryptosuite} · {time}'**
  String vtcJoinTrailVtaSummary(String name, String cryptosuite, String time);

  /// Trail step summary: the community referred the application to its administrators, and the phone verified the signature of its answer
  ///
  /// In en, this message translates to:
  /// **'Passed to its administrators · its signed answer verified'**
  String get vtcJoinTrailCommunitySummary;

  /// Trail step: the phone sent the signed application and the named community received it
  ///
  /// In en, this message translates to:
  /// **'Received by {name}'**
  String vtcJoinTrailCommunity(String name);

  /// Trail step summary when the application was sent before receipts were kept
  ///
  /// In en, this message translates to:
  /// **'Sent earlier; this phone keeps no receipt for it'**
  String get vtcJoinTrailNoReceipt;

  /// Trail step: the application waits for the community's administrators
  ///
  /// In en, this message translates to:
  /// **'Waiting for the administrators'**
  String get vtcJoinTrailReview;

  /// Trail step: the administrators deferred the application; it stays open
  ///
  /// In en, this message translates to:
  /// **'Put off by the administrators for now'**
  String get vtcJoinTrailDeferred;

  /// Trail step summary: when the app last asked the community
  ///
  /// In en, this message translates to:
  /// **'Last checked at {time}'**
  String vtcJoinTrailLastChecked(String time);

  /// Trail step summary: how often the app asks the community
  ///
  /// In en, this message translates to:
  /// **'Checked again every {seconds} seconds while this screen is open'**
  String vtcJoinTrailAutoCheck(int seconds);

  /// Trail step still to come: the membership card
  ///
  /// In en, this message translates to:
  /// **'Membership card'**
  String get vtcJoinTrailCard;

  /// Trail step summary: when the membership card comes and where it is kept
  ///
  /// In en, this message translates to:
  /// **'Issued once you\'re admitted, and kept on your VTA'**
  String get vtcJoinTrailCardSummary;

  /// Label of the DID the member applied as
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get vtcJoinTrailIdentity;

  /// Label of the Trust Task type of the signed application
  ///
  /// In en, this message translates to:
  /// **'Trust Task'**
  String get vtcJoinTrailTask;

  /// Label of the key that signed the application
  ///
  /// In en, this message translates to:
  /// **'Signing key'**
  String get vtcJoinTrailKey;

  /// Label of the cryptosuite the application was signed with
  ///
  /// In en, this message translates to:
  /// **'Cryptosuite'**
  String get vtcJoinTrailCryptosuite;

  /// Label of when the VTA signed the application
  ///
  /// In en, this message translates to:
  /// **'Signed at'**
  String get vtcJoinTrailSignedAt;

  /// Label of the community's id of the application
  ///
  /// In en, this message translates to:
  /// **'Request id at the community'**
  String get vtcJoinTrailRequestId;

  /// Label of the Trust Task type of the last signed status request
  ///
  /// In en, this message translates to:
  /// **'Last check'**
  String get vtcJoinTrailCheckTask;

  /// Label of when the VTA signed the last status request
  ///
  /// In en, this message translates to:
  /// **'Last check signed by your VTA at'**
  String get vtcJoinTrailCheckSignedAt;

  /// Label of when the community answered the last status request, whose signature was verified
  ///
  /// In en, this message translates to:
  /// **'Last check answered and verified at'**
  String get vtcJoinTrailCheckAnsweredAt;

  /// Label of what a signature's proof is for, e.g. authentication
  ///
  /// In en, this message translates to:
  /// **'Proof purpose'**
  String get vtcJoinTrailProofPurpose;

  /// Label of the community's key that signed its answer to the last status request
  ///
  /// In en, this message translates to:
  /// **'Key that signed the last answer'**
  String get vtcJoinTrailCheckAnswerKey;

  /// Tooltip of the button that copies a shown JSON document
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get vtcJoinJsonCopy;

  /// Tooltip of the icon that shows a trail step's signed Trust Task document as JSON
  ///
  /// In en, this message translates to:
  /// **'Show the signed document'**
  String get vtcJoinTrailShowDocument;

  /// Title of the dialog showing the application document the VTA signed
  ///
  /// In en, this message translates to:
  /// **'Your signed application'**
  String get vtcJoinTrailSubmitDocument;

  /// Title of the dialog showing the community's signed answer to the application
  ///
  /// In en, this message translates to:
  /// **'The community\'s signed answer'**
  String get vtcJoinTrailAnswerDocument;

  /// Title of the dialog showing the community's signed answer to the last status check
  ///
  /// In en, this message translates to:
  /// **'The community\'s last signed answer'**
  String get vtcJoinTrailCheckDocument;

  /// Label of the DID that signed the community's answer
  ///
  /// In en, this message translates to:
  /// **'Answered by'**
  String get vtcJoinTrailAnsweredBy;

  /// Label of when the community answered
  ///
  /// In en, this message translates to:
  /// **'Answered at'**
  String get vtcJoinTrailAnsweredAt;

  /// Toggle and heading over the steps that brought the membership card from the identity's inbox to the VTA
  ///
  /// In en, this message translates to:
  /// **'How your card arrived'**
  String get vtcDeliveryHeading;

  /// Delivery step: the VTA lent the identity's keys to this phone
  ///
  /// In en, this message translates to:
  /// **'Keys lent by your VTA'**
  String get vtcDeliveryKeysLent;

  /// Delivery step summary: how the lent keys are held
  ///
  /// In en, this message translates to:
  /// **'Held in memory only, while this screen collects the card'**
  String get vtcDeliveryKeysLentSummary;

  /// Delivery step summary: the VTA refused or could not lend the keys
  ///
  /// In en, this message translates to:
  /// **'Your VTA didn\'t lend the keys. Trying again'**
  String get vtcDeliveryKeysFailed;

  /// Label of the identity's key agreement key id
  ///
  /// In en, this message translates to:
  /// **'Key agreement key'**
  String get vtcDeliveryKeyAgreementKey;

  /// Delivery step: the phone signed in to the identity's inbox on its mediator
  ///
  /// In en, this message translates to:
  /// **'Signed in to your identity\'s inbox'**
  String get vtcDeliverySignedIn;

  /// Delivery step summary: how many messages waited in the identity's inbox
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No messages waiting} =1{1 message waiting} other{{count} messages waiting}}'**
  String vtcDeliveryWaitingMessages(int count);

  /// Delivery step summary: the mediator could not be reached
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the inbox. Trying again'**
  String get vtcDeliverySignedInFailed;

  /// Label of the mediator holding the identity's inbox
  ///
  /// In en, this message translates to:
  /// **'Mediator'**
  String get vtcDeliveryMediator;

  /// Delivery step: the named community's card was found in the identity's inbox
  ///
  /// In en, this message translates to:
  /// **'Card picked up from {name}'**
  String vtcDeliveryPickedUp(String name);

  /// Delivery step summary: the card's delivery was signed by the named community and its proof checked
  ///
  /// In en, this message translates to:
  /// **'Signed by {name} · proof verified'**
  String vtcDeliveryPickedUpSummary(String name);

  /// Delivery step summary: the named community has not delivered the card yet
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to deliver it'**
  String vtcDeliveryWaiting(String name);

  /// Label of the DID that signed the card's delivery
  ///
  /// In en, this message translates to:
  /// **'Sent by'**
  String get vtcDeliverySentBy;

  /// Title of the sheet showing the signed document that delivered the card
  ///
  /// In en, this message translates to:
  /// **'The community\'s signed delivery'**
  String get vtcDeliveryIssueDocument;

  /// Delivery step: the VTA checked and keeps the card
  ///
  /// In en, this message translates to:
  /// **'Kept on your VTA'**
  String get vtcDeliveryKept;

  /// Delivery step summary: the VTA verified the card when it stored it
  ///
  /// In en, this message translates to:
  /// **'Proof checked by your VTA'**
  String get vtcDeliveryKeptSummary;

  /// Delivery step summary: the VTA stored the card but does not hold it valid
  ///
  /// In en, this message translates to:
  /// **'Kept, but your VTA finds it revoked or expired'**
  String get vtcDeliveryKeptInvalid;

  /// Delivery step summary: the VTA refused to store the card
  ///
  /// In en, this message translates to:
  /// **'Your VTA didn\'t keep it. Trying again'**
  String get vtcDeliveryKeptFailed;

  /// Delivery step: the named community took the confirmation of the membership
  ///
  /// In en, this message translates to:
  /// **'Membership confirmed with {name}'**
  String vtcDeliveryConfirmed(String name);

  /// Delivery step summary: how the membership was confirmed
  ///
  /// In en, this message translates to:
  /// **'Your identity signed the card back to the community'**
  String get vtcDeliveryConfirmedSummary;

  /// Delivery step summary: the community did not take the confirmation
  ///
  /// In en, this message translates to:
  /// **'Not confirmed yet. Trying again'**
  String get vtcDeliveryConfirmedFailed;

  /// Delivery step summary of a step not reached yet
  ///
  /// In en, this message translates to:
  /// **'Still to come'**
  String get vtcDeliveryNext;

  /// The named community turned the application down
  ///
  /// In en, this message translates to:
  /// **'{name} didn\'t accept your application.'**
  String vtcJoinDenied(String name);

  /// The community's reason for turning down the member's previous application
  ///
  /// In en, this message translates to:
  /// **'Your last application was turned down. The community\'s reason: {reason}'**
  String vtcJoinLastDenied(String reason);

  /// The named community turned the application down and said why, in its own words
  ///
  /// In en, this message translates to:
  /// **'{name} didn\'t accept your application. Its reason: {reason}'**
  String vtcJoinDeniedWithReason(String name, String reason);

  /// No description provided for @vtcJoinNeedsMore.
  ///
  /// In en, this message translates to:
  /// **'The community needs more than Meeting Place can send, such as credentials.'**
  String get vtcJoinNeedsMore;

  /// Why joining a community could not go ahead
  ///
  /// In en, this message translates to:
  /// **'{reason, select, invalidCode{This isn\'t a community\'s code.} phraseNotFound{No community goes by this phrase in Meeting Place.} phraseExpired{This join phrase has expired. Ask the community for its current phrase.} profileMissing{Your VTA has no profile for this identity, so it can\'t share the details the community asks for. Set up your profile on your VTA, then try again.} detailsMissing{Your VTA doesn\'t hold a detail the community requires, so nothing was sent.} credentialMissing{Your identity holds no credential this way in accepts that your VTA can present, so nothing was sent.} vtaMissing{Link your VTA in Settings before joining a community.} unreachable{The community can\'t be reached from your phone.} noDidHosting{Your VTA has no DID hosting server, so it can\'t create an identity the community can find.} notAccepting{This community isn\'t accepting applications.} badAnswer{The community\'s answer couldn\'t be checked, so nothing was recorded.} lastAdministrator{You\'re this community\'s last administrator. Make another member an administrator before you leave.} other{The community or your VTA refused the application.}}'**
  String vtcJoinFailure(String reason);

  /// No description provided for @vtaDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'VTA details'**
  String get vtaDetailsTitle;

  /// No description provided for @vtaDetailsContextId.
  ///
  /// In en, this message translates to:
  /// **'Context ID'**
  String get vtaDetailsContextId;

  /// No description provided for @vtaDetailsProfileId.
  ///
  /// In en, this message translates to:
  /// **'Profile ID'**
  String get vtaDetailsProfileId;

  /// No description provided for @vtaDetailsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get vtaDetailsProfile;

  /// No description provided for @vtaDetailsCopyProfile.
  ///
  /// In en, this message translates to:
  /// **'Copy profile'**
  String get vtaDetailsCopyProfile;

  /// No description provided for @vtaDetailsProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this profile from your VTA.'**
  String get vtaDetailsProfileFailed;

  /// A long value in the profile JSON, cut short for display. The copied profile keeps it whole.
  ///
  /// In en, this message translates to:
  /// **'{start}… ({length} characters)'**
  String vtaDetailsValueShortened(String start, int length);

  /// No description provided for @vtcJoinPhraseHeading.
  ///
  /// In en, this message translates to:
  /// **'Join phrase'**
  String get vtcJoinPhraseHeading;

  /// Offers a community member to publish a join phrase
  ///
  /// In en, this message translates to:
  /// **'Let people find {name} in Meeting Place by a short phrase instead of its DID. They see the community and where it is hosted before they apply.'**
  String vtcJoinPhraseIntro(String name);

  /// No description provided for @vtcJoinPhrasePublishAction.
  ///
  /// In en, this message translates to:
  /// **'Publish join phrase'**
  String get vtcJoinPhrasePublishAction;

  /// Title of the dialog asking a member for a community's join phrase
  ///
  /// In en, this message translates to:
  /// **'Join phrase for {name}'**
  String vtcJoinPhraseDialogTitle(String name);

  /// No description provided for @vtcJoinPhraseHint.
  ///
  /// In en, this message translates to:
  /// **'Phrase'**
  String get vtcJoinPhraseHint;

  /// Description of a community's join phrase offer, as an app that opens it as a contact's offer shows it
  ///
  /// In en, this message translates to:
  /// **'Join {name} in Meeting Place'**
  String vtcJoinPhraseOfferDescription(String name);

  /// Explains a published join phrase of a community
  ///
  /// In en, this message translates to:
  /// **'People find {name} by entering \"{phrase}\" or scanning this code in Meeting Place, until you withdraw it.'**
  String vtcJoinPhrasePublished(String name, String phrase);

  /// Says what a published join phrase shows, and that anyone can publish one
  ///
  /// In en, this message translates to:
  /// **'The phrase shows only the community\'s DID, nothing about you. Anyone can publish a phrase for any community, so people still check the community before they apply.'**
  String get vtcJoinPhraseVisibility;

  /// No description provided for @vtcJoinPhraseWithdrawAction.
  ///
  /// In en, this message translates to:
  /// **'Withdraw phrase'**
  String get vtcJoinPhraseWithdrawAction;

  /// Asks a member to confirm withdrawing a join phrase
  ///
  /// In en, this message translates to:
  /// **'Withdraw \"{phrase}\"?'**
  String vtcJoinPhraseWithdrawTitle(String phrase);

  /// Explains what withdrawing a join phrase does
  ///
  /// In en, this message translates to:
  /// **'Meeting Place stops listing the phrase, and anyone can then publish it again.'**
  String get vtcJoinPhraseWithdrawMessage;

  /// Why publishing or withdrawing a join phrase failed
  ///
  /// In en, this message translates to:
  /// **'{reason, select, taken{That phrase is already taken in Meeting Place. Try another.} other{The phrase couldn\'t be published or withdrawn. Try again.}}'**
  String vtcJoinPhraseFailure(String reason);

  /// The scanned community is one the member belongs to
  ///
  /// In en, this message translates to:
  /// **'You\'re already a member of {name}.'**
  String vtcJoinAlreadyMember(String name);

  /// Button on a membership card that opens the member's groups in the community
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get vtcGroupsOpen;

  /// Title of the member's groups in a community, above the community's name
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get vtcGroupsTitle;

  /// Shown when the member belongs to no group of the community
  ///
  /// In en, this message translates to:
  /// **'You\'re not in any of this community\'s groups.'**
  String get vtcGroupsNone;

  /// Shown when no VTA is linked, so groups cannot be read
  ///
  /// In en, this message translates to:
  /// **'Link your VTA to see your groups.'**
  String get vtcGroupsVtaMissing;

  /// Shown when the community or the VTA cannot be reached
  ///
  /// In en, this message translates to:
  /// **'Your groups couldn\'t be loaded. Check your connection and try again.'**
  String get vtcGroupsUnreachable;

  /// Chip on a group the member manages
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get vtcGroupManager;

  /// Heading of where a group's chat stands, and of its link
  ///
  /// In en, this message translates to:
  /// **'Group chat'**
  String get vtcGroupChatHeading;

  /// A group's chat status when its link cannot be read
  ///
  /// In en, this message translates to:
  /// **'This group\'s chat couldn\'t be checked.'**
  String get vtcGroupChatUnknown;

  /// A group's chat status when no chat is linked
  ///
  /// In en, this message translates to:
  /// **'This group has no chat yet.'**
  String get vtcGroupChatNone;

  /// A group's chat status when the community linked a chat
  ///
  /// In en, this message translates to:
  /// **'This group has a chat you can join.'**
  String get vtcGroupChatLinked;

  /// A group's chat status when the member owns it
  ///
  /// In en, this message translates to:
  /// **'You own this group\'s chat. Members you let in appear in it.'**
  String get vtcGroupChatOwned;

  /// A group's chat status after the member asked to join
  ///
  /// In en, this message translates to:
  /// **'You asked to join this group\'s chat. You\'ll find it in your chats.'**
  String get vtcGroupChatJoined;

  /// Button for a group's manager to create its chat
  ///
  /// In en, this message translates to:
  /// **'Create chat'**
  String get vtcGroupChatCreate;

  /// Button for a member to ask to join a group's chat
  ///
  /// In en, this message translates to:
  /// **'Join chat'**
  String get vtcGroupChatJoin;

  /// Shown when a group's members are hidden from one another
  ///
  /// In en, this message translates to:
  /// **'This group hides its members, so it can\'t have a chat.'**
  String get vtcGroupChatHidesMembers;

  /// Shown when a member who does not manage the group tries to create its chat
  ///
  /// In en, this message translates to:
  /// **'Only a manager of this group can create its chat.'**
  String get vtcGroupChatNotAManager;

  /// Shown when the community already linked a chat to the group
  ///
  /// In en, this message translates to:
  /// **'This group already has a chat.'**
  String get vtcGroupChatAlreadyLinked;

  /// Shown when the community has not linked a chat to the group
  ///
  /// In en, this message translates to:
  /// **'This group\'s chat isn\'t linked yet. Ask one of its managers.'**
  String get vtcGroupChatNotLinked;

  /// Shown when the linked chat is published on another control plane
  ///
  /// In en, this message translates to:
  /// **'This group\'s chat is on another Meeting Place.'**
  String get vtcGroupChatElsewhere;

  /// Shown when the linked offer is not for the group's DID
  ///
  /// In en, this message translates to:
  /// **'The linked chat isn\'t this group\'s. Ask one of its managers.'**
  String get vtcGroupChatNotTheGroups;

  /// Shown when the member's VTA keeps no credential of the group
  ///
  /// In en, this message translates to:
  /// **'Your VTA doesn\'t have this group\'s membership credential yet. Try again later.'**
  String get vtcGroupChatNoCredential;

  /// Shown when creating or joining a group's chat fails for another reason
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Try again.'**
  String get vtcGroupChatFailed;

  /// Title of the dialog showing a new chat's link
  ///
  /// In en, this message translates to:
  /// **'Publish the chat\'s link'**
  String get vtcGroupChatLinkTitle;

  /// Explains how a new group chat's link is published
  ///
  /// In en, this message translates to:
  /// **'Members find the chat through the group\'s DID. Ask your community\'s operator to add this service to the group\'s DID document. Until then, members can\'t find the chat.'**
  String get vtcGroupChatLinkBody;

  /// Button that copies a group chat's link
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get vtcGroupChatLinkCopy;

  /// Shown after a group chat's link is copied
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get vtcGroupChatLinkCopied;

  /// Closes the dialog showing a group chat's link
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get vtcGroupChatLinkDone;

  /// Title of the overview of being vetted for a community
  ///
  /// In en, this message translates to:
  /// **'Meet a vetter'**
  String get vtcJoinVettingTitle;

  /// What vetting means, on its overview
  ///
  /// In en, this message translates to:
  /// **'{name} asks to meet you first. One of its vetters checks who you are, in person, and vouches for you.'**
  String vtcJoinVettingIntro(String name);

  /// How many vetters vouched so far
  ///
  /// In en, this message translates to:
  /// **'{have} of {needed} vetters vouched for you'**
  String vtcJoinVettingProgress(int have, int needed);

  /// A vetting method the community still needs statements by
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more must meet you} other{{count} more must meet you}} {method, select, inPerson{in person} video{over video} priorAcquaintance{and know you already} other{}}'**
  String vtcJoinVettingMethodNeed(int count, String method);

  /// The details each vetter must check
  ///
  /// In en, this message translates to:
  /// **'Vetters check: {claims}'**
  String vtcJoinVettingChecks(String claims);

  /// How long a vetter's statement counts
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{A vouch counts for 1 day} other{A vouch counts for {days} days}}'**
  String vtcJoinVettingMaxAge(int days);

  /// The statements break the community's independence rules
  ///
  /// In en, this message translates to:
  /// **'These vouches don\'t all count together. Ask another vetter.'**
  String get vtcJoinVettingNotIndependent;

  /// Heading of the vetters asked
  ///
  /// In en, this message translates to:
  /// **'Your vetters'**
  String get vtcJoinVettersHeading;

  /// Where vetting by one vetter stands
  ///
  /// In en, this message translates to:
  /// **'{status, select, requested{Waiting for them to answer} accepted{Confirmed as a vetter · waiting for them to start} inSession{Compare the match code} cardSent{Waiting for their vouch} vouched{Vouched for you} declined{Declined to vouch} refused{Couldn\'t go ahead} abandoned{You ended the session} other{}}'**
  String vtcJoinVettingStatus(String status);

  /// Why a vetting step could not go ahead
  ///
  /// In en, this message translates to:
  /// **'{reason, select, otherCommunity{This ticket is for another community.} invalidTicket{The vetter didn\'t take this ticket or code. It may have expired or been used. Ask them for a new one.} unavailable{The vetter can\'t vet you right now.} notVetter{This person couldn\'t show that the community made them a vetter, so nothing was shared.} vetterRevoked{The community no longer lets this person vet.} sessionExpired{The session has ended. Ask the vetter to start a new one.} badAnswer{The vetter\'s answer couldn\'t be checked, so it was ignored.} other{The vetter refused.}}'**
  String vtcJoinVettingFailure(String reason);

  /// Scans the QR code a vetter shows
  ///
  /// In en, this message translates to:
  /// **'Scan a vetter\'s ticket'**
  String get vtcJoinVettingScanAction;

  /// Types the code a vetter reads out
  ///
  /// In en, this message translates to:
  /// **'Enter a vetter\'s code'**
  String get vtcJoinVettingCodeAction;

  /// Applies with the statements gathered
  ///
  /// In en, this message translates to:
  /// **'Send application'**
  String get vtcJoinVettingSendAction;

  /// Title of picking the vetter in front of the member
  ///
  /// In en, this message translates to:
  /// **'Who are you meeting?'**
  String get vtcJoinChooseVetterTitle;

  /// Picking a vetter; names are self-asserted
  ///
  /// In en, this message translates to:
  /// **'Pick the vetter in front of you. Names are the vetters\' own.'**
  String get vtcJoinChooseVetterIntro;

  /// The community lists no vetters
  ///
  /// In en, this message translates to:
  /// **'{name} lists no vetters. Scan your vetter\'s ticket instead.'**
  String vtcJoinNoVetters(String name);

  /// Title of typing a vetter's code
  ///
  /// In en, this message translates to:
  /// **'Enter {vetter}\'s code'**
  String vtcJoinVettingCodeTitle(String vetter);

  /// How to get a vetter's code
  ///
  /// In en, this message translates to:
  /// **'Ask them to read out the code their app shows.'**
  String get vtcJoinVettingCodeIntro;

  /// Hint of the vetter code field
  ///
  /// In en, this message translates to:
  /// **'Code, e.g. K7QF-2M9X'**
  String get vtcJoinVettingCodeHint;

  /// The vetter's role was checked against the community
  ///
  /// In en, this message translates to:
  /// **'{vetter} is a vetter of {name} until {date}.'**
  String vtcJoinVettingVerified(String vetter, String name, String date);

  /// Title of comparing the session's match code
  ///
  /// In en, this message translates to:
  /// **'Do the codes match?'**
  String get vtcJoinMatchTitle;

  /// How to compare the match code
  ///
  /// In en, this message translates to:
  /// **'{vetter} sees a code too. Read yours out and check it\'s the same.'**
  String vtcJoinMatchIntro(String vetter);

  /// The match codes are the same
  ///
  /// In en, this message translates to:
  /// **'They match'**
  String get vtcJoinMatchYes;

  /// The match codes differ; ends the session
  ///
  /// In en, this message translates to:
  /// **'They don\'t match'**
  String get vtcJoinMatchNo;

  /// Title of approving the vetting card
  ///
  /// In en, this message translates to:
  /// **'Show these details to {vetter}?'**
  String vtcJoinVettingCardTitle(String vetter);

  /// Who sees the vetting card
  ///
  /// In en, this message translates to:
  /// **'Only {vetter} sees these. They check them against your ID, and the community gets their vouch, not your details.'**
  String vtcJoinVettingCardNote(String vetter);

  /// Ends the session without sending the card
  ///
  /// In en, this message translates to:
  /// **'Don\'t share'**
  String get vtcJoinVettingCardDecline;

  /// Heading of the session's match code
  ///
  /// In en, this message translates to:
  /// **'Your match code'**
  String get vtcJoinMatchCodeHeading;

  /// Heading of the details a vetting card carries
  ///
  /// In en, this message translates to:
  /// **'Details for your vetter'**
  String get vtcJoinVettingCardHeading;

  /// Opens the vetting desk of a community where the member is a vetter
  ///
  /// In en, this message translates to:
  /// **'Vet applicants'**
  String get vtcVetterStart;

  /// Title of the vetting desk
  ///
  /// In en, this message translates to:
  /// **'Vetting for {name}'**
  String vtcVetterTitle(String name);

  /// What the vetting desk is for
  ///
  /// In en, this message translates to:
  /// **'Show your ticket to someone who wants to join. You\'ll check their details in person.'**
  String get vtcVetterIntro;

  /// The member holds no valid vetter card for the community
  ///
  /// In en, this message translates to:
  /// **'You can\'t vet for {name} right now: your vetter card has expired or been withdrawn.'**
  String vtcVetterNotVetter(String name);

  /// Heading of the ticket's QR code
  ///
  /// In en, this message translates to:
  /// **'Your vetting ticket'**
  String get vtcVetterTicketHeading;

  /// Shown above the ticket's short code
  ///
  /// In en, this message translates to:
  /// **'Or read out this code'**
  String get vtcVetterTicketCodeHint;

  /// How long the ticket on show still works
  ///
  /// In en, this message translates to:
  /// **'{uses, plural, =1{Good for 1 more applicant} other{Good for {uses} more applicants}} until {date}.'**
  String vtcVetterTicketValid(int uses, String date);

  /// Replaces the ticket on show with a new one
  ///
  /// In en, this message translates to:
  /// **'New ticket'**
  String get vtcVetterNewTicket;

  /// How many applicants a new ticket is good for
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get vtcVetterUses;

  /// How many days a new ticket is good for
  ///
  /// In en, this message translates to:
  /// **'Days valid'**
  String get vtcVetterDays;

  /// Creates a ticket and shows it
  ///
  /// In en, this message translates to:
  /// **'Show a vetting ticket'**
  String get vtcVetterShowTicket;

  /// The desk waits for an applicant
  ///
  /// In en, this message translates to:
  /// **'Waiting for someone to scan the ticket or enter the code…'**
  String get vtcVetterWaiting;

  /// Before comparing the match code with the applicant
  ///
  /// In en, this message translates to:
  /// **'The applicant sees a code too. Ask them to read theirs out and check it\'s the same.'**
  String get vtcVetterMatchIntro;

  /// The applicant has yet to send their card
  ///
  /// In en, this message translates to:
  /// **'Waiting for the applicant\'s details…'**
  String get vtcVetterCardWaiting;

  /// Heading of the details on the applicant's card
  ///
  /// In en, this message translates to:
  /// **'Applicant\'s details'**
  String get vtcVetterCardHeading;

  /// How to check the applicant's details
  ///
  /// In en, this message translates to:
  /// **'Check these details against their ID document, with them in front of you.'**
  String get vtcVetterCardIntro;

  /// Heading of the choice of ID document
  ///
  /// In en, this message translates to:
  /// **'Document you checked'**
  String get vtcVetterDocumentHeading;

  /// A kind of ID document a vetter checks
  ///
  /// In en, this message translates to:
  /// **'{document, select, passport{Passport} nationalId{National ID card} driverLicence{Driving licence} other{{document}}}'**
  String vtcVetterDocument(String document);

  /// The vetter confirms the in-person check
  ///
  /// In en, this message translates to:
  /// **'I checked these details against the document, with the applicant in front of me.'**
  String get vtcVetterCheckedInPerson;

  /// Issues the vetting statement
  ///
  /// In en, this message translates to:
  /// **'Vouch for them'**
  String get vtcVetterIssue;

  /// Tells the applicant the vetter won't vouch
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get vtcVetterDecline;

  /// Heading of the vetter's issued statements, kept on their VTA
  ///
  /// In en, this message translates to:
  /// **'Statements you issued'**
  String get vtcVetterIssuedHeading;

  /// One issued statement
  ///
  /// In en, this message translates to:
  /// **'Issued {date}, valid until {until}'**
  String vtcVetterIssuedLine(String date, String until);

  /// The vetter has issued no statement
  ///
  /// In en, this message translates to:
  /// **'None yet.'**
  String get vtcVetterIssuedNone;

  /// A vetting desk step could not go ahead
  ///
  /// In en, this message translates to:
  /// **'{failure, select, notVetter{Your vetter card is no longer valid.} other{Something went wrong. Check your connection and try again.}}'**
  String vtcVetterFailure(String failure);

  /// The vetter card could not be checked on the community page
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check your vetter card, so vetting isn\'t offered. Try again later.'**
  String get vtcVetterCheckFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
