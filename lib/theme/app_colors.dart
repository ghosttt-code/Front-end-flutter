import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // CORE BRAND COLORS
  // ============================================================

  static const Color amber = Color(0xFFFFC670);
  static const Color amberHighlight = Color(0xFFFFE0A8);
  static const Color amberShadow = Color(0xFFEFA546);

  static const Color ink = Color(0xFF050A1C);
  static const Color warmWhite = Color(0xFFF6F3EC);

  static const Color softText = Color(0xBDF6F3EC);
  static const Color thinOutline = Color(0x42F6F3EC);

  // ============================================================
  // NIGHT
  // ============================================================

  static const Color loaderEdge = Color(0xFF070A12);
  static const Color loaderCenter = Color(0xFF121A2E);

  static const Color auraBubble = Color(0xFF171C27);
  static const Color bubbleOutline = Color(0x1FF6F3EC);

  static const Color badgeGlow = Color(0x47FFC670);

  static const Color cardGlass = Color(0x0FF6F3EC);
  static const Color inputGlass = Color(0x17F6F3EC);
  static const Color inputOutline = Color(0x3DF6F3EC);

  static const Color tabTrack = Color(0x14F6F3EC);
  static const Color selectedTab = Color(0x38F6F3EC);

  // ============================================================
  // SKY
  // ============================================================

  static const Color skyTop = Color(0xFF040A1C);
  static const Color skyMiddle = Color(0xFF0D1B40);
  static const Color skyHorizon = Color(0xFF3B3567);

  static const Color mountainFar = Color(0xFF20264F);
  static const Color mountainMiddle = Color(0xFF141A3C);
  static const Color mountainNear = Color(0xFF0A0F26);

  static const Color shore = Color(0xFF060A18);
  static const Color litWindow = Color(0xFFFFCE82);

  static const Color auroraGreen = Color(0xFF60F0BE);
  static const Color auroraBlue = Color(0xFF78AAFF);
  static const Color auroraViolet = Color(0xFFBE82FF);

  // ============================================================
  // DAY / NIGHT
  // ============================================================

  static bool get isDay {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  static Color get background {
    return isDay
        ? Colors.white
        : const Color(0xFF02040C);
  }

  static Color get primaryText {
    return isDay
        ? ink
        : warmWhite;
  }

  static Color get secondaryText {
    return isDay
        ? const Color(0xFF4B5160)
        : const Color(0xFFC0C2C8);
  }

  static Color get subtleText {
    return isDay
        ? const Color(0xFF687080)
        : const Color(0xFF9297A3);
  }

  static Color get card {
    return isDay
        ? const Color(0xFFF5F5F3)
        : const Color(0xFF11141C);
  }

  static Color get cardStrong {
    return isDay
        ? const Color(0xFFEEEDE9)
        : const Color(0xFF171C27);
  }

  static Color get outline {
    return isDay
        ? const Color(0xFFDADDE2)
        : warmWhite.withValues(alpha: 0.12);
  }

  static Color get input {
    return isDay
        ? const Color(0xFFF5F5F3)
        : const Color(0xFF151820);
  }

  static Color get navBar {
    return isDay
        ? Colors.white
        : const Color(0xFF050A1C);
  }

  static Color get navUnselected {
    return isDay
        ? const Color(0xFF555D6B)
        : const Color(0xFFA1A5AE);
  }
}