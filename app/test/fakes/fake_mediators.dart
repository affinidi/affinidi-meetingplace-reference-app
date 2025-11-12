import 'package:mpx_flutter_reference_app/domain/models/mediator/mediator.dart';
import 'package:mpx_flutter_reference_app/domain/models/mediator/mediator_status.dart';
import 'package:mpx_flutter_reference_app/domain/models/mediator/mediator_type.dart';

class FakeMediators {
  static final all = [
    const Mediator(
      id: 'default-mediator-id',
      mediatorName: 'Default Mediator',
      mediatorDid: 'did:peer:default-mediator',
      type: MediatorType.local,
      status: MediatorStatus.active,
    ),
    const Mediator(
      id: 'custom-mediator-id',
      mediatorName: 'Custom Mediator',
      mediatorDid: 'did:peer:custom-mediator',
      type: MediatorType.custom,
      status: MediatorStatus.active,
    ),
    const Mediator(
      id: 'secondary-mediator-id',
      mediatorName: 'Secondary Mediator',
      mediatorDid: 'did:peer:secondary-mediator',
      type: MediatorType.custom,
      status: MediatorStatus.active,
    ),
  ];

  static final defaultMediator = all[0];
  static final customMediator = all[1];
  static final secondaryMediator = all[2];
}
