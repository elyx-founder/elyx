import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// 🔥 NEW HOME
import 'immersive_home_screen.dart';

class InitializingMentorScreen extends StatefulWidget {
  const InitializingMentorScreen({super.key});

  @override
  State<InitializingMentorScreen> createState() =>
      _InitializingMentorScreenState();
}

class _InitializingMentorScreenState extends State<InitializingMentorScreen>
    with TickerProviderStateMixin {

  late AnimationController corePulse;
  late AnimationController scanController;

  String phase = "Scanning your potential";
  String mentorName = "";
  String mentorIntro = "";

  String displayedIntro = "";
  int charIndex = 0;

  bool showMentor = false;
  bool startTyping = false;

  final mentors = [
    {
      "name": "NYX",
      "intro":
      "You were not built for average. I will burn your excuses and rebuild your discipline. Stay sharp. We begin now."
    },
    {
      "name": "ORION",
      "intro":
      "Your comfort ends today. I train minds that refuse to stay small. Stand up. Focus. Move."
    },
    {
      "name": "ASTRA",
      "intro":
      "You want change? Then we create pressure. Under pressure you evolve. Under me, you transform."
    },
    {
      "name": "VULCAN",
      "intro":
      "Discipline is not motivation. It is a weapon. I will forge you until hesitation disappears."
    },
  ];

  @override
  void initState() {
    super.initState();

    corePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _sequence();
  }

  @override
  void dispose() {
    corePulse.dispose();
    scanController.dispose();
    super.dispose();
  }

  Future<void> _sequence() async {

    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => phase = "Reading your behavior");

    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => phase = "Matching you with a mentor");

    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => phase = "Energy alignment complete");

    await Future.delayed(const Duration(milliseconds: 700));

    final selected = mentors[Random().nextInt(mentors.length)];
    mentorName = selected["name"]!;
    mentorIntro = selected["intro"]!;

    setState(() {
      showMentor = true;
      phase = "MENTOR ACTIVATED";
    });

    await Future.delayed(const Duration(milliseconds: 600));

    startTyping = true;
    _typeIntro();
  }

  void _typeIntro() {
    Timer.periodic(const Duration(milliseconds: 28), (timer) {
      if (charIndex >= mentorIntro.length) {
        timer.cancel();
        _goHome();
        return;
      }

      setState(() {
        displayedIntro += mentorIntro[charIndex];
        charIndex++;
      });
    });
  }

  void _goHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ImmersiveHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// SCAN LINE
          AnimatedBuilder(
            animation: scanController,
            builder: (_, __) {
              return Positioned(
                top: MediaQuery.of(context).size.height *
                    scanController.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Colors.cyanAccent.withValues(alpha: 0.6),
                ),
              );
            },
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// CORE
                  AnimatedBuilder(
                    animation: corePulse,
                    builder: (_, __) {
                      double scale =
                          0.85 + (corePulse.value * 0.25);

                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyanAccent,
                                Colors.cyanAccent.withValues(alpha: 0.15),
                                Colors.black,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent
                                    .withValues(alpha: 0.9),
                                blurRadius: 70,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  Text(
                    phase,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 25),

                  AnimatedOpacity(
                    opacity: showMentor ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      mentorName,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (startTyping)
                    Text(
                      displayedIntro,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
