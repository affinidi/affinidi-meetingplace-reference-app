import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'async_loading_controller.dart';
import 'async_loading_status_error_localizer.dart';

/// Use this widget to observe asynchronous executions and display
/// a loading message.
/// In case of exceptions, displays the exception message in a snack bar while
/// hiding the loading message.
///
/// Example:
/// ```dart
/// InlineAsyncLoadingStatus(buttonControllerProvider)
/// ```
///
/// See also:
///
/// * [AsyncLoadingController] which is used as a provider
class InlineAsyncLoadingStatus extends HookConsumerWidget
    with AsyncLoadingStatusErrorLocalizer {
  const InlineAsyncLoadingStatus(
    this._provider, {
    super.key,
    bool initialLoading = false,
    required Widget child,
    void Function()? retry,
    String? loadingMessage,
  }) : _retry = retry,
       _child = child,
       _initialLoading = initialLoading,
       _loadingMessage = loadingMessage;

  final ProviderListenable<AsyncValue<void>> _provider;
  final String? _loadingMessage;
  final bool _initialLoading;
  final Widget _child;
  final void Function()? _retry;
  static const _logKey = 'INLINE';

  bool get _hasLoadingMessage => _loadingMessage?.isNotEmpty == true;

  /// Builds the widget tree, displaying a loading indicator, error message
  /// with retry option, or the provided child widget based on the asynchronous
  /// operation's status.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShowingProgress = useState(_initialLoading);
    final logger = ref.read(appLoggerProvider);
    final errorText = useState<String?>(null);
    final shouldShowRetryButton = useState<bool>(false);
    final l10n = context.l10n;

    void resetState() {
      errorText.value = null;
      shouldShowRetryButton.value = false;
    }

    void showProgressWidgetIfNeeded(BuildContext context) {
      if (isShowingProgress.value) {
        return;
      }

      isShowingProgress.value = true;
    }

    void dismissProgressWidgetIfNeeded() {
      if (!isShowingProgress.value) {
        return;
      }

      isShowingProgress.value = false;
    }

    void showErrorWidgetIfNeeded(Object exception, StackTrace stackTrace) {
      final localizedErrorMessage = getErrorMessage(context, exception);

      logger.error(
        localizedErrorMessage,
        stackTrace: stackTrace,
        name: _logKey,
      );

      if (errorText.value == localizedErrorMessage) {
        return;
      }

      shouldShowRetryButton.value = (_retry != null);
      errorText.value = localizedErrorMessage;
    }

    ref.listen<AsyncValue<void>>(
      _provider,
      (_, state) => state.whenOrNull(
        error: (error, stackTrace) {
          dismissProgressWidgetIfNeeded();
          showErrorWidgetIfNeeded(error, stackTrace);
        },
        loading: () {
          showProgressWidgetIfNeeded(context);
        },
        data: (_) {
          resetState();
          dismissProgressWidgetIfNeeded();
        },
      ),
    );

    return isShowingProgress.value
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  const CircularProgressIndicator.adaptive(),
                  if (_hasLoadingMessage) Text(_loadingMessage!),
                ],
              ),
            ),
          )
        : errorText.value != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                spacing: 24,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorText.value ?? l10n.error('other'),
                    textAlign: TextAlign.center,
                  ),
                  if (shouldShowRetryButton.value)
                    _RetryButton(onPressed: _retry!, text: l10n.generalRetry),
                ],
              ),
            ),
          )
        : _child;
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed, required this.text});

  final void Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: onPressed, child: Text(text));
  }
}
