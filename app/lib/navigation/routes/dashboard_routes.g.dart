// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$dashboardShellRouteData];

RouteBase get $dashboardShellRouteData => StatefulShellRouteData.$route(
  restorationScopeId: DashboardShellRouteData.$restorationScopeId,
  factory: $DashboardShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      navigatorKey: ContactsBranchData.$navigatorKey,
      restorationScopeId: ContactsBranchData.$restorationScopeId,
      routes: [
        GoRouteData.$route(
          path: '/contacts',
          name: 'contacts',
          factory: $ContactsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':contactId/connection-details',
              name: 'connectionDetails',
              parentNavigatorKey: ConnectionDetailsRoute.$parentNavigatorKey,
              factory: $ConnectionDetailsRoute._fromState,
            ),
            GoRouteData.$route(
              path: ':contactId/chat',
              name: 'chat',
              parentNavigatorKey: ChatRoute.$parentNavigatorKey,
              factory: $ChatRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: ConnectionsBranchData.$navigatorKey,
      restorationScopeId: ConnectionsBranchData.$restorationScopeId,
      routes: [
        GoRouteData.$route(
          path: '/connections',
          name: 'connections',
          factory: $ConnectionsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'find-offer',
              name: 'findOffer',
              parentNavigatorKey: FindOfferRoute.$parentNavigatorKey,
              factory: $FindOfferRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':mnemonic/accept',
                  name: 'acceptOffer',
                  parentNavigatorKey: AcceptOfferRoute.$parentNavigatorKey,
                  factory: $AcceptOfferRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'publish-offer',
              name: 'publishOffer',
              parentNavigatorKey: PublishOfferRoute.$parentNavigatorKey,
              factory: $PublishOfferRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'offer-details',
              name: 'offerDetails',
              parentNavigatorKey: OfferDetailsRoute.$parentNavigatorKey,
              factory: $OfferDetailsRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'oob-share-qr',
              name: 'oobQr',
              parentNavigatorKey: OOBShareQrRoute.$parentNavigatorKey,
              factory: $OOBShareQrRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'oob-scan-qr',
              name: 'qrScanner',
              parentNavigatorKey: OOBScanQrRoute.$parentNavigatorKey,
              factory: $OOBScanQrRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: IdentitiesBranchData.$navigatorKey,
      restorationScopeId: IdentitiesBranchData.$restorationScopeId,
      routes: [
        GoRouteData.$route(
          path: '/identities',
          name: 'identities',
          factory: $IdentitiesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'identity-form',
              name: 'identityForm',
              parentNavigatorKey: IdentityFormRoute.$parentNavigatorKey,
              factory: $IdentityFormRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: RCardsBranchData.$navigatorKey,
      restorationScopeId: RCardsBranchData.$restorationScopeId,
      routes: [
        GoRouteData.$route(
          path: '/r-cards',
          name: 'rCards',
          factory: $RCardsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':subjectDid/details',
              name: 'rCardDetails',
              parentNavigatorKey: RCardDetailsRoute.$parentNavigatorKey,
              factory: $RCardDetailsRoute._fromState,
            ),
            GoRouteData.$route(
              path: ':credentialId/vrc-details',
              name: 'vrcDetails',
              parentNavigatorKey: VrcDetailsRoute.$parentNavigatorKey,
              factory: $VrcDetailsRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: CredentialsBranchData.$navigatorKey,
      restorationScopeId: CredentialsBranchData.$restorationScopeId,
      routes: [
        GoRouteData.$route(
          path: '/credentials',
          name: 'credentials',
          factory: $CredentialsRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $DashboardShellRouteDataExtension on DashboardShellRouteData {
  static DashboardShellRouteData _fromState(GoRouterState state) =>
      const DashboardShellRouteData();
}

mixin $ContactsRoute on GoRouteData {
  static ContactsRoute _fromState(GoRouterState state) => const ContactsRoute();

  @override
  String get location => GoRouteData.$location('/contacts');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ConnectionDetailsRoute on GoRouteData {
  static ConnectionDetailsRoute _fromState(GoRouterState state) =>
      ConnectionDetailsRoute(contactId: state.pathParameters['contactId']!);

  ConnectionDetailsRoute get _self => this as ConnectionDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/contacts/${Uri.encodeComponent(_self.contactId)}/connection-details',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ChatRoute on GoRouteData {
  static ChatRoute _fromState(GoRouterState state) =>
      ChatRoute(contactId: state.pathParameters['contactId']!);

  ChatRoute get _self => this as ChatRoute;

  @override
  String get location => GoRouteData.$location(
    '/contacts/${Uri.encodeComponent(_self.contactId)}/chat',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ConnectionsRoute on GoRouteData {
  static ConnectionsRoute _fromState(GoRouterState state) =>
      const ConnectionsRoute();

  @override
  String get location => GoRouteData.$location('/connections');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FindOfferRoute on GoRouteData {
  static FindOfferRoute _fromState(GoRouterState state) =>
      FindOfferRoute(identityId: state.uri.queryParameters['identity-id']);

  FindOfferRoute get _self => this as FindOfferRoute;

  @override
  String get location => GoRouteData.$location(
    '/connections/find-offer',
    queryParams: {
      if (_self.identityId != null) 'identity-id': _self.identityId,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AcceptOfferRoute on GoRouteData {
  static AcceptOfferRoute _fromState(GoRouterState state) => AcceptOfferRoute(
    mnemonic: state.pathParameters['mnemonic']!,
    identityId: state.uri.queryParameters['identity-id']!,
  );

  AcceptOfferRoute get _self => this as AcceptOfferRoute;

  @override
  String get location => GoRouteData.$location(
    '/connections/find-offer/${Uri.encodeComponent(_self.mnemonic)}/accept',
    queryParams: {'identity-id': _self.identityId},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PublishOfferRoute on GoRouteData {
  static PublishOfferRoute _fromState(GoRouterState state) =>
      PublishOfferRoute(identityId: state.uri.queryParameters['identity-id']!);

  PublishOfferRoute get _self => this as PublishOfferRoute;

  @override
  String get location => GoRouteData.$location(
    '/connections/publish-offer',
    queryParams: {'identity-id': _self.identityId},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $OfferDetailsRoute on GoRouteData {
  static OfferDetailsRoute _fromState(GoRouterState state) =>
      OfferDetailsRoute(state.uri.queryParameters['offer-link']!);

  OfferDetailsRoute get _self => this as OfferDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/connections/offer-details',
    queryParams: {'offer-link': _self.offerLink},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $OOBShareQrRoute on GoRouteData {
  static OOBShareQrRoute _fromState(GoRouterState state) =>
      const OOBShareQrRoute();

  @override
  String get location => GoRouteData.$location('/connections/oob-share-qr');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $OOBScanQrRoute on GoRouteData {
  static OOBScanQrRoute _fromState(GoRouterState state) =>
      const OOBScanQrRoute();

  @override
  String get location => GoRouteData.$location('/connections/oob-scan-qr');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $IdentitiesRoute on GoRouteData {
  static IdentitiesRoute _fromState(GoRouterState state) =>
      const IdentitiesRoute();

  @override
  String get location => GoRouteData.$location('/identities');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $IdentityFormRoute on GoRouteData {
  static IdentityFormRoute _fromState(GoRouterState state) =>
      IdentityFormRoute(identityId: state.uri.queryParameters['identity-id']);

  IdentityFormRoute get _self => this as IdentityFormRoute;

  @override
  String get location => GoRouteData.$location(
    '/identities/identity-form',
    queryParams: {
      if (_self.identityId != null) 'identity-id': _self.identityId,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RCardsRoute on GoRouteData {
  static RCardsRoute _fromState(GoRouterState state) => const RCardsRoute();

  @override
  String get location => GoRouteData.$location('/r-cards');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CredentialsRoute on GoRouteData {
  static CredentialsRoute _fromState(GoRouterState state) =>
      const CredentialsRoute();

  @override
  String get location => GoRouteData.$location('/credentials');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RCardDetailsRoute on GoRouteData {
  static RCardDetailsRoute _fromState(GoRouterState state) =>
      RCardDetailsRoute(subjectDid: state.pathParameters['subjectDid']!);

  RCardDetailsRoute get _self => this as RCardDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/r-cards/${Uri.encodeComponent(_self.subjectDid)}/details',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $VrcDetailsRoute on GoRouteData {
  static VrcDetailsRoute _fromState(GoRouterState state) =>
      VrcDetailsRoute(credentialId: state.pathParameters['credentialId']!);

  VrcDetailsRoute get _self => this as VrcDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/r-cards/${Uri.encodeComponent(_self.credentialId)}/vrc-details',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
