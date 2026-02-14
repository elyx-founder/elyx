import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_controller.dart';
import '../services/haptic_service.dart';
import '../theme/level_theme.dart';

class DeepWorkScreen extends StatefulWidget {
  const DeepWorkScreen({super.key});

  @override
  State<DeepWorkScreen> createState() => _DeepWorkScreenState();
}

class _DeepWorkScreenState extends State<DeepWorkScreen> with TickerProviderStateMixin {
  // Timer State
  Timer? _timer;
  static const int _defaultTime = 25 * 60; // 25 Minutes
  int _remainingSeconds = _defaultTime;
  bool _isActive = false;

  // Animations
  late AnimationController _breathingController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // Breathing Glow (The Ring)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Brainwave Frequency
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    HapticService.heavy();

    setState(() {
      _isActive = !_isActive;
    });

    if (_isActive) {
      // Speed up the wave when active
      _waveController.duration = const Duration(milliseconds: 1000);
      _waveController.repeat();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _completeSession();
        }
      });
    } else {
      // Slow down wave when paused
      _waveController.duration = const Duration(seconds: 3);
      _waveController.repeat();
      _timer?.cancel();
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _isActive = false;
    HapticService.vibrate();
    // Award coins via provider
    context.read<UserProgressController>().addCoins(100);
    // Reset
    setState(() {
      _remainingSeconds = _defaultTime;
    });
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ElyxTheme.current(context);
    final color = theme.color;
    // Use the level background as the "Nebula" texture
    final bgImage = theme.bg;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------
          // LAYER 1: THE UNIVERSE (Background)
          // ------------------------------------------------
          // We overlay a heavy black gradient on the existing asset to make it look like deep space
          Image.asset(
            bgImage,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.8), // Darken significantly
            colorBlendMode: BlendMode.hardLight,
          ),

          // Color Tint for "Mood" (Nebula effect)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  color.withValues(alpha: 0.15),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // ------------------------------------------------
          // LAYER 2: UI CONTENT
          // ------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // HEADER
                Text(
                  "DEEP WORK",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10)
                      ]
                  ),
                ),

                const Spacer(),

                // TIMER RING
                GestureDetector(
                  onTap: _toggleTimer,
                  child: AnimatedBuilder(
                    animation: _breathingController,
                    builder: (context, child) {
                      return Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isActive
                                ? Colors.white
                                : color.withValues(alpha: 0.6),
                            width: 4,
                          ),
                          boxShadow: [
                            // Breathing Outer Glow
                            BoxShadow(
                              color: color.withValues(alpha: 0.2 + (_breathingController.value * 0.2)),
                              blurRadius: 40 + (_breathingController.value * 20),
                              spreadRadius: 5,
                            ),
                            // Inner Glow
                            BoxShadow(
                              color: color.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: -10,
                            )
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(_remainingSeconds),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  fontFeatures: [FontFeature.tabularFigures()], // Fixed width numbers
                                ),
                              ),
                              const SizedBox(height: 10),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: _isActive ? 0.0 : 1.0,
                                child: Text(
                                  "TAP TO START",
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 12,
                                      letterSpacing: 3,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                // BRAINWAVE VISUALIZER
                Text(
                  "Brainwave Activity",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _BrainwavePainter(
                          animationValue: _waveController.value,
                          color: color,
                          isActive: _isActive,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // MOTIVATIONAL QUOTE (From Image)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Text(
                        "THE ONLY LIMIT IS THE MIND'S CREATION.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "BUILD YOUR EMPIRE.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10)
                            ]
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Dock Clearance
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BRAINWAVE PAINTER
// -----------------------------------------------------------------------------

class _BrainwavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isActive;

  _BrainwavePainter({
    required this.animationValue,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final midY = height / 2;

    // We draw a sine wave that scrolls based on animationValue
    // If active, amplitude is high. If not, low (calm).
    double amplitude = isActive ? 20.0 : 5.0;
    double frequency = isActive ? 0.05 : 0.02;

    path.moveTo(0, midY);

    for (double x = 0; x <= width; x++) {
      // Calculate Y using sine wave formula
      // x * freq + phase shift
      double phase = animationValue * 2 * math.pi;

      // Add some randomness/complexity to make it look like a brainwave, not a pure sine
      double y1 = math.sin((x * frequency) + phase);
      double y2 = math.sin((x * frequency * 2.5) - phase); // Interference wave

      // Taper the ends so lines fade out at edges
      double taper = 1.0;
      if (x < 50) taper = x / 50;
      if (x > width - 50) taper = (width - x) / 50;

      double y = midY + ((y1 + y2) * amplitude * taper);
      path.lineTo(x, y);
    }

    // Shadow/Glow effect
    canvas.drawPath(path, paint..color = color.withValues(alpha: 0.5)..strokeWidth = 4);
    // Core line
    canvas.drawPath(path, paint..color = Colors.white..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _BrainwavePainter oldDelegate) => true;
}
