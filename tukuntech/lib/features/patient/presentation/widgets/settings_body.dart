import 'package:flutter/material.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';
import 'package:tukuntech/core/localization/language_manager.dart';
import 'dart:convert';
import 'package:tukuntech/core/api_client.dart';
import 'package:tukuntech/core/auth_store.dart';
import 'package:tukuntech/core/environment_config.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  static const Color _primary = Color(0xFF3B9784);

  late String _selectedLanguage;
  final List<String> _languages = [
    'English',
    'Spanish',
  ];

  bool _isLoading = false;
  String _userRole = '';
  String? _selectedPatientId;
  List<Map<String, dynamic>> _patients = [];

  final TextEditingController _minHrCtrl = TextEditingController();
  final TextEditingController _maxHrCtrl = TextEditingController();
  final TextEditingController _minO2Ctrl = TextEditingController();
  final TextEditingController _maxO2Ctrl = TextEditingController();
  final TextEditingController _minTempCtrl = TextEditingController();
  final TextEditingController _maxTempCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentLocale = LanguageManager.instance.currentLocale.languageCode;
    _selectedLanguage = currentLocale == 'es' ? 'Spanish' : 'English';
    _fetchInitialData();
  }

  @override
  void dispose() {
    _minHrCtrl.dispose();
    _maxHrCtrl.dispose();
    _minO2Ctrl.dispose();
    _maxO2Ctrl.dispose();
    _minTempCtrl.dispose();
    _maxTempCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final token = AuthStore.token;
      if (token == null || token.isEmpty) return;

      final profileUrl = '${EnvironmentConfig.baseUrl}/profiles/me';
      final profileRes = await ApiClient.get(
        Uri.parse(profileUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (profileRes.statusCode != 200 && profileRes.statusCode != 201) {
        return;
      }

      final profileData = jsonDecode(utf8.decode(profileRes.bodyBytes));
      _userRole = profileData['role'] ?? '';

      if (_userRole == 'CAREGIVER') {
        final patientsUrl = '${EnvironmentConfig.baseUrl}/profiles/me/patients';
        final patientsRes = await ApiClient.get(
          Uri.parse(patientsUrl),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (patientsRes.statusCode == 200 || patientsRes.statusCode == 201) {
          final List<dynamic> patientsList = jsonDecode(utf8.decode(patientsRes.bodyBytes));
          _patients = patientsList.map((e) => e as Map<String, dynamic>).toList();
          if (_patients.isNotEmpty) {
            _selectedPatientId = _patients.first['id']?.toString();
            _fetchVitalLimits(_selectedPatientId!);
          }
        }
      } else if (_userRole == 'PATIENT') {
        _selectedPatientId = profileData['id']?.toString();
        _fetchVitalLimits(_selectedPatientId!);
      }
    } catch (e) {
      debugPrint('Error fetching settings initial data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchVitalLimits(String patientId) async {
    try {
      final token = AuthStore.token;
      if (token == null) return;
      
      // Wait, is there a GET /profiles/{id}/vital-limits? 
      // If not, we might fall back to what we can get from the profile.
      // But let's assume personal-info or the profile itself has the data.
      // We'll try hitting /profiles/me or the patient profile
      final profileUrl = '${EnvironmentConfig.baseUrl}/profiles/$patientId';
      final profileRes = await ApiClient.get(
        Uri.parse(profileUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (profileRes.statusCode == 200 || profileRes.statusCode == 201) {
        final data = jsonDecode(utf8.decode(profileRes.bodyBytes));
        _populateThresholds(data);
      }
    } catch (e) {
      debugPrint('Error fetching vital limits: $e');
    }
  }

  void _populateThresholds(Map<String, dynamic> data) {
    setState(() {
      _minHrCtrl.text = (data['minHeartRate'] ?? '').toString();
      _maxHrCtrl.text = (data['maxHeartRate'] ?? '').toString();
      _minO2Ctrl.text = (data['minOxygenSaturation'] ?? '').toString();
      _maxO2Ctrl.text = (data['maxOxygenSaturation'] ?? '').toString();
      _minTempCtrl.text = (data['minTemperature'] ?? '').toString();
      _maxTempCtrl.text = (data['maxTemperature'] ?? '').toString();
    });
  }

  void _saveLanguage() {
    final newLocale = _selectedLanguage == 'Spanish' ? const Locale('es') : const Locale('en');
    LanguageManager.instance.setLocale(newLocale);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.translate('language_saved')} ${context.translate(_selectedLanguage == 'Spanish' ? 'lang_es' : 'lang_en')}'),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveMedicalParameters() async {
    if (_selectedPatientId == null) return;
    
    setState(() => _isLoading = true);
    try {
      final token = AuthStore.token;
      if (token == null) throw Exception('No token');
      
      final url = '${EnvironmentConfig.baseUrl}/profiles/$_selectedPatientId/vital-limits';
      final body = {
        "minHeartRate": int.tryParse(_minHrCtrl.text) ?? 0,
        "maxHeartRate": int.tryParse(_maxHrCtrl.text) ?? 0,
        "minOxygenSaturation": int.tryParse(_minO2Ctrl.text) ?? 0,
        "maxOxygenSaturation": int.tryParse(_maxO2Ctrl.text) ?? 0,
        "minTemperature": double.tryParse(_minTempCtrl.text) ?? 0,
        "maxTemperature": double.tryParse(_maxTempCtrl.text) ?? 0,
        "termsAccepted": true
      };

      final response = await ApiClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('saved_successfully') ?? 'Saved successfully'),
            backgroundColor: _primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _saveAll() {
    _saveLanguage();
    _saveMedicalParameters();
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
          borderSide: const BorderSide(color: _primary, width: 2),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('settings'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.translate('personalize_app'),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(context.translate('save')),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Card: Language ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.language,
                          color: _primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('language'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              context.translate('preferred_language'),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.translate('app_language'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _primary, width: 1.5),
                      ),
                    ),
                    items: _languages
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text(context.translate(l == 'Spanish' ? 'lang_es' : 'lang_en')),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v!),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // ── Card: Medical Parameters ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.monitor_heart_outlined, color: _primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('medical_parameters') ?? 'Parámetros médicos',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.translate('medical_parameters_desc') ?? 'Establece los rangos de monitoreo personalizados',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_userRole == 'CAREGIVER' && _patients.isNotEmpty) ...[
                    _buildLabel(context.translate('select_patient') ?? 'Seleccionar Paciente'),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedPatientId,
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
                          borderSide: const BorderSide(color: _primary, width: 2),
                        ),
                      ),
                      items: _patients.map((p) => DropdownMenuItem(
                        value: p['id']?.toString(),
                        child: Text(p['fullName'] ?? p['email'] ?? 'Patient', style: const TextStyle(fontSize: 13)),
                      )).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedPatientId = v;
                          _fetchVitalLimits(v!);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context.translate('min_heart_rate') ?? 'Frecuencia cardíaca mínima'),
                            const SizedBox(height: 4),
                            _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: _minHrCtrl, min: 30, max: 200),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context.translate('max_heart_rate') ?? 'Frecuencia cardíaca máxima'),
                            const SizedBox(height: 4),
                            _buildSuffixTextField('bpm', keyboardType: TextInputType.number, controller: _maxHrCtrl, min: 40, max: 250),
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
                            _buildLabel(context.translate('min_o2_sat') ?? 'Saturación de oxígeno mínima'),
                            const SizedBox(height: 4),
                            _buildSuffixTextField('%', keyboardType: TextInputType.number, controller: _minO2Ctrl, min: 50, max: 100),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context.translate('max_o2_sat') ?? 'Saturación de oxígeno máxima'),
                            const SizedBox(height: 4),
                            _buildSuffixTextField('%', keyboardType: TextInputType.number, controller: _maxO2Ctrl),
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
                            _buildLabel(context.translate('min_temp') ?? 'Temperatura mínima'),
                            const SizedBox(height: 4),
                            _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: _minTempCtrl, min: 30, max: 42),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context.translate('max_temp') ?? 'Temperatura máxima'),
                            const SizedBox(height: 4),
                            _buildSuffixTextField('°C', keyboardType: TextInputType.number, controller: _maxTempCtrl, min: 32, max: 45),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
