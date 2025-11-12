import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

extension EventMessageVcard on EventMessage {
  /// Returns a VCard constructed from `data['vCard']['values']`, or `null`
  /// if the structure is missing or has unexpected types.
  VCard? get vCard {
    final vCardField = data['vCard'];
    if (vCardField is! Map<String, dynamic>) return null;

    final values = vCardField['values'];
    if (values is! Map<String, dynamic>) return null;

    return VCard(values: values);
  }

  /// Returns the memberDid from data, or null if not present.
  String? get memberDid {
    return data['memberDid'] as String?;
  }
}
