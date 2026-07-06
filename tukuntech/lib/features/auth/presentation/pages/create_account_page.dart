import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/plan_selection_page.dart';
import 'package:tukuntech/features/auth/presentation/widgets/stepper_indicator.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_plan.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_account.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_personal.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_patients.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_address.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_delivery.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_payment.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_done.dart';

enum PlanType { personal, familyPro }

class CreateAccountPage extends StatefulWidget {
  final PlanType planType;

  const CreateAccountPage({super.key, this.planType = PlanType.personal});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  int _currentStep = 0;
  int get _totalSteps => 7;
  List<String> get _stepNames => const ['Plan', 'Account', 'Personal', 'Address', 'Delivery', 'Payment', 'Done'];

  final _dummyEmail = TextEditingController();
  final _dummyPassword = TextEditingController();
  final _dummyFullName = TextEditingController();
  final _dummyDni = TextEditingController();
  final _dummyAge = TextEditingController();
  final _dummyNotes = TextEditingController();
  final _dummyAddress = TextEditingController();
  final List<PatientData> _dummyPatients = List.generate(5, (_) => PatientData());
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _dummyEmail.dispose();
    _dummyPassword.dispose();
    _dummyFullName.dispose();
    _dummyDni.dispose();
    _dummyAge.dispose();
    _dummyNotes.dispose();
    _dummyAddress.dispose();
    for (var p in _dummyPatients) {
      p.dispose();
    }
    super.dispose();
  }

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
                      Image.asset(
                        'assets/icon_tukuntech.png',
                        width: 26,
                        height: 26,
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
                    steps: _stepNames,
                  ),
                  const SizedBox(height: 16),

                  // Step Content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStep(),
                  ),

                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
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
        return StepAccount(
          onContinue: _nextStep, 
          onBack: _previousStep,
          emailController: _dummyEmail,
          passwordController: _dummyPassword,
        );
      case 2:
        return widget.planType == PlanType.familyPro
            ? StepPatients(onContinue: _nextStep, onBack: _previousStep, patients: _dummyPatients)
            : StepPersonal(
                onContinue: _nextStep, 
                onBack: _previousStep,
                fullNameController: _dummyFullName,
                dniController: _dummyDni,
                ageController: _dummyAge,
                notesController: _dummyNotes,
                gender: 'Select gender',
                onGenderChanged: (v) {},
                bloodType: 'Select blood type',
                onBloodTypeChanged: (v) {},
                patientEmailController: _dummyPatients[0].emailCtrl,
                patientPasswordController: _dummyPatients[0].passwordCtrl,
                patientConfirmPasswordController: _dummyPatients[0].confirmPasswordCtrl,
                minHrController: _dummyPatients[0].minHrCtrl,
                maxHrController: _dummyPatients[0].maxHrCtrl,
                minO2Controller: _dummyPatients[0].minO2Ctrl,
                maxO2Controller: _dummyPatients[0].maxO2Ctrl,
                minTempController: _dummyPatients[0].minTempCtrl,
                maxTempController: _dummyPatients[0].maxTempCtrl,
              );
      case 3:
        return StepAddress(
          onContinue: _nextStep, 
          onBack: _previousStep,
          addressController: _dummyAddress,
        );
      case 4:
        return StepDelivery(onContinue: _nextStep, onBack: _previousStep);
      case 5:
        return StepPayment(
          planTitle: widget.planType == PlanType.personal ? 'Individual plan' : 'Family Pro plan',
          initialPayment: widget.planType == PlanType.personal ? '\$50' : '\$170',
          monthlyPayment: widget.planType == PlanType.personal ? '\$15/mo' : '\$25/mo',
          onContinue: _nextStep, 
          onBack: _previousStep,
          isRegistering: false,
          acceptedTerms: _acceptedTerms,
          onAcceptedTermsChanged: (val) => setState(() => _acceptedTerms = val),
        );
      case 6:
        return StepDone(planType: widget.planType);
      default:
        return const SizedBox.shrink();
    }
  }
}
