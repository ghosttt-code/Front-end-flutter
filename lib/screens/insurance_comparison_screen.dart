import 'package:flutter/material.dart';

import '../models/insurance_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class InsuranceComparisonScreen extends StatelessWidget {
  final InsuranceProfile profile;

  const InsuranceComparisonScreen({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = AppColors.primaryText;
    final secondaryText = AppColors.secondaryText;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              22,
              10,
              22,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: primaryText,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Compare',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Term vs.\nWhole Life',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 36,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Both can protect the people you care about, '
                  'but they are designed for different needs.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                _PolicyCard(
                  title: 'Term Life',
                  badge: 'Simple protection',
                  icon: Icons.schedule_rounded,
                  accent: AppColors.amber,
                  description:
                      'Coverage lasts for a defined period, '
                      'such as 10, 20 or 30 years.',
                  points: const [
                    'Designed for a specific period',
                    'Generally simpler to understand',
                    'Useful during high-responsibility years',
                    'Can protect income, debt and family needs',
                  ],
                ),

                const SizedBox(height: 14),

                _PolicyCard(
                  title: 'Whole Life',
                  badge: 'Long-term coverage',
                  icon: Icons.all_inclusive_rounded,
                  accent: AppColors.auroraViolet,
                  description:
                      'Whole life is designed to provide '
                      'long-term permanent coverage.',
                  points: const [
                    'Designed for longer-term protection',
                    'May include additional policy features',
                    'Can involve more cost and complexity',
                    'May suit longer-term financial goals',
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  'For your situation',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(
                      alpha:
                          AppColors.isDay ? 0.14 : 0.09,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.amber.withValues(
                        alpha: 0.32,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.amberShadow,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _personalizedInsight(),
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 12.5,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'At a glance',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                _CompareRow(
                  label: 'Coverage length',
                  term: 'Set period',
                  whole: 'Long term',
                ),

                _CompareRow(
                  label: 'Complexity',
                  term: 'Lower',
                  whole: 'Higher',
                ),

                _CompareRow(
                  label: 'Primary focus',
                  term: 'Protection',
                  whole: 'Protection + features',
                ),

                const SizedBox(height: 26),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.outline,
                    ),
                  ),
                  child: Text(
                    'Educational comparison only. Policy costs, '
                    'features and suitability vary.',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 11,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _personalizedInsight() {
    if (profile.dependents > 0 && profile.debts > 0) {
      return 'Because you have ${profile.dependents} '
          '${profile.dependents == 1 ? 'dependent' : 'dependents'} '
          'and outstanding debt, term coverage may be worth exploring '
          'during the years when those financial responsibilities are '
          'highest. Permanent coverage may be worth comparing for '
          'longer-term goals.';
    }

    if (profile.dependents > 0) {
      return 'Because other people rely on your income, coverage '
          'during your major earning and family-support years may '
          'be particularly important.';
    }

    if (profile.debts > 0) {
      return 'Your outstanding debt is an important consideration. '
          'Term coverage may help protect those obligations during '
          'a defined period.';
    }

    return 'The better fit depends on how long you need protection, '
        'your financial responsibilities and whether you want '
        'additional long-term policy features.';
  }
}

class _PolicyCard extends StatelessWidget {
  final String title;
  final String badge;
  final String description;
  final IconData icon;
  final Color accent;
  final List<String> points;

  const _PolicyCard({
    required this.title,
    required this.badge,
    required this.description,
    required this.icon,
    required this.accent,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.13),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            description,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                        height: 1.4,
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
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String term;
  final String whole;

  const _CompareRow({
    required this.label,
    required this.term,
    required this.whole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _CompareValue(
                  title: 'TERM',
                  value: term,
                  color: AppColors.amberShadow,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _CompareValue(
                  title: 'WHOLE',
                  value: whole,
                  color: AppColors.auroraViolet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompareValue extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _CompareValue({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}