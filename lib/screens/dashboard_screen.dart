import 'package:flutter/material.dart';

import '../models/insurance_profile.dart';
import '../services/coverage_engine.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class DashboardScreen extends StatelessWidget {
  final InsuranceProfile profile;

  /// Authoritative assessment from the Aura backend, when available.
  final CoverageAssessment? assessment;

  final VoidCallback onAskAI;
  final VoidCallback onRecalculate;
  final VoidCallback onCompare;

  const DashboardScreen({
    super.key,
    required this.profile,
    this.assessment,
    required this.onAskAI,
    required this.onRecalculate,
    required this.onCompare,
  });

  String _money(double value) {
    final text = value.round().toString();
    final result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final remaining = text.length - i;

      result.write(text[i]);

      if (remaining > 1 && remaining % 3 == 1) {
        result.write(',');
      }
    }

    return '\$${result.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    // Prefer the backend's authoritative numbers; fall back to a local estimate.
    final assessment = this.assessment ?? CoverageEngine.assess(profile);

    final primaryText = AppColors.primaryText;
    final secondaryText = AppColors.secondaryText;
    final cardColor = AppColors.card;
    final borderColor = AppColors.outline;

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
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                profile.name,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.isDay
                      ? const Color(0xFFFFF6E7)
                      : const Color(0xFF16191F),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.isDay
                        ? const Color(0xFFF0DDBD)
                        : AppColors.amber.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED COVERAGE NEED',
                      style: TextStyle(
                        color: AppColors.amberShadow,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _money(assessment.estimatedNeed),
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Personalized life insurance estimate',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Based on your income, debts, future needs '
                      'and existing coverage.',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Your breakdown',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Column(
                  children: [
                    _BreakdownRow(
                      label:
                          '${assessment.incomeReplacementYears} years income replacement',
                      value: _money(
                        assessment.incomeReplacement,
                      ),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                    Divider(
                      height: 1,
                      color: borderColor,
                    ),
                    _BreakdownRow(
                      label: 'Outstanding debt',
                      value: _money(assessment.debts),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                    Divider(
                      height: 1,
                      color: borderColor,
                    ),
                    _BreakdownRow(
                      label: 'Future family needs',
                      value: _money(assessment.futureNeeds),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                    Divider(
                      height: 1,
                      color: borderColor,
                    ),
                    _BreakdownRow(
                      label: 'Existing coverage',
                      value: '− ${_money(assessment.existingCoverage)}',
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      valueColor: AppColors.isDay
                          ? const Color(0xFF197A5A)
                          : AppColors.auroraGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Next steps',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              _ActionTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Ask Aura',
                subtitle: 'Ask questions about your estimate',
                accent: AppColors.amber,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                onTap: onAskAI,
              ),

              const SizedBox(height: 10),

              _ActionTile(
                icon: Icons.refresh_rounded,
                title: 'Update assessment',
                subtitle: 'Change income, debt or family needs',
                accent: AppColors.auroraBlue,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                onTap: onRecalculate,
              ),

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.amber,
                      size: 19,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'This estimate is educational and is not '
                        'a final insurance quote or recommendation.',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 11.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color primaryText;
  final Color secondaryText;
  final Color? valueColor;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.primaryText,
    required this.secondaryText,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? primaryText,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  final Color accent;
  final Color cardColor;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;

  final VoidCallback onTap;

  const _ActionTile({
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
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}