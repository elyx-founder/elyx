import 'package:flutter/material.dart';

class UserProgressController extends ChangeNotifier {

  int coins = 0;
  int level = 0;

  // Flag to trigger UI events (Navigation to LevelUpScene)
  bool levelUpHappened = false;

  /// Level requirements - Coins needed to reach next level.
  /// Index 0: Cost to go 0 -> 1
  /// Index 1: Cost to go 1 -> 2
  /// ...
  final List<int> levelRequirement = [
    90,   // 0 -> 1
    150,  // 1 -> 2
    300,  // 2 -> 3
    750,  // 3 -> 4
    1500, // 4 -> 5
    5000  // 5 -> 6
  ];

  /// Add Coins and check for level up
  void addCoins(int amount) {
    coins += amount;
    checkLevelUp();
    notifyListeners();
  }

  /// Penalty: Subtract coins for lack of discipline
  void punishUser() {
    coins -= 5;
    if (coins < 0) coins = 0;
    notifyListeners();
  }

  /// Internal check logic
  void checkLevelUp() {
    bool leveledUp = false;
    // Check if we have enough coins to advance (and we are not max level)
    while (level < levelRequirement.length &&
        coins >= levelRequirement[level]) {

      coins -= levelRequirement[level]; // Coins are consumed to level up
      level++;
      leveledUp = true;
    }

    if (leveledUp) {
      levelUpHappened = true;
      // We do not notify listeners here to avoid multiple rebuilds,
      // the caller (addCoins) notifies once at the end.
    }
  }

  /// Call this after the UI has handled the event (e.g., navigated to the cutscene)
  void resetLevelFlag() {
    levelUpHappened = false;
    // No notifyListeners() needed here usually, as it's state cleanup
  }

  // ---------------------------------------------------------------------------
  // DEBUG / GOD MODE METHODS
  // ---------------------------------------------------------------------------

  /// Force a level up for testing animation flow
  void debugLevelUp() {
    if (level < levelRequirement.length) {
      level++;
      levelUpHappened = true;
      notifyListeners();
    }
  }

  /// Reset progress for testing onboarding
  void debugResetLevel() {
    level = 0;
    coins = 0;
    levelUpHappened = false;
    notifyListeners();
  }
}
