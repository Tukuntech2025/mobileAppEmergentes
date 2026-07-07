import 'package:flutter/material.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

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
            children: [
              const Icon(Icons.people_outline, color: primaryColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${context.translate('register_patients_part_1')}1${context.translate('register_patients_part_2_singular')}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
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
                label: Text('${context.translate('patient_prefix')}1', style: const TextStyle(fontSize: 12)),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate('patient_account'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          context.translate('patient_account_desc'),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel(context.translate('patient_email')),
              const SizedBox(height: 4),
              _buildTextField(context.translate('enter_patient_email'), keyboardType: TextInputType.emailAddress, controller: widget.patientEmailController),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context.translate('patient_password')),
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
                        _buildLabel(context.translate('confirm_patient_password')),
                        const SizedBox(height: 4),
                        _buildPasswordField('••••••••', obscureText: _obscureConfirmPassword, controller: widget.patientConfirmPasswordController, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildLabel(context.translate('dni')),
              const SizedBox(height: 4),
              _buildTextField(context.translate('eight_digits'), keyboardType: TextInputType.number, controller: widget.dniController, maxLength: 8),
              const SizedBox(height: 16),

              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              _buildLabel(context.translate('full_name')),
              const SizedBox(height: 4),
              _buildTextField(context.translate('enter_full_name'), controller: widget.fullNameController),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context.translate('age')),
                        const SizedBox(height: 4),
                        _buildTextField(context.translate('enter_age'), keyboardType: TextInputType.number, controller: widget.ageController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context.translate('gender')),
                        const SizedBox(height: 4),
                        _buildDropdown(widget.gender, ['Select gender', 'MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'], widget.onGenderChanged),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildLabel(context.translate('blood_type')),
              const SizedBox(height: 4),
              _buildDropdown(widget.bloodType, ['Select blood type', 'A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE', 'AB_POSITIVE', 'AB_NEGATIVE', 'O_POSITIVE', 'O_NEGATIVE', 'UNKNOWN'], widget.onBloodTypeChanged),
              const SizedBox(height: 12),

              _buildLabel(context.translate('additional_notes')),
              const SizedBox(height: 4),
              _buildTextField(
                context.translate('additional_notes_hint'),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate('medical_parameters'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          context.translate('medical_parameters_desc'),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                        _buildLabel(context.translate('min_heart_rate')),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: widget.minHrController, min: 30, max: 200),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context.translate('max_heart_rate')),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: widget.maxHrController, min: 40, max: 250),
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
                        _buildLabel(context.translate('min_o2_sat')),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('%', keyboardType: TextInputType.number, controller: widget.minO2Controller, min: 50, max: 100),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context.translate('max_o2_sat')),
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
                        _buildLabel(context.translate('min_temp')),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: widget.minTempController, min: 30, max: 42),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context.translate('max_temp')),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: widget.maxTempController, min: 32, max: 45),
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
                        context.translate('parameters_info'),
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
              label: Text(
                context.translate('back_btn'),
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: _validateAndContinue,
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
                children: [
                  Text(context.translate('continue_btn'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  const Icon(Icons.check, size: 18),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _validateAndContinue() {
    if (widget.patientEmailController.text.trim().isEmpty || 
        widget.patientPasswordController.text.isEmpty || 
        widget.patientConfirmPasswordController.text.isEmpty || 
        widget.dniController.text.trim().isEmpty || 
        widget.fullNameController.text.trim().isEmpty || 
        widget.ageController.text.trim().isEmpty || 
        widget.minHrController.text.trim().isEmpty || 
        widget.maxHrController.text.trim().isEmpty || 
        widget.minO2Controller.text.trim().isEmpty || 
        widget.maxO2Controller.text.trim().isEmpty || 
        widget.minTempController.text.trim().isEmpty || 
        widget.maxTempController.text.trim().isEmpty || 
        widget.gender == 'Select gender' || 
        widget.bloodType == 'Select blood type') {
      _showErrorDialog(context.translate('error_fill_all_fields'));
      return;
    }

    if (widget.patientPasswordController.text.length < 6) {
      _showErrorDialog(context.translate('error_password_too_short'));
      return;
    }

    if (widget.patientPasswordController.text != widget.patientConfirmPasswordController.text) {
      _showErrorDialog(context.translate('error_passwords_do_not_match'));
      return;
    }

    if (widget.dniController.text.trim().length != 8) {
      _showErrorDialog(context.translate('error_dni_length'));
      return;
    }

    int? age = int.tryParse(widget.ageController.text.trim());
    if (age == null || age < 0 || age > 130) {
      _showErrorDialog(context.translate('error_invalid_age'));
      return;
    }

    double? minHeartRate = double.tryParse(widget.minHrController.text);
    double? maxHeartRate = double.tryParse(widget.maxHrController.text);
    if (minHeartRate != null && (minHeartRate < 30 || minHeartRate > 200)) { _showErrorDialog("Frecuencia cardíaca mínima irreal."); return; }
    if (maxHeartRate != null && (maxHeartRate < 40 || maxHeartRate > 250)) { _showErrorDialog("Frecuencia cardíaca máxima irreal."); return; }
    if (minHeartRate != null && maxHeartRate != null && minHeartRate >= maxHeartRate) { _showErrorDialog("Frecuencia cardíaca mínima no puede ser mayor o igual a la máxima."); return; }
    
    double? minOxygenSaturation = double.tryParse(widget.minO2Controller.text);
    double? maxOxygenSaturation = double.tryParse(widget.maxO2Controller.text);
    if (minOxygenSaturation != null && (minOxygenSaturation < 50 || minOxygenSaturation > 100)) { _showErrorDialog("Saturación de oxígeno irreal."); return; }
    if (minOxygenSaturation != null && maxOxygenSaturation != null && minOxygenSaturation >= maxOxygenSaturation) { _showErrorDialog("Saturación mínima no puede ser mayor o igual a la máxima."); return; }
    
    double? minTemperature = double.tryParse(widget.minTempController.text);
    double? maxTemperature = double.tryParse(widget.maxTempController.text);
    if (minTemperature != null && (minTemperature < 30 || minTemperature > 42)) { _showErrorDialog("Temperatura mínima irreal."); return; }
    if (maxTemperature != null && (maxTemperature < 32 || maxTemperature > 45)) { _showErrorDialog("Temperatura máxima irreal."); return; }
    if (minTemperature != null && maxTemperature != null && minTemperature >= maxTemperature) { _showErrorDialog("Temperatura mínima no puede ser mayor o igual a la máxima."); return; }
    
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
      'Select gender': context.translate('select_gender'),
      'MALE': context.translate('male'),
      'FEMALE': context.translate('female'),
      'OTHER': context.translate('other'),
      'PREFER_NOT_TO_SAY': context.translate('prefer_not_to_say'),
      'Select blood type': context.translate('select_blood_type'),
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

  Widget _buildSuffixTextField(String suffix, {TextInputType? keyboardType, TextEditingController? controller, double? min, double? max}) {
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (min != null && max != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        double current = double.tryParse(controller?.text ?? '') ?? min;
                        if (current < max) {
                          controller?.text = (current + 1).toInt().toString();
                        }
                      },
                      child: const Icon(Icons.arrow_drop_up, size: 20, color: Colors.black54),
                    ),
                    InkWell(
                      onTap: () {
                        double current = double.tryParse(controller?.text ?? '') ?? min;
                        if (current > min) {
                          controller?.text = (current - 1).toInt().toString();
                        }
                      },
                      child: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black54),
                    ),
                  ],
                ),
              if (min != null && max != null) const SizedBox(width: 4),
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
