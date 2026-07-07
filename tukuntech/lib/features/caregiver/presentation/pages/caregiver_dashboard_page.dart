import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tukuntech/core/api_client.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:tukuntech/core/auth_store.dart';
import 'package:tukuntech/features/auth/presentation/pages/role_selection_page.dart';
import 'package:tukuntech/core/widgets/custom_bottom_nav.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/patient_vital_card.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/device_status_card.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/patient_history_view.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/caregiver_profile_body.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/caregiver_reports_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/settings_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/support_body.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';

class CaregiverDashboardPage extends StatefulWidget {
  const CaregiverDashboardPage({super.key});

  @override
  State<CaregiverDashboardPage> createState() => _CaregiverDashboardPageState();
}

class _CaregiverDashboardPageState extends State<CaregiverDashboardPage> {
  int _currentIndex = 0;
  String? _drawerSection;
  bool _isLoading = true;
  List<PatientVitalData> _patients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final token = AuthStore.token;
      if (token == null) throw Exception("No token found");

      final response = await ApiClient.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/profiles/me/patients'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<PatientVitalData> fetchedPatients = [];
        
        for (int i = 0; i < data.length; i++) {
          final p = data[i];
          final String name = p['fullName'] ?? 'Unknown Patient';
          final String id = p['id']?.toString() ?? '${i + 2}';
          final String email = p['email'] ?? 'patient$id@test.com';
          
          String initials = 'PT';
          List<String> parts = name.trim().split(' ');
          if (parts.isNotEmpty) {
            initials = '';
            if (parts[0].isNotEmpty) initials += parts[0][0].toUpperCase();
            if (parts.length > 1 && parts[1].isNotEmpty) initials += parts[1][0].toUpperCase();
          }
          if (initials.isEmpty) initials = 'PT';

          String subtitleKey = 'greeting_calm';
          String badgeTextKey = 'calm_stable';
          Color badgeColor = const Color(0xFFA5D6A7).withOpacity(0.5);
          Color badgeDotColor = const Color(0xFF4CAF50);
          String heartRate = '74 bpm';
          String oxygen = '98%';
          String temperature = '36.7 °C';

          if (name.toLowerCase().contains('miguel') || name.toLowerCase().contains('montana')) {
            subtitleKey = 'alert_low_oxygen';
            badgeTextKey = 'low_oxygen';
            badgeColor = Colors.red.withOpacity(0.2);
            badgeDotColor = Colors.red;
            heartRate = '74 bpm';
            oxygen = '87%';
            temperature = '36.7 °C';
          } else if (name.toLowerCase().contains('coco') || name.toLowerCase().contains('manlin')) {
            subtitleKey = 'greeting_calm';
            badgeTextKey = 'slight_hr_variability';
            badgeColor = Colors.blue.withOpacity(0.2);
            badgeDotColor = Colors.blue;
            heartRate = '99 bpm';
            oxygen = '98%';
            temperature = '36.7 °C';
          }

          // Fetch device data
          String? deviceId;
          String? deviceModel;
          int? batteryLevel;
          String? wifiNetwork;
          bool? isOnline;
          String? lastSyncedAt;

          try {
            final dashRes = await ApiClient.get(
              Uri.parse('${EnvironmentConfig.baseUrl}/dashboard/caregiver/patient/$id'),
              headers: {'Authorization': 'Bearer $token'},
            ).timeout(const Duration(seconds: 5));
            if (dashRes.statusCode == 200) {
              final dashData = jsonDecode(utf8.decode(dashRes.bodyBytes));
              final deviceData = dashData['device'];
              if (deviceData != null) {
                deviceId = deviceData['deviceId'];
                deviceModel = deviceData['model'];
                batteryLevel = deviceData['batteryLevel'];
                wifiNetwork = deviceData['wifiNetwork'];
                isOnline = deviceData['isOnline'];
                lastSyncedAt = deviceData['lastSyncedAt'];
              }
              final vitalsData = dashData['currentVitals'];
              if (vitalsData != null) {
                heartRate = '${vitalsData['heartRate']} bpm';
                oxygen = '${vitalsData['oxygenSaturation']}%';
                temperature = '${vitalsData['temperature']} °C';
              }
            }
          } catch (e) {
            debugPrint("Error fetching dashboard for $id: $e");
          }

          fetchedPatients.add(
            PatientVitalData(
              initials: initials,
              titlePrefixKey: badgeTextKey.contains('oxygen') ? 'warning' : 'hello',
              name: name,
              subtitleKey: subtitleKey,
              badgeTextKey: badgeTextKey,
              badgeColor: badgeColor,
              badgeDotColor: badgeDotColor,
              heartRate: heartRate,
              heartRateSubtitleKey: 'resting_normal',
              oxygen: oxygen,
              oxygenSubtitleKey: 'spo2',
              temperature: temperature,
              temperatureSubtitleKey: 'normal',
              patientId: id,
              email: email,
              deviceId: deviceId,
              deviceModel: deviceModel,
              batteryLevel: batteryLevel,
              wifiNetwork: wifiNetwork,
              isOnline: isOnline,
              lastSyncedAt: lastSyncedAt,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _patients = fetchedPatients;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching caregiver patients: $e");
      final List<PatientVitalData> fallbackPatients = [
        PatientVitalData(
          initials: 'EM',
          titlePrefixKey: 'hello',
          name: 'Eleanor Marsh',
          subtitleKey: 'greeting_calm',
          badgeTextKey: 'calm_stable',
          badgeColor: const Color(0xFFA5D6A7).withOpacity(0.5),
          badgeDotColor: const Color(0xFF4CAF50),
          heartRate: '74 bpm',
          heartRateSubtitleKey: 'resting_normal',
          oxygen: '98%',
          oxygenSubtitleKey: 'spo2',
          temperature: '36.7 °C',
          temperatureSubtitleKey: 'normal',
          patientId: '2',
          email: 'patient2@test.com',
        ),
        PatientVitalData(
          initials: 'CM',
          titlePrefixKey: 'hello',
          name: 'Coco Manlin',
          subtitleKey: 'greeting_calm',
          badgeTextKey: 'slight_hr_variability',
          badgeColor: Colors.blue.withOpacity(0.2),
          badgeDotColor: Colors.blue,
          heartRate: '99 bpm',
          heartRateSubtitleKey: 'resting_normal',
          oxygen: '98%',
          oxygenSubtitleKey: 'spo2',
          temperature: '36.7 °C',
          temperatureSubtitleKey: 'normal',
          patientId: '3',
          email: 'patient3@test.com',
        ),
        PatientVitalData(
          initials: 'MM',
          titlePrefixKey: 'warning',
          name: 'Miguel Montana',
          subtitleKey: 'alert_low_oxygen',
          badgeTextKey: 'low_oxygen',
          badgeColor: Colors.red.withOpacity(0.2),
          badgeDotColor: Colors.red,
          heartRate: '74 bpm',
          heartRateSubtitleKey: 'resting_normal',
          oxygen: '87%',
          oxygenSubtitleKey: 'spo2',
          temperature: '36.7 °C',
          temperatureSubtitleKey: 'normal',
          patientId: '4',
          email: 'patient4@test.com',
        ),
      ];
      if (mounted) {
        setState(() {
          _patients = fallbackPatients;
          _isLoading = false;
        });
      }
    }
  }

  void _addNewPatient(String name, String initials) {
    setState(() {
      _patients.add(
        PatientVitalData(
          initials: initials,
          titlePrefixKey: 'hello',
          name: name,
          subtitleKey: 'waiting_device_conn',
          badgeTextKey: 'pending',
          badgeColor: Colors.grey.withOpacity(0.2),
          badgeDotColor: Colors.grey,
          heartRate: '-- bpm',
          heartRateSubtitleKey: 'no_data',
          oxygen: '--%',
          oxygenSubtitleKey: 'spo2',
          temperature: '-- °C',
          temperatureSubtitleKey: 'no_data',
        ),
      );
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(context.translate('confirm_logout')),
          content: Text(context.translate('logout_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.translate('cancel'), style: const TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                AuthStore.token = null;
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionPage(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(context.translate('log_out')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => _showLogoutConfirmation(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TukunTech',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.translate('caregiver_role'),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black54, size: 28),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  context.translate('menu'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Color(0xFF3B9784)),
                title: Text(
                  context.translate('settings'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  setState(() => _drawerSection = 'settings');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.support_agent_outlined, color: Color(0xFF3B9784)),
                title: Text(
                  context.translate('support'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  setState(() => _drawerSection = 'support');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _drawerSection == 'settings'
            ? const SettingsBody()
            : _drawerSection == 'support'
                ? const SupportBody()
                : _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B9784)))
                    : IndexedStack(
                        index: _currentIndex,
                        children: [
                            ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              children: [
                                Text(
                                  context.translate('vital_signs'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.translate('activity_today'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                ..._patients.map((patient) => PatientVitalCard(data: patient)).toList(),
                                
                                const SizedBox(height: 12),
                              ],
                            ),
                            ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              children: [
                                Text(
                                  context.translate('patient_devices'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.translate('device_status_sub'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                ..._patients.map((patient) => DeviceStatusCard(data: patient)).toList(),
                                
                                const SizedBox(height: 16),
                                
                                // Bottom Info Message
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: Colors.blue, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          context.translate('device_normal_alert'),
                                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                            PatientHistoryView(patients: _patients),
                            CaregiverProfileBody(onPatientAdded: _addNewPatient),
                            CaregiverReportsBody(patients: _patients),
                          ],
                        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _drawerSection = null;
          });
        },
      ),
    );
  }
}

