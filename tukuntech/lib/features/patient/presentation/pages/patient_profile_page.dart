import 'package:flutter/material.dart';
import 'package:tukuntech/core/widgets/custom_bottom_nav.dart';
import 'package:tukuntech/features/patient/presentation/widgets/patient_profile_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/settings_body.dart';
import 'package:tukuntech/features/patient/presentation/widgets/support_body.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 0; // Pestaña actual del BottomNav

  // Controla si se muestra Settings, Support o el contenido normal (Profile)
  String? _activeOverlayView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ─────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CareBand',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'PERSONAL',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3B9784),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 18),
          ),
        ),
        actions: [
          // ── Toggle Side Bar (Menú Desplegable) ─────────────────
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.black54,
              size: 26,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            offset: const Offset(0, 50),
            onSelected: (String value) {
              setState(() {
                _activeOverlayView = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.black54, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'support',
                child: Row(
                  children: [
                    Icon(Icons.support_agent, color: Colors.black54, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Support',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── Body ───────────────────────────────────────────────────
      body: SafeArea(
        child: _activeOverlayView == 'settings'
            ? const SettingsBody()
            : _activeOverlayView == 'support'
            ? const SupportBody()
            : IndexedStack(
                index: _currentIndex,
                children: const [
                  ProfileBody(), // El perfil del paciente
                ],
              ),
      ),

      // ── Bottom Nav ─────────────────────────────────────────────
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _activeOverlayView =
                null; // Cierra ajustes si tocas la barra inferior
          });
        },
      ),
    );
  }
}
