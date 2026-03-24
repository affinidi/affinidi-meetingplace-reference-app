/// This library allows accessing screens, flows and widgets of
/// the reference application to be reused in other apps.
library;

export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:shared_preferences/shared_preferences.dart';

export 'infrastructure/database/setup_sql_cipher.dart';
export 'infrastructure/firebase_messaging/firebase_options.dart';
export 'infrastructure/firebase_messaging/firebase_push_notification_messaging.dart';
export 'infrastructure/loggers/app_logger/app_logger.dart';
export 'infrastructure/loggers/error_logger/error_logger.dart';
export 'infrastructure/loggers/riverpod_provider_logger/provider_debug_logger.dart';
export 'infrastructure/plugins/audio_attachments_plugin/audio_attachments_plugin.dart';
export 'infrastructure/plugins/camera_attachments_plugin/camera_attachments_plugin.dart';
export 'infrastructure/plugins/gallery_attachments_plugin/gallery_attachments_plugin.dart';
export 'infrastructure/providers/available_attachment_plugins_provider.dart';
export 'infrastructure/providers/cache_manager_provider.dart';
export 'infrastructure/providers/channel_repository_provider.dart';
export 'infrastructure/providers/chat_repository_provider.dart';
export 'infrastructure/providers/connection_offer_repository_provider.dart';
export 'infrastructure/providers/contacts_repository_provider.dart';
export 'infrastructure/providers/group_repository_provider.dart';
export 'infrastructure/providers/identities_repository_provider.dart';
export 'infrastructure/providers/mediators_repository_provider.dart';
export 'infrastructure/providers/push_notification_messaging_provider.dart';
export 'infrastructure/providers/shared_preferences_provider.dart';
export 'infrastructure/repositories/contacts_repository/contacts_repository_drift/contacts_repository_drift.dart';
export 'infrastructure/repositories/identities_repository/identities_repository_drift/identities_repository_drift.dart';
export 'infrastructure/repositories/mediators_repository/mediators_repository_drift/mediators_repository_drift.dart';
export 'l10n/app_localizations.dart';
export 'navigation/router_config_provider.dart';
export 'presentation/app/app_controller.dart';
export 'presentation/themes/app_theme.dart';
export 'presentation/widgets/banners/no_connection_banner.dart';
