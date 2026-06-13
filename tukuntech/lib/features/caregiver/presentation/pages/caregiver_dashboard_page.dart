import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/role_selection_page.dart';
import 'package:tukuntech/core/widgets/custom_bottom_nav.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/patient_vital_card.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/device_status_card.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/patient_history_view.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/caregiver_profile_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/settings_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/support_body.dart';

class CaregiverDashboardPage extends StatefulWidget {
  const CaregiverDashboardPage({super.key});

  @override
  State<CaregiverDashboardPage> createState() => _CaregiverDashboardPageState();
}

class _CaregiverDashboardPageState extends State<CaregiverDashboardPage> {
  int _currentIndex = 0;
  String? _drawerSection;

  final List<PatientVitalData> mockPatients = [
    PatientVitalData(
      initials: 'EM',
      titlePrefix: 'Hello',
      name: 'Eleanor Marsh',
      subtitle: 'all good! You are feeling calm.',
      badgeText: 'Calm and stable',
      badgeColor: const Color(0xFFA5D6A7).withOpacity(0.5), // Light green
      badgeDotColor: const Color(0xFF4CAF50),
      heartRate: '74 bmp',
      heartRateSubtitle: 'Resting - normal',
      oxygen: '98%',
      oxygenSubtitle: 'SpO2',
      temperature: '36.7 °C',
      temperatureSubtitle: 'Normal',
    ),
    PatientVitalData(
      initials: 'CM',
      titlePrefix: 'Hello',
      name: 'Coco Manlin',
      subtitle: 'all good! You are feeling calm.',
      badgeText: 'Slight HR variability',
      badgeColor: Colors.blue.withOpacity(0.2), // Light blue
      badgeDotColor: Colors.blue,
      heartRate: '99 bmp',
      heartRateSubtitle: 'Resting - normal',
      oxygen: '98%',
      oxygenSubtitle: 'SpO2',
      temperature: '36.7 °C',
      temperatureSubtitle: 'Normal',
    ),
    PatientVitalData(
      initials: 'MM',
      titlePrefix: 'WARNING',
      name: 'Miguel Montana',
      subtitle: 'Alert! low oxygen',
      badgeText: 'Low Oxygen',
      badgeColor: Colors.red.withOpacity(0.2), // Light red
      badgeDotColor: Colors.red,
      heartRate: '74 bmp',
      heartRateSubtitle: 'Resting - normal',
      oxygen: '87%',
      oxygenSubtitle: 'SpO2',
      temperature: '36.7 °C',
      temperatureSubtitle: 'Normal',
    ),
  ];

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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const RoleSelectionPage(),
              ),
              (route) => false,
            );
          },
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
              'caregiver',
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Color(0xFF3B9784)),
                title: const Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  setState(() => _drawerSection = 'settings');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.support_agent_outlined, color: Color(0xFF3B9784)),
                title: const Text(
                  'Support',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                : IndexedStack(
                    index: _currentIndex,
                    children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              children: [
                const Text(
                  'Vital Signs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Detail view of today\'s activity',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                ...mockPatients.map((patient) => PatientVitalCard(data: patient)).toList(),
                
                const SizedBox(height: 12),
              ],
            ),
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              children: [
                const Text(
                  'Patient devices',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Status and conection details for your TukunTech IOT',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                ...mockPatients.map((patient) => DeviceStatusCard(data: patient)).toList(),
                
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
                      const Expanded(
                        child: Text(
                          "Your device is reporting normally. We'll notify you here if anything changes.",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
            PatientHistoryView(patients: mockPatients),
            const CaregiverProfileBody(),
            const Center(child: Text('Reports')),
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
