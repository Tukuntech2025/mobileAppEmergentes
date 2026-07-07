import 'package:flutter/material.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';
import 'package:tukuntech/features/auth/presentation/pages/plan_selection_page.dart';
import 'package:tukuntech/features/patient/presentation/pages/vital_signs_page.dart';
import 'package:tukuntech/features/caregiver/presentation/pages/caregiver_dashboard_page.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:tukuntech/core/api_client.dart';
import 'package:tukuntech/core/auth_store.dart';
import 'package:tukuntech/core/environment_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final String _loginUrl = '${EnvironmentConfig.baseUrl}/auth/login';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiClient.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String token = responseData['token'] ?? responseData['accessToken'] ?? '';
          final String refreshToken = responseData['refreshToken'] ?? '';
          
          if (token.isEmpty) {
            throw Exception(context.translate('error_no_token'));
          }

          AuthStore.token = token;
          if (refreshToken.isNotEmpty) {
            AuthStore.refreshToken = refreshToken;
          }

          final String profileUrl = '${EnvironmentConfig.baseUrl}/profiles/me';

          final profileResponse = await ApiClient.get(
            Uri.parse(profileUrl),
            headers: {'Authorization': 'Bearer $token'},
          ).timeout(const Duration(seconds: 10));

          if (profileResponse.statusCode == 200 || profileResponse.statusCode == 201) {
            final profileData = jsonDecode(utf8.decode(profileResponse.bodyBytes));
            final String role = profileData['role'] ?? '';
            
            if (role == 'PATIENT') {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VitalSignsPage(),
                  ),
                );
              }
            } else if (role == 'CAREGIVER') {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CaregiverDashboardPage(),
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.translate('error_unauthorized_role')} ($role)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          } else {
            throw Exception(context.translate('error_profile_fetch'));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${context.translate('error_label')}: $e')),
            );
          }
        }
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.translate('login_failed')}: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.translate('error_label')}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784); // Teal color from the design
    const backgroundColor = Color(0xFFF7F8F9); // Light background color

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and App Name
                  Row(
                    children: [
                      Image.asset(
                        'assets/icon_tukuntech.png',
                        width: 36,
                        height: 36,
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
                  const SizedBox(height: 16),
                  
                  // Headings
                  Text(
                    context.translate('sign_in'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.translate('enter_credentials'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Role Badge
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 18, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          Text(
                            context.translate('patient_caregiver_badge'),
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Email Field
                  Text(
                    context.translate('email_label'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate('password_label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          context.translate('forgot_password'),
                          style: const TextStyle(
                            color: primaryColor, 
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.black45,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(fontSize: 14, letterSpacing: _obscurePassword ? 4 : 0),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign In Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            context.translate('sign_in'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.translate('dont_have_account'),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PlanSelectionPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          context.translate('create_one'),
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                      ),
                      child: Text(
                        context.translate('choose_different_role'),
                        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
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
}

