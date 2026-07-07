import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tukuntech/core/api_client.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/patient_vital_card.dart';
import 'package:tukuntech/features/caregiver/data/models/caregiver_report_model.dart';
import 'package:intl/intl.dart';

class CaregiverReportsBody extends StatefulWidget {
  final List<PatientVitalData> patients;

  const CaregiverReportsBody({super.key, required this.patients});

  @override
  State<CaregiverReportsBody> createState() => _CaregiverReportsBodyState();
}

class _CaregiverReportsBodyState extends State<CaregiverReportsBody> {
  String? _selectedPatientId;
  late Future<List<CaregiverReportModel>> _reportsFuture;
  String _selectedPeriod = 'Weekly';
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.patients.isNotEmpty) {
      _selectedPatientId = widget.patients.first.patientId;
    }
    _fetchReports();
  }

  void _fetchReports() {
    if (_selectedPatientId != null && _selectedPatientId!.isNotEmpty) {
      _reportsFuture = _getReportsForPatient(_selectedPatientId!);
    } else {
      _reportsFuture = Future.value([]);
    }
  }

  Future<List<CaregiverReportModel>> _getReportsForPatient(String patientId) async {
    try {
      final url = Uri.parse('${EnvironmentConfig.baseUrl}/reports/caregiver/patient/$patientId');
      final response = await ApiClient.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => CaregiverReportModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      throw Exception('Error fetching reports: $e');
    }
  }

  void _onPatientChanged(String? newPatientId) {
    if (newPatientId != null && newPatientId != _selectedPatientId) {
      setState(() {
        _selectedPatientId = newPatientId;
        _fetchReports();
      });
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
    if (_selectedPatientId == null) return;
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      final range = _getDateRange();
      final url = Uri.parse('${EnvironmentConfig.baseUrl}/reports/caregiver/patient/$_selectedPatientId/generate');
      
      final response = await ApiClient.post(
        url,
        body: jsonEncode(range),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte generado exitosamente.'),
              backgroundColor: Color(0xFF3B9784),
            ),
          );
        }
        _fetchReports(); // Refrescar la lista de reportes
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al generar reporte: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Título ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reportes del Paciente',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Seleccione un paciente para ver su historial de reportes.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),

        // ── Selector de Paciente ─────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: widget.patients.map((patient) {
              final isSelected = patient.patientId == _selectedPatientId;
              const primaryColor = Color(0xFF3B9784);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _onPatientChanged(patient.patientId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            patient.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          patient.name,
                          style: TextStyle(
                            color: isSelected ? primaryColor : Colors.grey.shade600,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),

        // Generate Report Box
        if (_selectedPatientId != null && _selectedPatientId!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
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
                        child: const Icon(Icons.download_outlined, color: Color(0xFF3B9784)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Generar Reporte',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Genera un nuevo reporte del paciente con datos actualizados.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Periodo',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateReport,
                        icon: _isGenerating 
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.download, size: 14),
                        label: const Text(
                          'Generar',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B9784),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
        const SizedBox(height: 16),
        
        // Contenido de Reportes
        Expanded(
          child: _selectedPatientId == null || _selectedPatientId!.isEmpty
              ? const Center(child: Text('No hay ningún paciente seleccionado.'))
              : FutureBuilder<List<CaregiverReportModel>>(
                  future: _reportsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF3B9784)));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar los reportes.\nPor favor, intente de nuevo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Este paciente no tiene reportes generados.'),
                      );
                    }

                    final reports = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _fetchReports();
                        });
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          return _buildReportCard(reports[index]);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReportCard(CaregiverReportModel report) {
    final isCompleted = report.status == 'COMPLETED';
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    String formattedGeneratedAt = formatter.format(report.generatedAt);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado del Reporte
          Container(
            padding: const EdgeInsets.all(16),
            color: isCompleted ? const Color(0xFF3B9784).withOpacity(0.05) : Colors.orange.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reporte Semanal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.startDate} - ${report.endDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'Completado' : 'Fallido',
                    style: TextStyle(
                      color: isCompleted ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido Principal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isCompleted
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryStat(
                        icon: Icons.favorite,
                        iconColor: Colors.redAccent,
                        value: '${report.avgHeartRate ?? '--'}',
                        unit: 'bpm',
                        label: 'Ritmo Cardíaco',
                      ),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      _buildSummaryStat(
                        icon: Icons.air,
                        iconColor: Colors.blueAccent,
                        value: '${report.avgSpO2 ?? '--'}',
                        unit: '%',
                        label: 'Oxígeno',
                      ),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      _buildSummaryStat(
                        icon: Icons.thermostat,
                        iconColor: Colors.orange,
                        value: report.avgTemperature != null ? report.avgTemperature!.toStringAsFixed(1) : '--',
                        unit: '°C',
                        label: 'Temperatura',
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.orange[400], size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'El reporte no pudo generarse correctamente debido a la falta de datos suficientes en este periodo.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
          ),
          
          // Pie de Tarjeta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  'Generado el $formattedGeneratedAt',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const Spacer(),
                if (isCompleted)
                  Text(
                    'Ver detalles',
                    style: TextStyle(
                      color: const Color(0xFF3B9784),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String unit,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 10),
        ),
      ],
    );
  }
}
