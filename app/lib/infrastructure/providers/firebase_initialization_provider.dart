import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../firebase_messaging/firebase_initialization.dart';

part 'firebase_initialization_provider.g.dart';

@Riverpod(keepAlive: true)
FirebaseInitError? firebaseInitializationError(Ref ref) {
  return null;
}
