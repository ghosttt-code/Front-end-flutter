import 'package:flutter/material.dart';

import '../models/insurance_profile.dart';
import '../services/coverage_engine.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class AiAssistantScreen extends StatefulWidget {
  final InsuranceProfile initialProfile;

  const AiAssistantScreen({
    super.key,
    required this.initialProfile,
  });

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];

  late InsuranceProfile _profile;

  bool _isTyping = false;

  // -1 = normal chat
  // 0-4 = assessment questions
  // 5 = assessment complete
  int _assessmentStep = -1;

  @override
  void initState() {
    super.initState();

    _profile = widget.initialProfile;

    _messages.add(
      const _ChatMessage(
        text:
            'Hi, I’m Aura. I can help you understand life insurance, '
            'explain your coverage estimate, or guide you through a quick '
            'needs assessment. What would you like to know?',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isDay {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _messageController.text).trim();

    if (text.isEmpty || _isTyping) {
      return;
    }

    _messageController.clear();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );
    });

    _scrollToBottom();

    if (_assessmentStep >= 0 && _assessmentStep <= 4) {
      await _handleAssessmentAnswer(text);
      return;
    }

    await _handleNormalQuestion(text);
  }

  Future<void> _handleNormalQuestion(String text) async {
    final lower = text.toLowerCase();

    if (lower.contains('start assessment') ||
        lower.contains('start my assessment') ||
        lower.contains('calculate my coverage') ||
        lower.contains('coverage assessment')) {
      setState(() {
        _assessmentStep = 0;
      });

      await _reply(
        'Absolutely. I’ll ask five short questions and explain why each '
        'one matters.\n\nFirst, how many people depend on your income?',
      );

      return;
    }

    if (lower.contains('term') &&
        (lower.contains('whole') ||
            lower.contains('permanent') ||
            lower.contains('difference'))) {
      await _reply(
        'Term life covers you for a defined period, such as 10, 20, or '
        '30 years. It is usually focused on straightforward protection '
        'during years when financial responsibilities are high.\n\n'
        'Permanent life is designed to last much longer and may include '
        'additional features. Those features can make it more complex.\n\n'
        'For someone mainly trying to protect income, children, or a '
        'mortgage during key working years, term life may be worth exploring.',
      );

      return;
    }

    if (lower.contains('debt') ||
        lower.contains('mortgage') ||
        lower.contains('loan')) {
      await _reply(
        'Debt matters because financial obligations may remain even if '
        'the person who normally pays them dies. Including major debts '
        'in a needs estimate can help reduce the chance that those '
        'obligations become a burden on the family.',
      );

      return;
    }

    if (lower.contains('dependent') ||
        lower.contains('kids') ||
        lower.contains('children')) {
      await _reply(
        'Dependents affect the estimate because they may rely on your '
        'income for housing, food, childcare, education, and other '
        'expenses. More financial responsibility can mean a longer '
        'income-replacement period is worth considering.',
      );

      return;
    }

    if (lower.contains('existing coverage') ||
        lower.contains('already have') ||
        lower.contains('employer insurance')) {
      await _reply(
        'Existing life insurance reduces the additional amount you may '
        'need. LincolnLife subtracts the coverage you already have from '
        'the estimated need so the recommendation does not simply stack '
        'new coverage on top of your current protection.',
      );

      return;
    }

    if (lower.contains('income')) {
      await _reply(
        'Income is used to estimate how much financial support your '
        'household could lose. LincolnLife combines income replacement '
        'with debts and future family needs, then subtracts existing '
        'coverage.',
      );

      return;
    }

    if (lower.contains('private') ||
        lower.contains('privacy') ||
        lower.contains('secure') ||
        lower.contains('security')) {
      await _reply(
        'Your assessment should only use the information needed to '
        'produce the estimate. Password authentication is handled '
        'separately by a managed authentication service rather than '
        'being built into Aura itself.',
      );

      return;
    }

    if (lower.contains('how much') ||
        lower.contains('coverage') ||
        lower.contains('need')) {
      await _reply(
        'I can help calculate that. I’ll use income replacement, major '
        'debts, future family needs, and any coverage you already have.\n\n'
        'Type “Start my assessment” and I’ll walk you through it.',
      );

      return;
    }

    if (lower.contains('hello') ||
        lower.contains('hi ') ||
        lower == 'hi' ||
        lower.contains('hey')) {
      await _reply(
        'Hi! Ask me anything about life insurance, or type '
        '“Start my assessment” if you want a personalized estimate.',
      );

      return;
    }

    await _reply(
      'I can help explain coverage estimates, dependents, income '
      'replacement, debt, existing coverage, and term versus permanent '
      'life insurance.\n\n'
      'You can also type “Start my assessment” and I’ll build an '
      'estimate with you.',
    );
  }

  Future<void> _handleAssessmentAnswer(String text) async {
    switch (_assessmentStep) {
      case 0:
        final dependents = int.tryParse(
          text.replaceAll(RegExp(r'[^0-9]'), ''),
        );

        if (dependents == null) {
          await _reply(
            'Please enter the number of people who financially depend '
            'on you. For example: 0, 1, 2, or 3.',
          );
          return;
        }

        _profile = _profile.copyWith(
          dependents: dependents,
        );

        setState(() {
          _assessmentStep = 1;
        });

        await _reply(
          dependents == 0
              ? 'Got it — no financial dependents. What is your approximate annual income?'
              : 'Got it — $dependents dependent${dependents == 1 ? '' : 's'}. '
                  'What is your approximate annual income?',
        );

        break;

      case 1:
        final income = _parseMoney(text);

        if (income == null) {
          await _reply(
            'I couldn’t read that amount. Try something like '
            '\$75,000 or 75000.',
          );
          return;
        }

        _profile = _profile.copyWith(
          annualIncome: income,
        );

        setState(() {
          _assessmentStep = 2;
        });

        await _reply(
          'Thanks. Now tell me approximately how much major outstanding '
          'debt you would want covered — mortgage, student loans, car '
          'loans, or other significant obligations.',
        );

        break;

      case 2:
        final debt = _parseMoney(text);

        if (debt == null) {
          await _reply(
            'Please enter an approximate dollar amount. You can enter '
            '0 if you do not want to include any debt.',
          );
          return;
        }

        _profile = _profile.copyWith(
          debts: debt,
        );

        setState(() {
          _assessmentStep = 3;
        });

        await _reply(
          'Understood. How much would you like to account for in future '
          'family needs, such as education, childcare, or other major '
          'future expenses?',
        );

        break;

      case 3:
        final future = _parseMoney(text);

        if (future == null) {
          await _reply(
            'Please enter an approximate dollar amount, or 0 if you '
            'do not want to include additional future expenses.',
          );
          return;
        }

        _profile = _profile.copyWith(
          futureNeeds: future,
        );

        setState(() {
          _assessmentStep = 4;
        });

        await _reply(
          'Last question. How much life insurance coverage do you '
          'already have? Include employer coverage if you know the amount.',
        );

        break;

      case 4:
        final existing = _parseMoney(text);

        if (existing == null) {
          await _reply(
            'Please enter an approximate dollar amount, or 0 if you '
            'do not currently have life insurance.',
          );
          return;
        }

        _profile = _profile.copyWith(
          existingCoverage: existing,
        );

        setState(() {
          _assessmentStep = 5;
        });

        final assessment = CoverageEngine.assess(_profile);

        await _reply(
          'Your assessment is ready.\n\n'
          'Based on the information you entered, your estimated coverage '
          'need is about ${_formatMoney(assessment.estimatedNeed)}.\n\n'
          'That includes ${_formatMoney(assessment.incomeReplacement)} '
          'for income replacement, ${_formatMoney(assessment.debts)} '
          'for debt, and ${_formatMoney(assessment.futureNeeds)} for '
          'future needs, minus ${_formatMoney(assessment.existingCoverage)} '
          'in existing coverage.\n\n'
          'This is an educational estimate, not a final insurance quote.',
        );

        break;
    }
  }

  double? _parseMoney(String text) {
    final cleaned = text
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.]'), '');

    if (cleaned.isEmpty) {
      return null;
    }

    return double.tryParse(cleaned);
  }

  String _formatMoney(double value) {
    final number = value.round().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < number.length; i++) {
      final remaining = number.length - i;

      buffer.write(number[i]);

      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return '\$${buffer.toString()}';
  }

  Future<void> _reply(String text) async {
    setState(() {
      _isTyping = true;
    });

    _scrollToBottom();

    await Future.delayed(
      const Duration(milliseconds: 550),
    );

    if (!mounted) return;

    setState(() {
      _isTyping = false;

      _messages.add(
        _ChatMessage(
          text: text,
          isUser: false,
        ),
      );
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDay = _isDay;

    final primaryText =
        isDay ? AppColors.ink : AppColors.warmWhite;

    final secondaryText = isDay
        ? AppColors.ink.withValues(alpha: 0.58)
        : AppColors.warmWhite.withValues(alpha: 0.65);

    final auraBubble = isDay
        ? const Color(0xFFF3F2EE)
        : AppColors.auraBubble;

    final userBubble = AppColors.amber;

    final inputColor = isDay
        ? const Color(0xFFF7F7F5)
        : const Color(0xFF14171F);

    final borderColor = isDay
        ? const Color(0xFFE8E6E1)
        : AppColors.warmWhite.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  8,
                  16,
                  8,
                ),
                child: Row(
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

                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.badgeGlow,
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy_outlined,
                        color: AppColors.ink,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aura',
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'AI insurance assistant',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.auroraGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                color: borderColor,
              ),

              // CHAT
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    22,
                    18,
                    18,
                  ),
                  itemCount:
                      _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _TypingBubble(
                        bubbleColor: auraBubble,
                        dotColor: secondaryText,
                      );
                    }

                    final message = _messages[index];

                    return _MessageBubble(
                      message: message,
                      auraBubble: auraBubble,
                      userBubble: userBubble,
                      primaryText: primaryText,
                    );
                  },
                ),
              ),

              // QUICK QUESTIONS
              if (_messages.length <= 2 && _assessmentStep == -1)
                SizedBox(
                  height: 39,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _QuickPrompt(
                        text: 'Start assessment',
                        onTap: () {
                          _sendMessage('Start my assessment');
                        },
                        textColor: primaryText,
                        borderColor: borderColor,
                      ),
                      _QuickPrompt(
                        text: 'Term vs whole?',
                        onTap: () {
                          _sendMessage(
                            'What is the difference between term and whole life?',
                          );
                        },
                        textColor: primaryText,
                        borderColor: borderColor,
                      ),
                      _QuickPrompt(
                        text: 'Why does debt matter?',
                        onTap: () {
                          _sendMessage(
                            'Why does debt matter for life insurance?',
                          );
                        },
                        textColor: primaryText,
                        borderColor: borderColor,
                      ),
                    ],
                  ),
                ),

              if (_assessmentStep == 5)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    4,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _profile,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        foregroundColor: AppColors.ink,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'View My Full Estimate',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

              // INPUT
              Container(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  12,
                ),
                decoration: BoxDecoration(
                  color: isDay
                      ? Colors.white
                      : const Color(0xFF080B12),
                  border: Border(
                    top: BorderSide(
                      color: borderColor,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          _sendMessage();
                        },
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              _assessmentStep >= 0 && _assessmentStep <= 4
                                  ? 'Type your answer...'
                                  : 'Ask Aura anything...',
                          hintStyle: TextStyle(
                            color: secondaryText,
                          ),
                          filled: true,
                          fillColor: inputColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide(
                              color: borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(
                              color: AppColors.amber,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 9),

                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: AppColors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.ink,
                          size: 22,
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

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final Color auraBubble;
  final Color userBubble;
  final Color primaryText;

  const _MessageBubble({
    required this.message,
    required this.auraBubble,
    required this.userBubble,
    required this.primaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? userBubble : auraBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              message.isUser ? 18 : 5,
            ),
            bottomRight: Radius.circular(
              message.isUser ? 5 : 18,
            ),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? AppColors.ink : primaryText,
            fontSize: 13.5,
            height: 1.42,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final Color bubbleColor;
  final Color dotColor;

  const _TypingBubble({
    required this.bubbleColor,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 62,
        height: 38,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(),
            const SizedBox(width: 4),
            _dot(),
            const SizedBox(width: 4),
            _dot(),
          ],
        ),
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _QuickPrompt extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color textColor;
  final Color borderColor;

  const _QuickPrompt({
    required this.text,
    required this.onTap,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}