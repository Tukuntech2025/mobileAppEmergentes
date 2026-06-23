import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/create_account_page.dart';

class StepPayment extends StatelessWidget {
  final PlanType planType;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final bool isRegistering;

  const StepPayment({
    super.key,
    required this.planType,
    required this.onContinue,
    required this.onBack,
    required this.isRegistering,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This is a mock payment step. The real payment gateway will be\nconnected later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      planType == PlanType.personal ? 'Individual plan' : 'Family Pro plan',
                      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      planType == PlanType.personal ? '\$50/mo' : '\$200/mo',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isRegistering ? null : onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B9784),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isRegistering
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Simulate payment and continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
            label: const Text(
              'Back',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
