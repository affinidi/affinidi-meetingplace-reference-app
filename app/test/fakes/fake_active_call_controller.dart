import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';

class FakeActiveCallController extends ActiveCallController {
  FakeActiveCallController(this._initial);

  final ActiveCallState? _initial;

  @override
  ActiveCallState? build() => _initial;
}
