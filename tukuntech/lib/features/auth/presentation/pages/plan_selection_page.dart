import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/create_account_page.dart';

class PlanSelectionPage extends StatelessWidget {
  const PlanSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the screen is wide enough to show the split layout
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    if (isWideScreen) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            Expanded(child: _buildLeftPanel(context)),
            Expanded(child: _buildRightPanel(context)),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildLeftPanel(context, isMobile: true),
              _buildRightPanel(context),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLeftPanel(BuildContext context, {bool isMobile = false}) {
    const primaryColor = Color(0xFF3B9784);

    return Container(
      width: double.infinity,
      constraints: isMobile ? const BoxConstraints(minHeight: 300) : null,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE5F5F2), Colors.white],
          stops: [0.0, 0.8],
        ),
      ),
      padding: EdgeInsets.all(isMobile ? 32.0 : 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'TukunTech',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text(
            'Calm, connected care for the\npeople you love.',
            style: TextStyle(
              fontSize: isMobile ? 32 : 40,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Real-time vitals, gentle reminders, and peace of mind —\ndesigned for families and caregivers, not hospitals.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 64.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the plan that fits you. Accounts are created during checkout.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              
              // Plan Option 1
              _buildPlanCard(
                icon: Icons.person_outline,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.shade50,
                title: 'Personal — for one patient',
                subtitle: 'Includes one TukunTech device, vitals tracking, and reminders.',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountPage(planType: PlanType.personal),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Plan Option 2
              _buildPlanCard(
                icon: Icons.favorite_border,
                iconColor: primaryColor,
                iconBgColor: primaryColor.withOpacity(0.1),
                title: 'Family Pro — up to 5 patients',
                subtitle: 'Monitor up to five loved ones from a single caregiver dashboard.',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountPage(planType: PlanType.familyPro),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              
              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      // Pop all routes until we reach the root (LoginScreen)
                      Navigator.popUntil(context, (route) => route.isFirst);
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
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }
}
