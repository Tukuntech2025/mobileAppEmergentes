import 'package:flutter/material.dart';

class StepPersonal extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final TextEditingController fullNameController;
  final TextEditingController dniController;
  final TextEditingController ageController;
  final TextEditingController notesController;
  final String gender;
  final ValueChanged<String?> onGenderChanged;
  final String bloodType;
  final ValueChanged<String?> onBloodTypeChanged;

  // New controllers
  final TextEditingController patientEmailController;
  final TextEditingController patientPasswordController;
  final TextEditingController patientConfirmPasswordController;
  final TextEditingController minHrController;
  final TextEditingController maxHrController;
  final TextEditingController minO2Controller;
  final TextEditingController maxO2Controller;
  final TextEditingController minTempController;
  final TextEditingController maxTempController;

  const StepPersonal({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.fullNameController,
    required this.dniController,
    required this.ageController,
    required this.notesController,
    required this.gender,
    required this.onGenderChanged,
    required this.bloodType,
    required this.onBloodTypeChanged,
    required this.patientEmailController,
    required this.patientPasswordController,
    required this.patientConfirmPasswordController,
    required this.minHrController,
    required this.maxHrController,
    required this.minO2Controller,
    required this.maxO2Controller,
    required this.minTempController,
    required this.maxTempController,
  });

  @override
  State<StepPersonal> createState() => _StepPersonalState();
}

class _StepPersonalState extends State<StepPersonal> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: const [
              Icon(Icons.people_outline, color: primaryColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Register the 1 patient included in this plan.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Chips (Single Patient 1 Chip)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Patient 1', style: TextStyle(fontSize: 12)),
                selected: true,
                onSelected: (_) {},
                selectedColor: primaryColor,
                backgroundColor: Colors.white,
                labelStyle: const TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: primaryColor),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.all(0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Form Card Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient account header block
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.assignment_ind_outlined, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Each patient will have their own independent access.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Patient email'),
              const SizedBox(height: 4),
              _buildTextField('Enter patient email', keyboardType: TextInputType.emailAddress, controller: widget.patientEmailController),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Patient password'),
                        const SizedBox(height: 4),
                        _buildPasswordField('••••••••', obscureText: _obscurePassword, controller: widget.patientPasswordController, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Confirm patient password'),
                        const SizedBox(height: 4),
                        _buildPasswordField('••••••••', obscureText: _obscureConfirmPassword, controller: widget.patientConfirmPasswordController, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildLabel('DNI'),
              const SizedBox(height: 4),
              _buildTextField('8 digits', keyboardType: TextInputType.number, controller: widget.dniController, maxLength: 8),
              const SizedBox(height: 16),

              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              _buildLabel('Full name'),
              const SizedBox(height: 4),
              _buildTextField('Enter your full name', controller: widget.fullNameController),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Age'),
                        const SizedBox(height: 4),
                        _buildTextField('Enter your age', keyboardType: TextInputType.number, controller: widget.ageController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Gender'),
                        const SizedBox(height: 4),
                        _buildDropdown(widget.gender, ['Select gender', 'MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'], widget.onGenderChanged),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildLabel('Blood type'),
              const SizedBox(height: 4),
              _buildDropdown(widget.bloodType, ['Select blood type', 'A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE', 'AB_POSITIVE', 'AB_NEGATIVE', 'O_POSITIVE', 'O_NEGATIVE', 'UNKNOWN'], widget.onBloodTypeChanged),
              const SizedBox(height: 12),

              _buildLabel('Additional notes'),
              const SizedBox(height: 4),
              _buildTextField(
                'Allergies, conditions, anything we should know...',
                maxLines: 3,
                controller: widget.notesController,
              ),
              const SizedBox(height: 16),
              
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.monitor_heart_outlined, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical parameters',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Set the personalized monitoring ranges for this patient.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Minimum heart rate'),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: widget.minHrController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Maximum heart rate'),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: widget.maxHrController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Minimum oxygen saturation'),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('%', keyboardType: TextInputType.number, controller: widget.minO2Controller),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Maximum oxygen saturation'),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('%', keyboardType: TextInputType.number, controller: widget.maxO2Controller),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Minimum temperature'),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: widget.minTempController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Maximum temperature'),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: widget.maxTempController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'These values belong to the patient and will be used to evaluate readings and alerts. Patients and caregivers cannot edit them.',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
              label: const Text(
                'Back',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: widget.onContinue,
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
                children: const [
                  Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(width: 6),
                  Icon(Icons.check, size: 18),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, TextInputType? keyboardType, TextEditingController? controller, int? maxLength}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: Colors.white,
        counterText: "",
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    final Map<String, String> displayNameMap = {
      'Select gender': 'Select gender',
      'MALE': 'Male',
      'FEMALE': 'Female',
      'OTHER': 'Other',
      'PREFER_NOT_TO_SAY': 'Prefer not to say',
      'Select blood type': 'Select blood type',
      'A_POSITIVE': 'A+',
      'A_NEGATIVE': 'A-',
      'B_POSITIVE': 'B+',
      'B_NEGATIVE': 'B-',
      'AB_POSITIVE': 'AB+',
      'AB_NEGATIVE': 'AB-',
      'O_POSITIVE': 'O+',
      'O_NEGATIVE': 'O-',
      'UNKNOWN': 'UNKNOWN',
    };

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(displayNameMap[value] ?? value, style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.normal)),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            displayNameMap[item] ?? item,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSuffixTextField(String suffix, {TextInputType? keyboardType, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
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
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(suffix, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildPasswordField(String hint, {required bool obscureText, TextEditingController? controller, required VoidCallback onToggle}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }
}
