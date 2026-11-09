import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_community.dart';

part 'communities_controller.g.dart';

/// The communities the member belongs to or is applying to, as this phone
/// records them.
@riverpod
class CommunitiesController extends _$CommunitiesController {
  @override
  Future<List<VtcCommunity>> build() {
    final service = ref.read(vtcServiceProvider);
    // The Communities tab stays alive in the background: read again
    // whenever a membership is gained or left.
    final changes = service.membershipsChanged.listen((_) => refresh());
    ref.onDispose(changes.cancel);
    return service.communities();
  }

  /// Reads the communities again, e.g. after an application was sent,
  /// withdrawn or decided, which fires no membership change.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
