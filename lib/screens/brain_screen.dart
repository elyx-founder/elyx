import 'package:flutter/material.dart';
import 'graph_screen.dart';

class BrainScreen extends StatefulWidget {
  const BrainScreen({super.key});

  @override
  State<BrainScreen> createState() => _BrainScreenState();
}

class _BrainScreenState extends State<BrainScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta.dy;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragDistance < -120) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const GraphScreen(),
        ),
      );
    }
    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              const Text(
                'ELYX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  letterSpacing: 5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔧 ONLY FIX: Expanded added here
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Image.asset(
                          'assets/images/brain_only.png',
                          width: screenWidth * 1.1,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 36),

              const Text(
                'Access the Inner Circle',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 25,
                ),
              ),

              const SizedBox(height: 15),

              const Column(
                children: [
                  Icon(Icons.keyboard_arrow_up,
                      color: Colors.cyanAccent, size: 28),
                  Icon(Icons.keyboard_arrow_up,
                      color: Colors.cyanAccent, size: 28),
                  SizedBox(height: 10),
                  Text(
                    'SWIPE UP',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 19,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
