import 'package:flutter/material.dart';

class ModernStyles {
  static BoxDecoration glassPanel(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor.withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration glowingContainer(BuildContext context, {Color? glowColor, double opacity = 0.5, double borderRadius = 12}) {
    final color = glowColor ?? Theme.of(context).colorScheme.primary;
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color.withOpacity(0.6),
        width: 1.5,
      ),
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
