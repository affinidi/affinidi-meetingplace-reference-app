// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_chat_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appChatServiceHash() => r'3c7f74fc4267c88f424e51034572a7961ca5e724';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AppChatService
    extends BuildlessAutoDisposeNotifier<ChatServiceState> {
  late final String channelDid;

  ChatServiceState build(String channelDid);
}

/// See also [AppChatService].
@ProviderFor(AppChatService)
const appChatServiceProvider = AppChatServiceFamily();

/// See also [AppChatService].
class AppChatServiceFamily extends Family<ChatServiceState> {
  /// See also [AppChatService].
  const AppChatServiceFamily();

  /// See also [AppChatService].
  AppChatServiceProvider call(String channelDid) {
    return AppChatServiceProvider(channelDid);
  }

  @override
  AppChatServiceProvider getProviderOverride(
    covariant AppChatServiceProvider provider,
  ) {
    return call(provider.channelDid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'appChatServiceProvider';
}

/// See also [AppChatService].
class AppChatServiceProvider
    extends AutoDisposeNotifierProviderImpl<AppChatService, ChatServiceState> {
  /// See also [AppChatService].
  AppChatServiceProvider(String channelDid)
    : this._internal(
        () => AppChatService()..channelDid = channelDid,
        from: appChatServiceProvider,
        name: r'appChatServiceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$appChatServiceHash,
        dependencies: AppChatServiceFamily._dependencies,
        allTransitiveDependencies:
            AppChatServiceFamily._allTransitiveDependencies,
        channelDid: channelDid,
      );

  AppChatServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelDid,
  }) : super.internal();

  final String channelDid;

  @override
  ChatServiceState runNotifierBuild(covariant AppChatService notifier) {
    return notifier.build(channelDid);
  }

  @override
  Override overrideWith(AppChatService Function() create) {
    return ProviderOverride(
      origin: this,
      override: AppChatServiceProvider._internal(
        () => create()..channelDid = channelDid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channelDid: channelDid,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AppChatService, ChatServiceState>
  createElement() {
    return _AppChatServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppChatServiceProvider && other.channelDid == channelDid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelDid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AppChatServiceRef on AutoDisposeNotifierProviderRef<ChatServiceState> {
  /// The parameter `channelDid` of this provider.
  String get channelDid;
}

class _AppChatServiceProviderElement
    extends AutoDisposeNotifierProviderElement<AppChatService, ChatServiceState>
    with AppChatServiceRef {
  _AppChatServiceProviderElement(super.provider);

  @override
  String get channelDid => (origin as AppChatServiceProvider).channelDid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
