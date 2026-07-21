import 'dart:async';

import 'package:vta_dart_client/vta_dart_client.dart';
import 'package:web_socket_channel/io.dart';

class AuthenticatedWebSocketChannel implements VtaDidCommChannel {
  AuthenticatedWebSocketChannel({required this.uri, required this.accessToken});

  final Uri uri;
  final String accessToken;
  IOWebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final StreamController<String> _incoming =
      StreamController<String>.broadcast();
  bool _connected = false;

  @override
  Future<void> connect() async {
    if (_connected) return;

    _channel = IOWebSocketChannel.connect(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    await _channel!.ready;
    _subscription = _channel!.stream.listen(
      (dynamic event) => _incoming.add(event.toString()),
      onError: (Object error) {
        _connected = false;
        _incoming.addError(error);
      },
      onDone: () => _connected = false,
    );
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    final channel = _channel;
    _channel = null;
    _connected = false;
    await _subscription?.cancel();
    _subscription = null;
    await channel?.sink.close();
  }

  @override
  Future<void> send(String packedMessage) async {
    _channel?.sink.add(packedMessage);
  }

  @override
  Future<String?> receive({Duration timeout = const Duration(seconds: 15)}) {
    return _incoming.stream.first.timeout(timeout, onTimeout: () => '');
  }
}
