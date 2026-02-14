import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'graph_screen.dart';
import 'war_screen.dart';
import 'status_screen.dart';
import 'chat_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;
  bool chatOpen = false;

  final pages = const [
    ImmersiveHomeScreen(),
    GraphScreen(),
    WarScreen(),
    StatusScreen(),
  ];

  void openChat() => setState(() => chatOpen = true);
  void closeChat() => setState(() => chatOpen = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: pages,
          ),

          /// CHAT OVERLAY (transparent)
          if (chatOpen)
            Positioned.fill(
              child: Stack(
                children: [

                  /// BLUR BACKGROUND
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),

                  /// CHAT SCREEN
                  const ChatScreen(),

                  /// CLOSE BUTTON
                  Positioned(
                    top: 48,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: closeChat,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      /// CENTER CHAT BUTTON
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: openChat,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.cyanAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.7),
                blurRadius: 24,
              )
            ],
          ),
          child: const Icon(Icons.chat, color: Colors.black, size: 30),
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navIcon(Icons.home, 0),
              navIcon(Icons.bar_chart, 1),
              const SizedBox(width: 40),
              navIcon(Icons.local_fire_department, 2),
              navIcon(Icons.person, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget navIcon(IconData icon, int i) {
    final active = currentIndex == i;

    return IconButton(
      onPressed: () {
        setState(() {
          currentIndex = i;
          chatOpen = false;
        });
      },
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: active
              ? [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.7),
              blurRadius: 16,
            )
          ]
              : [],
        ),
        child: Icon(
          icon,
          size: 26,
          color: active ? Colors.cyanAccent : Colors.white54,
        ),
      ),
    );
  }
}
