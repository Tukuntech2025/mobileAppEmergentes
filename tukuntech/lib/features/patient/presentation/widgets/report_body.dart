import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportBody extends StatefulWidget {
  const ReportBody({super.key});

  @override
  State<ReportBody> createState() => _ReportBodyState();
}

class _ReportBodyState extends State<ReportBody> {
  String _selectedPeriod = 'Weekly';
  bool _isLoading = true;
  List<dynamic> _reports = [];
  String? _error;
  Timer? _pollingTimer;

  // Use 10.0.2.2 for Android emulator, otherwise localhost
  final String _baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8080/api/v1/reports' 
      : 'http://localhost:8080/api/v1/reports';

  @override
  void initState() {
    super.initState();
    _fetchReports();
    // Poll the backend every 5 seconds to keep the history updated
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchReports(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchReports({bool silent = false}) async {
    if (!silent && _reports.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final response = await http.get(Uri.parse('$_baseUrl/patient/1')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _reports = data;
            _isLoading = false;
            if (silent) _error = null; // Clear error if silent fetch succeeds
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
              _error = 'Connection timed out. Backend is not reachable.';
            } else {
              _error = 'Connection error. Check your backend.';
            }
          }
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$_baseUrl/patient/1/generate')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 || response.statusCode == 201) {
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
            _error = 'Connection timed out. Backend is not reachable.';
          } else {
            _error = 'Connection error. Check your backend.';
          }
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    try {
      final DateTime date = DateTime.parse(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _fetchReports(silent: true),
      color: const Color(0xFF3B9784),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        physics: const AlwaysScrollableScrollPhysics(), // Ensure scrolling for RefreshIndicator
        children: [
          const Text(
            'My history',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your recent vital signs - heart rate, oxygen, and temperature.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildGenerateReportCard(),
          const SizedBox(height: 24),
          _buildHistoryCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenerateReportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), // Light teal
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF3B9784), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_downward, // A generic down arrow to match the design
                  color: Color(0xFF3B9784),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate report',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Export a vital signs summary report',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Period',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
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
                    border: Border.all(color: Colors.white),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 16),
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
                onPressed: _isLoading ? null : _generateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B9784),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text(
                  'Generate Report',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4F8), // Light blueish
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Color(0xFF3B9784),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Vital signs history',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading && _reports.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Color(0xFF3B9784)),
              ),
            )
          else if (_error != null && _reports.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else if (_reports.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No reports available.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ..._reports.reversed.toList().asMap().entries.map((entry) {
              final int index = entry.key;
              final report = entry.value;
              final isLast = index == _reports.length - 1;
              
              // Map API fields (assuming camelCase)
              final String date = _formatDate(report['generatedAt'] ?? report['startDate'] ?? report['endDate']);
              final num hrAvg = report['avgHeartRate'] ?? 0;
              final num hrMin = report['minHeartRate'] ?? 0;
              final num hrMax = report['maxHeartRate'] ?? 0;
              
              final num spo2Avg = report['avgSpo2'] ?? 0;
              final num spo2Min = report['minSpo2'] ?? 0;
              
              final num tempAvg = report['avgTemperature'] ?? 0;
              final String tempStatus = (tempAvg >= 36.0 && tempAvg <= 37.5) ? 'normal' : 'abnormal';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHistoryItem(
                    date: date,
                    hrText: '${hrAvg.toInt()} bpm avg. ${hrMin.toInt()}-${hrMax.toInt()}',
                    spo2Text: '${spo2Avg.toInt()}% avg. ${spo2Min.toInt()}-100',
                    tempText: '${tempAvg.toStringAsFixed(1)} °C - $tempStatus',
                  ),
                  if (!isLast) const Divider(height: 24),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String hrText,
    required String spo2Text,
    required String tempText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('HR: ', hrText),
        const SizedBox(height: 4),
        _buildDetailRow('SpO2: ', spo2Text),
        const SizedBox(height: 4),
        _buildDetailRow('Temp: ', tempText),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

