import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  const GenderSelector({Key? key}) : super(key: key);

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String _selectedGender = 'Nam'; // Mặc định chọn Nam

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildGenderOption('Nam'),
        const SizedBox(width: 12),
        _buildGenderOption('Nữ'),
        const SizedBox(width: 12),
        _buildGenderOption('Khác'),
      ],
    );
  }

  Widget _buildGenderOption(String title) {
    bool isSelected = _selectedGender == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
            borderRadius: BorderRadius.circular(30), // Bo tròn như viên thuốc
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
