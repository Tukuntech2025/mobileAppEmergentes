import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tukuntech/core/api_client.dart';
import 'package:tukuntech/core/auth_store.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

class EmergencyContactData {
  String? internalId;
  String name;
  String relation;
  String phone;

  EmergencyContactData({
    this.internalId,
    required this.name,
    required this.relation,
    required this.phone,
  });
}

class EmergencyContactController {
  String? internalId;
  TextEditingController nameCtrl;
  TextEditingController relationCtrl;
  TextEditingController phoneCtrl;

  EmergencyContactController({
    this.internalId,
    required String name,
    required String relation,
    required String phone,
  })  : nameCtrl = TextEditingController(text: name),
        relationCtrl = TextEditingController(text: relation),
        phoneCtrl = TextEditingController(text: phone);

  void dispose() {
    nameCtrl.dispose();
    relationCtrl.dispose();
    phoneCtrl.dispose();
  }
}

class PatientProfileData {
  String id;
  String initials;
  String name;
  String age;
  String gender;
  String address;
  String bloodType;
  String dni;
  String notes;
  List<EmergencyContactData> contacts;

  PatientProfileData({
    required this.id,
    required this.initials,
    required this.name,
    required this.age,
    required this.gender,
    required this.address,
    required this.bloodType,
    this.dni = '',
    this.notes = '',
    required this.contacts,
  });
}

class CaregiverProfileBody extends StatefulWidget {
  final void Function(String name, String initials)? onPatientAdded;

  const CaregiverProfileBody({super.key, this.onPatientAdded});

  @override
  State<CaregiverProfileBody> createState() => _CaregiverProfileBodyState();
}

class _CaregiverProfileBodyState extends State<CaregiverProfileBody> {
  static const Color _primary = Color(0xFF3B9784);

