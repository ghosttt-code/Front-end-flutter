import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class ServicesScreen extends StatelessWidget {
  final VoidCallback onStartAI;
  final VoidCallback onDashboard;
  final VoidCallback onCompare;

  const ServicesScreen({
    super.key,
    required this.onStartAI,
    required this.onDashboard,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = AppColors.primaryText;
    final secondaryText = AppColors.secondaryText;
    final cardColor = AppColors.card;
    final borderColor = AppColors.outline;

    final fadeBase = AppColors.isDay
        ? Colors.white
        : const Color(0xFF02040C);

    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            125,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.amber.withValues(
                        alpha: 0.14,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.amber,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'LincolnLife',
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              SizedBox(
                height: 245,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0,
                      right: -22,
                      bottom: 0,
                      width: 245,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Opacity(
                          opacity:
                              AppColors.isDay ? 0.40 : 0.23,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1542037104857-ffbb0b9155fb'
                            '?auto=format&fit=crop&w=1000&q=85',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                fadeBase,
                                fadeBase.withValues(alpha: 0.98),
                                fadeBase.withValues(alpha: 0.90),
                                fadeBase.withValues(alpha: 0.62),
                                fadeBase.withValues(alpha: 0.18),
                                Colors.transparent,
                              ],
                              stops: const [
                                0,
                                0.24,
                                0.44,
                                0.63,
                                0.82,
                                1,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 65,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                fadeBase.withValues(alpha: 0.82),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 270,
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Protection made\nsimple.',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 36,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: 230,
                              child: Text(
                                'Clear guidance for protecting '
                                'the people who matter most.',
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 14,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Explore',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Choose what you need help with.',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 17),

              _ExploreItem(
                icon: Icons.auto_awesome_rounded,
                title: 'AI Needs Analyzer',
                subtitle: 'Build a personalized estimate with Aura',
                accent: AppColors.amber,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                onTap: onStartAI,
              ),

              const SizedBox(height: 9),

              _ExploreItem(
                icon: Icons.bar_chart_rounded,
                title: 'Coverage Estimate',
                subtitle: 'Review your recommended protection',
                accent: AppColors.auroraBlue,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                onTap: onDashboard,
              ),

              const SizedBox(height: 9),

              _ExploreItem(
                icon: Icons.compare_arrows_rounded,
                title: 'Term vs. Permanent',
                subtitle: 'Compare coverage options and tradeoffs',
                accent: AppColors.auroraViolet,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                onTap: onCompare,
              ),

              const SizedBox(height: 9),

              _ExploreItem(
                icon: Icons.family_restroom_rounded,
                title: 'Family Planning',
                subtitle: 'See how family needs affect your coverage',
                accent: AppColors.auroraGreen,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                onTap: onStartAI,
              ),

              const SizedBox(height: 28),

              InkWell(
                onTap: onStartAI,
                borderRadius: BorderRadius.circular(17),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.amber,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amber.withValues(
                                alpha: 0.22,
                              ),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy_outlined,
                          color: AppColors.ink,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Not sure where to start?',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Text(
                        'Ask Aura',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.amber,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Private • Educational guidance only',
                  style: TextStyle(
                    color: AppColors.subtleText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  final Color accent;
  final Color cardColor;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;

  final VoidCallback onTap;

  const _ExploreItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.cardColor,
    required this.borderColor,
    required this.primaryText,
    required this.secondaryText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11.5,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: secondaryText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}