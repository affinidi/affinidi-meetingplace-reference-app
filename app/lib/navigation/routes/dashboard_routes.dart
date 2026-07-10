import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/page_transitions/slide_up_transition_page.dart';
import '../../presentation/scaffolds/scaffold_with_nav_bar.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/connections/connection_details/connection_details_screen.dart';
import '../../presentation/screens/connections/connections_screen.dart';
import '../../presentation/screens/contacts/contacts_screen.dart';
import '../../presentation/screens/credentials/credentials_screen.dart';
import '../../presentation/screens/identities/form_screen/identity_form_screen.dart';
import '../../presentation/screens/identities/identities_screen.dart';
import '../../presentation/screens/offer/accept_offer_screen/accept_offer_screen.dart';
import '../../presentation/screens/offer/find_offer_screen/find_offer_screen.dart';
import '../../presentation/screens/offer/offer_details/offer_details_screen.dart';
import '../../presentation/screens/offer/publish_offer_screen/publish_offer_screen.dart';
import '../../presentation/screens/oob/oob_scan_qr_screen/oob_scan_qr_screen.dart';
import '../../presentation/screens/oob/oob_share_qr_screen/oob_share_qr_screen.dart';
import '../../presentation/screens/personal_agent/personal_agent_screen.dart';
import '../../presentation/screens/r_cards/r_card_details_screen.dart';
import '../../presentation/screens/r_cards/r_cards_screen.dart';
import '../../presentation/screens/verifiable_credential/verifiable_credential_screen.dart';
import '../router_config_provider.dart';
import 'route_names.dart';
import 'route_paths.dart';

part 'connection/connection_details_route.dart';
part 'contact/chat_route.dart';
part 'dashboard_routes.g.dart';
part 'identity/identity_form_route.dart';
part 'offer/accept_offer_route.dart';
part 'offer/find_offer_route.dart';
part 'offer/offer_details_route.dart';
part 'offer/publish_offer_route.dart';
part 'qr/oob_share_qr_route.dart';
part 'qr/qr_scanner_route.dart';
part 'r_card/r_card_details_route.dart';
part 'vrc/vrc_details_route.dart';