  int _selectedPatientIndex = 0;
  bool _isLoading = true;
  List<PatientProfileData> _patients = [];

  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _addressCtrl;
  String _gender = 'OTHER';
  String _bloodType = 'A_POSITIVE';
  List<EmergencyContactController> _contactControllers = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: '');
    _ageCtrl = TextEditingController(text: '');
    _addressCtrl = TextEditingController(text: '');
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final token = AuthStore.token;
      if (token == null) throw Exception("No token");

      final res = await ApiClient.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/profiles/me/patients'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        final List<PatientProfileData> loaded = [];

        for (var p in data) {
          final String name = p['fullName'] ?? 'Unknown Patient';
          
          List<String> parts = name.trim().split(' ');
          String initials = 'PT';
          if (parts.isNotEmpty) {
            initials = '';
            if (parts[0].isNotEmpty) initials += parts[0][0].toUpperCase();
            if (parts.length > 1 && parts[1].isNotEmpty) initials += parts[1][0].toUpperCase();
          }
          if (initials.isEmpty) initials = 'PT';

          String ageStr = '30';
          if (p['age'] != null) {
            ageStr = p['age'].toString();
          } else if (p['birthDate'] != null) {
            final birthDate = DateTime.tryParse(p['birthDate']);
            if (birthDate != null) {
              ageStr = (DateTime.now().year - birthDate.year).toString();
            }
          }

          String rawGender = p['gender'] ?? 'OTHER';
          String gender = ['MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'].contains(rawGender) ? rawGender : 'OTHER';

          String rawBlood = p['bloodType'] ?? 'A_POSITIVE';
          String blood = rawBlood;

          final List<EmergencyContactData> contacts = [];
          if (p['emergencyContacts'] != null) {
            for (var c in p['emergencyContacts']) {
              contacts.add(EmergencyContactData(
                internalId: c['internalId'],
                name: c['name'] ?? '',
                relation: c['relationship'] ?? '',
                phone: c['phoneNumber'] ?? '',
              ));
            }
          }

          loaded.add(PatientProfileData(
            id: p['id'] ?? '',
            initials: initials,
            name: name,
            age: ageStr,
            gender: gender,
            address: p['address'] ?? '',
            bloodType: blood,
            dni: p['dni'] ?? '',
            notes: p['notes'] ?? '',
            contacts: contacts,
          ));
        }

        if (mounted) {
          setState(() {
            _patients = loaded;
            if (_selectedPatientIndex >= _patients.length) {
              _selectedPatientIndex = 0;
            }
            if (_patients.isNotEmpty) {
              _disposeControllers();
              _initControllersForSelectedPatient();
            }
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching caregiver patient profiles: $e");
      final List<PatientProfileData> fallback = [
        PatientProfileData(
          id: '',
          initials: 'EM',
          name: 'Eleanor Marsh',
          age: '68',
          gender: 'FEMALE',
          address: 'Av. siempre viva 235',
          bloodType: 'A_POSITIVE',
          contacts: [
            EmergencyContactData(name: 'Sara Marsh', relation: 'Daughter', phone: '940999345'),
            EmergencyContactData(name: 'Sara Marsh', relation: 'Daughter', phone: '840989345'),
          ],
        ),
        PatientProfileData(
          id: '',
          initials: 'CM',
          name: 'Coco Manlin',
          age: '45',
          gender: 'MALE',
          address: '123 Fake Street',
          bloodType: 'O_POSITIVE',
          contacts: [],
        ),
        PatientProfileData(
          id: '',
          initials: 'MM',
          name: 'Miguel Montana',
          age: '50',
          gender: 'MALE',
          address: '456 Another St',
          bloodType: 'B_NEGATIVE',
          contacts: [],
        ),
      ];
      if (mounted) {
        setState(() {
          _patients = fallback;
          if (_selectedPatientIndex >= _patients.length) {
            _selectedPatientIndex = 0;
          }
          if (_patients.isNotEmpty) {
            _disposeControllers();
            _initControllersForSelectedPatient();
          }
          _isLoading = false;
        });
      }
    }
  }

  void _initControllersForSelectedPatient() {
    final patient = _patients[_selectedPatientIndex];
    _nameCtrl = TextEditingController(text: patient.name);
    _ageCtrl = TextEditingController(text: patient.age);
    _gender = patient.gender;
    _addressCtrl = TextEditingController(text: patient.address);
    _bloodType = patient.bloodType;

    _contactControllers = patient.contacts
        .map((c) => EmergencyContactController(
              internalId: c.internalId,
              name: c.name,
              relation: c.relation,
              phone: c.phone,
            ))
        .toList();
  }

  void _disposeControllers() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    for (var c in _contactControllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _onPatientSelected(int index) {
    if (_selectedPatientIndex == index) return;

    setState(() {
      _selectedPatientIndex = index;
      _disposeControllers();
      _initControllersForSelectedPatient();
    });
  }

  Future<void> _savePersonalInfo() async {
    if (_patients.isEmpty) return;
    final patient = _patients[_selectedPatientIndex];

    try {
      final token = AuthStore.token;
      if (token == null) throw Exception("No token");

      final body = jsonEncode({
        'fullName': _nameCtrl.text.trim(),
        'dni': patient.dni,
        'gender': _gender,
        'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
        'bloodType': _bloodType,
        'address': _addressCtrl.text.trim(),
        'notes': patient.notes,
      });

      final res = await ApiClient.put(
        Uri.parse('${EnvironmentConfig.baseUrl}/profiles/${patient.id}/personal-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('changes_saved_success')),
              backgroundColor: _primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        await _fetchPatients();
      } else {
        throw Exception("Failed to save: ${res.statusCode}");
      }
    } catch (e) {
      if (mounted) {
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

  Future<void> _addEmergencyContact(String patientId, String name, String relation, String phone, BuildContext ctx) async {
    try {
      final token = AuthStore.token;
      if (token == null) throw Exception("No token");

      final String baseUrl = EnvironmentConfig.baseUrl;
      final body = jsonEncode({
        'name': name,
        'relationship': relation.isEmpty ? 'FAMILY' : relation.toUpperCase(),
        'phoneNumber': phone,
      });

      final res = await ApiClient.post(
        Uri.parse('$baseUrl/profiles/$patientId/emergency-contacts'),
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
        await _fetchPatients();
      } else {
        throw Exception("Failed to add contact");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${context.translate('error_saving_changes')}: $e'), backgroundColor: Colors.red));
      }
    }
  }

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
                        final patientId = _patients[_selectedPatientIndex].id;
                        if (patientId.isEmpty) return;
                        _addEmergencyContact(
                          patientId,
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

  Future<void> _deleteContact(int index) async {
    final c = _contactControllers[index];
    final patientId = _patients[_selectedPatientIndex].id;

    if (c.internalId != null && patientId.isNotEmpty) {
      try {
        final token = AuthStore.token;
        if (token == null) throw Exception("No token");

        final res = await ApiClient.delete(
          Uri.parse('${EnvironmentConfig.baseUrl}/profiles/$patientId/emergency-contacts/${c.internalId}'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 5));

        if (res.statusCode != 200 && res.statusCode != 204) {
          throw Exception("Failed to delete contact");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
        return; // do not remove visually if api fails
      }
    }

    setState(() {
      c.dispose();
      _contactControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primary,
        ),
      );
    }
    if (_patients.isEmpty) {
      return Center(
        child: Text(
          context.translate('no_patients_assigned'),
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }
    final currentPatient = _patients[_selectedPatientIndex];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // ── Título ──────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('patient_profile'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.translate('caregiver_profile_sub'),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Selector de Pacientes ─────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_patients.length, (index) {
              final isSelected = index == _selectedPatientIndex;
              final p = _patients[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _onPatientSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _primary.withOpacity(0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? _primary : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          p.name,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
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
                  currentPatient.initials,
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
                    currentPatient.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentPatient.age} ${context.translate('years_old')}',
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
                    value: ['A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE', 'AB_POSITIVE', 'AB_NEGATIVE', 'O_POSITIVE', 'O_NEGATIVE', 'UNKNOWN'].contains(_bloodType) ? _bloodType : 'UNKNOWN',
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
              if (_contactControllers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    context.translate('no_contacts'),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ),
              ...List.generate(_contactControllers.length, (i) {
                final c = _contactControllers[i];
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
                color: _primary,
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

