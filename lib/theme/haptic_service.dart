import 'package:flutter/services.dart';

class HapticService {

  /// Light tap for standard interactions (tab switches, small buttons)
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium thud for significant actions (opening menus, toggling chat)
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for level ups or major confirmations
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Sharp tick for selection changes or sliders
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Double pulse for success or errors
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
