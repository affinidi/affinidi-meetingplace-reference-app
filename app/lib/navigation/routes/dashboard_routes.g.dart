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

          factory: _$ContactsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':contactId/connection-details',
              name: 'connectionDetails',

              parentNavigatorKey: ConnectionDetailsRoute.$parentNavigatorKey,

              factory: _$ConnectionDetailsRoute._fromState,
            ),
            GoRouteData.$route(
              path: ':contactId/chat',
              name: 'chat',

              parentNavigatorKey: ChatRoute.$parentNavigatorKey,

              factory: _$ChatRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':matrixRoomId/video-call',
                  name: 'videoCall',

                  parentNavigatorKey: VideoCallRoute.$parentNavigatorKey,

                  factory: _$VideoCallRoute._fromState,
                ),
              ],
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

          factory: _$ConnectionsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'find-offer',
              name: 'findOffer',

              parentNavigatorKey: FindOfferRoute.$parentNavigatorKey,

              factory: _$FindOfferRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':mnemonic/accept',
                  name: 'acceptOffer',

                  parentNavigatorKey: AcceptOfferRoute.$parentNavigatorKey,

                  factory: _$AcceptOfferRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'publish-offer',
              name: 'publishOffer',

              parentNavigatorKey: PublishOfferRoute.$parentNavigatorKey,

              factory: _$PublishOfferRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'offer-details',
              name: 'offerDetails',

              parentNavigatorKey: OfferDetailsRoute.$parentNavigatorKey,

              factory: _$OfferDetailsRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'oob-share-qr',
              name: 'oobQr',

              parentNavigatorKey: OOBShareQrRoute.$parentNavigatorKey,

              factory: _$OOBShareQrRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'oob-scan-qr',
              name: 'qrScanner',

              parentNavigatorKey: OOBScanQrRoute.$parentNavigatorKey,

              factory: _$OOBScanQrRoute._fromState,
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

          factory: _$IdentitiesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'identity-form',
              name: 'identityForm',

              parentNavigatorKey: IdentityFormRoute.$parentNavigatorKey,

              factory: _$IdentityFormRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: SettingsBranchData.$navigatorKey,
      restorationScopeId: SettingsBranchData.$restorationScopeId,

      routes: [
        GoRouteData.$route(
          path: '/settings',
          name: 'settings',

          factory: _$SettingsRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $DashboardShellRouteDataExtension on DashboardShellRouteData {
  static DashboardShellRouteData _fromState(GoRouterState state) =>
      const DashboardShellRouteData();
}

mixin _$ContactsRoute on GoRouteData {
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

mixin _$ConnectionDetailsRoute on GoRouteData {
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

mixin _$ChatRoute on GoRouteData {
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

mixin _$VideoCallRoute on GoRouteData {
  static VideoCallRoute _fromState(GoRouterState state) => VideoCallRoute(
    contactId: state.pathParameters['contactId']!,
    matrixRoomId: state.pathParameters['matrixRoomId']!,
    audioOnly:
        _$convertMapValue(
          'audio-only',
          state.uri.queryParameters,
          _$boolConverter,
        ) ??
        false,
  );

  VideoCallRoute get _self => this as VideoCallRoute;

  @override
  String get location => GoRouteData.$location(
    '/contacts/${Uri.encodeComponent(_self.contactId)}/chat/${Uri.encodeComponent(_self.matrixRoomId)}/video-call',
    queryParams: {
      if (_self.audioOnly != false) 'audio-only': _self.audioOnly.toString(),
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

mixin _$ConnectionsRoute on GoRouteData {
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

mixin _$FindOfferRoute on GoRouteData {
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

mixin _$AcceptOfferRoute on GoRouteData {
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

mixin _$PublishOfferRoute on GoRouteData {
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

mixin _$OfferDetailsRoute on GoRouteData {
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

mixin _$OOBShareQrRoute on GoRouteData {
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

mixin _$OOBScanQrRoute on GoRouteData {
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

mixin _$IdentitiesRoute on GoRouteData {
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

mixin _$IdentityFormRoute on GoRouteData {
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

mixin _$SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

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

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}
