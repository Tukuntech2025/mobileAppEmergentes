import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/patient_create_account_page.dart';
import 'package:tukuntech/features/auth/presentation/pages/caregiver_create_account_page.dart';
import 'package:tukuntech/features/auth/presentation/pages/role_selection_page.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

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
                    Text(
                      context.translate('create_account_title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF112A24),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.translate('choose_plan_subtitle'),
                      style: const TextStyle(
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
                      title: context.translate('individual_plan'),
                      subtitle: context.translate('plan_desc_1_patient'),
                      initialPayment: '\$50',
                      monthlyPayment: '\$15/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientCreateAccountPage(
                              planTitle: context.translate('individual_plan'),
                              planSubtitle: context.translate('plan_desc_1_patient'),
                              initialPayment: '\$50',
                              monthlyPayment: '\$15/mo',
                            ),
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
                      title: context.translate('family_plan_2'),
                      subtitle: context.translate('plan_desc_2_patients'),
                      initialPayment: '\$95',
                      monthlyPayment: '\$28/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CaregiverCreateAccountPage(
                              planTitle: context.translate('family_plan_2'),
                              planSubtitle: context.translate('plan_desc_2_patients'),
                              initialPayment: '\$95',
                              monthlyPayment: '\$28/mo',
                            ),
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
                      title: context.translate('family_plan_3'),
                      subtitle: context.translate('plan_desc_3_patients'),
                      initialPayment: '\$140',
                      monthlyPayment: '\$40/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CaregiverCreateAccountPage(
                              planTitle: context.translate('family_plan_3'),
                              planSubtitle: context.translate('plan_desc_3_patients'),
                              initialPayment: '\$140',
                              monthlyPayment: '\$40/mo',
                              isRecommended: true,
                            ),
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
                      title: context.translate('family_plan_4'),
                      subtitle: context.translate('plan_desc_4_patients'),
                      initialPayment: '\$180',
                      monthlyPayment: '\$52/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CaregiverCreateAccountPage(
                              planTitle: context.translate('family_plan_4'),
                              planSubtitle: context.translate('plan_desc_4_patients'),
                              initialPayment: '\$180',
                              monthlyPayment: '\$52/mo',
                            ),
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
                      title: context.translate('family_plan_5'),
                      subtitle: context.translate('plan_desc_5_patients'),
                      initialPayment: '\$215',
                      monthlyPayment: '\$62/mo',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CaregiverCreateAccountPage(
                              planTitle: context.translate('family_plan_5'),
                              planSubtitle: context.translate('plan_desc_5_patients'),
                              initialPayment: '\$215',
                              monthlyPayment: '\$62/mo',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.translate('already_have_account'),
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
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
                          child: Text(
                            context.translate('sign_in'),
                            style: const TextStyle(
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
                  '${context.translate('initial_payment_label')} $initialPayment',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${context.translate('monthly_label')} $monthlyPayment',
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
