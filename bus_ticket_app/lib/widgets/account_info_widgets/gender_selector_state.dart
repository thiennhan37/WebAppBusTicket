import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final Function(String) onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildGenderOption(context, 'Nam', 'MALE'),
        const SizedBox(width: 12),
        _buildGenderOption(context, 'Nữ', 'FEMALE'),
        const SizedBox(width: 12),
        _buildGenderOption(context, 'Khác', 'OTHER'),
      ],
    );
  }

  Widget _buildGenderOption(BuildContext context, String title, String value) {
    bool isSelected = selectedGender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1E88E5)
                  : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
