import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/profile_circle_avatar.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/video_call_pip_window.dart';

import 'fakes/fake_identities.dart';

class _FakeIdentitiesService extends IdentitiesService {
  _FakeIdentitiesService(this._state);

  final IdentitiesServiceState _state;

  @override
  IdentitiesServiceState build() => _state;
}

Widget _wrapWindow({
  required bool isCameraEnabled,
  required IdentitiesServiceState identitiesState,
}) {
  final participant = AudioVideoCallParticipant(
    participantId: 'self',
    isSelf: true,
    hasVideo: isCameraEnabled,
  );

  return ProviderScope(
    overrides: [
      identitiesServiceProvider.overrideWith(
        () => _FakeIdentitiesService(identitiesState),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Stack(
        children: [
          VideoCallPiPWindow(
            contactId: 'contact-1',
            session: null,
            participant: participant,
            isCameraEnabled: isCameraEnabled,
            availableSize: const Size(400, 800),
          ),
        ],
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/pip_window_test.log'),
    );
  });

  group('VideoCallPiPWindow self avatar placeholder', () {
    testWidgets('shows ProfileCircleAvatar when camera is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWindow(
          isCameraEnabled: false,
          identitiesState: IdentitiesServiceState(
            currentIdentity: FakeIdentities.primaryIdentity,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ProfileCircleAvatar), findsOneWidget);
    });

    testWidgets(
      'shows ProfileCircleAvatar with person icon fallback when no profile pic',
      (tester) async {
        await tester.pumpWidget(
          _wrapWindow(
            isCameraEnabled: false,
            identitiesState: IdentitiesServiceState(),
          ),
        );
        await tester.pump();

        // Fallback renders the ProfileCircleAvatar (which shows the person icon
        // child when no image is set).
        expect(find.byType(ProfileCircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      },
    );

    testWidgets(
      'does not show avatar placeholder when camera is enabled with video',
      (tester) async {
        await tester.pumpWidget(
          _wrapWindow(
            isCameraEnabled: true,
            identitiesState: IdentitiesServiceState(
              currentIdentity: FakeIdentities.primaryIdentity,
            ),
          ),
        );
        await tester.pump();

        // Camera on: video view renders, no avatar placeholder.
        expect(find.byType(ProfileCircleAvatar), findsNothing);
      },
    );
  });
}
