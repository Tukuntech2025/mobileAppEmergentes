import 'package:flutter/material.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

class StepAccount extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const StepAccount({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<StepAccount> createState() => _StepAccountState();
}

class _StepAccountState extends State<StepAccount> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel(context.translate('caregiver_email')),
          const SizedBox(height: 2),
          _buildTextField('you@example.com', controller: widget.emailController),
          const SizedBox(height: 20),
          _buildLabel(context.translate('caregiver_password')),
          const SizedBox(height: 2),
          _buildPasswordField('••••••••', obscureText: _obscurePassword, controller: widget.passwordController, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
          const SizedBox(height: 20),
          _buildLabel(context.translate('confirm_caregiver_password')),
          const SizedBox(height: 2),
          _buildPasswordField('••••••••', obscureText: _obscureConfirmPassword, controller: _confirmPasswordController, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
                label: Text(
                  context.translate('back_btn'),
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: _validateAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          context.translate('continue_btn'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _validateAndContinue() {
    final email = widget.emailController.text.trim();
    final password = widget.passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog(context.translate('error_fill_all_fields'));
      return;
    }

    if (password.length < 6) {
      _showErrorDialog(context.translate('error_password_too_short'));
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog(context.translate('error_passwords_do_not_match'));
      return;
    }

    widget.onContinue();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Text(context.translate('error_label')),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF3B9784))),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(String hint, {bool obscureText = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          borderSide: const BorderSide(color: Color(0xFF3B9784), width: 2),
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        letterSpacing: obscureText ? 4 : 0,
      ),
    );
  }

  Widget _buildPasswordField(String hint, {required bool obscureText, TextEditingController? controller, required VoidCallback onToggle}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          borderSide: const BorderSide(color: Color(0xFF3B9784), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.black45,
          ),
          onPressed: onToggle,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        letterSpacing: obscureText ? 4 : 0,
      ),
    );
  }
}
