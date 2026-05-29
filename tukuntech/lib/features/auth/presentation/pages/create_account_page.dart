import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/plan_selection_page.dart';
import 'package:tukuntech/features/auth/presentation/widgets/stepper_indicator.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_plan.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_account.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_personal.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_patients.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_address.dart';

enum PlanType { personal, familyPro }

class CreateAccountPage extends StatefulWidget {
  final PlanType planType;

  const CreateAccountPage({super.key, this.planType = PlanType.personal});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and App Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monitor_heart_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'TukunTech',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Headings
                  Text(
                    widget.planType == PlanType.personal
                        ? 'Create your patient account'
                        : 'Create your Family Pro account',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.planType == PlanType.personal
                        ? 'Subscribe to activate your TukunTech.'
                        : 'Monitor up to 5 patients under your care.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Stepper Indicator
                  StepperIndicator(
                    currentStep: _currentStep,
                    onBack: _previousStep,
                    stepThreeTitle: widget.planType == PlanType.personal ? 'Personal' : 'Patients',
                  ),
                  const SizedBox(height: 4),

                  // Step Content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStep(),
                  ),

                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PlanSelectionPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '← Choose a different plan',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return StepPlan(
          planType: widget.planType,
          onContinue: _nextStep,
        );
      case 1:
        return StepAccount(onContinue: _nextStep, onBack: _previousStep);
      case 2:
        return widget.planType == PlanType.familyPro
            ? StepPatients(onContinue: _nextStep, onBack: _previousStep)
            : StepPersonal(onContinue: _nextStep, onBack: _previousStep);
      case 3:
        return StepAddress(onContinue: () {}, onBack: _previousStep);
      default:
        return const SizedBox.shrink();
    }
  }
}
