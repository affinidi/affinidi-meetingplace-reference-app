/// Application version information container.
///
/// Factory parameters:
/// - [versionName] - Human readable version name
/// - [version] - Internal or semantic version string used by the app.
/// - [buildNumber] - Build identifier (for CI/build systems).
class AppInfo {
  AppInfo({
    required this.versionName,
    required this.version,
    required this.buildNumber,
  });

  final String versionName;
  final String version;
  final String buildNumber;
}
