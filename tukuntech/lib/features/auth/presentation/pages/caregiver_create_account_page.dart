import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_patients.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_address.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_delivery.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_payment.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_success.dart';

class CaregiverCreateAccountPage extends StatefulWidget {
  const CaregiverCreateAccountPage({super.key});

  @override
  State<CaregiverCreateAccountPage> createState() => _CaregiverCreateAccountPageState();
}

class _CaregiverCreateAccountPageState extends State<CaregiverCreateAccountPage> {
  int _currentStep = 0;
  final int _totalSteps = 7;
  final List<String> _stepNames = const [
    'Plan', 'Account', 'Personal', 'Address', 'Delivery', 'Payment', 'Done'
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context); // Go back to PlanSelectionPage
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);
    const backgroundColor = Color(0xFFF7F8F9);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create your Family Pro account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF112A24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monitor up to 5 patients under your care.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Steps Indicator with Arrows and Progress Bar
                  _buildStepper(primaryColor),
                  
                  const SizedBox(height: 16),
                  
                  // Step Content
                  if (_currentStep == 0) _buildPlanCard(primaryColor)
                  else if (_currentStep == 1) _buildAccountForm(primaryColor)
                  else if (_currentStep == 2) const StepPatients()
                  else if (_currentStep == 3) const StepAddress()
                  else if (_currentStep == 4) const StepDelivery()
                  else if (_currentStep == 5) StepPayment(onContinue: _nextStep)
                  else if (_currentStep == 6) StepSuccess(onGoToWebsite: () => Navigator.of(context).popUntil((route) => route.isFirst))
                  else Center(child: Text('Step ${_currentStep + 1} Content', style: const TextStyle(fontSize: 18))),
                  
                  const SizedBox(height: 16),
                  
                  // Bottom Actions
                  if (_currentStep == 6) const SizedBox.shrink()
                  else if (_currentStep == 0) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            SizedBox(width: 6),
                            Icon(Icons.check, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(foregroundColor: Colors.black54),
                        child: const Text('← Choose a different plan', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
                          label: const Text('Back', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        if (_currentStep != 5)
                          ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                SizedBox(width: 6),
                                Icon(Icons.check, size: 18),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(Color primaryColor) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.arrow_left, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_stepNames.length, (index) {
                    return _buildStep(index + 1, _stepNames[index], isActive: index == _currentStep, isCompleted: index < _currentStep, primaryColor: primaryColor);
                  }),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_right, color: Colors.black54),
          ],
        ),
        const SizedBox(height: 16),
        // Progress Bar
        LayoutBuilder(
          builder: (context, constraints) {
            double progress = (_currentStep + 1) / _totalSteps;
            return Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 6,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500, // Darker gray for progress
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep(int number, String title, {required bool isActive, required bool isCompleted, required Color primaryColor}) {
    Color circleColor;
    Color textColor;
    BoxBorder? border;

    if (isCompleted) {
      circleColor = primaryColor;
      textColor = Colors.white;
    } else if (isActive) {
      circleColor = Colors.white;
      textColor = primaryColor;
      border = Border.all(color: primaryColor, width: 1.5);
    } else {
      circleColor = Colors.grey.shade200;
      textColor = Colors.black54;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: border,
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: isCompleted || isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isCompleted || isActive ? Colors.black87 : Colors.black54,
              fontWeight: isCompleted || isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountForm(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          TextField(
            decoration: InputDecoration(
              hintText: 'you@example.com',
              hintStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.black54),
              suffixIcon: const Icon(Icons.visibility_outlined, color: Colors.black54),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Confirm password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.black54),
              suffixIcon: const Icon(Icons.visibility_outlined, color: Colors.black54),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Family Pro',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '\$200/mo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Up to 5 TukunTech devices · family dashboard · vitals tracking · Mobile app and web access',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
