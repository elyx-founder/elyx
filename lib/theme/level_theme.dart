import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_controller.dart';

class LevelTheme {
  final String bg;
  final String entity;
  final Color color;
  final String title; // Rank Title (e.g. Commander)
  final String world; // World Name (e.g. Fortress)

  const LevelTheme(this.bg, this.entity, this.color, this.title, this.world);
}

const List<LevelTheme> themes = [
  // Level 0
  LevelTheme(
      "assets/levels/bg_0.jpg",
      "assets/levels/entity_0.png",
      Color(0xFFB0BEC5), // Grey/Desaturated
      "SLAVE",
      "THE RUIN"
  ),
  // Level 1
  LevelTheme(
      "assets/levels/bg_1.jpg",
      "assets/levels/entity_1.png",
      Color(0xFF00E5FF), // Cyan
      "MERCENARY",
      "OUTPOST"
  ),
  // Level 2
  LevelTheme(
      "assets/levels/bg_2.jpg",
      "assets/levels/entity_2.png",
      Color(0xFF00FF94), // Green
      "COMMANDER",
      "FORTRESS"
  ),
  // Level 3
  LevelTheme(
      "assets/levels/bg_3.jpg",
      "assets/levels/entity_3.png",
      Color(0xFFD500F9), // Purple
      "STRATEGIST",
      "DOMINION"
  ),
  // Level 4
  LevelTheme(
      "assets/levels/bg_4.jpg",
      "assets/levels/entity_4.png",
      Color(0xFFFFD700), // Gold
      "CONQUEROR",
      "EMPIRE"
  ),
  // Level 5
  LevelTheme(
      "assets/levels/bg_5.jpg",
      "assets/levels/entity_5.png",
      Color(0xFFFF3D00), // Red/Orange
      "OVERLORD",
      "DYNASTY"
  ),
  // Level 6
  LevelTheme(
      "assets/levels/bg_6.jpg",
      "assets/levels/entity_6.png",
      Color(0xFFFFFFFF), // White/Prismatic
      "LEGEND",
      "ETERNITY"
  ),
];

/// 🔮 Global theme accessor
class ElyxTheme {
  static LevelTheme current(BuildContext context) {
    final progress = context.watch<UserProgressController>();
    int lvl = progress.level;

    // Safety bounds check
    if (lvl < 0) lvl = 0;
    if (lvl >= themes.length) lvl = themes.length - 1;

    return themes[lvl];
  }

  static Color color(BuildContext context) {
    return current(context).color;
  }
}
