import 'package:flutter/material.dart';
import 'login_screen.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
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
          // ❌ const hata diya — यही main fix है
          builder: (_) => LoginScreen(),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              // graph image
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [_controller.value, _controller.value],
                            colors: const [
                              Colors.white,
                              Colors.transparent,
                            ],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(
                          'assets/images/graph.png',
                          width: screenWidth * 0.85,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Measure Your Ascent.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 26,
                ),
              ),

              const SizedBox(height: 12),

              const Column(
                children: [
                  Icon(Icons.keyboard_arrow_up,
                      color: Colors.cyanAccent, size: 28),
                  Icon(Icons.keyboard_arrow_up,
                      color: Colors.cyanAccent, size: 28),
                  SizedBox(height: 10),
                  Text(
                    'SWIPE UP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
