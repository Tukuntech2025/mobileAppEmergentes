import 'package:flutter/material.dart';
import 'package:tukuntech/core/localization/app_localizations.dart';
import 'package:tukuntech/features/patient/presentation/pages/device_form_page.dart';

class DeviceBody extends StatelessWidget {
  final String email;
  const DeviceBody({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        children: [
          Text(
            context.translate('my_device'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.translate('device_status_subtitle'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildDeviceCard(context),
          const SizedBox(height: 24),
          _buildInfoAlert(context),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceFormPage(initialEmail: email),
            ),
          );
        },
        backgroundColor: const Color(0xFF3B9784),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Top section (Green gradient)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE0F2F1), // Light teal
                  const Color(0xFFB2DFDB).withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B9784), // Primary teal
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.memory, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate('device_name'),
                        style: TextStyle(color: Colors.grey[700], fontSize: 11),
                      ),
                      const Text(
                        'CB-9F32-01',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${context.translate('version')} 1.0.5',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.translate('online'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Details section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatusRow(context.translate('battery'), '88%', Icons.battery_full, 0.88),
                const Divider(height: 24),
                _buildStatusRow(context.translate('wifi'), context.translate('strong'), Icons.wifi, 0.9),
                const Divider(height: 24),
                _buildStatusRow(context.translate('sync'), context.translate('good'), Icons.check_circle_outline, 0.95),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Icon(icon, color: const Color(0xFF3B9784), size: 18),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFE0F2F1),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B9784)),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildInfoAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F8), // Light blue
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF4FC3F7), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.translate('device_normal_alert'),
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
