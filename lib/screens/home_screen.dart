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
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late AnimationController _scanlineController;

  // Particle System
  final List<_Particle> _particles = [];
  late AnimationController _particleController;

  // Navigation State
  int _currentIndex = 0; // 0: Home, 1: Chat, 2: Status, 3: War, 4: Deep Work

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
    _particleController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      HapticService.light();
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
      resizeToAvoidBottomInset: false, // Prevents dock from jumping up
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -------------------------------------------------------
          // LAYER 1: THE LIVING BACKGROUND (Always Visible)
          // -------------------------------------------------------
          _buildBackgroundLayer(entityImage, primaryColor),

          // -------------------------------------------------------
          // LAYER 2: CINEMATIC VFX
          // -------------------------------------------------------
          _buildVfxOverlays(primaryColor),

          // -------------------------------------------------------
          // LAYER 3: CONTENT SWITCHER (Navigation Body)
          // -------------------------------------------------------
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutQuart,
              switchOutCurve: Curves.easeInQuart,
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Subtle slide and fade for content
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
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
          // LAYER 4: HEADER (Signature)
          // -------------------------------------------------------
          Positioned(
            top: 50,
            left: 24,
            child: SafeArea(
              child: Row(
                children: [
                  Text(
                    "ELYX",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      fontSize: 16,
                      shadows: [
                        Shadow(color: primaryColor.withValues(alpha: 0.8), blurRadius: 15)
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    height: 16,
                    width: 1.5,
                    color: Colors.white24,
                  ),
                  Text(
                    "ALEX", // Dynamic User Name
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------
          // LAYER 5: FLOATING DOCK (Persistent Bottom Nav)
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
    // Keys ensure AnimatedSwitcher treats them as unique widgets
    switch (_currentIndex) {
      case 0:
        return _HomeView(key: const ValueKey(0), color: color);
      case 1:
        return const ChatScreen(key: ValueKey(1)); // Transparent Overlay
      case 2:
        return const StatusScreen(key: ValueKey(2)); // Stats Hub
      case 3:
        return const WarScreen(key: ValueKey(3)); // Competitive Containers
      case 4:
        return const DeepWorkScreen(key: ValueKey(4));
      default:
        return _HomeView(key: const ValueKey(0), color: color);
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
                  duration: const Duration(seconds: 2), // Slow morph
                  child: Image.asset(
                    entityImage,
                    key: ValueKey(entityImage), // Triggers animation on change
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
            duration: const Duration(seconds: 2), // Slow morph transition
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: Image.asset(
              entityImage,
              key: ValueKey(entityImage),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
        ),

        // D. Vignette (Dark edges for focus)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.45, 1.0],
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
      margin: const EdgeInsets.symmetric(horizontal: 40),
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
              _DockIcon(
                icon: Icons.grid_view_rounded,
                color: color,
                isSelected: _currentIndex == 0,
                onTap: () => _onTabChanged(0),
              ),
              _DockIcon(
                icon: Icons.chat_bubble_outline_rounded,
                color: color,
                isSelected: _currentIndex == 1,
                onTap: () => _onTabChanged(1),
              ),
              // Center Action Button (Stats/Status)
              GestureDetector(
                onTap: () => _onTabChanged(2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 2
                        ? color
                        : Colors.white.withValues(alpha: 0.1),
                    boxShadow: [
                      if (_currentIndex == 2)
                        BoxShadow(
                            color: color.withValues(alpha: 0.5), blurRadius: 15)
                    ],
                  ),
                  child: Icon(Icons.bar_chart_rounded,
                      color: _currentIndex == 2 ? Colors.black : Colors.white,
                      size: 20),
                ),
              ),
              _DockIcon(
                icon: Icons.bolt_rounded,
                color: color,
                isSelected: _currentIndex == 3,
                onTap: () => _onTabChanged(3),
              ),
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
// INTERNAL HOME VIEW (The Ring)
// -----------------------------------------------------------------------------

class _HomeView extends StatefulWidget {
  final Color color;
  const _HomeView({super.key, required this.color});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
        vsync: this, duration: const Duration(seconds: 40))
      ..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text("SYSTEM\nONLINE",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w100,
                    shadows: [
                      Shadow(
                          color: widget.color.withValues(alpha: 0.8),
                          blurRadius: 25)
                    ])),
            RotationTransition(
                turns: _rotateController,
                child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _RingPainter(
                        color: widget.color.withValues(alpha: 0.8),
                        dashes: 3,
                        strokeWidth: 1.5))),
            RotationTransition(
                turns: ReverseAnimation(_rotateController),
                child: CustomPaint(
                    size: const Size(280, 280),
                    painter: _RingPainter(
                        color: widget.color.withValues(alpha: 0.3),
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
