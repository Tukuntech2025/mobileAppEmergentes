import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_patients.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_address.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_delivery.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_payment.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_success.dart';
import 'package:tukuntech/features/auth/presentation/pages/plan_selection_page.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_account.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';


class CaregiverCreateAccountPage extends StatefulWidget {
  final String planTitle;
  final String planSubtitle;
  final String initialPayment;
  final String monthlyPayment;
  final bool isRecommended;

  const CaregiverCreateAccountPage({
    super.key,
    this.planTitle = 'Family plan 2',
    this.planSubtitle = '2 patients + 1 caregiver · vital signs monitoring · web and mobile access',
    this.initialPayment = '\$95',
    this.monthlyPayment = '\$28/mo',
    this.isRecommended = false,
  });

  @override
  State<CaregiverCreateAccountPage> createState() => _CaregiverCreateAccountPageState();
}

class _CaregiverCreateAccountPageState extends State<CaregiverCreateAccountPage> {
  int _currentStep = 0;
  final int _totalSteps = 7;
  List<String> get _stepNames => [
    'step_plan', 'step_account', 'step_personal', 'step_address', 'step_delivery', 'step_payment_title', 'step_done'
  ];

  final _dummyEmail = TextEditingController();
  final _dummyPassword = TextEditingController();
  final _dummyAddress = TextEditingController();
  late final List<PatientData> _patients;
  bool _isRegistering = false;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    final match = RegExp(r'\d+').firstMatch(widget.planTitle);
    final count = match != null ? int.parse(match.group(0)!) : 5;
    _patients = List.generate(count, (_) => PatientData());
  }

  final String _baseUrl = EnvironmentConfig.baseUrl;

  @override
  void dispose() {
    _dummyEmail.dispose();
    _dummyPassword.dispose();
    _dummyAddress.dispose();
    for (var p in _patients) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _processRegistration() async {
    setState(() { _isRegistering = true; });

    try {
      final activePatients = _patients.where((p) => p.fullNameCtrl.text.trim().isNotEmpty).toList();
      if (activePatients.isEmpty) {
        throw Exception('Please fill in details for at least one patient.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/profiles/onboarding'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'caregiverEmail': _dummyEmail.text.trim(),
          'caregiverPassword': _dummyPassword.text,
          'plan': 'FAMILY',
          'patients': activePatients.map((patient) {
            String apiGender = 'OTHER';
            if (patient.gender == 'Male') apiGender = 'MALE';
            if (patient.gender == 'Female') apiGender = 'FEMALE';

            String apiBloodType = 'UNKNOWN';
            final bloodMap = {
              'A+': 'A_POSITIVE', 'A-': 'A_NEGATIVE',
              'B+': 'B_POSITIVE', 'B-': 'B_NEGATIVE',
              'AB+': 'AB_POSITIVE', 'AB-': 'AB_NEGATIVE',
              'O+': 'O_POSITIVE', 'O-': 'O_NEGATIVE',
            };
            if (patient.bloodType != null && bloodMap.containsKey(patient.bloodType)) {
              apiBloodType = bloodMap[patient.bloodType]!;
            }

            return {
              'email': patient.emailCtrl.text.trim().isEmpty 
                  ? 'patient_${DateTime.now().millisecondsSinceEpoch}_${activePatients.indexOf(patient)}@tukuntech.app' 
                  : patient.emailCtrl.text.trim(),
              'password': patient.passwordCtrl.text.trim().isEmpty ? '123456' : patient.passwordCtrl.text,
              'dni': patient.dniCtrl.text.trim(),
              'fullName': patient.fullNameCtrl.text.trim(),
              'age': int.tryParse(patient.ageCtrl.text.trim()) ?? 0,
              'address': _dummyAddress.text.trim(),
              'bloodType': apiBloodType,
              'gender': apiGender,
              'notes': patient.notesCtrl.text.trim(),
              'minHeartRate': int.tryParse(patient.minHrCtrl.text.trim()) ?? 0,
              'maxHeartRate': int.tryParse(patient.maxHrCtrl.text.trim()) ?? 0,
              'minOxygenSaturation': int.tryParse(patient.minO2Ctrl.text.trim()) ?? 0,
              'maxOxygenSaturation': int.tryParse(patient.maxO2Ctrl.text.trim()) ?? 0,
              'minTemperature': double.tryParse(patient.minTempCtrl.text.trim()) ?? 0.0,
              'maxTemperature': double.tryParse(patient.maxTempCtrl.text.trim()) ?? 0.0,
              'termsAccepted': _acceptedTerms,
              'emergencyContacts': [
                {
                  'name': 'Emergency Contact',
                  'relationship': 'FAMILY',
                  'phoneNumber': '123456789'
                }
              ]
            };
          }).toList(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create account: ${response.body}');
      }

      String stripeUrl = response.body.trim();
      if (!stripeUrl.startsWith('http://') && !stripeUrl.startsWith('https://')) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          stripeUrl = responseData['url'] ?? responseData['stripeUrl'] ?? responseData['paymentUrl'] ?? response.body.trim();
        } catch (e) {
          stripeUrl = response.body.trim();
        }
      }

      if (stripeUrl.isNotEmpty) {
        final Uri url = Uri.parse(stripeUrl);
        launchUrl(url).catchError((e) {
          print('Error launching default: $e');
          return launchUrl(url, mode: LaunchMode.externalApplication);
        }).catchError((e) {
          print('Error launching Stripe URL: $e');
          return false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Redirecting to Stripe payment...'),
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Open manually',
                onPressed: () {
                  launchUrl(url).catchError((_) => false);
                },
              ),
            ),
          );
        }
      }

      if (!mounted) return;
      setState(() { _currentStep++; });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() { _isRegistering = false; });
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 5) {
      _processRegistration();
    } else if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlanSelectionPage()),
      ); // Go back to PlanSelectionPage
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
                  Row(
                    children: [
                      Image.asset(
                        'assets/icon_tukuntech.png',
                        width: 24,
                        height: 24,
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
                  const SizedBox(height: 24),
                  Text(
                    context.translate('create_tukuntech_account'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF112A24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.translate('register_caregiver_first'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Steps Indicator with Arrows and Progress Bar
                  _buildStepper(primaryColor),
                  
                  const SizedBox(height: 16),
                  
                  // Step Content
                  if (_currentStep == 0) _buildPlanCard(primaryColor)
                  else if (_currentStep == 1) StepAccount(
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    emailController: _dummyEmail,
                    passwordController: _dummyPassword,
                  )
                  else if (_currentStep == 2) StepPatients(onContinue: _nextStep, onBack: _previousStep, patients: _patients)
                  else if (_currentStep == 3) StepAddress(
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    addressController: _dummyAddress,
                  )
                  else if (_currentStep == 4) StepDelivery(onContinue: _nextStep, onBack: _previousStep)
                  else if (_currentStep == 5) StepPayment(
                    planTitle: widget.planTitle,
                    initialPayment: widget.initialPayment,
                    monthlyPayment: widget.monthlyPayment,
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    isRegistering: _isRegistering,
                    acceptedTerms: _acceptedTerms,
                    onAcceptedTermsChanged: (val) => setState(() => _acceptedTerms = val),
                  )
                  else if (_currentStep == 6) StepSuccess(onGoToWebsite: () => Navigator.of(context).popUntil((route) => route.isFirst))
                  else Center(child: Text('Step ${_currentStep + 1} Content', style: const TextStyle(fontSize: 18))),
                  
                  const SizedBox(height: 16),
                  
                  // Bottom Actions
                  if (_currentStep == 0) ...[
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.translate('continue_btn'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            const Icon(Icons.check, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const PlanSelectionPage()),
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.black54),
                        child: Text(context.translate('choose_different_plan'), style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13)),
                      ),
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
                    return _buildStep(index + 1, context.translate(_stepNames[index]), isActive: index == _currentStep, isCompleted: index < _currentStep, primaryColor: primaryColor);
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

  Widget _buildPlanCard(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.planTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF112A24),
                        ),
                      ),
                    ),
                    if (widget.isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          context.translate('recommended'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.planSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${context.translate('initial_payment_label')} ${widget.initialPayment}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${context.translate('monthly_label')} ${widget.monthlyPayment}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
