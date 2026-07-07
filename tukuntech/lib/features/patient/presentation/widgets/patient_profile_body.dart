import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tukuntech/core/auth_store.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

// ── Modelos locales ────────────────────────────────────────────────────────────
class EmergencyContact {
  String? internalId;
  TextEditingController nameCtrl;
  TextEditingController relationCtrl;
  TextEditingController phoneCtrl;

  EmergencyContact({
    this.internalId,
    required String name,
    required String relation,
    required String phone,
  }) : nameCtrl = TextEditingController(text: name),
       relationCtrl = TextEditingController(text: relation),
       phoneCtrl = TextEditingController(text: phone);

  void dispose() {
    nameCtrl.dispose();
    relationCtrl.dispose();
    phoneCtrl.dispose();
  }
}

// ── Contenido del Perfil (Perspectiva Paciente) ────────────────────────────────
class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  static const Color _primary = Color(0xFF3B9784);

  // ── Datos del paciente (Perspectiva única) ────────────────────
  final Map<String, dynamic> _patientData = {
    'initials': 'EM',
    'name': 'Eleanor Marsh',
    'age': '68',
    'gender': 'Female',
    'address': 'Av. siempre viva 235',
    'bloodType': 'A+',
  };

  // ── Campos de información personal ──────────────────────────
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _addressCtrl;
  String _gender = 'OTHER';
  String _bloodType = 'A_POSITIVE';

  // ── Contactos de emergencia ──────────────────────────────────
  final List<EmergencyContact> _contacts = [];

  bool _isLoading = true;
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: '');
    _ageCtrl = TextEditingController(text: '');
    _addressCtrl = TextEditingController(text: '');
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final token = AuthStore.token;
      if (token == null) throw Exception("No token");

      final String baseUrl = EnvironmentConfig.baseUrl;

      final res = await http.get(
        Uri.parse('$baseUrl/profiles/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (mounted) {
          setState(() {
            _patientId = data['id'];
            _patientData['name'] = data['fullName'] ?? '';
            if (data['age'] != null) {
              _patientData['age'] = data['age'].toString();
            } else if (data['birthDate'] != null) {
              final birthDate = DateTime.tryParse(data['birthDate']);
              if (birthDate != null) {
                _patientData['age'] = (DateTime.now().year - birthDate.year).toString();
              }
            }
            
            String rawGender = data['gender'] ?? 'OTHER';
            _gender = ['MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'].contains(rawGender) ? rawGender : 'OTHER';
            _patientData['gender'] = _gender;

            _patientData['address'] = data['address'] ?? '';
            _patientData['dni'] = data['dni'] ?? '';
            _patientData['notes'] = data['notes'] ?? '';

            String rawBlood = data['bloodType'] ?? 'A_POSITIVE';
            _bloodType = rawBlood;
            _patientData['bloodType'] = _bloodType;

            List<String> parts = _patientData['name']!.trim().split(' ');
            String ini = '';
            if (parts.isNotEmpty && parts[0].isNotEmpty) ini += parts[0][0].toUpperCase();
            if (parts.length > 1 && parts[1].isNotEmpty) ini += parts[1][0].toUpperCase();
            if (ini.isNotEmpty) _patientData['initials'] = ini;

            _nameCtrl.text = _patientData['name']!;
            _ageCtrl.text = _patientData['age']!;
            _addressCtrl.text = _patientData['address']!;

            _contacts.clear();
            if (data['emergencyContacts'] != null) {
              for (var c in data['emergencyContacts']) {
                _contacts.add(EmergencyContact(
                  internalId: c['internalId'],
                  name: c['name'] ?? '',
                  relation: c['relationship'] ?? '',
                  phone: c['phoneNumber'] ?? '',
                ));
              }
            }
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to fetch profile");
      }
    } catch (e) {
      print("Error fetching profile: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    for (var contact in _contacts) {
      contact.dispose();
    }
    super.dispose();
  }

  // ── Guardar información personal ────────────────────────────
  Future<void> _savePersonalInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = AuthStore.token;
      if (token == null) throw Exception("No token found");

      final String baseUrl = EnvironmentConfig.baseUrl;



      final body = jsonEncode({
        'fullName': _nameCtrl.text.trim(),
        'dni': _patientData['dni'] ?? '',
        'gender': _gender,
        'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
        'bloodType': _bloodType,
        'address': _addressCtrl.text.trim(),
        'notes': _patientData['notes'] ?? '',
      });

      final res = await http.put(
        Uri.parse('$baseUrl/profiles/$_patientId/personal-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        await _fetchProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('changes_saved_success')),
              backgroundColor: _primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception("Failed to update profile: ${res.statusCode}");
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.translate('error_saving_changes')}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addEmergencyContact(String name, String relation, String phone, BuildContext ctx) async {
    if (_patientId == null) return;
    try {
      final token = AuthStore.token;
      if (token == null) throw Exception("No token");

      final String baseUrl = EnvironmentConfig.baseUrl;
      final body = jsonEncode({
        'name': name,
        'relationship': relation.isEmpty ? 'FAMILY' : relation.toUpperCase(),
        'phoneNumber': phone,
      });

      final res = await http.post(
        Uri.parse('$baseUrl/profiles/$_patientId/emergency-contacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.translate('changes_saved_success')), backgroundColor: _primary));
        }
        await _fetchProfile(); // Refresh to get the new internalId
      } else {
        throw Exception("Failed to add contact");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${context.translate('error_saving_changes')}: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ── Modal: agregar contacto de emergencia ───────────────────
  void _showAddContactModal() {
    final modalNameCtrl = TextEditingController();
    final modalRelationCtrl = TextEditingController();
    final modalPhoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('add_emergency_contact'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.translate('enter_emergency_info'),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: _primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _field(context.translate('name'), modalNameCtrl),
                const SizedBox(height: 12),
                _field(context.translate('relation'), modalRelationCtrl),
                const SizedBox(height: 12),
                _field(
                  context.translate('phone'),
                  modalPhoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          context.translate('cancel'),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (modalNameCtrl.text.trim().isEmpty) return;
                          _addEmergencyContact(
                            modalNameCtrl.text.trim(),
                            modalRelationCtrl.text.trim(),
                            modalPhoneCtrl.text.trim(),
                            ctx
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(context.translate('save_changes')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Eliminar contacto ────────────────────────────────────────
  Future<void> _deleteContact(int index) async {
    final contact = _contacts[index];
    
    if (contact.internalId != null && _patientId != null) {
      try {
        final token = AuthStore.token;
        if (token == null) throw Exception("No token");

        final res = await http.delete(
          Uri.parse('${EnvironmentConfig.baseUrl}/profiles/$_patientId/emergency-contacts/${contact.internalId}'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 5));

        if (res.statusCode != 200 && res.statusCode != 204) {
          throw Exception("Failed to delete contact");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
        return; // No lo eliminamos visualmente si falló
      }
    }

    setState(() {
      contact.dispose();
      _contacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // ── Título ──────────────────────────────────────────────
        Text(
          context.translate('my_profile'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.translate('profile_subtitle'),
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 20),

        // ── Card principal del paciente ──────────────────────────
        _card(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  _patientData['initials']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _patientData['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_patientData['age']} ${context.translate('years_old')}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Card: Información personal ──────────────────────────
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('personal_info'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _field(context.translate('full_name'), _nameCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      context.translate('age'),
                      _ageCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate('gender'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: _primary, width: 1.5)),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                          ),
                          items: [
                            DropdownMenuItem(value: 'MALE', child: Text(context.translate('male'), overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'FEMALE', child: Text(context.translate('female'), overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'OTHER', child: Text(context.translate('other'), overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'PREFER_NOT_TO_SAY', child: Text(context.translate('prefer_not_to_say'), overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(context.translate('address'), _addressCtrl),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('blood_type'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _bloodType,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                        borderSide: const BorderSide(
                          color: _primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A_POSITIVE', child: Text('A+')),
                      DropdownMenuItem(value: 'A_NEGATIVE', child: Text('A-')),
                      DropdownMenuItem(value: 'B_POSITIVE', child: Text('B+')),
                      DropdownMenuItem(value: 'B_NEGATIVE', child: Text('B-')),
                      DropdownMenuItem(value: 'AB_POSITIVE', child: Text('AB+')),
                      DropdownMenuItem(value: 'AB_NEGATIVE', child: Text('AB-')),
                      DropdownMenuItem(value: 'O_POSITIVE', child: Text('O+')),
                      DropdownMenuItem(value: 'O_NEGATIVE', child: Text('O-')),
                      DropdownMenuItem(value: 'UNKNOWN', child: Text('UNKNOWN')),
                    ],
                    onChanged: (v) => setState(() => _bloodType = v!),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePersonalInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  context.translate('save_changes'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Card: Contactos de emergencia ───────────────────────
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_in_talk_outlined,
                    color: _primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate('emergency_contacts'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.translate('add_contacts_here'),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddContactModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_add_alt_1,
                            size: 16,
                            color: _primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.translate('add'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: _primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_contacts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    context.translate('no_contacts'),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ),
              ...List.generate(_contacts.length, (i) {
                final c = _contacts[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _field(context.translate('name'), c.nameCtrl)),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _deleteContact(i),
                            child: const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Icon(
                                Icons.delete_outline,
                                size: 22,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _field(context.translate('relation'), c.relationCtrl)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              context.translate('phone'),
                              c.phoneCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ── Helpers Visuales ───────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: child,
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFF3B9784),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
        ),
      ],
    );
  }
}
