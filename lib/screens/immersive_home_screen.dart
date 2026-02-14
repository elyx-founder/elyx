import 'dart:ui' hide Image;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import '../services/user_progress_controller.dart';
import '../services/haptic_service.dart';
import '../theme/level_theme.dart';

// Screens (Embedded Widgets)
import 'war_screen.dart';
import 'status_screen.dart';
import 'chat_screen.dart';
import 'deep_work_screen.dart';
import 'level_up_scene.dart';

class ImmersiveHomeScreen extends StatefulWidget {
  const ImmersiveHomeScreen({super.key});

  @override
  State<ImmersiveHomeScreen> createState() => _ImmersiveHomeScreenState();
}

class _ImmersiveHomeScreenState extends State<ImmersiveHomeScreen>
    with TickerProviderStateMixin {
  // Background Animations
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late AnimationController _scanlineController;

  // Persistent Orb Animation
  late AnimationController _orbController;

  // Chat Button Pulse
  late AnimationController _chatPulseController;

  // Particle System
  final List<_Particle> _particles = [];
  late AnimationController _particleController;

  // Navigation State
  // 0: Home (View Only)
  // 1: Status/Stats
  // 2: Chat (Center)
  // 3: War
  // 4: Deep Work
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 1. Background Animation Loop
    _breathingController = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);

    _scanlineController = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    _orbController = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();

    _chatPulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _particleController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _initParticles();
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(random));
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    _scanlineController.dispose();
    _orbController.dispose();
    _chatPulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      HapticService.medium(); // Heavier feedback for main nav
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<UserProgressController>(context);
    final theme = ElyxTheme.current(context);
    final Color primaryColor = theme.color;
    final String entityImage = theme.entity;

    // Listen for Level Up (Global overlay)
    if (progress.levelUpHappened) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        progress.resetLevelFlag();
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => LevelUpScene(
              newLevel: progress.level,
              color: primaryColor,
              entityImage: entityImage,
            ),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -------------------------------------------------------
          // LAYER 1: THE LIVING BACKGROUND (Entity)
          // -------------------------------------------------------
          _buildBackgroundLayer(entityImage, primaryColor),

          // -------------------------------------------------------
          // LAYER 1.5: PERSISTENT COMMAND CENTRE (The Orb)
          // -------------------------------------------------------
          // Always visible to satisfy "Command Centre visible behind chat"
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                // Dim slightly when in War/Deep Work to focus, but keep for Chat
                duration: const Duration(milliseconds: 500),
                opacity: (_currentIndex == 3 || _currentIndex == 4) ? 0.3 : 1.0,
                child: _SystemOrb(
                    color: primaryColor,
                    controller: _orbController
                ),
              ),
            ),
          ),

          // -------------------------------------------------------
          // LAYER 2: CINEMATIC VFX
          // -------------------------------------------------------
          _buildVfxOverlays(primaryColor),

          // -------------------------------------------------------
          // LAYER 3: CONTENT SWITCHER (Overlay Panels)
          // -------------------------------------------------------
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutQuart,
              switchOutCurve: Curves.easeInQuart,
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Slide up from bottom for panel feel
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildBodyContent(primaryColor),
            ),
          ),

          // -------------------------------------------------------
          // LAYER 4: HEADER (Mentor Name & User)
          // -------------------------------------------------------
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left: App Name
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "ELYX",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center: MENTOR NAME (VULCAL) - Premium Glow
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "VULCAL",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            fontSize: 16,
                            shadows: [
                              Shadow(color: primaryColor.withValues(alpha: 0.8), blurRadius: 20),
                              Shadow(color: primaryColor, blurRadius: 5),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 40,
                          height: 2,
                          decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2)
                          ),
                        )
                      ],
                    ),

                    // Right: User
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "ALEX",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // -------------------------------------------------------
          // LAYER 5: DEBUG LEVEL UP BUTTON (Per Request)
          // -------------------------------------------------------
          Positioned(
            bottom: 110, // Just above the dock
            right: 0,
            left: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticService.heavy();
                  progress.debugLevelUp();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1))
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bug_report, size: 12, color: Colors.white54),
                      SizedBox(width: 6),
                      Text("TEST LVL UP",
                          style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // -------------------------------------------------------
          // LAYER 6: FLOATING DOCK (Persistent Bottom Nav)
          // -------------------------------------------------------
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: _buildFloatingDock(primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(Color color) {
    // 0 = Home (Just background/orb visible)
    // 2 = Chat (Overlay)
    switch (_currentIndex) {
      case 0:
        return const SizedBox.shrink(key: ValueKey(0)); // Show nothing, let Orb shine
      case 1:
        return const StatusScreen(key: ValueKey(1));
      case 2:
        return const ChatScreen(key: ValueKey(2));
      case 3:
        return const WarScreen(key: ValueKey(3));
      case 4:
        return const DeepWorkScreen(key: ValueKey(4));
      default:
        return const SizedBox.shrink(key: ValueKey(0));
    }
  }

  Widget _buildBackgroundLayer(String entityImage, Color color) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // A. Back Glow
        AnimatedBuilder(
          animation: Listenable.merge([_breathingController, _pulseController]),
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_breathingController.value * 0.06),
              child: Opacity(
                opacity: 0.15 + (_pulseController.value * 0.1),
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3), // Extended to 3s for cinematic feel
                  child: Image.asset(
                    entityImage,
                    key: ValueKey(entityImage),
                    fit: BoxFit.cover,
                    color: color,
                    colorBlendMode: BlendMode.srcATop,
                  ),
                ),
              ),
            );
          },
        ),

        // B. Particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(particles: _particles, color: color),
              size: Size.infinite,
            );
          },
        ),

        // C. Main Entity (The Mentor)
        AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.02 + (_breathingController.value * 0.03),
              child: child,
            );
          },
          child: AnimatedSwitcher(
            duration: const Duration(seconds: 3), // 3s Cinematic Morph
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            // Custom Transition: New rises from bottom, Old sinks down.
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.15), // Start 15% lower (Rise effect)
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Image.asset(
              entityImage,
              key: ValueKey(entityImage),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
        ),

        // D. Vignette
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVfxOverlays(Color color) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _scanlineController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ScanlinePainter(
                progress: _scanlineController.value, color: color),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildFloatingDock(Color color) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Home
              _DockIcon(
                icon: Icons.grid_view_rounded,
                color: color,
                isSelected: _currentIndex == 0,
                onTap: () => _onTabChanged(0),
              ),
              // 2. Stats
              _DockIcon(
                icon: Icons.bar_chart_rounded,
                color: color,
                isSelected: _currentIndex == 1,
                onTap: () => _onTabChanged(1),
              ),

              // 3. CENTER: CHAT (Main)
              GestureDetector(
                onTap: () => _onTabChanged(2),
                child: AnimatedBuilder(
                    animation: _chatPulseController,
                    builder: (context, child) {
                      final pulse = _chatPulseController.value * 6;
                      final isSelected = _currentIndex == 2;
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
                            boxShadow: [
                              BoxShadow(
                                  color: color.withValues(alpha: isSelected ? 0.6 : 0.2),
                                  blurRadius: 15 + pulse
                              )
                            ],
                            border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 1.5
                            )
                        ),
                        child: Icon(
                            Icons.chat_bubble_rounded,
                            color: isSelected ? Colors.black : Colors.white,
                            size: 24
                        ),
                      );
                    }
                ),
              ),

              // 4. War
              _DockIcon(
                icon: Icons.bolt_rounded,
                color: color,
                isSelected: _currentIndex == 3,
                onTap: () => _onTabChanged(3),
              ),
              // 5. Timer
              _DockIcon(
                icon: Icons.timer_outlined,
                color: color,
                isSelected: _currentIndex == 4,
                onTap: () => _onTabChanged(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SYSTEM ORB (PERSISTENT COMMAND CENTRE)
// -----------------------------------------------------------------------------

class _SystemOrb extends StatelessWidget {
  final Color color;
  final AnimationController controller;

  const _SystemOrb({required this.color, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Static Text
            Text("SYSTEM\nONLINE",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w100,
                    shadows: [
                      Shadow(
                          color: color.withValues(alpha: 0.8),
                          blurRadius: 25)
                    ])),
            // Inner Ring
            RotationTransition(
                turns: controller,
                child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _RingPainter(
                        color: color.withValues(alpha: 0.8),
                        dashes: 3,
                        strokeWidth: 1.5))),
            // Outer Ring (Reverse)
            RotationTransition(
                turns: ReverseAnimation(controller),
                child: CustomPaint(
                    size: const Size(280, 280),
                    painter: _RingPainter(
                        color: color.withValues(alpha: 0.3),
                        dashes: 6,
                        strokeWidth: 0.5))),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;
  const _DockIcon(
      {required this.icon,
        required this.color,
        required this.onTap,
        this.isSelected = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          color: Colors.transparent, // Hitbox
          padding: const EdgeInsets.all(12),
          child: Icon(icon,
              color: isSelected ? color : Colors.white.withValues(alpha: 0.4),
              size: 24)),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final int dashes;
  final double strokeWidth;
  _RingPainter(
      {required this.color, required this.dashes, required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final double radius = size.width / 2;
    final Rect rect =
    Rect.fromCircle(center: Offset(radius, radius), radius: radius);
    final double gap = math.pi / (dashes * 2);
    final double sweep = (2 * math.pi / dashes) - gap;
    for (int i = 0; i < dashes; i++) {
      paint.color = color.withValues(alpha: i % 2 == 0 ? 1.0 : 0.5);
      canvas.drawArc(rect, i * (2 * math.pi / dashes), sweep, false, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Particle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;
  _Particle(math.Random random) {
    _reset(random, firstRun: true);
  }
  void _reset(math.Random random, {bool firstRun = false}) {
    x = random.nextDouble();
    y = firstRun ? random.nextDouble() : 1.1;
    size = random.nextDouble() * 2 + 1.5;
    speed = random.nextDouble() * 0.002 + 0.0005;
    opacity = random.nextDouble() * 0.5 + 0.1;
  }
  void update(math.Random random) {
    y -= speed;
    if (y < -0.1) _reset(random);
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final math.Random random = math.Random();
  _ParticlePainter({required this.particles, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var particle in particles) {
      particle.update(random);
      paint.color = color.withValues(alpha: particle.opacity);
      canvas.drawCircle(Offset(particle.x * size.width, particle.y * size.height),
          particle.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ScanlinePainter extends CustomPainter {
  final double progress;
  final Color color;
  _ScanlinePainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.08),
            Colors.transparent
          ],
          stops: const [0.0, 0.5, 1.0]).createShader(Rect.fromLTWH(
          0, (size.height * progress) - 100, size.width, 200));
    canvas.drawRect(
        Rect.fromLTWH(0, (size.height * progress) - 100, size.width, 200),
        paint);
  }
  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
