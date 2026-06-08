import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class FakeConnectivity implements Connectivity {
  FakeConnectivity({
    this._initialConnectivityToReturn = const [ConnectivityResult.none],
  });

  final List<ConnectivityResult> _initialConnectivityToReturn;

  final _connectivityChangedController =
      StreamController<List<ConnectivityResult>>.broadcast();
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivityChangedController.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _initialConnectivityToReturn;
  }

  void emitConnectivityChange(List<ConnectivityResult> results) {
    _connectivityChangedController.add(results);
  }
}
