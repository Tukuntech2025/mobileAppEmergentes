import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/plan_selection_page.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_account.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_personal.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_address.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_delivery.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_payment.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_done.dart';
import 'package:tukuntech/features/auth/presentation/pages/create_account_page.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:tukuntech/core/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';


class PatientCreateAccountPage extends StatefulWidget {
  final String planTitle;
  final String planSubtitle;
  final String initialPayment;
  final String monthlyPayment;
  final bool isRecommended;

  const PatientCreateAccountPage({
    super.key,
    this.planTitle = 'Individual plan',
    this.planSubtitle = '1 patient + 1 caregiver · vital signs monitoring · web and mobile access',
    this.initialPayment = '\$50',
    this.monthlyPayment = '\$15/mo',
    this.isRecommended = false,
  });

  @override
  State<PatientCreateAccountPage> createState() => _PatientCreateAccountPageState();
}

class _PatientCreateAccountPageState extends State<PatientCreateAccountPage> {
  int _currentStep = 0;
  int get _totalSteps => 7;
  List<String> get _stepNames => [
    'step_plan', 'step_account', 'step_personal', 'step_address', 'step_delivery', 'step_payment_title', 'step_done'
  ];

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();

  // Patient sub-account & parameters controllers
  final _patientEmailController = TextEditingController();
  final _patientPasswordController = TextEditingController();
  final _patientConfirmPasswordController = TextEditingController();
  final _minHrController = TextEditingController();
  final _maxHrController = TextEditingController();
  final _minO2Controller = TextEditingController();
  final _maxO2Controller = TextEditingController();
  final _minTempController = TextEditingController();
  final _maxTempController = TextEditingController();
  
  String _gender = 'Select gender';
  String _bloodType = 'Select blood type';

  bool _isRegistering = false;
  bool _acceptedTerms = false;

  final String _baseUrl = EnvironmentConfig.baseUrl;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _dniController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    _patientEmailController.dispose();
    _patientPasswordController.dispose();
    _patientConfirmPasswordController.dispose();
    _minHrController.dispose();
    _maxHrController.dispose();
    _minO2Controller.dispose();
    _maxO2Controller.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    super.dispose();
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error de Validación'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateForm() {
    if (_emailController.text.trim().isEmpty) return "El correo del cuidador no puede ser nulo o vacío.";
    if (_emailController.text.trim().length > 255) return "El correo del cuidador excede los 255 caracteres.";
    
    if (_passwordController.text.isEmpty) return "La contraseña del cuidador no puede ser nula o vacía.";
    
    if (_patientEmailController.text.trim().isEmpty) return "El correo del paciente no puede ser nulo o vacío.";
    if (_patientEmailController.text.trim().length > 255) return "El correo del paciente excede los 255 caracteres.";
    
    if (_patientPasswordController.text.isEmpty) return "La contraseña del paciente no puede ser nula o vacía.";
    if (_patientPasswordController.text != _patientConfirmPasswordController.text) return "Las contraseñas del paciente no coinciden.";

    if (_fullNameController.text.trim().length > 255) return "El nombre completo excede los 255 caracteres.";
    if (_dniController.text.trim().length > 255) return "El DNI excede los 255 caracteres.";
    if (_addressController.text.trim().length > 255) return "La dirección excede los 255 caracteres.";

    if (_ageController.text.trim().isNotEmpty && int.tryParse(_ageController.text.trim()) == null) {
      return "La edad debe ser un número entero válido.";
    }

    if (_minHrController.text.trim().isNotEmpty) {
      int? minHr = int.tryParse(_minHrController.text.trim());
      if (minHr == null || minHr < 30 || minHr > 200) return "La frecuencia cardíaca mínima debe estar entre 30 y 200 bpm.";
    }
    if (_maxHrController.text.trim().isNotEmpty) {
      int? maxHr = int.tryParse(_maxHrController.text.trim());
      if (maxHr == null || maxHr < 40 || maxHr > 250) return "La frecuencia cardíaca máxima debe estar entre 40 y 250 bpm.";
    }
    if (_minO2Controller.text.trim().isNotEmpty) {
      int? minO2 = int.tryParse(_minO2Controller.text.trim());
      if (minO2 == null || minO2 < 50 || minO2 > 100) return "La saturación de oxígeno mínima debe estar entre 50% y 100%.";
    }
    if (_maxO2Controller.text.trim().isNotEmpty) {
      int? maxO2 = int.tryParse(_maxO2Controller.text.trim());
      if (maxO2 != null && maxO2 > 100) return "La saturación de oxígeno máxima no puede superar el 100%.";
    }
    if (_minTempController.text.trim().isNotEmpty) {
      double? minTemp = double.tryParse(_minTempController.text.trim());
      if (minTemp == null || minTemp < 30 || minTemp > 42) return "La temperatura mínima debe estar entre 30°C y 42°C.";
    }
    if (_maxTempController.text.trim().isNotEmpty) {
      double? maxTemp = double.tryParse(_maxTempController.text.trim());
      if (maxTemp == null || maxTemp < 32 || maxTemp > 45) return "La temperatura máxima debe estar entre 32°C y 45°C.";
    }

