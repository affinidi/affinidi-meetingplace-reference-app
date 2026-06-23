import 'package:mpx_flutter_reference_app/application/services/settings_service/settings_service.dart';
import 'package:mpx_flutter_reference_app/application/services/settings_service/settings_service_state.dart';

class FakeSettingsService extends SettingsService {
  @override
  SettingsServiceState build() =>
      SettingsServiceState(selectedMediatorDid: '', alreadyOnboarded: false);
}
