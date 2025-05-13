import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    required this.label,
    required this.onPressed,
    this.isSubmitted = false,
    super.key,
  });

  final String label;
  final bool isSubmitted;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (isSubmitted) {
      return FilledButton.icon(
        onPressed: null,
        icon: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            color: colorScheme.outline,
          ),
        ),
        label: Text('Loading...'),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}