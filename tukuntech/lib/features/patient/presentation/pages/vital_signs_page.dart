import 'package:flutter/material.dart';

class VitalSignsPage extends StatelessWidget {
  const VitalSignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              'Patient',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vital Signs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                'Detail view of today\'s activity',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(flex: 4, child: _buildGreetingCard()),
              const SizedBox(height: 6),
              Expanded(flex: 3, child: _buildHeartRateCard()),
              const SizedBox(height: 6),
              Expanded(flex: 3, child: _buildOxygenCard()),
              const SizedBox(height: 6),
              Expanded(flex: 3, child: _buildTemperatureCard()),
              const SizedBox(height: 6),
              Expanded(flex: 4, child: _buildLiveEcgCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE0F2F1), // Light teal
            const Color(0xFFB2DFDB).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B9784), // Primary teal
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
                  mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3B9784).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF3B9784).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B9784),
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
          )
        ],
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), // Light teal
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Heart rate',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Icon(Icons.favorite_border, color: Color(0xFF3B9784), size: 18),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            '74 bpm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Resting - normal',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildOxygenCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F8), // Light blue
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oxygen',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Icon(Icons.air, color: Color(0xFF4FC3F7), size: 18),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            '98%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'SpO2',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5E8), // Light yellow/beige
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temperature',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Icon(Icons.thermostat, color: Color(0xFFFFCA28), size: 18),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            '36.7 °C',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Normal',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveEcgCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_border, color: Color(0xFF3B9784), size: 16),
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
          // ECG Mock Graph
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: CustomPaint(
                painter: EcgPainter(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class EcgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = const Color(0xFFE0F2F1).withOpacity(0.5)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw ECG line
    final linePaint = Paint()
      ..color = const Color(0xFF3B9784)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    double currentX = 0;
    final middleY = size.height / 2;

    path.moveTo(0, middleY);

    // Create a repeating ECG pattern
    while (currentX < size.width) {
      // Flat segment
      path.lineTo(currentX + 10, middleY);
      currentX += 10;
      if (currentX >= size.width) break;

      // P wave (small bump)
      path.quadraticBezierTo(currentX + 2.5, middleY - 5, currentX + 5, middleY);
      currentX += 5;
      if (currentX >= size.width) break;

      // Flat segment
      path.lineTo(currentX + 5, middleY);
      currentX += 5;
      if (currentX >= size.width) break;

      // Q wave (small dip)
      path.lineTo(currentX + 2, middleY + 5);
      currentX += 2;
      if (currentX >= size.width) break;

      // R wave (tall peak)
      path.lineTo(currentX + 4, middleY - 20); // reduced peak height slightly
      currentX += 4;
      if (currentX >= size.width) break;

      // S wave (deep dip)
      path.lineTo(currentX + 4, middleY + 12); // reduced dip height slightly
      currentX += 4;
      if (currentX >= size.width) break;

      // Back to baseline
      path.lineTo(currentX + 2, middleY);
      currentX += 2;
      if (currentX >= size.width) break;

      // Flat segment
      path.lineTo(currentX + 8, middleY);
      currentX += 8;
      if (currentX >= size.width) break;

      // T wave (medium bump)
      path.quadraticBezierTo(currentX + 5, middleY - 8, currentX + 10, middleY);
      currentX += 10;
      if (currentX >= size.width) break;
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
