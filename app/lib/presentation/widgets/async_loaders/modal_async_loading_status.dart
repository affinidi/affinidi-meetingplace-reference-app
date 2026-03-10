import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'async_loading_controller.dart';
import 'async_loading_status_error_localizer.dart';

class LoadingMessageStyleTheme {
  LoadingMessageStyleTheme({
    required this.color,
    required this.backgroundColor,
  });

  final Color color;
  final Color backgroundColor;
}

enum LoadingMessageStyle {
  complete,
  progress,
  error;

  LoadingMessageStyleTheme theme(BuildContext context) {
    switch (this) {
      case LoadingMessageStyle.complete:
        return LoadingMessageStyleTheme(
          backgroundColor: context.customColors.success,
          color: context.colorScheme.onErrorContainer,
        );
      case LoadingMessageStyle.progress:
        return LoadingMessageStyleTheme(
          backgroundColor: context.colorScheme.primary,
          color: context.colorScheme.onErrorContainer,
        );
      case LoadingMessageStyle.error:
        return LoadingMessageStyleTheme(
          backgroundColor: context.colorScheme.errorContainer,
          color: context.colorScheme.onErrorContainer,
        );
    }
  }
}

/// Use this widget to observe asynchronous executions and display
/// a loading message.
/// In case of exceptions, displays the exception message in a snack bar while
/// hiding the loading message.
///
/// If [_loadingMessage] is not provided, it will default to 'loading'.
///
/// The [_successMessage], if provided and is a non-empty string,
/// will be shown when the operation completes successfully.
///
/// Example:
/// ```dart
/// ModalAsyncLoadingStatus(buttonControllerProvider)
/// ```
///
/// See also:
///
/// * [AsyncLoadingController] which is used as a provider
class ModalAsyncLoadingStatus extends HookConsumerWidget
    with AsyncLoadingStatusErrorLocalizer {
  const ModalAsyncLoadingStatus(
    this._provider, {
    super.key,
    String? loadingMessage,
    String? successMessage,
    LoadingMessageStyle successMessageStyle = LoadingMessageStyle.complete,
  }) : _successMessageStyle = successMessageStyle,
       _successMessage = successMessage,
       _loadingMessage = loadingMessage;

  final ProviderListenable<AsyncValue<void>> _provider;
  final String? _loadingMessage;
  final String? _successMessage;
  final LoadingMessageStyle _successMessageStyle;

  static const _logKey = 'MODAL';

  void _showProgressDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator.adaptive(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(_loadingMessage ?? context.l10n.loading),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccess(BuildContext context, String successMessage) {
    final theme = _successMessageStyle.theme(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          successMessage,
          style: context.textTheme.bodyMedium?.copyWith(color: theme.color),
        ),
        backgroundColor: theme.backgroundColor,
      ),
    );
  }

  void _showError(
    BuildContext context,
    Object exception,
    StackTrace stackTrace,
    AppLogger logger,
  ) {
    final errorMessage = getErrorMessage(context, exception);

    logger.error(errorMessage, name: _logKey, stackTrace: stackTrace);
    final errorTheme = LoadingMessageStyle.error.theme(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: context.textTheme.bodyMedium?.copyWith(
            color: errorTheme.color,
          ),
        ),
        backgroundColor: errorTheme.backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShowingProgressDialog = useRef(false);
    final logger = ref.read(appLoggerProvider);

    void showProgressDialogIfNeeded(BuildContext context) {
      if (isShowingProgressDialog.value) {
        return;
      }

      isShowingProgressDialog.value = true;
      _showProgressDialog(context);
    }

    void dismissProgressDialogIfNeeded() {
      if (!isShowingProgressDialog.value) {
        return;
      }

      isShowingProgressDialog.value = false;
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
    }

    ref.listen<AsyncValue<void>>(
      _provider,
      (_, state) => state.whenOrNull(
        error: (error, stackTrace) {
          dismissProgressDialogIfNeeded();
          _showError(context, error, stackTrace, logger);
        },
        loading: () {
          showProgressDialogIfNeeded(context);
        },
        data: (_) {
          dismissProgressDialogIfNeeded();
          if (_successMessage?.isEmpty ?? true) return;
          _showSuccess(context, _successMessage!);
        },
      ),
    );

    return const SizedBox();
  }
}
