import 'package:mpx_flutter_reference_app/navigation/navigator.dart';

/// Records navigation targets so tests can assert on the resulting location.
class RecordingNavigator implements Navigator {
  final List<String> goCalls = [];

  @override
  void go(String path) => goCalls.add(path);

  @override
  Future<T?> push<T extends Object?>(String path) async => null;

  @override
  void pop<T extends Object?>([T? result]) {}
}
