import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/app_info.dart';
import '../configuration/environment.dart';

/// A [FutureProvider] that retrieves application information.
///
/// Combines environment settings with platform-specific package info
/// to build an [AppInfo] object.
final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final env = ref.read(environmentProvider);

  return AppInfo(
    versionName: env.appVersionName,
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
  );
}, name: 'appInfoProvider');
