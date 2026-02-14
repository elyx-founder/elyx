import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_controller.dart';
import '../services/haptic_service.dart';
import '../theme/level_theme.dart';

class WarScreen extends StatefulWidget {
  const WarScreen({super.key});

  @override
  State<WarScreen> createState() => _WarScreenState();
}

class _WarScreenState extends State<WarScreen> with TickerProviderStateMixin {
  late AnimationController _globeController;
  late AnimationController _scanController;

  // Data animations
  double _userFocus = 0.0;
  double _rivalFocus = 0.0;

  @override
  void initState() {
    super.initState();
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Trigger data animation on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _userFocus = 0.92;
        _rivalFocus = 0.88;
      });
    });
  }

  @override
  void dispose() {
    _globeController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<UserProgressController>();
    final theme = ElyxTheme.current(context);
    final color = theme.color; // Use theme color for the "Warzone" feel

    return Container(
      color: Colors.black.withValues(alpha: 0.95), // Deep opaque background
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // 1. HEADER
              Center(
                child: Text(
                  "DISCIPLINE WARZONE",
                  style: TextStyle(
                      color: Colors.redAccent, // Always Red for War context? Or dynamic. Let's stick to Red for "War" vibe as per image.
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(color: Colors.redAccent.withValues(alpha: 0.6), blurRadius: 15)
                      ]
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. CENTRAL HOLOGRAPHIC GLOBE & COMPARISON
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The Globe
                    AnimatedBuilder(
                      animation: _globeController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(200, 200),
                          painter: _HologramGlobePainter(
                            rotation: _globeController.value * 2 * math.pi,
                            color: Colors.redAccent,
                          ),
                        );
                      },
                    ),

                    // Cross Lines (The X visual from reference)
                    CustomPaint(
                      size: Size.infinite,
                      painter: _TacticalCrossPainter(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),

                    // Left Side: USER Data
                    Positioned(
                      left: 0,
                      child: _buildSideStats(
                        label: "USER: ALEX",
                        subLabel: "USLO LEGENDS",
                        alignLeft: true,
                        color: color,
                      ),
                    ),

                    // Right Side: RIVAL Data
                    Positioned(
                      right: 0,
                      child: _buildSideStats(
                        label: "RIVAL: ANATA",
                        subLabel: "GROUP ALPHA",
                        alignLeft: false,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. GLOBAL TEXT
              Center(
                child: Text(
                  "GLOBAL COMPARISON",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
              ),

              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 150,
                  height: 1,
                  color: Colors.white24,
                ),
              ),

              const SizedBox(height: 10),

              // 4. DECRYPT TEXT (Effect)
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    "XJOI WRJ20 RJ209 RJ209 JR209 RJ209", // Decryption visuals
                    style: TextStyle(
                      color: Colors.white12,
                      fontSize: 8,
                      letterSpacing: 2,
                      fontFamily: "Courier",
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 5. DETAILED STAT BARS (The "Objective Tracker" area)
              Expanded(
                child: Row(
                  children: [
                    // Left Column (User)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("OBJECTIVE TRACKER", alignLeft: true),
                          const SizedBox(height: 15),
                          _buildTechBar(
                              label: "FOCUS RATING",
                              percent: _userFocus,
                              color: color,
                              alignLeft: true
                          ),
                          const SizedBox(height: 15),
                          _buildTechBar(
                              label: "DISCIPLINE STREAK",
                              percent: 0.85,
                              color: color,
                              alignLeft: true
                          ),
                          const SizedBox(height: 15),
                          _buildTechBar(
                              label: "WEALTH GAINED",
                              percent: 0.16,
                              color: color,
                              alignLeft: true,
                              displayValue: "+16%"
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Right Column (Rival)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSectionHeader("FACTION CLASH", alignLeft: false),
                          const SizedBox(height: 15),
                          _buildTechBar(
                              label: "FOCUS RATING",
                              percent: _rivalFocus,
                              color: Colors.redAccent,
                              alignLeft: false
                          ),
                          const SizedBox(height: 15),
                          _buildTechBar(
                              label: "MISSION COMPLETE",
                              percent: 0.75,
                              color: Colors.redAccent,
                              alignLeft: false
                          ),
                          const SizedBox(height: 15),
                          _buildTechBar(
                              label: "WEALTH GAINED",
                              percent: 0.15,
                              color: Colors.redAccent,
                              alignLeft: false,
                              displayValue: "+15%"
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 6. VOICE COMMAND BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 100.0), // Space for dock
                child: GestureDetector(
                  onTap: () {
                    HapticService.medium();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2), // Sharp corners
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_none, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "VOICE COMMAND",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required bool alignLeft}) {
    return Column(
      crossAxisAlignment: alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 80,
          height: 1,
          color: Colors.white24,
        )
      ],
    );
  }

  Widget _buildSideStats({
    required String label,
    required String subLabel,
    required bool alignLeft,
    required Color color
  }) {
    return Column(
      crossAxisAlignment: alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          subLabel,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 9,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignLeft) ...[
              Icon(Icons.shield_outlined, color: color, size: 14),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            if (alignLeft) ...[
              const SizedBox(width: 6),
              Icon(Icons.shield_outlined, color: color, size: 14),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTechBar({
    required String label,
    required double percent,
    required Color color,
    required bool alignLeft,
    String? displayValue,
  }) {
    return Column(
      crossAxisAlignment: alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alignLeft) Icon(Icons.bolt, color: color, size: 10),
            if (alignLeft) SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
            if (!alignLeft) SizedBox(width: 4),
            if (!alignLeft) Icon(Icons.bolt, color: color, size: 10),
          ],
        ),
        const SizedBox(height: 6),
        // Bar Container
        Row(
          mainAxisAlignment: alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutExpo,
              builder: (context, value, _) {
                return Container(
                  width: 100 * value, // Max width relative
                  height: 6,
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)
                      ]
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              displayValue ?? "${(percent * 100).toInt()}%",
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
        const SizedBox(height: 2),
        // Thin background line
        Container(
          width: 130, // Max width
          height: 1,
          color: Colors.white12,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// VFX PAINTERS
// -----------------------------------------------------------------------------

class _HologramGlobePainter extends CustomPainter {
  final double rotation;
  final Color color;

  _HologramGlobePainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Globe Outline
    paint.color = color.withValues(alpha: 0.1);
    canvas.drawCircle(center, radius, paint);

    // Draw Longitude Lines (Rotating)
    paint.color = color.withValues(alpha: 0.4);
    for (int i = 0; i < 5; i++) {
      double angle = rotation + (i * math.pi / 5);
      // Project 3D circle to 2D ellipse based on rotation
      double widthFactor = math.cos(angle);

      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 2 * widthFactor, height: radius * 2),
        paint,
      );
    }

    // Draw Latitude Lines
    paint.color = color.withValues(alpha: 0.2);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 0.8),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 1.6),
      paint,
    );

    // Continents (Abstract Glitchy Shapes)
    final glitchPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Simulating a "continent" with a path
    final path = Path();
    path.moveTo(center.dx - 20, center.dy - 10);
    path.lineTo(center.dx + 10, center.dy - 30);
    path.lineTo(center.dx + 30, center.dy + 10);
    path.lineTo(center.dx - 10, center.dy + 40);
    path.close();

    canvas.drawPath(path, glitchPaint);
  }

  @override
  bool shouldRepaint(covariant _HologramGlobePainter oldDelegate) => true;
}

class _TacticalCrossPainter extends CustomPainter {
  final Color color;
  _TacticalCrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final center = Offset(w/2, h/2);

    // Draw the "X" connecting stats to globe
    final path = Path();

    // Top Left to Center
    path.moveTo(0, h * 0.2);
    path.lineTo(w * 0.3, h * 0.4);

    // Top Right to Center
    path.moveTo(w, h * 0.2);
    path.lineTo(w * 0.7, h * 0.4);

    // Bottom Left to Center
    path.moveTo(0, h * 0.8);
    path.lineTo(w * 0.3, h * 0.6);

    // Bottom Right to Center
    path.moveTo(w, h * 0.8);
    path.lineTo(w * 0.7, h * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
