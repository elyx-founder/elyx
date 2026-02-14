import 'dart:ui' hide Image;
import 'package:flutter/material.dart';
import '../theme/level_theme.dart';

class LevelUpScene extends StatefulWidget {
  final int newLevel;
  final Color color;
  final String entityImage;

  const LevelUpScene({
    super.key,
    required this.newLevel,
    required this.color,
    required this.entityImage,
  });

  @override
  State<LevelUpScene> createState() => _LevelUpSceneState();
}

class _LevelUpSceneState extends State<LevelUpScene> with TickerProviderStateMixin {
  late AnimationController _masterController;

  // Staggered Animations
  late Animation<double> _bgOpacity;
  late Animation<double> _mainTextOpacity;
  late Animation<double> _mainTextScale;
  late Animation<double> _subTextSlide;
  late Animation<double> _quoteOpacity;
  late Animation<double> _btnOpacity;
  late Animation<double> _lineProgress;

  final String _quote = "\"Progress earned. Power unlocked.\"";

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Cinematic slow burn
    );

    // 1. Background Fade In (0.0 - 1.0s)
    _bgOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut))
    );

    // 2. "CONGRATULATIONS" Scale & Fade (0.5 - 1.5s)
    _mainTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.2, 0.5, curve: Curves.easeOut))
    );
    _mainTextScale = Tween<double>(begin: 1.2, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic))
    );

    // 3. Level Title Slide Up (1.0 - 2.0s)
    _subTextSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic))
    );

    // 4. Line drawing (1.5 - 2.5s)
    _lineProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.5, 0.8, curve: Curves.easeInOut))
    );

    // 5. Quote Fade In (2.5 - 3.5s)
    _quoteOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.7, 0.9, curve: Curves.easeOut))
    );

    // 6. Button Fade (3.5s+)
    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.85, 1.0, curve: Curves.easeOut))
    );

    _masterController.forward();
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = (widget.newLevel >= 0 && widget.newLevel < themes.length)
        ? widget.newLevel
        : 0;
    final levelTheme = themes[safeIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ------------------------------------------------
          // LAYER 1: ATMOSPHERIC VOID
          // ------------------------------------------------
          AnimatedBuilder(
            animation: _bgOpacity,
            builder: (context, child) {
              return Opacity(
                opacity: _bgOpacity.value,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.95), // Nearly opaque to hide old level
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.2,
                          colors: [
                            widget.color.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ------------------------------------------------
          // LAYER 2: CINEMATIC CONTENT
          // ------------------------------------------------
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // "SYSTEM UPGRADE" Label
                  FadeTransition(
                    opacity: _mainTextOpacity,
                    child: Text(
                      "SYSTEM UPGRADE COMPLETE",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        letterSpacing: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // MAIN TITLE: CONGRATULATIONS
                  AnimatedBuilder(
                    animation: _mainTextScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _mainTextScale.value,
                        child: Opacity(
                          opacity: _mainTextOpacity.value,
                          child: Text(
                            "CONGRATULATIONS",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28, // Reduced slightly for elegance
                                letterSpacing: 4,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: widget.color.withValues(alpha: 0.8),
                                    blurRadius: 30,
                                  ),
                                  Shadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  )
                                ]
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // LEVEL NAME (Animated Slide)
                  AnimatedBuilder(
                    animation: _subTextSlide,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _subTextSlide.value),
                        child: Opacity(
                          opacity: _mainTextOpacity.value,
                          child: Column(
                            children: [
                              Text(
                                "YOU HAVE REACHED",
                                style: TextStyle(
                                  color: widget.color.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                levelTheme.title, // e.g. COMMANDER
                                style: TextStyle(
                                  color: widget.color,
                                  fontSize: 42,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w100, // Thin futuristic look
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                "LEVEL ${widget.newLevel}",
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 14,
                                  letterSpacing: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // ANIMATED DIVIDER LINE
                  AnimatedBuilder(
                    animation: _lineProgress,
                    builder: (context, child) {
                      return Container(
                        height: 1,
                        width: 100 * _lineProgress.value,
                        decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.5),
                            boxShadow: [
                              BoxShadow(color: widget.color, blurRadius: 10, spreadRadius: 1)
                            ]
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // MOTIVATIONAL QUOTE
                  FadeTransition(
                    opacity: _quoteOpacity,
                    child: Text(
                      _quote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------
          // LAYER 3: BUTTON (Bottom Anchor)
          // ------------------------------------------------
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _btnOpacity,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: widget.color.withValues(alpha: 0.3)),
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      "ENTER ${levelTheme.world}",
                      style: TextStyle(
                        color: widget.color,
                        letterSpacing: 4,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
