import 'package:flutter/material.dart';

@immutable
class RoundedInputDecoration extends ThemeExtension<RoundedInputDecoration> {
  RoundedInputDecoration(this.inputDecoration);

  final InputDecoration inputDecoration;

  @override
  ThemeExtension<RoundedInputDecoration> copyWith({
    InputDecoration? inputDecoration,
  }) {
    return RoundedInputDecoration(inputDecoration ?? this.inputDecoration);
  }

  @override
  ThemeExtension<RoundedInputDecoration> lerp(
    covariant ThemeExtension<RoundedInputDecoration>? other,
    double t,
  ) {
    return this;
  }
}
