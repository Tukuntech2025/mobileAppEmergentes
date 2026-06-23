import 'package:flutter/material.dart';

class PatientData {
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();
  
  final TextEditingController minHrCtrl = TextEditingController();
  final TextEditingController maxHrCtrl = TextEditingController();
  final TextEditingController minO2Ctrl = TextEditingController();
  final TextEditingController maxO2Ctrl = TextEditingController();
  final TextEditingController minTempCtrl = TextEditingController();
  final TextEditingController maxTempCtrl = TextEditingController();

  String? gender;
  String? bloodType;

  void dispose() {
    fullNameCtrl.dispose();
    ageCtrl.dispose();
    notesCtrl.dispose();
    minHrCtrl.dispose();
    maxHrCtrl.dispose();
    minO2Ctrl.dispose();
    maxO2Ctrl.dispose();
    minTempCtrl.dispose();
    maxTempCtrl.dispose();
  }
}

class StepPatients extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepPatients({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<StepPatients> createState() => _StepPatientsState();
}

class _StepPatientsState extends State<StepPatients> {
  int _currentPatientIndex = 0; // 0 to 4
  final List<PatientData> _patients = List.generate(5, (_) => PatientData());

  @override
  void dispose() {
    for (var p in _patients) {
      p.dispose();
    }
    super.dispose();
  }

  void _nextPatient() {
    if (_currentPatientIndex < 4) {
      setState(() => _currentPatientIndex++);
    }
  }

  void _previousPatient() {
    if (_currentPatientIndex > 0) {
      setState(() => _currentPatientIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);
    final currentPatient = _patients[_currentPatientIndex];

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
              Icon(Icons.people_outline, color: primaryColor, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Register all 5 patients under your care.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
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
            children: List.generate(5, (index) {
              final isSelected = index == _currentPatientIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('Patient ${index + 1}', style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _currentPatientIndex = index);
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
              _buildLabel('Full name'),
              const SizedBox(height: 4),
              _buildTextField('Enter your full name', controller: currentPatient.fullNameCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Age'),
                        const SizedBox(height: 4),
                        _buildTextField('Enter your age', keyboardType: TextInputType.number, controller: currentPatient.ageCtrl),
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
                        _buildDropdown(
                          'Select gender', 
                          ['Female', 'Male', 'Other'],
                          currentPatient.gender,
                          (val) => setState(() => currentPatient.gender = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLabel('Blood type'),
              const SizedBox(height: 4),
              _buildDropdown(
                'Select blood type', 
                ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                currentPatient.bloodType,
                (val) => setState(() => currentPatient.bloodType = val),
              ),
              const SizedBox(height: 12),
              _buildLabel('Additional notes'),
              const SizedBox(height: 4),
              _buildTextField(
                'Allergies, conditions...',
                maxLines: 2,
                controller: currentPatient.notesCtrl,
              ),
              const SizedBox(height: 16),
              
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8),
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
                        _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: currentPatient.minHrCtrl),
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
                        _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: currentPatient.maxHrCtrl),
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
                        _buildSuffixTextField('%', keyboardType: TextInputType.number, controller: currentPatient.minO2Ctrl),
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
                        _buildLabel('Minimum temperature'),
                        const SizedBox(height: 4),
                        _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: currentPatient.minTempCtrl),
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
                        _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: currentPatient.maxTempCtrl),
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentPatientIndex > 0 ? _previousPatient : widget.onBack,
                      icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF3B9784)),
                      label: const Text('Previous', style: TextStyle(color: Color(0xFF3B9784), fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B9784).withOpacity(0.05),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPatientIndex < 4 ? _nextPatient : widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Flexible(child: Text('Next', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildTextField(String hint, {int maxLines = 1, TextInputType? keyboardType, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildSuffixTextField(String suffix, {TextInputType? keyboardType, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.black54, fontSize: 13),
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
