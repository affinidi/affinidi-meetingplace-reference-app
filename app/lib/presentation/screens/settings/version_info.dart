part of 'settings_screen.dart';

class _VersionInfoSection extends ConsumerStatefulWidget {
  const _VersionInfoSection();

  @override
  ConsumerState<_VersionInfoSection> createState() =>
      _VersionInfoSectionState();
}

class _VersionInfoSectionState extends ConsumerState<_VersionInfoSection> {
  int _tapCount = 0;
  Timer? _tapResetTimer;

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = settingsScreenControllerProvider;
    final controller = ref.read(provider.notifier);

    final appInfo = ref.watch(provider.select((state) => state.appInfo));
    final appVersion = appInfo?.version ?? '';
    final appVersionName = appInfo?.versionName ?? '';
    final buildNumber = appInfo?.buildNumber ?? '';
    final numberOfTapsToUnlockDebug = ref.watch(
      provider.select((state) => state.numberOfTapsToUnlockDebug),
    );
    final isDebugMode = ref.watch(
      provider.select((state) => state.isDebugMode),
    );

    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        setState(() {
          _tapCount++;

          _tapResetTimer?.cancel();
          _tapResetTimer = Timer(const Duration(seconds: 2), () {
            setState(() {
              _tapCount = 0;
            });
          });

          if (_tapCount == numberOfTapsToUnlockDebug) {
            if (!isDebugMode) {
              controller.toggleDebugMode();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: context.customColors.success,
                  content: Text(l10n.easterEggEnabled),
                ),
              );
            } else {
              controller.toggleDebugMode();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colorScheme.primary,
                  content: Text(l10n.debugModeDisabled),
                ),
              );
            }

            _tapCount = 0;
          }
        });
      },
      child: FormCard(
        title: l10n.versionInfoAppName(appVersionName),
        child: Column(
          children: [
            CupertinoFormRow(
              prefix: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Container(
                      height: 24.0,
                      width: 24.0,
                      color: colorScheme.primary,
                      child: Icon(
                        Icons.qr_code,
                        color: colorScheme.onPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.versionInfoVersion(appVersion),
                        style: context.textTheme.bodyMedium,
                      ),
                      Text(
                        l10n.versionInfoBuild(buildNumber),
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage('assets/images/version_cat.jpg'),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
