import 'package:flutter/material.dart';

class StepIndicatorWidget extends StatelessWidget {
  final int currentStep;

  const StepIndicatorWidget({
    super.key,
    required this.currentStep,
  });

  static const List<String> labels = [
    'Chọn chỗ',
    'Chọn điểm đón',
    'Chọn điểm trả',
    'Nhập thông tin',
    'Thông tin chuyến đi',
    'Thanh toán',
    'Hoàn tất',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blue[600],
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildVisibleSteps(),
      ),
    );
  }

  List<Widget> _buildVisibleSteps() {
    final List<Widget> items = [];

    int start = currentStep - 1;
    int end = currentStep + 1;

    // FIX RANGE
    if (start < 1) {
      start = 1;
      end = 3;
    }

    if (end > labels.length) {
      end = labels.length;
      start = labels.length - 2;
    }

    if (start < 1) start = 1;

    for (int step = start; step <= end; step++) {
      final bool isActive = step == currentStep;
      final bool isCompleted = step < currentStep;

      items.add(
        Expanded(
          flex: isActive ? 2 : 1,
          child: _stepItem(
            step,
            labels[step - 1],
            isActive: isActive,
            isCompleted: isCompleted,
          ),
        ),
      );

      if (step != end) {
        items.add(_stepDivider());
      }
    }

    return items;
  }

  Widget _stepItem(
      int number,
      String label, {
        bool isActive = false,
        bool isCompleted = false,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 26 : 22,
          height: isActive ? 26 : 22,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : isCompleted
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(
                isCompleted ? 0.4 : 0.8,
              ),
              width: 1.4,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            )
                : Text(
              '$number',
              style: TextStyle(
                color: isActive
                    ? Colors.blue[700]
                    : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: isActive
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white70,
              fontSize: isActive ? 14 : 13,
              fontWeight:
              isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepDivider() {
    return Container(
      width: 20,
      height: 1.4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white30,
    );
  }
}