import 'package:flutter/material.dart';

import '../models/insurance_profile.dart';
import '../services/coverage_engine.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

enum ResultsAction {
  dashboard,
  compare,
}

class ResultsScreen extends StatelessWidget {
  final InsuranceProfile profile;

  const ResultsScreen({
    super.key,
    required this.profile,
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
    final assessment = CoverageEngine.assess(profile);

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
              30,
            ),
            child: Column(
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
                    const Spacer(),
                    Text(
                      'Your Results',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 28),

                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.amber,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amber.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.ink,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Your personalized\nestimate is ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 30,
                    height: 1.06,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Aura used your answers to build a clear '
                  'coverage estimate.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                      const Text(
                        'ESTIMATED COVERAGE NEED',
                        style: TextStyle(
                          color: AppColors.amberShadow,
                          fontSize: 10,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Text(
                        _money(assessment.estimatedNeed),
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 39,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${assessment.incomeReplacementYears} years of '
                        'income replacement plus major obligations '
                        'and future needs, minus existing coverage.',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _ResultRow(
                        label: 'Income replacement',
                        value: _money(
                          assessment.incomeReplacement,
                        ),
                      ),

                      _ResultRow(
                        label: 'Outstanding debts',
                        value: '+ ${_money(assessment.debts)}',
                      ),

                      _ResultRow(
                        label: 'Future needs',
                        value:
                            '+ ${_money(assessment.futureNeeds)}',
                      ),

                      _ResultRow(
                        label: 'Existing coverage',
                        value:
                            '− ${_money(assessment.existingCoverage)}',
                        valueColor: AppColors.isDay
                            ? const Color(0xFF197A5A)
                            : AppColors.auroraGreen,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.outline,
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
                          'This is an educational estimate, not a '
                          'final quote or policy recommendation.',
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

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        ResultsAction.dashboard,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.amber,
                      foregroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'View Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        ResultsAction.compare,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryText,
                      side: BorderSide(
                        color: AppColors.outline,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Compare Term vs. Whole Life',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
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
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.primaryText,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}