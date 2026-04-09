import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? initValue;
  final String? hintText;
  final Widget? suffixIcon;
  final TextInputType? keyboardInputType;
  final Function(String)? onChanged;

  const CustomInputField({
    super.key,
    required this.label,
    required this.isRequired,
    this.initValue,
    this.hintText,
    this.suffixIcon,
    this.keyboardInputType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initValue,
      keyboardType: keyboardInputType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(color: Colors.grey),
              ),
              if (isRequired)
                const TextSpan(
                  text: '*',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        // Đẩy nhãn lên trên khi nhập
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.normal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
      ),
    );
  }
}
