import 'package:mpx_flutter_reference_app/application/services/authentication_service/authentication_service.dart';
import 'package:mpx_flutter_reference_app/application/services/authentication_service/authentication_state.dart';

class FakeAuthenticationService extends AuthenticationService {
  @override
  AuthenticationState build() => const AuthenticationState();
}
