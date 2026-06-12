import 'package:flutter/material.dart';
import 'package:tukuntech/core/widgets/custom_bottom_nav.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/patient_vital_card.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/device_status_card.dart';
import 'package:tukuntech/features/caregiver/presentation/widgets/patient_history_view.dart';

class CaregiverDashboardPage extends StatefulWidget {
  const CaregiverDashboardPage({super.key});

  @override
  State<CaregiverDashboardPage> createState() => _CaregiverDashboardPageState();
}

class _CaregiverDashboardPageState extends State<CaregiverDashboardPage> {
  int _currentIndex = 0;

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
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
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
            const Center(child: Text('Profile')),
            const Center(child: Text('Reports')),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
