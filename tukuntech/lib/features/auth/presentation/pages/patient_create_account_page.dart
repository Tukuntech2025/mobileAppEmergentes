import 'package:flutter/material.dart';

class PatientCreateAccountPage extends StatefulWidget {
  const PatientCreateAccountPage({super.key});

  @override
  State<PatientCreateAccountPage> createState() => _PatientCreateAccountPageState();
}

class _PatientCreateAccountPageState extends State<PatientCreateAccountPage> {
  int _currentStep = 0;
  final int _totalSteps = 4;
  final List<String> _stepNames = const [
    'Plan', 'Account', 'Personal', 'Address'
  ];

  int _selectedPlanIndex = 0; // 0 for Personal, 1 for Personal Plus

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context); // Go back to Patient Login
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
                    'Create your patient account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF112A24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Subscribe to activate your TukunTech.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Steps Indicator
                  _buildStepper(primaryColor),
                  
                  const SizedBox(height: 24),
                  
                  // Step Content
                  if (_currentStep == 0) ...[
                    _buildPlanCard(
                      title: 'Personal',
                      price: '\$29/mo',
                      description: '1 TukunTech device · vitals · reminders',
                      isRecommended: true,
                      isSelected: _selectedPlanIndex == 0,
                      onTap: () => setState(() => _selectedPlanIndex = 0),
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildPlanCard(
                      title: 'Personal Plus',
                      price: '\$39/mo',
                      description: 'Adds priority support & extended history',
                      isRecommended: false,
                      isSelected: _selectedPlanIndex == 1,
                      onTap: () => setState(() => _selectedPlanIndex = 1),
                      primaryColor: primaryColor,
                    ),
                  ] else Center(child: Text('Step ${_currentStep + 1} Content', style: const TextStyle(fontSize: 16))),
                  
                  const SizedBox(height: 24),
                  
                  // Continue Button
                  Align(
                    alignment: Alignment.centerRight,
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
                        Navigator.pop(context);
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

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required bool isRecommended,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
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
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
