import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'r_card_details_screen.dart';

part 'returning_card_provider.g.dart';

/// Provider used to trigger the "return" animation when navigating back
/// from [RCardDetailsScreen].
@riverpod
class ReturningCard extends _$ReturningCard {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}
