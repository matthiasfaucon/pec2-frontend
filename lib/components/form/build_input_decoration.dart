import 'package:flutter/material.dart';

InputDecoration buildInputDecoration({
  required ColorScheme colorScheme,
  required String label,
}) {
  final defaultBorder = OutlineInputBorder(
    borderSide: BorderSide(
      color: colorScheme.outlineVariant,
    ),
    borderRadius: BorderRadius.circular(16),
  );

  return InputDecoration(
    label: Text(label),
    border: defaultBorder,
    enabledBorder: defaultBorder,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
  );
}