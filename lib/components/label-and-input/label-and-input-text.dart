import 'package:flutter/material.dart';

class LabelAndInput {

  Widget buildLabel(String text, {String? error}) {
    return Row(
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    bool obscureText,
    bool hasError,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? Colors.red : Color(0xFF6C3FFE),
          ),
        ),
      ),
    );
  }

  Widget buildLabelAndInputText(
    String labelName,
    TextEditingController controller,
    String placeholder, {
    bool obscureText = false, // valeur par défaut
    bool hasError = false, // valeur par défaut
    String messageError = '', // valeur par défaut
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(labelName, error: hasError ? messageError : null),
        SizedBox(height: 8),
        buildTextField(controller, placeholder, obscureText, hasError),
        SizedBox(height: 24),
      ],
    );
  }

  Widget buildLabelAndCalendar(
    String labelName,
    bool hasError,
    String messageError,
    context,
    setState,
    birthdayDate,
    Function(DateTime?) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(labelName, error: hasError ? messageError : null),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? date = await showDatePicker(
              context: context,
              initialDate: birthdayDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              birthdayDate == null
                  ? "Sélectionner une date"
                  : "${birthdayDate.day}/${birthdayDate.month}/${birthdayDate.year}",
            ),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget buildLabelAndRadioList(
    String labelName,
    bool hasError,
    String messageError,
    list,
    selectedOption,
      Function(String?) onSexeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(labelName, error: hasError ? messageError : null),
        SizedBox(height: 8),
        Column(
          children:
              ["Homme", "Femme", "Autre"].map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: selectedOption,
                  onChanged: onSexeSelected,
                );
              }).toList(),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}