// Dashboard shell route
@TypedStatefulShellRoute<DashboardShellRouteData>(
  branches: [
    TypedStatefulShellBranch<ContactsBranchData>(
      routes: [
        TypedGoRoute<ContactsRoute>(
          path: RoutePaths.contacts,
          name: RouteNames.contacts,
          routes: [
            TypedGoRoute<ConnectionDetailsRoute>(
              path: RoutePaths.connectionDetails,
              name: RouteNames.connectionDetails,
            ),
            TypedGoRoute<ChatRoute>(
              path: RoutePaths.chat,
              name: RouteNames.chat,
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ConnectionsBranchData>(
      routes: [
        TypedGoRoute<ConnectionsRoute>(
          path: RoutePaths.connections,
          name: RouteNames.connections,
          routes: [
            TypedGoRoute<FindOfferRoute>(
              path: RoutePaths.findOffer,
              name: RouteNames.findOffer,
              routes: [
                TypedGoRoute<AcceptOfferRoute>(
                  path: RoutePaths.acceptOffer,
                  name: RouteNames.acceptOffer,
                ),
              ],
            ),
            TypedGoRoute<PublishOfferRoute>(
              path: RoutePaths.publishOffer,
              name: RouteNames.publishOffer,
            ),
            TypedGoRoute<OfferDetailsRoute>(
              path: RoutePaths.offerDetails,
              name: RouteNames.offerDetails,
            ),
            TypedGoRoute<OOBShareQrRoute>(
              path: RoutePaths.oobShareQr,
              name: RouteNames.oobShareQr,
            ),
            TypedGoRoute<OOBScanQrRoute>(
              path: RoutePaths.oobScanQr,
              name: RouteNames.oobScanQr,
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<IdentitiesBranchData>(
      routes: [
        TypedGoRoute<IdentitiesRoute>(
          path: RoutePaths.identities,
          name: RouteNames.identities,
          routes: [
            TypedGoRoute<IdentityFormRoute>(
              path: RoutePaths.identityForm,
              name: RouteNames.identityForm,
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<RCardsBranchData>(
      routes: [
        TypedGoRoute<RCardsRoute>(
          path: RoutePaths.rCards,
          name: RouteNames.rCards,
          routes: [
            TypedGoRoute<RCardDetailsRoute>(
              path: RoutePaths.rCardDetails,
              name: RouteNames.rCardDetails,
            ),
            TypedGoRoute<VrcDetailsRoute>(
              path: RoutePaths.vrcDetails,
              name: RouteNames.vrcDetails,
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<PersonalAgentBranchData>(
      routes: [
        TypedGoRoute<PersonalAgentRoute>(
          path: RoutePaths.personalAgent,
          name: RouteNames.personalAgent,
        ),
      ],
    ),
    TypedStatefulShellBranch<CredentialsBranchData>(
      routes: [
        TypedGoRoute<CredentialsRoute>(
          path: RoutePaths.credentials,
          name: RouteNames.credentials,
        ),
      ],
    ),
  ],
)
class DashboardShellRouteData extends StatefulShellRouteData {
  const DashboardShellRouteData();

  static final $navigatorKey = dashboardNavigatorKey;
  static const String $restorationScopeId = 'appShellRestorationScopeId';

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return NoTransitionPage(
      child: ScaffoldWithNavBar(navigationShell: navigationShell),
    );
  }
}

// Global navigator keys for branches
final dashboardNavigatorKey = GlobalKey<NavigatorState>();
final _contactsNavigatorKey = GlobalKey<NavigatorState>();
final _connectionsNavigatorKey = GlobalKey<NavigatorState>();
final _identitiesNavigatorKey = GlobalKey<NavigatorState>();
final _rCardsNavigatorKey = GlobalKey<NavigatorState>();
final _personalAgentNavigatorKey = GlobalKey<NavigatorState>();
final _credentialsNavigatorKey = GlobalKey<NavigatorState>();

// Branch data classes for each tab
class ContactsBranchData extends StatefulShellBranchData {
  const ContactsBranchData();

  static final $navigatorKey = _contactsNavigatorKey;
  static const String $restorationScopeId = 'contactsBranchRestorationScopeId';
}

class ConnectionsBranchData extends StatefulShellBranchData {
  const ConnectionsBranchData();

  static final $navigatorKey = _connectionsNavigatorKey;
  static const String $restorationScopeId =
      'connectionsBranchRestorationScopeId';
}

class IdentitiesBranchData extends StatefulShellBranchData {
  const IdentitiesBranchData();

  static final $navigatorKey = _identitiesNavigatorKey;
  static const String $restorationScopeId =
      'identitiesBranchRestorationScopeId';
}

class RCardsBranchData extends StatefulShellBranchData {
  const RCardsBranchData();

  static final $navigatorKey = _rCardsNavigatorKey;
  static const String $restorationScopeId = 'rCardsBranchRestorationScopeId';
}

class PersonalAgentBranchData extends StatefulShellBranchData {
  const PersonalAgentBranchData();

  static final $navigatorKey = _personalAgentNavigatorKey;
  static const String $restorationScopeId =
      'personalAgentBranchRestorationScopeId';
}

class CredentialsBranchData extends StatefulShellBranchData {
  const CredentialsBranchData();

  static final $navigatorKey = _credentialsNavigatorKey;
  static const String $restorationScopeId =
      'credentialsBranchRestorationScopeId';
}

// Main tabs
class ContactsRoute extends GoRouteData with $ContactsRoute {
  const ContactsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ContactsScreen();
}

class ConnectionsRoute extends GoRouteData with $ConnectionsRoute {
  const ConnectionsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ConnectionsScreen();
}

class IdentitiesRoute extends GoRouteData with $IdentitiesRoute {
  const IdentitiesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const IdentitiesScreen();
}

class RCardsRoute extends GoRouteData with $RCardsRoute {
  const RCardsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RCardsScreen();
}

class PersonalAgentRoute extends GoRouteData with $PersonalAgentRoute {
  const PersonalAgentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PersonalAgentScreen();
}

class CredentialsRoute extends GoRouteData with $CredentialsRoute {
  const CredentialsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CredentialsScreen();
}
