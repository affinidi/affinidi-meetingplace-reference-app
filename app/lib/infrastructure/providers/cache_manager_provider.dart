import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final cacheManagerProvider = Provider<BaseCacheManager>((ref) {
  ref.keepAlive();

  final cacheManager = DefaultCacheManager();
  final images = <String>[
    'assets/images/version_cat.jpg',
    'assets/images/meeting-place-splash-white-1024.png',
    'assets/images/meetingplace-banner.png'
  ];
  final config = ImageConfiguration(
    devicePixelRatio:
        PlatformDispatcher.instance.views.firstOrNull?.devicePixelRatio ?? 1.0,
  );
  for (var path in images) {
    AssetImage(path).resolve(config);
  }

  return cacheManager;
});
