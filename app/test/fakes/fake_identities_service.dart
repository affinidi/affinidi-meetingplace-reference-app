import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';

class FakeIdentitiesService extends IdentitiesService {
  FakeIdentitiesService(this._state);

  final IdentitiesServiceState _state;

  @override
  IdentitiesServiceState build() => _state;
}
