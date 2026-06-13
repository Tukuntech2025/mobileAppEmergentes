import 'package:flutter/material.dart';
import 'package:tukuntech/features/auth/presentation/pages/role_selection_page.dart';
import 'package:tukuntech/core/widgets/custom_bottom_nav.dart';
import 'package:tukuntech/features/patient/presentation/widgets/device_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/report_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/patient_profile_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/settings_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/support_body.dart';

class VitalSignsPage extends StatefulWidget {
  const VitalSignsPage({super.key});

  @override
  State<VitalSignsPage> createState() => _VitalSignsPageState();
}

class _VitalSignsPageState extends State<VitalSignsPage> {
  static const Color _primary = Color(0xFF3B9784);
  static const Color _primaryLight = Color(0xFFE0F2F1);

  int _currentIndex = 0;

  // ── Drawer: sección activa ───────────────────────────────────
  // null = muestra los tabs del BottomNav, 'settings' = Settings, 'support' = Support
  String? _drawerSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),

      // ── AppBar ───────────────────────────────────────────────
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
              'patient', // O 'Patient' según la vista que uses
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        actions: [
          // ── Botón de las 3 rayitas que abre el Side Bar ───────
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black54, size: 28),
              onPressed: () {
                Scaffold.of(ctx).openEndDrawer();
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── Toggle Side Bar (End Drawer) ─────────────────────────
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón para cerrar el Drawer
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
              // Opción Settings
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: _primary),
                title: const Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  setState(() => _drawerSection = 'settings');
                  Navigator.pop(context); // Cierra el sidebar
                },
              ),
              // Opción Support
              ListTile(
                leading: const Icon(
                  Icons.support_agent_outlined,
                  color: _primary,
                ),
                title: const Text(
                  'Support',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  setState(() => _drawerSection = 'support');
                  Navigator.pop(context); // Cierra el sidebar
                },
              ),
            ],
          ),
        ),
      ),

      // ── Body principal ───────────────────────────────────────
      body: SafeArea(
        child: _drawerSection == 'settings'
            ? const SettingsBody()
            : _drawerSection == 'support'
            ? const SupportBody()
            : IndexedStack(
                index: _currentIndex,
                children: [
                  // 0: Vital Signs
                  _buildVitalSignsTab(),
                  // 1: Device
                  const DeviceBody(),
                  // 2: Report
                  const ReportBody(),
                  // 3: Profile (Tu archivo modificado anteriormente)
                  const ProfileBody(),
                ],
              ),
      ),

      // ── Bottom Nav ────────────────────────────────────────────
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _drawerSection =
                null; // Al tocar abajo, salimos de settings/support y volvemos a los tabs
          });
        },
      ),
    );
  }

  // ── Vital Signs tab ──────────────────────────────────────────
  Widget _buildVitalSignsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      children: [
        const Text(
          'Vital Signs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          'Detail view of today\'s activity',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildGreetingCard(),
        const SizedBox(height: 12),
        _buildMetricCard(
          label: 'Heart rate',
          value: '74 bpm',
          sub: 'Resting - normal',
          color: _primaryLight,
          icon: Icons.favorite_border,
          iconColor: _primary,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          label: 'Oxygen',
          value: '98%',
          sub: 'SpO2',
          color: const Color(0xFFE8F4F8),
          icon: Icons.air,
          iconColor: const Color(0xFF4FC3F7),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          label: 'Temperature',
          value: '36.7 °C',
          sub: 'Normal',
          color: const Color(0xFFF9F5E8),
          icon: Icons.thermostat,
          iconColor: const Color(0xFFFFCA28),
        ),
        const SizedBox(height: 12),
        _buildLiveEcgCard(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryLight, _primaryLight.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'EM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    const Text(
                      'Eleanor Marsh',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'all good! You are feeling calm.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primary.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Calm and stable',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLiveEcgCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_border, color: _primary, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Heart rate - live',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Real-time electrocardiogram waveform from the wearable',
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 100,
            child: CustomPaint(painter: _EcgPainter()),
          ),
        ],
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE0F2F1).withOpacity(0.5)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF3B9784)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    double x = 0;
    final mid = size.height / 2;
    path.moveTo(0, mid);
    while (x < size.width) {
      path.lineTo(x + 10, mid);
      x += 10;
      if (x >= size.width) break;
      path.quadraticBezierTo(x + 2.5, mid - 5, x + 5, mid);
      x += 5;
      if (x >= size.width) break;
      path.lineTo(x + 5, mid);
      x += 5;
      if (x >= size.width) break;
      path.lineTo(x + 2, mid + 5);
      x += 2;
      if (x >= size.width) break;
      path.lineTo(x + 4, mid - 20);
      x += 4;
      if (x >= size.width) break;
      path.lineTo(x + 4, mid + 12);
      x += 4;
      if (x >= size.width) break;
      path.lineTo(x + 2, mid);
      x += 2;
      if (x >= size.width) break;
      path.lineTo(x + 8, mid);
      x += 8;
      if (x >= size.width) break;
      path.quadraticBezierTo(x + 5, mid - 8, x + 10, mid);
      x += 10;
      if (x >= size.width) break;
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
