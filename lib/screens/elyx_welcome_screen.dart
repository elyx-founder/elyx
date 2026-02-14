import 'package:flutter/material.dart';

class ElyxWelcomeScreen extends StatefulWidget {
  final bool firstTime;
  final Widget nextScreen;

  const ElyxWelcomeScreen({
    super.key,
    required this.firstTime,
    required this.nextScreen,
  });

  @override
  State<ElyxWelcomeScreen> createState() => _ElyxWelcomeScreenState();
}

class _ElyxWelcomeScreenState extends State<ElyxWelcomeScreen> {
  bool showText = false;

  @override
  void initState() {
    super.initState();

    // 🔹 TEXT APPEAR TIMING
    Future.delayed(
      Duration(seconds: widget.firstTime ? 2 : 0),
          () {
        if (!mounted) return;
        setState(() {
          showText = true;
        });
      },
    );

    // 🔹 SCREEN EXIT TIMING
    Future.delayed(
      Duration(seconds: widget.firstTime ? 5 : 3),
          () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => widget.nextScreen,
            transitionsBuilder: (_, animation, __, child) {
              final fade = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              );

              return FadeTransition(
                opacity: fade,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🔹 CENTER LOGO
          Center(
            child: Image.asset(
              'assets/images/elyx_logo.png',
              width: 290,
            ),
          ),

          // 🔹 BOTTOM ANIMATED TEXT
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: showText ? Offset.zero : const Offset(0, 0.25),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: showText ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                child: const Center(
                  child: Text(
                    'YOUR ERA BEGINS',
                    style: TextStyle(
                      fontSize: 22,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
