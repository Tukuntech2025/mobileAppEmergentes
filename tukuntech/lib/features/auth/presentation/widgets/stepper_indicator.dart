import 'package:flutter/material.dart';

class StepperIndicator extends StatelessWidget {
  final int currentStep;
  final VoidCallback? onBack;
  final List<String> steps;

  const StepperIndicator({
    super.key,
    required this.currentStep,
    this.onBack,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);
    const inactiveColor = Color(0xFFE9ECEF);
    const textColor = Colors.black87;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            int stepIndex = index ~/ 2;
            return _buildStep(stepIndex, steps[stepIndex], primaryColor, inactiveColor);
          } else {
            int stepIndex = index ~/ 2;
            return _buildDivider(stepIndex, primaryColor, inactiveColor);
          }
        }),
      ),
    );
  }

  Widget _buildStep(int stepIndex, String title, Color primaryColor, Color inactiveColor) {
    final isCompleted = currentStep > stepIndex;
    final isActive = currentStep == stepIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? primaryColor : (isActive ? primaryColor.withOpacity(0.1) : inactiveColor),
            border: Border.all(
              color: isActive ? primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    color: isActive ? primaryColor : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: isActive || isCompleted ? Colors.black87 : Colors.black54,
            fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(int stepIndex, Color primaryColor, Color inactiveColor) {
    final isCompleted = currentStep > stepIndex;
    return Container(
      width: 16,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 2,
      color: isCompleted ? primaryColor : inactiveColor,
    );
  }
}
