import 'package:collection/collection.dart';

enum ChatProtocolApp {
  /// Represents a "typing" or activity indicator.
  chatMatchmakerRecommendation(
      'https://affinidi.io/mpx/chat-sdk/extension/matchmaker/recommendation');

  /// Creates a [ChatProtocol] instance with the given URI [value].
  const ChatProtocolApp(this.value);

  /// The URI string that uniquely identifies this chat protocol.
  final String value;

  /// Looks up a [ChatProtocol] by its URI [value].
  ///
  /// **Parameters:**
  /// - [value]: The URI string of the protocol.
  ///
  /// **Returns:**
  /// - The matching [ChatProtocolApp], or `null` if no match is found.
  static ChatProtocolApp? byValue(String value) {
    return ChatProtocolApp.values.firstWhereOrNull((e) => e.value == value);
  }
}
