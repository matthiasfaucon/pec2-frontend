import 'package:firstflutterapp/components/form/build_input_decoration.dart';
import 'package:firstflutterapp/services/validators_service.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    required this.label,
    this.validators = const [],
    this.obscure = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final List<Validator> validators;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: buildInputDecoration(
        colorScheme: colorScheme,
        label: label,
      ),
      validator: (value) {
        for (final validator in validators) {
          final result = validator.validate(value ?? '');
          if (result != null) return result;
        }
        return null;
      },
    );
  }
}