    if (!_acceptedTerms) return "Debes aceptar los límites y términos de uso.";

    return null;
  }

  Future<void> _processRegistration() async {
    final String? validationError = _validateForm();
    if (validationError != null) {
      _showErrorDialog(validationError);
      return;
    }

    setState(() { _isRegistering = true; });

    try {
      String apiGender = _gender == 'Select gender' ? 'OTHER' : _gender;
      String apiBloodType = _bloodType == 'Select blood type' ? 'UNKNOWN' : _bloodType;

      final response = await ApiClient.post(
        Uri.parse('$_baseUrl/profiles/onboarding'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'caregiverEmail': _emailController.text.trim(),
          'caregiverPassword': _passwordController.text,
          'plan': 'INDIVIDUAL',
          'patients': [
            {
              'email': _patientEmailController.text.trim(),
              'password': _patientPasswordController.text,
              'dni': _dniController.text.trim(),
              'fullName': _fullNameController.text.trim(),
              'age': int.tryParse(_ageController.text.trim()) ?? 0,
              'address': _addressController.text.trim(),
              'bloodType': apiBloodType,
              'gender': apiGender,
              'notes': _notesController.text.trim(),
              'minHeartRate': int.tryParse(_minHrController.text.trim()) ?? 0,
              'maxHeartRate': int.tryParse(_maxHrController.text.trim()) ?? 0,
              'minOxygenSaturation': int.tryParse(_minO2Controller.text.trim()) ?? 0,
              'maxOxygenSaturation': int.tryParse(_maxO2Controller.text.trim()) ?? 0,
              'minTemperature': double.tryParse(_minTempController.text.trim()) ?? 0.0,
              'maxTemperature': double.tryParse(_maxTempController.text.trim()) ?? 0.0,
              'termsAccepted': _acceptedTerms,
              'emergencyContacts': [
                {
                  'name': 'Emergency Contact',
                  'relationship': 'FAMILY',
                  'phoneNumber': '123456789'
                }
              ]
            }
          ]
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
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
                  
                  // Steps Indicator
                  _buildStepper(primaryColor),
                  
                  const SizedBox(height: 24),
                  
                  if (_currentStep == 0) ...[
                    _buildPlanCard(primaryColor),
                  ] 
                  else if (_currentStep == 1) StepAccount(
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  )
                  else if (_currentStep == 2) StepPersonal(
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    fullNameController: _fullNameController,
                    dniController: _dniController,
                    ageController: _ageController,
                    notesController: _notesController,
                    gender: _gender,
                    onGenderChanged: (val) => setState(() => _gender = val ?? _gender),
                    bloodType: _bloodType,
                    onBloodTypeChanged: (val) => setState(() => _bloodType = val ?? _bloodType),
                    patientEmailController: _patientEmailController,
                    patientPasswordController: _patientPasswordController,
                    patientConfirmPasswordController: _patientConfirmPasswordController,
                    minHrController: _minHrController,
                    maxHrController: _maxHrController,
                    minO2Controller: _minO2Controller,
                    maxO2Controller: _maxO2Controller,
                    minTempController: _minTempController,
                    maxTempController: _maxTempController,
                  )
                  else if (_currentStep == 3) StepAddress(
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    addressController: _addressController,
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
                  else if (_currentStep == 6) StepDone(planType: PlanType.personal, onFinish: () => Navigator.of(context).popUntil((route) => route.isFirst)),
                  
                  const SizedBox(height: 24),
                  
                  if (_currentStep == 0) ...[
                    // Continue Button
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
                            Text(
                              context.translate('continue_btn'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.check, size: 18),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Choose a different plan link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const PlanSelectionPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
                        ),
                        child: Text(
                          context.translate('choose_different_plan'),
                          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                        ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_stepNames.length, (index) {
          bool isActive = index == _currentStep;
          bool isCompleted = index < _currentStep;
          
          return Row(
            children: [
              _buildStepCircle(index + 1, isActive, isCompleted, primaryColor),
              const SizedBox(width: 8),
              Text(
                context.translate(_stepNames[index]),
                style: TextStyle(
                  color: isCompleted || isActive ? Colors.black87 : Colors.black54,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              if (index < _stepNames.length - 1)
                Container(
                  width: 24,
                  height: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.only(right: 8),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepCircle(int number, bool isActive, bool isCompleted, Color primaryColor) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isActive ? primaryColor.withOpacity(0.1) : Colors.grey.shade200,
        border: isActive ? Border.all(color: primaryColor, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(
          color: isCompleted || isActive ? primaryColor : Colors.black54,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
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

