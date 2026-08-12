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
  /// **'{tabName, select, connections{Invitations} contacts{Channels} identities{Identities} rCards{R-Cards} personalAgent{Agent} credentials{Credentials} settings{Settings} other{Invalid}}'**
  String tabsTitle(String tabName);

  /// No description provided for @personalAgentPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up and manage your personal AI agent without exposing DID details.'**
  String get personalAgentPanelSubtitle;

  /// No description provided for @personalAgentSetupInProgressButton.
  ///
  /// In en, this message translates to:
  /// **'Setting up and connecting...'**
  String get personalAgentSetupInProgressButton;

  /// No description provided for @personalAgentReconnectButton.
  ///
  /// In en, this message translates to:
  /// **'Reconnect Personal Agent'**
  String get personalAgentReconnectButton;

  /// No description provided for @personalAgentConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect Personal Agent'**
  String get personalAgentConnectButton;

  /// No description provided for @personalAgentReviewSetupPrompt.
  ///
  /// In en, this message translates to:
  /// **'Review setup prompt'**
  String get personalAgentReviewSetupPrompt;

  /// No description provided for @personalAgentConnectedSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get personalAgentConnectedSectionTitle;

  /// No description provided for @personalAgentSummaryContextId.
  ///
  /// In en, this message translates to:
  /// **'Context ID: {contextId}'**
  String personalAgentSummaryContextId(String contextId);

  /// No description provided for @personalAgentSummaryContextCreated.
  ///
  /// In en, this message translates to:
  /// **'Context created: {value}'**
  String personalAgentSummaryContextCreated(String value);

  /// No description provided for @personalAgentSummaryProfile.
  ///
  /// In en, this message translates to:
  /// **'Agent profile: {value}'**
  String personalAgentSummaryProfile(String value);

  /// No description provided for @personalAgentSummaryAgentCreated.
  ///
  /// In en, this message translates to:
  /// **'Agent created: {value}'**
  String personalAgentSummaryAgentCreated(String value);

  /// No description provided for @personalAgentSummaryMode.
  ///
  /// In en, this message translates to:
  /// **'Mode: {value}'**
  String personalAgentSummaryMode(String value);

  /// No description provided for @personalAgentSummarySetupStatus.
  ///
  /// In en, this message translates to:
  /// **'Setup status: {value}'**
  String personalAgentSummarySetupStatus(String value);

  /// No description provided for @personalAgentSummaryOfferAvailable.
  ///
  /// In en, this message translates to:
  /// **'Offer available: {value}'**
  String personalAgentSummaryOfferAvailable(String value);

  /// No description provided for @personalAgentStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Personal AI connected'**
  String get personalAgentStatusConnected;

  /// No description provided for @personalAgentStatusContextRequired.
  ///
  /// In en, this message translates to:
  /// **'Context setup required'**
  String get personalAgentStatusContextRequired;

  /// No description provided for @personalAgentStatusSettingUp.
  ///
  /// In en, this message translates to:
  /// **'Personal AI setup in progress'**
  String get personalAgentStatusSettingUp;

  /// No description provided for @personalAgentStatusNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Personal AI not connected'**
  String get personalAgentStatusNotConnected;

  /// No description provided for @personalAgentStatusSubtitleConnected.
  ///
  /// In en, this message translates to:
  /// **'Your assistant is ready and will appear in contacts once the channel is active.'**
  String get personalAgentStatusSubtitleConnected;

  /// No description provided for @personalAgentStatusSubtitleNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Connect your Personal AI in one tap. MPX stays usable throughout setup.'**
  String get personalAgentStatusSubtitleNotConnected;

  /// No description provided for @personalAgentContextSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Personal AI'**
  String get personalAgentContextSetupTitle;

  /// No description provided for @personalAgentContextSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Help your Personal AI get to know you. Upload a text file with your background, preferences, and working style. This becomes the AI\'s long-term knowledge about you.'**
  String get personalAgentContextSetupDescription;

  /// No description provided for @personalAgentContextWhatToIncludeTitle.
  ///
  /// In en, this message translates to:
  /// **'What to include in your file'**
  String get personalAgentContextWhatToIncludeTitle;

  /// No description provided for @personalAgentContextWhatToIncludeItem1.
  ///
  /// In en, this message translates to:
  /// **'Name, role, and professional background'**
  String get personalAgentContextWhatToIncludeItem1;

  /// No description provided for @personalAgentContextWhatToIncludeItem2.
  ///
  /// In en, this message translates to:
  /// **'Working style and communication preferences'**
  String get personalAgentContextWhatToIncludeItem2;

  /// No description provided for @personalAgentContextWhatToIncludeItem3.
  ///
  /// In en, this message translates to:
  /// **'Current responsibilities and focus areas'**
  String get personalAgentContextWhatToIncludeItem3;

  /// No description provided for @personalAgentContextWhatToIncludeItem4.
  ///
  /// In en, this message translates to:
  /// **'Any other context you\'d like the AI to remember'**
  String get personalAgentContextWhatToIncludeItem4;

  /// No description provided for @personalAgentContextPickFile.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a .txt file'**
  String get personalAgentContextPickFile;

  /// No description provided for @personalAgentContextFileSelected.
  ///
  /// In en, this message translates to:
  /// **'File selected'**
  String get personalAgentContextFileSelected;

  /// No description provided for @personalAgentContextFileTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a different file'**
  String get personalAgentContextFileTapToChange;

  /// No description provided for @personalAgentContextUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Context File'**
  String get personalAgentContextUploadButton;

  /// No description provided for @personalAgentContextUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get personalAgentContextUploading;

  /// No description provided for @personalAgentContextUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Context uploaded successfully'**
  String get personalAgentContextUploadSuccess;

  /// No description provided for @personalAgentContextUploadedFile.
  ///
  /// In en, this message translates to:
  /// **'Uploaded: {fileName}'**
  String personalAgentContextUploadedFile(String fileName);

  /// No description provided for @personalAgentWhatHappensNext.
  ///
  /// In en, this message translates to:
  /// **'What happens next'**
  String get personalAgentWhatHappensNext;

  /// No description provided for @personalAgentStepCreateOffer.
  ///
  /// In en, this message translates to:
  /// **'A Personal AI offer is created for your current identity.'**
  String get personalAgentStepCreateOffer;

  /// No description provided for @personalAgentStepFetchMnemonic.
  ///
  /// In en, this message translates to:
  /// **'MPX retrieves the mnemonic from backend offer API.'**
  String get personalAgentStepFetchMnemonic;

  /// No description provided for @personalAgentStepAcceptOffer.
  ///
  /// In en, this message translates to:
  /// **'The app accepts the offer and waits for channel inauguration.'**
  String get personalAgentStepAcceptOffer;

  /// No description provided for @personalAgentStepContactAppears.
  ///
  /// In en, this message translates to:
  /// **'Personal AI appears in contacts when channel activity arrives.'**
  String get personalAgentStepContactAppears;

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
  /// **'{errorCode, select, connection_offer_owned_by_claiming_party{You cannot accept this invitation because you are the inviter!} connection_offer_already_claimed_by_claiming_party{You cannot accept this invitation because you already requested to connect and have an outstanding claim in progress} missingMnemonic{Please enter an invitation passphrase to search} connection_offer_not_found_error{The details you provided did not match any active invitations.} discovery_register_offer_group_generic{Failed to publish invitation.} missingDeviceToken{Unable to find device notification token} offerOwnedByClaimingParty{You cannot claim this invitation because you are the owner} offerAlreadyClaimedByParty{You cannot claim this offer because you already accepted the invitation and have an outstanding request in progress} offerNotFound{The details you provided did not match any active invitations.} mediatorAlreadyExists{Message server with the same DID already exists.} mediator_get_did_error{No message server found at the provided URL} unableToFindMediator{No message server found at the provided URL} oobFlowTimedOut{Unable to establish a connection with other party, QR code was likely already used} connection_offer_expired{This invitation has expired} connection_offer_limit_exceeded{This invitation has reached its maximum number of uses} register_offer_mnemonic_in_use{This phrase is already in use, please choose another one} invalidQrCode{QR-Code is not valid} oob_invalid_data{QR-Code data is not valid} oob_not_found{QR-Code data does not match any active invitation} oob_invalid_type{QR-Code data not supported} network_error{Could not connect. Check your internet connection and try again.} deleteContactFailed{Failed to delete contact.} other{{errorCode}}}'**
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

  /// No description provided for @chatMessageActionAskSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Ask for suggestion'**
  String get chatMessageActionAskSuggestion;

  /// No description provided for @chatSuggestionActionIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get chatSuggestionActionIgnore;

  /// No description provided for @chatSuggestionActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get chatSuggestionActionEdit;

  /// No description provided for @chatSuggestionActionSendAsMe.
  ///
  /// In en, this message translates to:
  /// **'Send as Me'**
  String get chatSuggestionActionSendAsMe;

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

  /// No description provided for @chatSuggestionRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not request suggestion'**
  String get chatSuggestionRequestFailed;

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

  /// No description provided for @agentContextWorkAiLabel.
  ///
  /// In en, this message translates to:
  /// **'Work AI'**
  String get agentContextWorkAiLabel;

  /// No description provided for @agentContextPersonalAiLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal AI'**
  String get agentContextPersonalAiLabel;

  /// No description provided for @contactsChannelContextSet.
  ///
  /// In en, this message translates to:
  /// **'Channel context set to {label}'**
  String contactsChannelContextSet(String label);

  /// No description provided for @chatContextUploaded.
  ///
  /// In en, this message translates to:
  /// **'{label} context uploaded: {fileName}'**
  String chatContextUploaded(String label, String fileName);

  /// No description provided for @chatUploadFileFirst.
  ///
  /// In en, this message translates to:
  /// **'Upload {fileName} first.'**
  String chatUploadFileFirst(String fileName);

  /// No description provided for @chatChannelUsesContext.
  ///
  /// In en, this message translates to:
  /// **'Channel now uses {label}.'**
  String chatChannelUsesContext(String label);

  /// No description provided for @chatMenuUseWorkAi.
  ///
  /// In en, this message translates to:
  /// **'Use Work AI'**
  String get chatMenuUseWorkAi;

  /// No description provided for @chatMenuUsePersonalAi.
  ///
  /// In en, this message translates to:
  /// **'Use Personal AI'**
  String get chatMenuUsePersonalAi;

  /// No description provided for @chatMenuUploadWorkContext.
  ///
  /// In en, this message translates to:
  /// **'Upload work-context.txt'**
  String get chatMenuUploadWorkContext;

  /// No description provided for @chatMenuReuploadWorkContext.
  ///
  /// In en, this message translates to:
  /// **'Re-upload work-context.txt'**
  String get chatMenuReuploadWorkContext;

  /// No description provided for @chatMenuUploadPersonalContext.
  ///
  /// In en, this message translates to:
  /// **'Upload personal-context.txt'**
  String get chatMenuUploadPersonalContext;

  /// No description provided for @chatMenuReuploadPersonalContext.
  ///
  /// In en, this message translates to:
  /// **'Re-upload personal-context.txt'**
  String get chatMenuReuploadPersonalContext;

  /// No description provided for @identitiesSetupMyAgent.
  ///
  /// In en, this message translates to:
  /// **'Set up your AI'**
  String get identitiesSetupMyAgent;

  /// No description provided for @identitiesSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get identitiesSetupButton;

  /// No description provided for @identitiesSetupPromptDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a work context so your AI is ready when you need it.'**
  String get identitiesSetupPromptDescription;

  /// No description provided for @identitiesSettingUp.
  ///
  /// In en, this message translates to:
  /// **'Setting Up...'**
  String get identitiesSettingUp;

  /// No description provided for @identitiesNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get identitiesNotNow;

  /// No description provided for @identitiesAgentConfiguredTooltip.
  ///
  /// In en, this message translates to:
  /// **'Agent configured'**
  String get identitiesAgentConfiguredTooltip;

  /// No description provided for @personalAgentNoContextCreated.
  ///
  /// In en, this message translates to:
  /// **'No context created'**
  String get personalAgentNoContextCreated;

  /// No description provided for @personalAgentContextUploadedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'{label} uploaded: {fileName}'**
  String personalAgentContextUploadedSnackBar(String label, String fileName);

  /// No description provided for @personalAgentSetupSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your AI. Choose what context to set up.'**
  String get personalAgentSetupSectionSubtitle;

  /// No description provided for @personalAgentChooseFileToSetUp.
  ///
  /// In en, this message translates to:
  /// **'Choose a file to set up'**
  String get personalAgentChooseFileToSetUp;

  /// No description provided for @personalAgentAlreadySetUp.
  ///
  /// In en, this message translates to:
  /// **'Already set up: {fileName}'**
  String personalAgentAlreadySetUp(String fileName);

  /// No description provided for @personalAgentSetupCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your AI'**
  String get personalAgentSetupCardTitle;

  /// No description provided for @personalAgentSetupCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose what context to set up.'**
  String get personalAgentSetupCardDescription;

  /// No description provided for @personalAgentConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting {label}...'**
  String personalAgentConnecting(String label);

  /// No description provided for @personalAgentDefaultConnectingLabel.
  ///
  /// In en, this message translates to:
  /// **'agent'**
  String get personalAgentDefaultConnectingLabel;

  /// No description provided for @personalAgentWorkAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Agent'**
  String get personalAgentWorkAgentTitle;

  /// No description provided for @personalAgentPersonalAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Agent'**
  String get personalAgentPersonalAgentTitle;

  /// No description provided for @personalAgentMyWorkAiTitle.
  ///
  /// In en, this message translates to:
  /// **'My Work AI'**
  String get personalAgentMyWorkAiTitle;

  /// No description provided for @personalAgentWorkContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Work (ctx 0)'**
  String get personalAgentWorkContextLabel;

  /// No description provided for @personalAgentMyPersonalAiTitle.
  ///
  /// In en, this message translates to:
  /// **'My Personal AI'**
  String get personalAgentMyPersonalAiTitle;

  /// No description provided for @personalAgentPersonalContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal (ctx 1)'**
  String get personalAgentPersonalContextLabel;

  /// No description provided for @personalAgentCancelConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel {label} connection?'**
  String personalAgentCancelConnectionTitle(String label);

  /// No description provided for @personalAgentCancelConnectionContent.
  ///
  /// In en, this message translates to:
  /// **'This will remove your connection to the {agentLabel}.'**
  String personalAgentCancelConnectionContent(String agentLabel);

  /// No description provided for @personalAgentKeepConnection.
  ///
  /// In en, this message translates to:
  /// **'Keep connection'**
  String get personalAgentKeepConnection;

  /// No description provided for @personalAgentCancelConnection.
  ///
  /// In en, this message translates to:
  /// **'Cancel connection'**
  String get personalAgentCancelConnection;

  /// No description provided for @personalAgentConnectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'{label} connection cancelled.'**
  String personalAgentConnectionCancelled(String label);

  /// No description provided for @personalAgentCancelConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to cancel {label} connection.'**
  String personalAgentCancelConnectionError(String label);

  /// No description provided for @personalAgentNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get personalAgentNotAvailable;

  /// No description provided for @personalAgentNoSnapshotYet.
  ///
  /// In en, this message translates to:
  /// **'No snapshot yet'**
  String get personalAgentNoSnapshotYet;

  /// No description provided for @personalAgentNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get personalAgentNotSetUp;

  /// No description provided for @personalAgentAuthAgentDid.
  ///
  /// In en, this message translates to:
  /// **'Agent DID'**
  String get personalAgentAuthAgentDid;

  /// No description provided for @personalAgentAuthAclRole.
  ///
  /// In en, this message translates to:
  /// **'ACL role'**
  String get personalAgentAuthAclRole;

  /// No description provided for @personalAgentAuthCapabilities.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get personalAgentAuthCapabilities;

  /// No description provided for @personalAgentAuthContextScope.
  ///
  /// In en, this message translates to:
  /// **'Context scope'**
  String get personalAgentAuthContextScope;

  /// No description provided for @personalAgentAuthDomainId.
  ///
  /// In en, this message translates to:
  /// **'Domain ID'**
  String get personalAgentAuthDomainId;

  /// No description provided for @personalAgentAuthProvision.
  ///
  /// In en, this message translates to:
  /// **'Provision'**
  String get personalAgentAuthProvision;

  /// No description provided for @personalAgentAuthUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get personalAgentAuthUpdated;

  /// No description provided for @mnemonicErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get mnemonicErrorOccurred;

  /// No description provided for @mnemonicEntrySelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like\nto enter your wallet?'**
  String get mnemonicEntrySelectionTitle;

  /// No description provided for @mnemonicScanQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get mnemonicScanQrTitle;

  /// No description provided for @mnemonicScanQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your camera to scan a wallet QR code'**
  String get mnemonicScanQrSubtitle;

  /// No description provided for @mnemonicEnterManuallyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get mnemonicEnterManuallyTitle;

  /// No description provided for @mnemonicEnterManuallySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type the mnemonic phrase that was shared with you'**
  String get mnemonicEnterManuallySubtitle;

  /// No description provided for @mnemonicManualEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your mnemonic'**
  String get mnemonicManualEntryTitle;

  /// No description provided for @mnemonicManualEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the mnemonic phrase that was shared with you.'**
  String get mnemonicManualEntrySubtitle;

  /// No description provided for @mnemonicManualHint.
  ///
  /// In en, this message translates to:
  /// **'word1 word2 word3 ...'**
  String get mnemonicManualHint;

  /// No description provided for @mnemonicContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get mnemonicContinue;

  /// No description provided for @mnemonicSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get mnemonicSuccessTitle;

  /// No description provided for @mnemonicSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy MeetingPlace and get engaged\nwith your personal AI agent.'**
  String get mnemonicSuccessSubtitle;

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

  /// No description provided for @trustTaskHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust task history'**
  String get trustTaskHistoryTitle;

  /// No description provided for @trustTaskHistoryRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get trustTaskHistoryRefresh;

  /// No description provided for @trustTaskHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trust tasks yet'**
  String get trustTaskHistoryEmpty;

  /// No description provided for @trustTaskHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load trust task history'**
  String get trustTaskHistoryError;

  /// No description provided for @trustTaskHistoryRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get trustTaskHistoryRetry;

  /// No description provided for @trustTaskHistoryLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get trustTaskHistoryLoadMore;

  /// No description provided for @trustTaskHistoryItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Signing request'**
  String get trustTaskHistoryItemTitle;

  /// No description provided for @trustTaskHistoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get trustTaskHistoryDetails;

  /// No description provided for @trustTaskStatusSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get trustTaskStatusSigned;

  /// No description provided for @trustTaskStatusDenied.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get trustTaskStatusDenied;

  /// No description provided for @trustTaskStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get trustTaskStatusUnknown;
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
