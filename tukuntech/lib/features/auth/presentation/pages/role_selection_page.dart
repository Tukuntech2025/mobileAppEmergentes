import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/login_page.dart';
import 'package:tukuntech/features/auth/presentation/pages/caregiver_login_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);
    const backgroundColor = Color(0xFFF7F8F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/icon_tukuntech.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Headings
                  const Text(
                    'Welcome to TukunTech',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF112A24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose your role to continue.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Role Options
                  _buildRoleCard(
                    context,
                    title: 'I\'m a Patient',
                    subtitle: 'Access your vital signs, device, and subscription.',
                    icon: Icons.person_outline,
                    iconColor: Colors.blue[300]!,
                    iconBgColor: Colors.blue.withOpacity(0.1),
                    destination: const LoginScreen(),
                  ),
                  const SizedBox(height: 12),
                  _buildRoleCard(
                    context,
                    title: 'I\'m a Caregiver / Family',
                    subtitle: 'Monitor up to 5 people under your care.',
                    icon: Icons.favorite_border,
                    iconColor: primaryColor,
                    iconBgColor: primaryColor.withOpacity(0.15),
                    destination: const CaregiverLoginScreen(),
                  ),
                  const SizedBox(height: 12),
                  _buildRoleCard(
                    context,
                    title: 'I\'m an Administrator',
                    subtitle: 'Operational console — login only.',
                    icon: Icons.shield_outlined,
                    iconColor: primaryColor,
                    iconBgColor: primaryColor.withOpacity(0.15),
                    destination: const LoginScreen(),
                  ),
                  const SizedBox(height: 24),

                  // Language pill
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLangButton('EN', true, primaryColor),
                          _buildLangButton('ES', false, primaryColor),
                          const SizedBox(width: 8),
                          Icon(Icons.translate, size: 18, color: primaryColor),
                          const SizedBox(width: 12),
                        ],
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

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Widget destination,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
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
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_outlined, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String text, bool isSelected, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isSelected
          ? BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}
