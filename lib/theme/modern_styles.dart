import 'package:flutter/material.dart';

class ModernStyles {
  // Blue Route Colors
  static const Color blueRouteBackground = Color(0xFF0B287E);
  static const Color blueRouteSidebar = Color(0xFF1345C5);
  static const Color blueRouteButton = Color(0xFF1E5FF5);
  static const Color blueRouteBadgeCyan = Color(0xFF00E5FF);
  static const Color blueRouteBadgeBlue = Color(0xFF2962FF);
  static const Color blueRouteBadgeGrey = Color(0xFFB0BEC5);
  static const Color blueRouteDarkText = Color(0xFF101828);
  static const Color blueRouteSecondaryText = Color(0xFF475467);
  static const Color blueRouteDivider = Color(0xFFEAECF0);

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : Colors.white;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : blueRouteDarkText;
  }

  static BoxDecoration glassPanel(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: blueRouteDivider, width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration glowingContainer(
    BuildContext context, {
    Color? glowColor,
    double opacity = 0.5,
    double borderRadius = 12,
  }) {
    final color = glowColor ?? blueRouteButton;
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color.withOpacity(0.6), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    );
  }
}
