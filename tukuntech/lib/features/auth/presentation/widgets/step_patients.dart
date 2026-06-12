import 'package:flutter/material.dart';

class PatientData {
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();
  String? gender;
  String? bloodType;

  void dispose() {
    fullNameCtrl.dispose();
    ageCtrl.dispose();
    notesCtrl.dispose();
  }
}

class StepPatients extends StatefulWidget {
  const StepPatients({super.key});

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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentPatientIndex > 0 ? _previousPatient : null,
                      icon: Icon(Icons.arrow_back, size: 16, color: _currentPatientIndex > 0 ? primaryColor : Colors.grey),
                      label: Text('Previous', style: TextStyle(color: _currentPatientIndex > 0 ? primaryColor : Colors.grey, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor.withOpacity(0.05),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPatientIndex < 4 ? _nextPatient : null,
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
