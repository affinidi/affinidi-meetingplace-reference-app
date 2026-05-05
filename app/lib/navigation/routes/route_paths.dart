class RoutePaths {
  // Root
  static const root = '/';

  // Tabs
  static const connections = '/connections';
  static const contacts = '/contacts';
  static const identities = '/identities';
  static const settings = '/settings';

  // Contacts
  static const chat = ':contactId/chat';

  // Connections
  static const connectionDetails = ':contactId/connection-details';

  // Offers
  static const publishOffer = 'publish-offer';
  static const offerDetails = 'offer-details';
  static const findOffer = 'find-offer';
  static const acceptOffer = ':mnemonic/accept';

  // Identity
  static const identityForm = 'identity-form';

  // OOB
  static const oobShareQr = 'oob-share-qr';
  static const oobScanQr = 'oob-scan-qr';

  // R-Cards
  static const rCards = '/r-cards';
  static const rCardDetails = ':subjectDid/details';

  // Media
  static const media = '/media';
  static const mediaPreview = 'preview';

  // Authentication
  static const authentication = '/authentication';

  // Onboarding
  static const String onboarding = '/onboarding';
}
