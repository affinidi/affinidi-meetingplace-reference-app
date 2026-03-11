import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/configuration/environment.dart';

class ExpiryDatePickerMenu {
  static Future<DateTime?> show({
    required BuildContext context,
    required WidgetRef ref,
    required DateTime initialDate,
    required DateTime minDate,
    required DateTime maxDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
    );
    if (date == null) return null;

    final environment = ref.read(environmentProvider);
    final initialTime = TimeOfDay.fromDateTime(
      initialDate.add(environment.initialTimeOffset),
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
