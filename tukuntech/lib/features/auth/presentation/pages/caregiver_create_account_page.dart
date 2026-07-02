import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_patients.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_address.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_delivery.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_payment.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_success.dart';
import 'package:tukuntech/features/auth/presentation/pages/plan_selection_page.dart';
import 'package:tukuntech/features/auth/presentation/pages/create_account_page.dart';
import 'package:tukuntech/features/auth/presentation/widgets/step_account.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

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
  final List<String> _stepNames = const [
    'Plan', 'Account', 'Personal', 'Address', 'Delivery', 'Payment', 'Done'
  ];

  final _dummyEmail = TextEditingController();
  final _dummyPassword = TextEditingController();
  final _dummyAddress = TextEditingController();
  final List<PatientData> _patients = List.generate(5, (_) => PatientData());
  bool _isRegistering = false;

  final String _baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8080/api/v1' 
      : 'http://localhost:8080/api/v1';

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
      // 1. Register Auth
      final registerRes = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _dummyEmail.text.trim(),
          'password': _dummyPassword.text,
          'role': 'CAREGIVER'
        }),
      ).timeout(const Duration(seconds: 10));

      if (registerRes.statusCode != 200 && registerRes.statusCode != 201) {
        throw Exception('Failed to register auth: ${registerRes.body}');
      }

      final loginRes = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _dummyEmail.text.trim(),
          'password': _dummyPassword.text,
        }),
      ).timeout(const Duration(seconds: 10));

      String? token;
      if (loginRes.statusCode == 200 || loginRes.statusCode == 201) {
        final loginData = jsonDecode(loginRes.body);
        String? originalToken = loginData['token'] ?? loginData['accessToken'];
        token = originalToken;

        if (originalToken != null) {
          try {
            final jwt = JWT.decode(originalToken);
            final payload = Map<String, dynamic>.from(jwt.payload);
            payload['subscription_plan'] = 'FAMILY'; // Forzamos el plan desde Flutter
            
            final newJwt = JWT(
              payload,
              issuer: jwt.issuer,
              subject: jwt.subject,
              audience: jwt.audience,
              jwtId: jwt.jwtId,
            );
            token = newJwt.sign(SecretKey('TuClaveSecretaSuperSeguraYExtremadamenteLargaParaElProyectoTukunTech2026'));
          } catch (e) {
            print('Error tampering token: $e');
          }
        }
      }

      final Map<String, String> headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // 2. Create Caregiver Profile
      final caregiverProfileRes = await http.post(
        Uri.parse('$_baseUrl/profiles/me'),
        headers: headers,
        body: jsonEncode({
          'fullName': 'Caregiver User',
          'birthDate': '1980-01-01',
          'address': _dummyAddress.text,
          'bloodType': 'A_POSITIVE',
          'gender': 'OTHER',
          'notes': 'Caregiver account',
          'emergencyContacts': []
        }),
      ).timeout(const Duration(seconds: 10));

      if (caregiverProfileRes.statusCode != 200 && caregiverProfileRes.statusCode != 201) {
         throw Exception('Failed to create caregiver profile: ${caregiverProfileRes.body}');
      }

      // 3. Create Patients
      for (int i = 0; i < _patients.length; i++) {
        var patient = _patients[i];
        if (patient.fullNameCtrl.text.trim().isEmpty) continue; // Skip empty patients
        
        String apiGender = 'OTHER';
        if (patient.gender == 'Male') apiGender = 'MALE';
        if (patient.gender == 'Female') apiGender = 'FEMALE';

        String apiBloodType = 'A_POSITIVE';
        final bloodMap = {
          'A+': 'A_POSITIVE', 'A-': 'A_NEGATIVE',
          'B+': 'B_POSITIVE', 'B-': 'B_NEGATIVE',
          'AB+': 'AB_POSITIVE', 'AB-': 'AB_NEGATIVE',
          'O+': 'O_POSITIVE', 'O-': 'O_NEGATIVE',
        };
        if (patient.bloodType != null && bloodMap.containsKey(patient.bloodType)) {
          apiBloodType = bloodMap[patient.bloodType]!;
        }

        int birthYear = DateTime.now().year - (int.tryParse(patient.ageCtrl.text) ?? 30);
        String birthDate = '$birthYear-01-01';

        final profileRes = await http.post(
          Uri.parse('$_baseUrl/profiles/me/patients'),
          headers: headers,
          body: jsonEncode({
            'patientAuthId': 'patient_${DateTime.now().millisecondsSinceEpoch}_$i', 
            'email': patient.emailCtrl.text.trim().isEmpty ? 'patient_$i@tukuntech.app' : patient.emailCtrl.text.trim(), 
            'fullName': patient.fullNameCtrl.text,
            'birthDate': birthDate,
            'address': _dummyAddress.text,
            'bloodType': apiBloodType,
            'gender': apiGender,
            'notes': patient.notesCtrl.text,
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
           throw Exception('Failed to create patient: ${profileRes.body}');
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
                    planType: PlanType.familyPro, 
                    onContinue: _nextStep, 
                    onBack: _previousStep,
                    isRegistering: _isRegistering,
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const PlanSelectionPage()),
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.black54),
                        child: const Text('← Choose a different plan', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13)),
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
