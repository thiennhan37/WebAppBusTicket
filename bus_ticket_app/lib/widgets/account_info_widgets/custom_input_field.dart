import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
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
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController(text: widget.initValue);
  }

  // Nếu dữ liệu load bất đồng bộ (sau khung hình đầu), cần thêm hàm này
  @override
  void didUpdateWidget(covariant CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initValue != oldWidget.initValue &&
        _controller.text != widget.initValue) {
      _controller.text = widget.initValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      // initialValue: widget.initValue,
      keyboardType: widget.keyboardInputType,
      onChanged: widget.onChanged,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: const TextStyle(color: Colors.grey),
              ),
              if (widget.isRequired)
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
        hintText: widget.hintText,
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
