import 'package:flutter/material.dart';

class StepperIndicator extends StatelessWidget {
  final int currentStep;
  final VoidCallback? onBack;
  final String stepThreeTitle;

  const StepperIndicator({
    super.key,
    required this.currentStep,
    this.onBack,
    this.stepThreeTitle = 'Personal',
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);
    const inactiveColor = Color(0xFFE9ECEF);
    const textColor = Colors.black87;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStep(0, 'Plan', primaryColor, inactiveColor),
            _buildDivider(0, primaryColor, inactiveColor),
            _buildStep(1, 'Account', primaryColor, inactiveColor),
            _buildDivider(1, primaryColor, inactiveColor),
            _buildStep(2, stepThreeTitle, primaryColor, inactiveColor),
            _buildDivider(2, primaryColor, inactiveColor),
            _buildStep(3, 'Address', primaryColor, inactiveColor),
          ],
        ),
      ],
    );
  }

  Widget _buildStep(int stepIndex, String title, Color primaryColor, Color inactiveColor) {
    final isCompleted = currentStep > stepIndex;
    final isActive = currentStep == stepIndex;

    return Flexible(
      child: Row(
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
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive || isCompleted ? Colors.black87 : Colors.black54,
                fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(int stepIndex, Color primaryColor, Color inactiveColor) {
    final isCompleted = currentStep > stepIndex;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 2,
        color: isCompleted ? primaryColor : inactiveColor,
      ),
    );
  }
}
