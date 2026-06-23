import 'package:flutter/material.dart';

class StepPersonal extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepPersonal({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('Full name'),
          const SizedBox(height: 2),
          _buildTextField('Enter your full name'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Age'),
                    const SizedBox(height: 4),
                    _buildTextField('Enter your age', keyboardType: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Gender'),
                    const SizedBox(height: 4),
                    _buildDropdown('Select gender', ['Select gender', 'Female', 'Male', 'Other']),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLabel('Blood type'),
          const SizedBox(height: 4),
          _buildDropdown('Select blood type', ['Select blood type', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
          const SizedBox(height: 8),
          _buildLabel('Additional notes'),
          const SizedBox(height: 4),
          _buildTextField(
            'Allergies, conditions, anything we should know...',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
          const SizedBox(height: 16),
          
          // Medical parameters header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.monitor_heart_outlined, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Medical parameters',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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

          // Heart Rate
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Minimum heart rate'),
                    const SizedBox(height: 4),
                    _buildTextFieldWithSuffix('bpm'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Maximum heart rate'),
                    const SizedBox(height: 4),
                    _buildTextFieldWithSuffix('bpm'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Oxygen
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Minimum oxygen saturation'),
                    const SizedBox(height: 4),
                    _buildTextFieldWithSuffix('%'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Maximum oxygen saturation'),
                    const SizedBox(height: 4),
                    _buildTextFieldWithSuffix('%'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Temperature
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Minimum temperature'),
                    const SizedBox(height: 4),
                    _buildTextFieldWithSuffix('°C'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Maximum temperature'),
                    const SizedBox(height: 4),
                    _buildTextFieldWithSuffix('°C'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline, size: 16, color: Colors.black54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These values belong to the patient and will be used to evaluate readings and alerts. Patients and caregivers cannot edit them.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
                label: const Text(
                  'Back',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF86C1B1), // Light green for Continue button when not fully enabled or just based on screenshot
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Flexible(
                        child: Text(
                          'Continue',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.check, size: 18),
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

  Widget _buildTextField(String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
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
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildDropdown(String value, List<String> items) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            style: TextStyle(
              fontSize: 14,
              color: item.startsWith('Select') ? Colors.black54 : Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: (val) {},
    );
  }

  Widget _buildTextFieldWithSuffix(String suffix) {
    return TextField(
      keyboardType: TextInputType.number,
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
              Text(suffix, style: const TextStyle(color: Colors.black54, fontSize: 14)),
            ],
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
}
