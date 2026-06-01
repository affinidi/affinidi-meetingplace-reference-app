import 'package:flutter/services.dart';

/// Reads the device's region setting via platform-specific native code.
///
/// On iOS this returns `Locale.current.region.identifier` (the Region
/// setting under Settings > General > Language & Region).
/// On Android this returns `Locale.getDefault().country`.
class DeviceRegionPlugin {
  DeviceRegionPlugin._();

  static const _channel = MethodChannel(
    'com.example.meetingplace/device_region',
  );

  static String? _cachedRegionCode;

  /// Must be called once during app startup (after
  /// `WidgetsFlutterBinding.ensureInitialized()`).
  static Future<void> initialize() async {
    _cachedRegionCode = await _fetchRegionCode();
  }

  /// Returns the cached ISO 3166-1 alpha-2 region code (e.g. "DE"),
  /// or `null` if unavailable.
  static String? get regionCode => _cachedRegionCode;

  static Future<String?> _fetchRegionCode() async {
    try {
      final result = await _channel.invokeMethod<String>('getRegionCode');
      if (result != null && RegExp(r'^[A-Za-z]{2}$').hasMatch(result)) {
        return result.toUpperCase();
      }
      return null;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
