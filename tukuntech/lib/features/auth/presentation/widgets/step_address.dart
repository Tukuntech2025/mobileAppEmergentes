import 'package:flutter/material.dart';

class StepAddress extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepAddress({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Address',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter your address',
              hintStyle: const TextStyle(color: Colors.black45, fontWeight: FontWeight.normal),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          // Mock Map Area
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E3DF), // Standard map background color
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Grid pattern to simulate map streets
                Positioned.fill(
                  child: CustomPaint(
                    painter: MapGridPainter(),
                  ),
                ),
                // Map Pin
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.location_on, size: 40, color: Colors.redAccent.shade700),
                  ),
                ),
                // Leaflet Controls (+ / -)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.add, size: 20, color: Colors.black87),
                          ),
                        ),
                        Container(height: 1, width: 28, color: Colors.grey.shade300),
                        InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.remove, size: 20, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Attribution
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: Colors.white.withOpacity(0.8),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, color: Colors.blue), // mock leaflet icon
                        const SizedBox(width: 4),
                        const Text(
                          'Leaflet | © OpenStreetMap contributors',
                          style: TextStyle(fontSize: 9, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A simple painter to draw a grid background simulating a map
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0;

    final secondaryPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0;

    const spacing = 30.0;
    
    // Draw secondary grid
    for (double i = 0; i < size.width; i += spacing / 2) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), secondaryPaint);
    }
    for (double i = 0; i < size.height; i += spacing / 2) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), secondaryPaint);
    }

    // Draw main grid
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Draw a thick main road
    final roadPaint = Paint()
      ..color = const Color(0xFFF9D28B) // Yellowish road color
      ..strokeWidth = 6.0;
    canvas.drawLine(const Offset(0, 50), Offset(size.width, 150), roadPaint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
