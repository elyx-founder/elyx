import 'dart:ui' hide Image;
import 'dart:math' as math;
import 'package:flutter/material.dart';

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
  late AnimationController _pulseController;

  // Staggered Animations
  late Animation<double> _bgOpacity;
  late Animation<double> _burstScale;
  late Animation<double> _burstOpacity;
  late Animation<double> _entityScale;
  late Animation<double> _entityOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _btnOpacity;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // The entire intro sequence
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // 1. Flash / Burst (0.0 - 0.5s)
    _burstScale = Tween<double>(begin: 0.0, end: 4.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.0, 0.3, curve: Curves.easeOutExpo))
    );
    _burstOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.1, 0.5, curve: Curves.easeIn))
    );

    // 2. Background Fade In (0.2 - 0.8s)
    _bgOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut))
    );

    // 3. Entity Manifestation (0.5 - 1.5s)
    _entityScale = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.4, 0.8, curve: Curves.elasticOut))
    );
    _entityOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut))
    );

    // 4. Text Slide & Glitch (1.0 - 1.8s)
    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic))
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.6, 0.8, curve: Curves.easeOut))
    );

    // 5. Button Appear (2.0s+)
    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: const Interval(0.8, 1.0, curve: Curves.easeOut))
    );

    _masterController.forward();
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getWorldTitle() {
    switch (widget.newLevel) {
      case 1: return "NEURAL AWAKENING";
      case 2: return "FOCUS PROTOCOL";
      case 3: return "DEEP STATE";
      case 4: return "FLOW MASTERY";
      case 5: return "SOVEREIGN MIND";
      default: return "SYSTEM UPGRADE";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Allows underlying app to show through initially
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [

          // ------------------------------------------------
          // LAYER 1: Background Dimmer & Color Wash
          // ------------------------------------------------
          AnimatedBuilder(
            animation: _bgOpacity,
            builder: (context, child) {
              return Opacity(
                opacity: _bgOpacity.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.95), // Deep dark
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        widget.color.withOpacity(0.2),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ------------------------------------------------
          // LAYER 2: Energy Burst (The Explosion)
          // ------------------------------------------------
          AnimatedBuilder(
            animation: _masterController,
            builder: (context, child) {
              if (_burstOpacity.value == 0) return const SizedBox.shrink();
              return Opacity(
                opacity: _burstOpacity.value,
                child: Transform.scale(
                  scale: _burstScale.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                    ),
                  ),
                ),
              );
            },
          ),

          // ------------------------------------------------
          // LAYER 3: The Entity (Mentor)
          // ------------------------------------------------
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_entityScale, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _entityScale.value + (_pulseController.value * 0.05),
                    child: Opacity(
                      opacity: _entityOpacity.value,
                      child: Container(
                        height: 350,
                        width: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.4),
                              blurRadius: 60,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Image.asset(
                          widget.entityImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),

              // ------------------------------------------------
              // LAYER 4: Typography
              // ------------------------------------------------
              AnimatedBuilder(
                animation: _textSlide,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          Text(
                            "LEVEL ${widget.newLevel}",
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 16,
                              letterSpacing: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _getWorldTitle(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: 'Courier', // Placeholder for tech font
                              letterSpacing: 2,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 50,
                            height: 2,
                            color: widget.color,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // ------------------------------------------------
          // LAYER 5: Action Button
          // ------------------------------------------------
          Positioned(
            bottom: 80,
            child: AnimatedBuilder(
              animation: _btnOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _btnOpacity.value,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.color.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(30),
                        color: widget.color.withOpacity(0.1),
                      ),
                      child: Text(
                        "ENTER SIMULATION",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}