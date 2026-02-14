import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_controller.dart';
import '../services/haptic_service.dart';
import '../theme/level_theme.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tickerController;
  Timer? _focusTimer;
  bool _isFocusing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tickerController.dispose();
    _focusTimer?.cancel();
    super.dispose();
  }

  void _startFocus(UserProgressController progress) {
    HapticService.medium();
    setState(() {
      _isFocusing = true;
    });
    // Simulate earning coins while holding/tapping focus
    _focusTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      progress.addCoins(1); // Add 1 coin per tick
      if (timer.tick % 5 == 0) HapticService.light(); // Feedback
    });
  }

  void _stopFocus() {
    if (_isFocusing) {
      HapticService.medium();
      _focusTimer?.cancel();
      setState(() {
        _isFocusing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<UserProgressController>();
    final theme = ElyxTheme.current(context);
    final color = theme.color;

    return Container(
      color: Colors.black.withValues(alpha: 0.95), // Deep dark opaque
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. HEADER: MISSION STATUS
            Text(
              "MISSION STATUS",
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: [
                  Shadow(color: color.withValues(alpha: 0.8), blurRadius: 20),
                  Shadow(color: color.withValues(alpha: 0.4), blurRadius: 40),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. CENTRAL LEVEL INDICATOR (The Circle)
            Expanded(
              flex: 4,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Glow
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.2 + (_pulseController.value * 0.1)),
                                blurRadius: 50,
                                spreadRadius: 10,
                              )
                            ],
                            border: Border.all(
                              color: color.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                        ),
                        // Inner Ring
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color,
                              width: 6,
                            ),
                          ),
                        ),
                        // Text Content
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "LEVEL ${progress.level}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              theme.title, // e.g. ELITE, SLAVE, COMMANDER
                              style: TextStyle(
                                  color: color, // The theme color (Red, etc)
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  shadows: [Shadow(color: color, blurRadius: 10)]
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // 3. STAT PILLS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildStatPill(
                    icon: Icons.show_chart_rounded,
                    label: "NET WORTH GROWTH",
                    value: "+12.5%",
                    color: color,
                    valueColor: const Color(0xFF00FF94), // Green for positive growth
                  ),
                  const SizedBox(height: 16),
                  _buildStatPill(
                    icon: Icons.bolt_rounded,
                    label: "HABIT CONSISTENCY",
                    value: "85%",
                    color: color,
                    valueColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  _buildStatPill(
                    icon: Icons.account_balance_wallet_outlined,
                    label: "MISSION CREDITS",
                    value: "${progress.coins}", // Real data
                    color: color,
                    valueColor: Colors.white,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 4. FOCUS BUTTON (For earning Elite Coins)
            GestureDetector(
              onLongPressStart: (_) => _startFocus(progress),
              onLongPressEnd: (_) => _stopFocus(),
              onTap: () {
                HapticService.light();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.black,
                      content: Text("HOLD TO GENERATE FOCUS ENERGY",
                          style: TextStyle(color: color, fontWeight: FontWeight.bold)
                      ),
                      duration: const Duration(seconds: 1),
                    )
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                    color: _isFocusing ? color.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                    boxShadow: _isFocusing ? [BoxShadow(color: color, blurRadius: 20)] : []
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_center_focus, color: color, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _isFocusing ? "GENERATING..." : "FOCUS PROTOCOL",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 5. QUOTE BOX
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                  border: Border.all(color: color, width: 1),
                  borderRadius: BorderRadius.circular(40), // Fully rounded ends
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)
                  ]
              ),
              child: const Text(
                "\"EXCUSES DON'T BUILD EMPIRES. MAINTAIN DIRECTION.\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),

            // Spacer to push ticker to very bottom
            const Spacer(),

            // 6. BOTTOM TICKER
            Container(
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                color: Colors.black,
              ),
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _tickerController,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      widthFactor: 2.0, // Make it wide
                      alignment: Alignment(_tickerController.value * 2 - 1, 0), // Scroll
                      child: Row(
                        children: [
                          _buildTickerText("REAL ESTATE MARKET +0.4%"),
                          _buildTickerText("LUXURY APARTMENTS DEMAND UP"),
                          _buildTickerText("TECH STOCKS CLIMB"),
                          _buildTickerText("AI SECTOR BOOMING"),
                          _buildTickerText("SELF MASTERY INDEX: HIGH"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Floating Dock Clearance
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color valueColor,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTickerText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.redAccent.withValues(alpha: 0.8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
