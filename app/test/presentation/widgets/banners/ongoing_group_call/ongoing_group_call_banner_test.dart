import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/ongoing_group_call/ongoing_group_call_banner.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/ongoing_group_call/ongoing_group_call_banner_state.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/profile_circle_avatar.dart';

OngoingGroupCallBannerData _data(int count) => OngoingGroupCallBannerData(
  participantCount: count,
  avatars: [
    for (var i = 0; i < count; i++)
      OngoingGroupCallAvatar(id: 'p$i', firstName: 'P$i'),
  ],
  isAudioOnly: false,
);

Widget _wrap(Widget child, {double? width}) => MaterialApp(
  theme: AppTheme.dark,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
  group('visibleAvatarCount', () {
    test('returns 0 when nothing fits', () {
      expect(visibleAvatarCount(maxWidth: 0, total: 5), 0);
      expect(visibleAvatarCount(maxWidth: 10, total: 5, avatarSize: 32), 0);
    });

    test('returns 1 when exactly one avatar fits', () {
      expect(
        visibleAvatarCount(maxWidth: 32, total: 5, avatarSize: 32, overlap: 10),
        1,
      );
    });

    test('caps at the number that fits before overflow', () {
      // advance = 32 - 10 = 22. width for k avatars = 32 + (k-1)*22.
      // maxWidth 98 -> 32 + 3*22 = 98 -> exactly 4 fit.
      expect(
        visibleAvatarCount(
          maxWidth: 98,
          total: 10,
          avatarSize: 32,
          overlap: 10,
        ),
        4,
      );
      // one pixel short of the 4th avatar -> only 3 fit.
      expect(
        visibleAvatarCount(
          maxWidth: 97,
          total: 10,
          avatarSize: 32,
          overlap: 10,
        ),
        3,
      );
    });

    test('never exceeds the total number of avatars', () {
      expect(
        visibleAvatarCount(
          maxWidth: 1000,
          total: 3,
          avatarSize: 32,
          overlap: 10,
        ),
        3,
      );
    });
  });

  group('OngoingGroupCallBannerView layout', () {
    testWidgets('shows the ongoing-call label with the participant count', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          OngoingGroupCallBannerView(data: _data(3), onJoin: () {}),
          width: 400,
        ),
      );

      expect(find.text('Ongoing call (3)'), findsOneWidget);
    });

    testWidgets('tapping Join invokes the callback', (tester) async {
      var joined = false;
      await tester.pumpWidget(
        _wrap(
          OngoingGroupCallBannerView(
            data: _data(2),
            onJoin: () => joined = true,
          ),
          width: 400,
        ),
      );

      await tester.tap(find.text('Join'));
      await tester.pump();

      expect(joined, isTrue);
    });

    testWidgets('renders every avatar when they all fit', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OngoingGroupCallBannerView(data: _data(3), onJoin: () {}),
          width: 500,
        ),
      );

      expect(find.byType(ProfileCircleAvatar), findsNWidgets(3));
    });
  });

  group('OngoingGroupCallBannerView avatar overflow', () {
    testWidgets('drops avatars that do not fit the available width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          OngoingGroupCallBannerView(data: _data(20), onJoin: () {}),
          width: 260,
        ),
      );

      final rendered = tester
          .widgetList(find.byType(ProfileCircleAvatar))
          .length;
      expect(rendered, greaterThan(0));
      expect(rendered, lessThan(20));
    });

    testWidgets('avatars never overlap the Join button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OngoingGroupCallBannerView(data: _data(20), onJoin: () {}),
          width: 260,
        ),
      );

      final avatars = find.byType(ProfileCircleAvatar);
      expect(avatars, findsWidgets);

      final joinLeft = tester.getTopLeft(find.byType(FilledButton)).dx;
      final lastAvatarRight = tester.getTopRight(avatars.last).dx;

      expect(lastAvatarRight, lessThanOrEqualTo(joinLeft));
    });
  });
}
