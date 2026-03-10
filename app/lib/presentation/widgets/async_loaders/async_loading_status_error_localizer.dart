import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';

mixin AsyncLoadingStatusErrorLocalizer {
  String _extractErrorCode(
    BuildContext context,
    MeetingPlaceCoreSDKException exception,
  ) {
    final innerException = exception.innerException;
    return switch (innerException) {
      MissingDeviceException _ => 'missingDeviceToken',
      _ => exception.code,
    };
  }

  /// Returns a localized error message for the given [exception].
  ///
  /// [context] is used to access localization resources.
  /// [exception] can be an [AppException], [MeetingPlaceCoreSDKException],
  /// or any other error object.
  String getErrorMessage(BuildContext context, Object exception) {
    final errorCode = switch (exception) {
      AppException appException => appException.code,
      MeetingPlaceCoreSDKException mpxSdkException => _extractErrorCode(
        context,
        mpxSdkException,
      ),
      _ => exception.toString(),
    };

    return context.l10n.error(errorCode);
  }
}
