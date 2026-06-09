import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';

import '../../application/services/credential_service/demo_liveness_evidence_source.dart';

final livenessEvidenceSourceProvider = Provider<LivenessEvidenceSource>(
  (ref) => const DemoLivenessEvidenceSource(),
  name: 'livenessEvidenceSourceProvider',
);
