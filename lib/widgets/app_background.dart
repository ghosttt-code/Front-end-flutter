import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  bool _isDayTime() {
    final hour = DateTime.now().hour;

    // Day = 6 AM through 5:59 PM
    return hour >= 6 && hour < 18;
  }

  @override
  Widget build(BuildContext context) {
    final isDay = _isDayTime();

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: isDay
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF02040C),
          ),
        ),

        // Only show the aurora/night effects at night.
        if (!isDay) ...[
          Positioned(
            top: 50,
            right: -130,
            child: _Glow(
              color: AppColors.auroraBlue,
              size: 330,
              opacity: 0.18,
            ),
          ),

          Positioned(
            top: 210,
            left: -150,
            child: _Glow(
              color: AppColors.auroraGreen,
              size: 310,
              opacity: 0.11,
            ),
          ),

          Positioned(
            bottom: 40,
            right: -120,
            child: _Glow(
              color: AppColors.auroraViolet,
              size: 300,
              opacity: 0.12,
            ),
          ),
        ],

        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Glow({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.25),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}