import 'package:flutter/material.dart';

class PatientVitalData {
  final String initials;
  final String titlePrefix; // 'Hello' or 'WARNING'
  final String name;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color badgeDotColor;
  final String heartRate;
  final String heartRateSubtitle;
  final String oxygen;
  final String oxygenSubtitle;
  final String temperature;
  final String temperatureSubtitle;

  PatientVitalData({
    required this.initials,
    required this.titlePrefix,
    required this.name,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeDotColor,
    required this.heartRate,
    required this.heartRateSubtitle,
    required this.oxygen,
    required this.oxygenSubtitle,
    required this.temperature,
    required this.temperatureSubtitle,
  });
}

class PatientVitalCard extends StatelessWidget {
  final PatientVitalData data;

  const PatientVitalCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Gradient Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFC8E6C9), // Light green top
                  Colors.white.withOpacity(0.1), // Fade to white
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B9784),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        data.initials,
                        style: const TextStyle(
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
                            data.titlePrefix,
                            style: TextStyle(
                              color: data.titlePrefix == 'WARNING' ? Colors.red.shade700 : Colors.grey[600],
                              fontSize: 11,
                              fontWeight: data.titlePrefix == 'WARNING' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            data.name,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.subtitle,
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.badgeColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: data.badgeDotColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: data.badgeDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        data.badgeText,
                        style: TextStyle(
                          color: data.badgeDotColor == Colors.red ? Colors.white : (data.badgeDotColor == Colors.blue ? Colors.white : Colors.white),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Middle Stats Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    'Heart rate',
                    Icons.favorite_border,
                    data.heartRate,
                    data.heartRateSubtitle,
                    const Color(0xFF3B9784),
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildStatColumn(
                    'Oxigen',
                    Icons.air,
                    data.oxygen,
                    data.oxygenSubtitle,
                    const Color(0xFF3B9784),
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildStatColumn(
                    'Temperature',
                    Icons.thermostat,
                    data.temperature,
                    data.temperatureSubtitle,
                    Colors.orange.shade300,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // ECG Mock Graph
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: CustomPaint(
                painter: SmallEcgPainter(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bottom Device Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                const Text('Device', style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(width: 12),
                const Text('CB-8DF3-01', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const Spacer(),
                const Text('86%', style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(width: 4),
                const Icon(Icons.battery_full, color: Color(0xFF3B9784), size: 16),
                const SizedBox(width: 12),
                const Text('Strong', style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(width: 4),
                const Icon(Icons.wifi, color: Colors.blue, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStatColumn(String label, IconData icon, String value, String subtitle, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11), overflow: TextOverflow.ellipsis)),
            Icon(icon, color: iconColor, size: 14),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, fontSize: 11),
        ),
      ],
    );
  }
}

class SmallEcgPainter extends CustomPainter {
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
    double currentX = 0;
    final middleY = size.height / 2;

    path.moveTo(0, middleY);

    while (currentX < size.width) {
      path.lineTo(currentX + 5, middleY);
      currentX += 5;
      if (currentX >= size.width) break;

      path.lineTo(currentX + 2, middleY - 4);
      currentX += 2;
      path.lineTo(currentX + 2, middleY + 2);
      currentX += 2;
      path.lineTo(currentX + 2, middleY);
      currentX += 2;
      if (currentX >= size.width) break;

      path.lineTo(currentX + 5, middleY);
      currentX += 5;
      if (currentX >= size.width) break;

      path.lineTo(currentX + 3, middleY - 15);
      currentX += 3;
      path.lineTo(currentX + 3, middleY + 10);
      currentX += 3;
      path.lineTo(currentX + 3, middleY);
      currentX += 3;
      if (currentX >= size.width) break;

      path.lineTo(currentX + 6, middleY);
      currentX += 6;
      if (currentX >= size.width) break;

      path.quadraticBezierTo(currentX + 4, middleY - 6, currentX + 8, middleY);
      currentX += 8;
      if (currentX >= size.width) break;
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
