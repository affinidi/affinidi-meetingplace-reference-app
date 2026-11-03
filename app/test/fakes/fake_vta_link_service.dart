import 'package:mpx_flutter_reference_app/application/services/vtc_service/vta_link_service.dart';

/// A VTA link that is already active, so the router lets tests into the app.
class FakeVtaLinkService extends VtaLinkService {
  @override
  VtaLinkState build() =>
      const VtaLinkState(status: VtaLinkStatus.active, vtaDid: 'did:key:vta');
}
