import 'dart:async';
import 'dart:convert';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:crypto/crypto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/providers/mnemonic_configured_provider.dart';
import '../../../infrastructure/secure_storage/secure_storage.dart';
import 'mnemonic_screen_state.dart';

part 'mnemonic_screen_controller.g.dart';

@riverpod
class MnemonicScreenController extends _$MnemonicScreenController {
  @override
  MnemonicScreenState build() => const MnemonicScreenState();

  Future<bool> saveMnemonic(String mnemonic) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final trimmed = mnemonic.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (trimmed.isEmpty) {
        throw Exception('Please enter your mnemonic phrase.');
      }
      Mnemonic.fromSentence(trimmed, Language.english);
      final ciergeConfig = ref.read(environmentProvider).ciergeEventConfig;
      if (ciergeConfig.isNotEmpty) {
        final hash = sha256.convert(utf8.encode(trimmed)).toString();
        if (!ciergeConfig.containsKey(hash)) {
          throw Exception('This mnemonic is not authorized for this app.');
        }
      }
      final storage = await ref.read(secureStorageProvider.future);
      await storage.saveMnemonic(trimmed);
      ref.read(mnemonicConfiguredProvider.notifier).setConfigured();
      // Wait for SDK to initialize so any connection failure is reported here
      // rather than silently leaving the user on a broken contacts screen.
      await ref.read(meetingPlaceSdkProvider.future);
      return true;
    } catch (e) {
      // Invalidate so the user can retry by clicking Continue again.
      ref.invalidate(meetingPlaceSdkProvider);
      final message = e is TimeoutException
          ? 'Could not connect to server. Check your network and try again.'
          : e is MnemonicException
          ? e.message
          : e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isError: true, errorMessage: message);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
