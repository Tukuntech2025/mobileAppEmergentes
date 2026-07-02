import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/patient_create_account_page.dart';
import 'package:tukuntech/features/auth/presentation/pages/caregiver_create_account_page.dart';
import 'package:tukuntech/features/auth/presentation/pages/role_selection_page.dart';

class PlanSelectionPage extends StatelessWidget {
  const PlanSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);
    const backgroundColor = Color(0xFFF7F8F9); // Light background color from the mockup

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title and Subtitle
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF112A24),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose the plan that fits you. Accounts are created during checkout.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Plan Option 1
                    _buildPlanCard(
                      context: context,
                      icon: Icons.person_outline,
                      iconColor: Colors.blue,
                      iconBgColor: Colors.blue.shade50,
                      title: 'Individual plan',
                      subtitle: '1 patient + 1 caregiver · vital signs monitoring · web and mobile access',
                      initialPayment: '\$50',
                      monthlyPayment: '\$15/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientCreateAccountPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Plan Option 2
                    _buildPlanCard(
                      context: context,
                      icon: Icons.people_outline,
                      iconColor: primaryColor,
                      iconBgColor: primaryColor.withOpacity(0.1),
                      title: 'Family plan 2',
                      subtitle: '2 patients + 1 caregiver · vital signs monitoring · web and mobile access',
                      initialPayment: '\$95',
                      monthlyPayment: '\$28/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CaregiverCreateAccountPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Plan Option 3
                    _buildPlanCard(
                      context: context,
                      icon: Icons.people_outline,
                      iconColor: primaryColor,
                      iconBgColor: primaryColor.withOpacity(0.1),
                      title: 'Family plan 3',
                      subtitle: '3 patients + 1 caregiver · vital signs monitoring · web and mobile access',
                      initialPayment: '\$140',
                      monthlyPayment: '\$40/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CaregiverCreateAccountPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Plan Option 4
                    _buildPlanCard(
                      context: context,
                      icon: Icons.people_outline,
                      iconColor: primaryColor,
                      iconBgColor: primaryColor.withOpacity(0.1),
                      title: 'Family plan 4',
                      subtitle: '4 patients + 1 caregiver · vital signs monitoring · web and mobile access',
                      initialPayment: '\$180',
                      monthlyPayment: '\$52/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CaregiverCreateAccountPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Plan Option 5
                    _buildPlanCard(
                      context: context,
                      icon: Icons.people_outline,
                      iconColor: primaryColor,
                      iconBgColor: primaryColor.withOpacity(0.1),
                      title: 'Family plan 5',
                      subtitle: '5 patients + 1 caregiver · vital signs monitoring · web and mobile access',
                      initialPayment: '\$215',
                      monthlyPayment: '\$62/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CaregiverCreateAccountPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                              (route) => false,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String initialPayment,
    required String monthlyPayment,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Initial payment: $initialPayment',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Monthly: $monthlyPayment',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
