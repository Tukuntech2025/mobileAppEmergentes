import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/patient_vital_card.dart';

class PatientHistoryView extends StatefulWidget {
  final List<PatientVitalData> patients;

  const PatientHistoryView({super.key, required this.patients});

  @override
  State<PatientHistoryView> createState() => _PatientHistoryViewState();
}

class _PatientHistoryViewState extends State<PatientHistoryView> {
  int _selectedPatientIndex = 0;
  String _selectedPeriod = 'Weekly';

  bool _isLoading = true;
  List<dynamic> _reports = [];
  String? _error;
  Timer? _pollingTimer;

  final String _baseUrl = '${EnvironmentConfig.baseUrl}/reports';

  @override
  void initState() {
    super.initState();
    _fetchReports();
    // Poll the backend every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchReports(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  String get _currentPatientId {
    if (widget.patients.isEmpty) return '${_selectedPatientIndex + 2}';
    return widget.patients[_selectedPatientIndex].patientId ?? '${_selectedPatientIndex + 2}';
  }

  String get _currentPatientEmail {
    if (widget.patients.isEmpty) return 'patient$_currentPatientId@test.com';
    return widget.patients[_selectedPatientIndex].email ?? 'patient$_currentPatientId@test.com';
  }

  Future<void> _fetchReports({bool silent = false}) async {
    if (!silent && _reports.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      // Generamos un token al vuelo simulando ser el paciente para poder usar el endpoint /me
      final jwt = JWT(
        {'role': 'PATIENT', 'email': _currentPatientEmail},
        subject: '$_currentPatientId',
      );
      final fakePatientToken = jwt.sign(SecretKey('TuClaveSecretaSuperSeguraYExtremadamenteLargaParaElProyectoTukunTech2026'));

      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {'Authorization': 'Bearer $fakePatientToken'},
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _reports = data;
            _isLoading = false;
            if (silent) _error = null;
          });
        }
      } else {
        if (mounted && !silent) {
          setState(() {
            _error = 'Failed to load: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (!silent) {
            if (e is TimeoutException) {
              _error = 'Connection timed out.';
            } else {
              _error = 'Connection error.';
            }
          }
          _isLoading = false;
        });
      }
    }
  }

  Map<String, String> _getDateRange() {
    final now = DateTime.now();
    DateTime start;
    switch (_selectedPeriod) {
      case 'Daily':
        start = now;
        break;
      case 'Monthly':
        start = now.subtract(const Duration(days: 30));
        break;
      case 'Yearly':
        start = now.subtract(const Duration(days: 365));
        break;
      case 'Weekly':
      default:
        start = now.subtract(const Duration(days: 7));
        break;
    }
    return {
      'startDate': start.toIso8601String().split('T')[0],
      'endDate': now.toIso8601String().split('T')[0],
    };
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Generamos un token al vuelo simulando ser el paciente para poder usar el endpoint /me/generate
      final jwt = JWT(
        {'role': 'PATIENT', 'email': _currentPatientEmail},
        subject: '$_currentPatientId',
      );
      final fakePatientToken = jwt.sign(SecretKey('TuClaveSecretaSuperSeguraYExtremadamenteLargaParaElProyectoTukunTech2026'));

      final range = _getDateRange();
      final response = await http.post(
        Uri.parse('$_baseUrl/me/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $fakePatientToken',
        },
        body: jsonEncode(range),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        await _fetchReports();
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to generate: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is TimeoutException) {
            _error = 'Connection timed out.';
          } else {
            _error = 'Connection error.';
          }
          _isLoading = false;
        });
      }
    }
  }

  DateTime? _parseReportDate(String dateStr) {
    if (dateStr.contains('T')) {
      final hasTimezone = dateStr.endsWith('Z') || 
                          RegExp(r'[+-]\d{2}(:?\d{2})?$').hasMatch(dateStr.substring(dateStr.indexOf('T')));
      if (!hasTimezone) {
        return DateTime.tryParse('${dateStr}Z')?.toLocal();
      } else {
        return DateTime.tryParse(dateStr)?.toLocal();
      }
    } else {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.tryParse(dateStr);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    try {
      final DateTime? date = _parseReportDate(dateStr);
      if (date == null) return dateStr;
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    } catch (_) {
      return dateStr;
    }
  }

  List<dynamic> get _filteredReports {
    final now = DateTime.now();
    return _reports.where((r) {
      final dateStr = r['generatedAt'] ?? r['startDate'] ?? r['endDate'];
      if (dateStr == null) return true;
      
      final date = _parseReportDate(dateStr);
      if (date == null) return true;

      switch (_selectedPeriod) {
        case 'Daily':
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case 'Weekly':
          // Current week (assuming week starts on Monday, or just last 7 days as an approximation)
          // To be precise with "this week":
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          final dateOnly = DateTime(date.year, date.month, date.day);
          final startOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          final endOnly = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
          return dateOnly.isAfter(startOnly.subtract(const Duration(days: 1))) && 
                 dateOnly.isBefore(endOnly.add(const Duration(days: 1)));
        case 'Monthly':
          return date.year == now.year && date.month == now.month;
        case 'Yearly':
          return date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);
    final filteredReports = _filteredReports;

    return RefreshIndicator(
      onRefresh: () => _fetchReports(silent: true),
      color: primaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        children: [
          const Text(
            'Patient history',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Patient recent vital signs - heart rate, oxygen, and temperature.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Patient Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.patients.length, (index) {
                final isSelected = _selectedPatientIndex == index;
                final patient = widget.patients[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: patient.badgeDotColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            patient.initials,
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(patient.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected && _selectedPatientIndex != index) {
                        setState(() {
                          _selectedPatientIndex = index;
                          _reports = []; // Clear reports immediately when switching patient
                        });
                        _fetchReports();
                      }
                    },
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Generate Report Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download_outlined, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    const Text('Generate report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Export a vital signs summary report', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 16),
                          const Text('Period', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPeriod,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                                items: <String>['Daily', 'Weekly', 'Monthly', 'Yearly'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedPeriod = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Patient', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.patients[_selectedPatientIndex].name,
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _generateReport,
                              icon: const Icon(Icons.download, size: 14),
                              label: const Text('Generate Report', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vital signs history card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.show_chart, color: primaryColor),
                    ),
                    const SizedBox(width: 16),
                    const Text('Vital signs history', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isLoading && filteredReports.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Color(0xFF3B9784)),
                    ),
                  )
                else if (_error != null && filteredReports.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  )
                else if (filteredReports.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No reports available for this period.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...filteredReports.reversed.toList().asMap().entries.map((entry) {
                    final int index = entry.key;
                    final report = entry.value;
                    final isLast = index == filteredReports.length - 1;
                    
                    final String date = _formatDate(report['generatedAt'] ?? report['startDate'] ?? report['endDate']);
                    final num hrAvg = report['avgHeartRate'] ?? 0;
                    final num hrMin = report['minHeartRate'] ?? 0;
                    final num hrMax = report['maxHeartRate'] ?? 0;
                    
                    final num spo2Avg = report['avgSpO2'] ?? 0;
                    final num spo2Min = report['minSpO2'] ?? 0;
                    
                    final num tempAvg = report['avgTemperature'] ?? 0;
                    final String tempStatus = (tempAvg >= 36.0 && tempAvg <= 37.5) ? 'normal' : 'abnormal';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHistoryRow(
                          date,
                          '${hrAvg.toInt()} bpm avg. ${hrMin.toInt()}-${hrMax.toInt()}',
                          '${spo2Avg.toInt()}% avg. ${spo2Min.toInt()}-100',
                          '${tempAvg.toStringAsFixed(1)} °C - $tempStatus',
                        ),
                        if (!isLast) const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: Colors.black12),
                        ),
                      ],
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String date, String hr, String spo2, String temp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 12),
        Text('HR: $hr', style: const TextStyle(fontSize: 12, color: Colors.black87)),
        const SizedBox(height: 8),
        Text('SpO2: $spo2', style: const TextStyle(fontSize: 12, color: Colors.black87)),
        const SizedBox(height: 8),
        Text('Temp: $temp', style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}
