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
  List<String> get _stepNames => const [
    'Plan', 'Account', 'Personal', 'Address', 'Delivery', 'Payment', 'Done'
  ];

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _gender = 'Select gender';
  String _bloodType = 'Select blood type';

  bool _isRegistering = false;

  final String _baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8080/api/v1' 
      : 'http://localhost:8080/api/v1';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processRegistration() async {
    setState(() { _isRegistering = true; });

    try {
      // 1. Register Auth
      final registerRes = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'role': 'PATIENT'
        }),
      ).timeout(const Duration(seconds: 10));

      if (registerRes.statusCode != 200 && registerRes.statusCode != 201) {
        throw Exception('Failed to register auth: ${registerRes.body}');
      }

      final loginRes = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      String? token;
      if (loginRes.statusCode == 200 || loginRes.statusCode == 201) {
        final loginData = jsonDecode(loginRes.body);
        token = loginData['token'] ?? loginData['accessToken']; 
      }

      final Map<String, String> headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      String apiGender = 'OTHER';
      if (_gender == 'Male') apiGender = 'MALE';
      if (_gender == 'Female') apiGender = 'FEMALE';

      String apiBloodType = 'A_POSITIVE';
      final bloodMap = {
        'A+': 'A_POSITIVE', 'A-': 'A_NEGATIVE',
        'B+': 'B_POSITIVE', 'B-': 'B_NEGATIVE',
        'AB+': 'AB_POSITIVE', 'AB-': 'AB_NEGATIVE',
        'O+': 'O_POSITIVE', 'O-': 'O_NEGATIVE',
      };
      if (bloodMap.containsKey(_bloodType)) {
        apiBloodType = bloodMap[_bloodType]!;
      }

      int birthYear = DateTime.now().year - (int.tryParse(_ageController.text) ?? 30);
      String birthDate = '$birthYear-01-01';

      // 2. Create Profile
      final profileRes = await http.post(
        Uri.parse('$_baseUrl/profiles/me'),
        headers: headers,
        body: jsonEncode({
          'fullName': _fullNameController.text,
          'birthDate': birthDate,
          'address': _addressController.text,
          'bloodType': apiBloodType,
          'gender': apiGender,
          'notes': _notesController.text,
          'emergencyContacts': [
             {
               "name": "Emergency Contact",
               "relationship": "FAMILY",
               "phoneNumber": "123456789"
             }
          ]
        }),
      ).timeout(const Duration(seconds: 10));

      if (profileRes.statusCode != 200 && profileRes.statusCode != 201) {
         throw Exception('Failed to create profile: ${profileRes.body}');
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
                  const Text(
                    'Create your TukunTech account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF112A24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register the caregiver first, then the patients included in your plan.',
                    style: TextStyle(
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
                    ageController: _ageController,
                    notesController: _notesController,
                    gender: _gender,
                    onGenderChanged: (val) => setState(() => _gender = val ?? _gender),
                    bloodType: _bloodType,
                    onBloodTypeChanged: (val) => setState(() => _bloodType = val ?? _bloodType),
                  )
                  else if (_currentStep == 3) StepAddress(
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    addressController: _addressController,
                  )
                  else if (_currentStep == 4) StepDelivery(onContinue: _nextStep, onBack: _previousStep)
                  else if (_currentStep == 5) StepPayment(
                    planType: PlanType.personal, 
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    isRegistering: _isRegistering,
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.check, size: 18),
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
                        child: const Text(
                          '← Choose a different plan',
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
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
                _stepNames[index],
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
                    Text(
                      widget.planTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF112A24),
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
                        child: const Text(
                          'RECOMMENDED',
                          style: TextStyle(
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
                'Initial payment: ${widget.initialPayment}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Monthly: ${widget.monthlyPayment}',
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
