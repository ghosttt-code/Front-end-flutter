import 'package:flutter/material.dart';

import '../models/insurance_profile.dart';
import '../services/aura_api.dart';
import '../services/coverage_engine.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

/// Returned to the caller when a signed-in assessment completes: the updated
/// profile plus the backend's authoritative assessment (so downstream screens
/// show exactly what Aura calculated).
class AuraResult {
  final InsuranceProfile profile;
  final CoverageAssessment assessment;

  const AuraResult({required this.profile, required this.assessment});
}

class AiAssistantScreen extends StatefulWidget {
  final InsuranceProfile initialProfile;

  /// When true the screen is opened from the login/front page before the user
  /// has an account. It behaves identically but does not require a profile and
  /// does not auto-return a result (nothing downstream to update yet).
  final bool guestMode;

  const AiAssistantScreen({
    super.key,
    required this.initialProfile,
    this.guestMode = false,
  });

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AuraApi _api = AuraApi();

  /// What's shown in the UI.
  final List<_ChatMessage> _messages = [];

  /// Exact history sent to the backend (stateless server; we send it every turn).
  final List<ChatTurn> _history = [];

  late InsuranceProfile _profile;

  /// Guided options from the latest backend turn (empty => free-text expected).
  List<AuraOption> _options = [];

  bool _isTyping = false;
  bool _isComplete = false;

  /// The latest backend calculations (used to build the authoritative result).
  AuraCalculations? _lastCalc;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    // Fetch Aura's greeting from the backend (empty history => greeting, no LLM call).
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapGreeting());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _api.dispose();
    super.dispose();
  }

  bool get _isDay {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  Future<void> _bootstrapGreeting() async {
    setState(() => _isTyping = true);
    try {
      final res = await _api.chat(const []); // empty history returns the greeting
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: res.reply, isUser: false));
        _options = res.options;
      });
    } on AuraApiException {
      if (!mounted) return;
      setState(() {
        _messages.add(const _ChatMessage(
          text:
              'Hi, I’m Aura from Lincoln Life. I’m having trouble connecting '
              'right now — please make sure the Aura backend is running, then '
              'send a message to try again.',
          isUser: false,
        ));
      });
    } finally {
      if (mounted) setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _messageController.text).trim();
    if (text.isEmpty || _isTyping) return;

    _messageController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _history.add(ChatTurn(role: 'user', content: text));
      _options = []; // clear options as soon as the user answers
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final res = await _api.chat(_history);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: res.reply,
          isUser: false,
          disclaimer: res.calculations.isComplete ? res.disclaimer : null,
        ));
        _history.add(ChatTurn(role: 'assistant', content: res.reply));
        _options = res.options;
        _isComplete = res.calculations.isComplete;
        _lastCalc = res.calculations;
        // Backend owns the math; mirror the extracted figures into the app profile.
        _profile = res.profile.mergeInto(_profile);
      });
    } on AuraApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text:
              'Sorry, I couldn’t reach the assistant just now. $e\n\nPlease '
              'try again in a moment.',
          isUser: false,
        ));
        // Drop the unanswered user turn so retry doesn't duplicate it.
        if (_history.isNotEmpty && _history.last.role == 'user') {
          _history.removeLast();
        }
      });
    } finally {
      if (mounted) setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  /// Build the authoritative assessment from the backend's figures and return
  /// it (with the updated profile) to the caller.
  void _returnEstimate() {
    final calc = _lastCalc;
    if (calc == null || !calc.isComplete) {
      Navigator.pop(context, AuraResult(
        profile: _profile,
        assessment: CoverageEngine.assess(_profile),
      ));
      return;
    }
    final years = (_profile.annualIncome > 0 && calc.incomeNeeded != null)
        ? (calc.incomeNeeded! / _profile.annualIncome).round()
        : 0;
    final assessment = CoverageEngine.fromBackend(
      years: years,
      incomeReplacement: calc.incomeNeeded ?? 0,
      debts: calc.totalDebts ?? _profile.debts,
      futureNeeds: calc.futureGoals ?? _profile.futureNeeds,
      existingCoverage: calc.existingCoverage ?? _profile.existingCoverage,
      estimatedNeed: calc.recommendedCoverage ?? 0,
    );
    Navigator.pop(context, AuraResult(profile: _profile, assessment: assessment));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
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
    final primaryText = isDay ? AppColors.ink : AppColors.warmWhite;
    final secondaryText = isDay
        ? AppColors.ink.withValues(alpha: 0.58)
        : AppColors.warmWhite.withValues(alpha: 0.65);
    final auraBubble =
        isDay ? const Color(0xFFF3F2EE) : AppColors.auraBubble;
    final userBubble = AppColors.amber;
    final inputColor =
        isDay ? const Color(0xFFF7F7F5) : const Color(0xFF14171F);
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
                padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
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
                          BoxShadow(color: AppColors.badgeGlow, blurRadius: 18),
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

              Divider(height: 1, color: borderColor),

              // CHAT
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
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
                      secondaryText: secondaryText,
                    );
                  },
                ),
              ),

              // GUIDED OPTIONS (Claude-style chips from the backend)
              if (_options.isNotEmpty && !_isTyping)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final opt in _options)
                        _OptionChip(
                          label: opt.label,
                          onTap: () {
                            // Empty value => the option means "type your own".
                            if (opt.value.trim().isEmpty) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              return;
                            }
                            _sendMessage(opt.value);
                          },
                          textColor: primaryText,
                          borderColor: borderColor,
                        ),
                    ],
                  ),
                ),

              // VIEW ESTIMATE (only for signed-in flow once complete)
              if (_isComplete && !widget.guestMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _returnEstimate,
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
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),

              // INPUT
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: BoxDecoration(
                  color: isDay ? Colors.white : const Color(0xFF080B12),
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        enabled: !_isTyping,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: TextStyle(color: primaryText, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Ask Aura anything...',
                          hintStyle: TextStyle(color: secondaryText),
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
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(color: AppColors.amber),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    GestureDetector(
                      onTap: _isTyping ? null : _sendMessage,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _isTyping
                              ? AppColors.amber.withValues(alpha: 0.5)
                              : AppColors.amber,
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
  final String? disclaimer;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.disclaimer,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final Color auraBubble;
  final Color userBubble;
  final Color primaryText;
  final Color secondaryText;

  const _MessageBubble({
    required this.message,
    required this.auraBubble,
    required this.userBubble,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            margin: EdgeInsets.only(bottom: message.disclaimer == null ? 12 : 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: message.isUser ? userBubble : auraBubble,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(message.isUser ? 18 : 5),
                bottomRight: Radius.circular(message.isUser ? 5 : 18),
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
          if (message.disclaimer != null)
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Text(
                message.disclaimer!,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 10.5,
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final Color bubbleColor;
  final Color dotColor;

  const _TypingBubble({required this.bubbleColor, required this.dotColor});

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
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color borderColor;

  const _OptionChip({
    required this.label,
    required this.onTap,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.6)),
          color: AppColors.amber.withValues(alpha: 0.08),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
