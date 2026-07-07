import 'package:flutter/material.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

class PatientData {
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();
  
  final TextEditingController minHrCtrl = TextEditingController();
  final TextEditingController maxHrCtrl = TextEditingController();
  final TextEditingController minO2Ctrl = TextEditingController();
  final TextEditingController maxO2Ctrl = TextEditingController();
  final TextEditingController minTempCtrl = TextEditingController();
  final TextEditingController maxTempCtrl = TextEditingController();

  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  final TextEditingController dniCtrl = TextEditingController();

  String? gender;
  String? bloodType;

  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    ageCtrl.dispose();
    notesCtrl.dispose();
    minHrCtrl.dispose();
    maxHrCtrl.dispose();
    minO2Ctrl.dispose();
    maxO2Ctrl.dispose();
    minTempCtrl.dispose();
    maxTempCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    dniCtrl.dispose();
  }
}

class StepPatients extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final List<PatientData> patients;

  const StepPatients({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.patients,
  });

  @override
  State<StepPatients> createState() => _StepPatientsState();
}

class _StepPatientsState extends State<StepPatients> {
  int _currentPatientIndex = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    super.dispose();
  }

  void _nextPatient() {
    if (_currentPatientIndex < widget.patients.length - 1) {
      setState(() {
        _currentPatientIndex++;
        _obscurePassword = true;
        _obscureConfirmPassword = true;
      });
    }
  }

  void _previousPatient() {
    if (_currentPatientIndex > 0) {
      setState(() {
        _currentPatientIndex--;
        _obscurePassword = true;
        _obscureConfirmPassword = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);
    final currentPatient = widget.patients[_currentPatientIndex];

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
                  '${context.translate('register_patients_part_1')}${widget.patients.length}${widget.patients.length == 1 ? context.translate('register_patients_part_2_singular') : context.translate('register_patients_part_2_plural')}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.patients.length, (index) {
              final isSelected = index == _currentPatientIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('${context.translate('patient_prefix')}${index + 1}', style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _currentPatientIndex = index;
                        _obscurePassword = true;
                        _obscureConfirmPassword = true;
                      });
                    }
                  },
                  selectedColor: primaryColor,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.all(0),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),

        // Form Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(height: 2),
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
              _buildTextField(context.translate('enter_patient_email'), keyboardType: TextInputType.emailAddress, controller: currentPatient.emailCtrl),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context.translate('patient_password')),
                        const SizedBox(height: 4),
                        _buildPasswordField('••••••••', obscureText: _obscurePassword, controller: currentPatient.passwordCtrl, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
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
                        _buildPasswordField('••••••••', obscureText: _obscureConfirmPassword, controller: currentPatient.confirmPasswordCtrl, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildLabel(context.translate('dni')),
              const SizedBox(height: 4),
              _buildTextField(context.translate('eight_digits'), keyboardType: TextInputType.number, controller: currentPatient.dniCtrl, maxLength: 8),
              const SizedBox(height: 16),

              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              _buildLabel(context.translate('full_name')),
              const SizedBox(height: 4),
              _buildTextField(context.translate('enter_full_name'), controller: currentPatient.fullNameCtrl),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context.translate('age')),
                        const SizedBox(height: 4),
                        _buildTextField(context.translate('enter_age'), keyboardType: TextInputType.number, controller: currentPatient.ageCtrl),
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
                        _buildDropdown(
                          context.translate('select_gender'), 
                          [context.translate('female'), context.translate('male'), context.translate('other')],
                          currentPatient.gender,
                          (val) => setState(() => currentPatient.gender = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildLabel(context.translate('blood_type')),
              const SizedBox(height: 4),
              _buildDropdown(
                context.translate('select_blood_type'), 
                ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                currentPatient.bloodType,
                (val) => setState(() => currentPatient.bloodType = val),
              ),
              const SizedBox(height: 12),

              _buildLabel(context.translate('additional_notes')),
              const SizedBox(height: 4),
              _buildTextField(
                context.translate('additional_notes_hint'),
                maxLines: 3,
                controller: currentPatient.notesCtrl,
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
                        const SizedBox(height: 2),
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
                        _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: currentPatient.minHrCtrl, min: 30, max: 200),
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
                        _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: currentPatient.maxHrCtrl, min: 40, max: 250),
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
                        _buildSuffixTextField('%', keyboardType: TextInputType.number, controller: currentPatient.minO2Ctrl, min: 50, max: 100),
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
                        _buildSuffixTextField('%', keyboardType: TextInputType.number, controller: currentPatient.maxO2Ctrl),
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
                        _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: currentPatient.minTempCtrl, min: 30, max: 42),
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
                        _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: currentPatient.maxTempCtrl, min: 32, max: 45),
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
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPatientIndex > 0 ? _previousPatient : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B9784).withOpacity(0.05),
                        disabledBackgroundColor: Colors.grey.shade100,
                        disabledForegroundColor: Colors.black26,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, size: 16, color: Color(0xFF3B9784)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              context.translate('previous_patient'),
                              style: const TextStyle(color: Color(0xFF3B9784), fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPatientIndex < widget.patients.length - 1 ? _nextPatient : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B9784),
                        disabledBackgroundColor: Colors.grey.shade100,
                        disabledForegroundColor: Colors.black26,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              context.translate('next_patient'),
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
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
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
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
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(hint, style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.normal)),
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
            item,
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
}
