import 'package:flutter/material.dart';

@immutable
class ChatInputDecoration extends ThemeExtension<ChatInputDecoration> {
  ChatInputDecoration(this.inputDecoration);

  final InputDecoration inputDecoration;

  @override
  ThemeExtension<ChatInputDecoration> copyWith({
    InputDecoration? inputDecoration,
  }) {
    return ChatInputDecoration(inputDecoration ?? this.inputDecoration);
  }

  @override
  ThemeExtension<ChatInputDecoration> lerp(
    covariant ThemeExtension<ChatInputDecoration>? other,
    double t,
  ) {
    return this;
  }
}
