import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/create_account_page.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

class StepDone extends StatelessWidget {
  final PlanType planType;
  final VoidCallback? onFinish;

  const StepDone({
    super.key,
    required this.planType,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: primaryColor, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            planType == PlanType.personal ? context.translate('account_created') : context.translate('family_account_created'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            planType == PlanType.personal
                ? context.translate('patient_account_success')
                : context.translate('family_account_success'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: onFinish ?? () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B9784),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(context.translate('go_to_website'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
