import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'post_login_shell.dart';

// ============================================================
// LINCOLNLIFE COLORS
// ============================================================

const Color _ink = Color(0xFF050A1C);
const Color _warmWhite = Color(0xFFF6F3EC);

const Color _amber = Color(0xFFFFC670);
const Color _amberHi = Color(0xFFFFE0A8);
const Color _amberShadow = Color(0xFFEFA546);

const Color _panel = Color(0xFF171C27);
const Color _field = Color(0xFF202530);

const Color _skyTop = Color(0xFF040A1C);
const Color _skyMiddle = Color(0xFF0D1B40);
const Color _skyHorizon = Color(0xFF3B3567);

const Color _mountainFar = Color(0xFF20264F);
const Color _mountainMiddle = Color(0xFF141A3C);
const Color _mountainNear = Color(0xFF0A0F26);

const Color _shore = Color(0xFF060A18);

const Color _auroraGreen = Color(0xFF60F0BE);
const Color _auroraBlue = Color(0xFF78AAFF);
const Color _auroraViolet = Color(0xFFBE82FF);

// ============================================================
// MAIN OPENING / LOGIN SCREEN
// ============================================================

class OpeningLoginScreen extends StatefulWidget {
  const OpeningLoginScreen({
    super.key,
  });

  @override
  State<OpeningLoginScreen> createState() =>
      _OpeningLoginScreenState();
}

class _OpeningLoginScreenState
    extends State<OpeningLoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _openingController;
  late final AnimationController _skyController;

  bool _showLogin = false;

  bool _auraOpen = false;
  bool _auraQuestion = true;

  String _auraText =
      'Hey, this is Aura. Do you need help signing in or signing up?';

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // Opening sequence
    //
    // First:
    // logo sits in the center
    //
    // Then:
    // it spirals toward the bottom-right
    //
    // Finally:
    // login screen appears
    // ----------------------------------------------------------

    _openingController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 4900,
      ),
    )
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed &&
              mounted) {
            setState(() {
              _showLogin = true;
            });

            _skyController.repeat();

            // Aura opens shortly after the login page appears.
            Future<void>.delayed(
              const Duration(
                milliseconds: 900,
              ),
              () {
                if (mounted) {
                  setState(() {
                    _auraOpen = true;
                  });
                }
              },
            );
          }
        },
      )
      ..forward();

    // Slow background animation.
    _skyController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 18,
      ),
    );
  }

  @override
  void dispose() {
    _openingController.dispose();
    _skyController.dispose();

    super.dispose();
  }

  // ============================================================
  // AURA
  // ============================================================

  void _toggleAura() {
    setState(() {
      _auraOpen = !_auraOpen;

      if (_auraOpen) {
        _auraQuestion = true;

        _auraText =
            'Hey, this is Aura. Do you need help signing in or signing up?';
      }
    });
  }

  void _answerAura(
    bool yes,
  ) {
    setState(() {
      _auraQuestion = false;

      if (yes) {
        _auraText =
            'New here? Tap Sign up. If not, sign in with your email.';
      } else {
        _auraText =
            'No problem. Tap me any time.';
      }
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _ink,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_showLogin)
              _LoginScene(
                skyController:
                    _skyController,
                auraOpen:
                    _auraOpen,
                auraQuestion:
                    _auraQuestion,
                auraText:
                    _auraText,
                onAuraTap:
                    _toggleAura,
                onAuraYes: () {
                  _answerAura(
                    true,
                  );
                },
                onAuraNo: () {
                  _answerAura(
                    false,
                  );
                },
              )
            else
              _OpeningLoader(
                controller:
                    _openingController,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// OPENING ANIMATION
// ============================================================

class _OpeningLoader extends StatelessWidget {
  final AnimationController controller;

  const _OpeningLoader({
    required this.controller,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final size =
        MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (
        context,
        child,
      ) {
        final t =
            controller.value;

        // Logo stays in the center for roughly
        // the first half of the animation.
        final moveT =
            ((t - 0.53) / 0.47)
                .clamp(
          0.0,
          1.0,
        );

        final eased =
            Curves.easeInOutCubic
                .transform(
          moveT,
        );

        final center =
            Offset(
          size.width / 2,
          size.height / 2,
        );

        // Destination is the Aura position.
        final destination =
            Offset(
          size.width - 54,
          size.height - 76,
        );

        // Spiral motion.
        final angle =
            -math.pi / 2 +
                math.pi *
                    3 *
                    eased;

        final radius =
            72 *
                math.sin(
                  math.pi *
                      eased,
                );

        final x =
            center.dx +
                (destination.dx -
                        center.dx) *
                    eased +
                math.cos(
                      angle,
                    ) *
                    radius;

        final y =
            center.dy +
                (destination.dy -
                        center.dy) *
                    eased +
                math.sin(
                      angle,
                    ) *
                    radius;

        final scale =
            1.0 -
                (0.48 *
                    eased);

        final fadeText =
            (1.0 -
                    (moveT *
                        1.5))
                .clamp(
          0.0,
          1.0,
        );

        final pulse =
            0.5 +
                0.5 *
                    math.sin(
                      t *
                          math.pi *
                          8,
                    );

        return Stack(
          fit: StackFit.expand,
          children: [
            // ----------------------------------------------------
            // DARK LOADER BACKGROUND
            // ----------------------------------------------------

            const DecoratedBox(
              decoration:
                  BoxDecoration(
                gradient:
                    RadialGradient(
                  center:
                      Alignment(
                    0,
                    -0.15,
                  ),
                  radius:
                      0.9,
                  colors: [
                    Color(
                      0xFF121A2E,
                    ),
                    Color(
                      0xFF070A12,
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------
            // FALLING LIGHT
            // ----------------------------------------------------

            Positioned.fill(
              child: CustomPaint(
                painter:
                    _FallingLightPainter(
                  t,
                ),
              ),
            ),

            // ----------------------------------------------------
            // LINCOLNLIFE WORDMARK
            // ----------------------------------------------------

            if (fadeText > 0)
              Positioned(
                left: 0,
                right: 0,
                top:
                    size.height *
                        0.63,
                child: Opacity(
                  opacity:
                      fadeText,
                  child:
                      const Column(
                    children: [
                      Text(
                        'LincolnLife',
                        style:
                            TextStyle(
                          color:
                              _warmWhite,
                          fontSize:
                              25,
                          fontWeight:
                              FontWeight
                                  .w800,
                          letterSpacing:
                              -0.8,
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Protection made simple.',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xBDF6F3EC,
                          ),
                          fontSize:
                              12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ----------------------------------------------------
            // ANIMATED LINCOLNLIFE BADGE
            // ----------------------------------------------------

            Positioned(
              left:
                  x -
                      42 *
                          scale,
              top:
                  y -
                      42 *
                          scale,
              child:
                  Transform.rotate(
                angle:
                    math.pi *
                        2 *
                        eased,
                child:
                    Transform.scale(
                  scale:
                      scale,
                  child:
                      _LincolnBadge(
                    size:
                        84,
                    glowStrength:
                        0.75 +
                            pulse *
                                0.25,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// LINCOLNLIFE LOGO / BADGE
// ============================================================

class _LincolnBadge extends StatelessWidget {
  final double size;
  final double glowStrength;

  const _LincolnBadge({
    required this.size,
    this.glowStrength = 1,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,

        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            _amberHi,
            _amber,
            _amberShadow,
          ],
        ),

        boxShadow: [
          BoxShadow(
            color:
                _amber.withValues(
              alpha:
                  0.28 *
                      glowStrength,
            ),
            blurRadius:
                32 *
                    glowStrength,
            spreadRadius:
                4,
          ),
        ],
      ),
      child: Container(
        margin:
            const EdgeInsets.all(
          5,
        ),
        decoration:
            const BoxDecoration(
          color: _ink,
          shape:
              BoxShape.circle,
        ),
        child:
            const Icon(
          Icons.shield_outlined,
          color: _amber,
          size: 34,
        ),
      ),
    );
  }
}

// ============================================================
// FALLING LIGHT EFFECT
// ============================================================

class _FallingLightPainter
    extends CustomPainter {
  final double t;

  _FallingLightPainter(
    this.t,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final random =
        math.Random(
      7,
    );

    for (int i = 0;
        i < 42;
        i++) {
      final x =
          random.nextDouble() *
              size.width;

      final baseY =
          random.nextDouble() *
              size.height;

      final speed =
          80 +
              random.nextDouble() *
                  140;

      final y =
          (baseY +
                  t *
                      speed *
                      7) %
              size.height;

      final length =
          5 +
              random.nextDouble() *
                  18;

      final alpha =
          0.06 +
              random.nextDouble() *
                  0.14;

      final paint =
          Paint()
            ..strokeWidth =
                random.nextDouble() >
                        0.85
                    ? 1.4
                    : 0.7
            ..strokeCap =
                StrokeCap.round
            ..color =
                _warmWhite
                    .withValues(
              alpha:
                  alpha,
            );

      canvas.drawLine(
        Offset(
          x,
          y,
        ),
        Offset(
          x,
          y + length,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _FallingLightPainter
        oldDelegate,
  ) {
    return oldDelegate.t !=
        t;
  }
}

// ============================================================
// LOGIN SCENE
// ============================================================

class _LoginScene extends StatelessWidget {
  final AnimationController
      skyController;

  final bool auraOpen;
  final bool auraQuestion;

  final String auraText;

  final VoidCallback onAuraTap;
  final VoidCallback onAuraYes;
  final VoidCallback onAuraNo;

  const _LoginScene({
    required this.skyController,
    required this.auraOpen,
    required this.auraQuestion,
    required this.auraText,
    required this.onAuraTap,
    required this.onAuraYes,
    required this.onAuraNo,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // --------------------------------------------------------
        // NIGHT SKY
        // --------------------------------------------------------

        AnimatedBuilder(
          animation:
              skyController,
          builder: (
            context,
            child,
          ) {
            return CustomPaint(
              painter:
                  _NightScenePainter(
                skyController.value,
              ),
            );
          },
        ),

        // --------------------------------------------------------
        // LOGIN CONTENT
        // --------------------------------------------------------

        SafeArea(
          child:
              SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
            padding:
                EdgeInsets.fromLTRB(
              22,
              24,
              22,
              118 +
                  MediaQuery
                      .viewInsetsOf(
                    context,
                  )
                      .bottom,
            ),
            child:
                const Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                _BrandHeader(),

                SizedBox(
                  height: 24,
                ),

                _AuthCard(),
              ],
            ),
          ),
        ),

        // --------------------------------------------------------
        // AURA CHAT BUBBLE
        // --------------------------------------------------------

        if (auraOpen)
          Positioned(
            right: 20,
            bottom: 108,
            child:
                _AuraBubble(
              text:
                  auraText,
              showActions:
                  auraQuestion,
              onYes:
                  onAuraYes,
              onNo:
                  onAuraNo,
            ),
          ),

        // --------------------------------------------------------
        // AURA BUTTON
        // --------------------------------------------------------

        Positioned(
          right: 18,
          bottom: 28,
          child:
              GestureDetector(
            onTap:
                onAuraTap,
            child:
                const _LincolnBadge(
              size: 58,
              glowStrength:
                  1,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LINCOLNLIFE BRAND HEADER
// ============================================================

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,
            color:
                _amber.withValues(
              alpha: 0.14,
            ),
            border:
                Border.all(
              color:
                  _amber
                      .withValues(
                alpha: 0.25,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _amber
                        .withValues(
                  alpha:
                      0.12,
                ),
                blurRadius:
                    18,
              ),
            ],
          ),
          child:
              const Icon(
            Icons.shield_outlined,
            color:
                _amber,
            size:
                22,
          ),
        ),

        const SizedBox(
          width: 11,
        ),

        const Text(
          'LincolnLife',
          style:
              TextStyle(
            color:
                _warmWhite,
            fontSize:
                20,
            fontWeight:
                FontWeight
                    .w800,
            letterSpacing:
                -0.6,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LOGIN / SIGNUP CARD
// ============================================================

class _AuthCard extends StatefulWidget {
  const _AuthCard();

  @override
  State<_AuthCard> createState() =>
      _AuthCardState();
}

class _AuthCardState
    extends State<_AuthCard> {
  final TextEditingController
      _nameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  bool _signUp = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // ENTER MAIN APP
  // ============================================================

  void _enterApp() {
    FocusScope.of(
      context,
    ).unfocus();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PostLoginShell(),
      ),
    );
  }

  // ============================================================
  // NORMAL AUTH
  //
  // Your friend's backend should be connected HERE.
  // ============================================================

  Future<void> _submit() async {
    /*
      Later:

      final result = await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result.success) {
        _enterApp();
      }
    */

    // Temporary demo handoff.
    _enterApp();
  }

  // ============================================================
  // GOOGLE AUTH
  //
  // Your friend's managed Google authentication goes HERE.
  // ============================================================

  Future<void> _google() async {
    /*
      Later:

      final result =
          await authService.signInWithGoogle();

      if (result.success) {
        _enterApp();
      }
    */

    // Temporary demo handoff.
    _enterApp();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        color:
            _panel.withValues(
          alpha: 0.83,
        ),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border:
            Border.all(
          color:
              _warmWhite
                  .withValues(
            alpha: 0.12,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha:
                  0.24,
            ),
            blurRadius:
                30,
            offset:
                const Offset(
              0,
              16,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------

          Text(
            _signUp
                ? 'Create your account'
                : 'Welcome back',
            style:
                const TextStyle(
              color:
                  _warmWhite,
              fontSize:
                  28,
              height:
                  1.05,
              fontWeight:
                  FontWeight
                      .w900,
              letterSpacing:
                  -0.9,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            _signUp
                ? 'Start your personalized coverage journey.'
                : 'Sign in to continue your coverage journey.',
            style:
                TextStyle(
              color:
                  _warmWhite
                      .withValues(
                alpha:
                    0.68,
              ),
              fontSize:
                  13,
              height:
                  1.45,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          // ------------------------------------------------------
          // SIGN IN / SIGN UP SELECTOR
          // ------------------------------------------------------

          Container(
            height: 45,
            padding:
                const EdgeInsets.all(
              4,
            ),
            decoration:
                BoxDecoration(
              color:
                  _warmWhite
                      .withValues(
                alpha:
                    0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child:
                Row(
              children: [
                Expanded(
                  child:
                      _SegmentButton(
                    label:
                        'Sign in',
                    selected:
                        !_signUp,
                    onTap:
                        () {
                      setState(
                        () {
                          _signUp =
                              false;
                        },
                      );
                    },
                  ),
                ),

                Expanded(
                  child:
                      _SegmentButton(
                    label:
                        'Sign up',
                    selected:
                        _signUp,
                    onTap:
                        () {
                      setState(
                        () {
                          _signUp =
                              true;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // ------------------------------------------------------
          // NAME — ONLY SIGN UP
          // ------------------------------------------------------

          if (_signUp) ...[
            _LoginField(
              controller:
                  _nameController,
              hint:
                  'Full name',
              icon:
                  Icons
                      .person_outline_rounded,
            ),

            const SizedBox(
              height: 11,
            ),
          ],

          // ------------------------------------------------------
          // EMAIL
          // ------------------------------------------------------

          _LoginField(
            controller:
                _emailController,
            hint:
                'Email address',
            icon:
                Icons.mail_outline_rounded,
            keyboardType:
                TextInputType.emailAddress,
          ),

          const SizedBox(
            height: 11,
          ),

          // ------------------------------------------------------
          // PASSWORD
          // ------------------------------------------------------

          TextField(
            controller:
                _passwordController,
            obscureText:
                !_showPassword,
            style:
                const TextStyle(
              color:
                  _warmWhite,
              fontSize:
                  14,
            ),
            decoration:
                _inputDecoration(
              hint:
                  'Password',
              icon:
                  Icons.lock_outline_rounded,
              suffix:
                  IconButton(
                onPressed:
                    () {
                  setState(
                    () {
                      _showPassword =
                          !_showPassword;
                    },
                  );
                },
                icon:
                    Icon(
                  _showPassword
                      ? Icons
                          .visibility_off_outlined
                      : Icons
                          .visibility_outlined,
                  color:
                      _warmWhite
                          .withValues(
                    alpha:
                        0.55,
                  ),
                  size:
                      20,
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // FORGOT PASSWORD
          // ------------------------------------------------------

          if (!_signUp) ...[
            const SizedBox(
              height: 6,
            ),

            Align(
              alignment:
                  Alignment.centerRight,
              child:
                  TextButton(
                onPressed:
                    () {
                  // Password reset can be connected
                  // to backend later.
                },
                style:
                    TextButton.styleFrom(
                  foregroundColor:
                      _amber,
                ),
                child:
                    const Text(
                  'Forgot password?',
                  style:
                      TextStyle(
                    fontSize:
                        11.5,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(
              height: 16,
            ),

          // ------------------------------------------------------
          // MAIN BUTTON
          // ------------------------------------------------------

          SizedBox(
            height: 52,
            child:
                ElevatedButton(
              onPressed:
                  _submit,
              style:
                  ElevatedButton.styleFrom(
                elevation:
                    0,
                backgroundColor:
                    _amber,
                foregroundColor:
                    _ink,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child:
                  Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    _signUp
                        ? 'Create Account'
                        : 'Sign In',
                    style:
                        const TextStyle(
                      fontSize:
                          14,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    width: 7,
                  ),

                  const Icon(
                    Icons
                        .arrow_forward_rounded,
                    size:
                        18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          // ------------------------------------------------------
          // OR
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child:
                    Divider(
                  color:
                      _warmWhite
                          .withValues(
                    alpha:
                        0.10,
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      10,
                ),
                child:
                    Text(
                  'OR',
                  style:
                      TextStyle(
                    color:
                        _warmWhite
                            .withValues(
                      alpha:
                          0.48,
                    ),
                    fontSize:
                        10,
                  ),
                ),
              ),

              Expanded(
                child:
                    Divider(
                  color:
                      _warmWhite
                          .withValues(
                    alpha:
                        0.10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ------------------------------------------------------
          // GOOGLE
          // ------------------------------------------------------

          SizedBox(
            height: 50,
            child:
                OutlinedButton(
              onPressed:
                  _google,
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    _warmWhite,
                side:
                    BorderSide(
                  color:
                      _warmWhite
                          .withValues(
                    alpha:
                        0.16,
                  ),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child:
                  const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  _GoogleMark(),

                  SizedBox(
                    width: 10,
                  ),

                  Text(
                    'Continue with Google',
                    style:
                        TextStyle(
                      fontSize:
                          13,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 17,
          ),

          // ------------------------------------------------------
          // SECURITY NOTE
          // ------------------------------------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color:
                    _warmWhite
                        .withValues(
                  alpha:
                      0.45,
                ),
                size:
                    13,
              ),

              const SizedBox(
                width: 5,
              ),

              Text(
                'Secure authentication • Your privacy matters',
                style:
                    TextStyle(
                  color:
                      _warmWhite
                          .withValues(
                    alpha:
                        0.45,
                  ),
                  fontSize:
                      9.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SIGN IN / SIGN UP SEGMENT
// ============================================================

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap:
          onTap,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds:
              180,
        ),
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          color:
              selected
                  ? _warmWhite
                      .withValues(
                      alpha:
                          0.20,
                    )
                  : Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        child:
            Text(
          label,
          style:
              TextStyle(
            color:
                selected
                    ? _warmWhite
                    : _warmWhite
                        .withValues(
                        alpha:
                            0.55,
                      ),
            fontSize:
                12.5,
            fontWeight:
                selected
                    ? FontWeight
                        .w700
                    : FontWeight
                        .w500,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NORMAL INPUT FIELD
// ============================================================

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  final TextInputType keyboardType;

  const _LoginField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType =
        TextInputType.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return TextField(
      controller:
          controller,
      keyboardType:
          keyboardType,
      style:
          const TextStyle(
        color:
            _warmWhite,
        fontSize:
            14,
      ),
      decoration:
          _inputDecoration(
        hint:
            hint,
        icon:
            icon,
      ),
    );
  }
}

// ============================================================
// INPUT DECORATION
// ============================================================

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText:
        hint,

    hintStyle:
        TextStyle(
      color:
          _warmWhite.withValues(
        alpha:
            0.48,
      ),
      fontSize:
          13.5,
    ),

    prefixIcon:
        Icon(
      icon,
      color:
          _warmWhite.withValues(
        alpha:
            0.52,
      ),
      size:
          19,
    ),

    suffixIcon:
        suffix,

    filled:
        true,

    fillColor:
        _field.withValues(
      alpha:
          0.86,
    ),

    contentPadding:
        const EdgeInsets.symmetric(
      horizontal:
          15,
      vertical:
          15,
    ),

    border:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      borderSide:
          BorderSide(
        color:
            _warmWhite.withValues(
          alpha:
              0.16,
        ),
      ),
    ),

    enabledBorder:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      borderSide:
          BorderSide(
        color:
            _warmWhite.withValues(
          alpha:
              0.14,
        ),
      ),
    ),

    focusedBorder:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      borderSide:
          const BorderSide(
        color:
            _amber,
        width:
            1.4,
      ),
    ),
  );
}

// ============================================================
// GOOGLE MARK
// ============================================================

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          25,
      height:
          25,
      alignment:
          Alignment.center,
      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,
        color:
            _warmWhite.withValues(
          alpha:
              0.08,
        ),
        border:
            Border.all(
          color:
              _warmWhite
                  .withValues(
            alpha:
                0.12,
          ),
        ),
      ),
      child:
          const Text(
        'G',
        style:
            TextStyle(
          color:
              _warmWhite,
          fontSize:
              13,
          fontWeight:
              FontWeight
                  .w900,
        ),
      ),
    );
  }
}

// ============================================================
// AURA LOGIN HELP BUBBLE
// ============================================================

class _AuraBubble extends StatelessWidget {
  final String text;
  final bool showActions;

  final VoidCallback onYes;
  final VoidCallback onNo;

  const _AuraBubble({
    required this.text,
    required this.showActions,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final maxWidth =
        math.min(
      MediaQuery.sizeOf(
            context,
          ).width -
          52,
      300.0,
    );

    return Container(
      width:
          maxWidth,
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            _panel.withValues(
          alpha:
              0.96,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border:
            Border.all(
          color:
              _warmWhite
                  .withValues(
            alpha:
                0.12,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha:
                  0.28,
            ),
            blurRadius:
                22,
            offset:
                const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color:
                    _amber,
                size:
                    15,
              ),

              SizedBox(
                width:
                    6,
              ),

              Text(
                'Aura',
                style:
                    TextStyle(
                  color:
                      _amber,
                  fontSize:
                      12,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                9,
          ),

          Text(
            text,
            style:
                const TextStyle(
              color:
                  _warmWhite,
              fontSize:
                  12.5,
              height:
                  1.42,
            ),
          ),

          if (showActions) ...[
            const SizedBox(
              height:
                  12,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton(
                    onPressed:
                        onNo,
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          _warmWhite,
                      side:
                          BorderSide(
                        color:
                            _warmWhite
                                .withValues(
                          alpha:
                              0.15,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'No',
                    ),
                  ),
                ),

                const SizedBox(
                  width:
                      8,
                ),

                Expanded(
                  child:
                      ElevatedButton(
                    onPressed:
                        onYes,
                    style:
                        ElevatedButton.styleFrom(
                      elevation:
                          0,
                      backgroundColor:
                          _amber,
                      foregroundColor:
                          _ink,
                    ),
                    child:
                        const Text(
                      'Yes',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// NIGHT SKY BACKGROUND
// ============================================================

class _NightScenePainter
    extends CustomPainter {
  final double t;

  _NightScenePainter(
    this.t,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final h =
        size.height;

    final w =
        size.width;

    final horizon =
        h * 0.58;

    // ----------------------------------------------------------
    // SKY GRADIENT
    // ----------------------------------------------------------

    final skyPaint =
        Paint()
          ..shader =
              const LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              _skyTop,
              _skyMiddle,
              _skyHorizon,
            ],
            stops: [
              0,
              0.58,
              1,
            ],
          ).createShader(
            Rect.fromLTWH(
              0,
              0,
              w,
              horizon,
            ),
          );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        w,
        horizon,
      ),
      skyPaint,
    );

    // ----------------------------------------------------------
    // WARM HORIZON GLOW
    // ----------------------------------------------------------

    final glowCenter =
        Offset(
      w * 0.30,
      horizon * 0.95,
    );

    canvas.drawCircle(
      glowCenter,
      w * 0.55,
      Paint()
        ..shader =
            RadialGradient(
          colors: [
            const Color(
              0xFFFFAA6E,
            ).withValues(
              alpha:
                  0.23,
            ),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center:
                glowCenter,
            radius:
                w * 0.55,
          ),
        ),
    );

    // ----------------------------------------------------------
    // BACKGROUND ELEMENTS
    // ----------------------------------------------------------

    _paintAurora(
      canvas,
      size,
    );

    _paintStars(
      canvas,
      size,
      horizon,
    );

    _paintMountains(
      canvas,
      size,
      horizon,
    );

    _paintLake(
      canvas,
      size,
      horizon,
    );

    _paintHouse(
      canvas,
      size,
      horizon,
    );
  }

  // ==========================================================
  // STARS
  // ==========================================================

  void _paintStars(
    Canvas canvas,
    Size size,
    double horizon,
  ) {
    final random =
        math.Random(
      19,
    );

    for (int i = 0;
        i < 72;
        i++) {
      final x =
          random.nextDouble() *
              size.width;

      final y =
          random.nextDouble() *
              horizon *
              0.80;

      final radius =
          0.45 +
              random.nextDouble() *
                  1.25;

      final phase =
          random.nextDouble() *
              math.pi *
              2;

      final alpha =
          0.35 +
              0.55 *
                  (0.5 +
                      0.5 *
                          math.sin(
                            t *
                                    math.pi *
                                    2 +
                                phase,
                          ));

      canvas.drawCircle(
        Offset(
          x,
          y,
        ),
        radius,
        Paint()
          ..color =
              _warmWhite
                  .withValues(
            alpha:
                alpha,
          ),
      );
    }
  }

  // ==========================================================
  // AURORA
  // ==========================================================

  void _paintAurora(
    Canvas canvas,
    Size size,
  ) {
    final drift =
        math.sin(
              t *
                  math.pi *
                  2,
            ) *
            14;

    final paths = <
        ({
          Color color,
          double y,
          double opacity,
        })>[
      (
        color:
            _auroraGreen,
        y:
            0.19,
        opacity:
            0.10,
      ),
      (
        color:
            _auroraBlue,
        y:
            0.24,
        opacity:
            0.10,
      ),
      (
        color:
            _auroraViolet,
        y:
            0.29,
        opacity:
            0.08,
      ),
    ];

    for (final band
        in paths) {
      final path =
          Path();

      path.moveTo(
        -20,
        size.height *
            band.y,
      );

      path.cubicTo(
        size.width *
            0.25,
        size.height *
                band.y -
            34 +
            drift,
        size.width *
            0.60,
        size.height *
                band.y +
            38 -
            drift,
        size.width +
            30,
        size.height *
                band.y -
            8,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color =
              band.color
                  .withValues(
            alpha:
                band.opacity,
          )
          ..strokeWidth =
              30
          ..style =
              PaintingStyle.stroke
          ..maskFilter =
              const MaskFilter.blur(
            BlurStyle.normal,
            22,
          ),
      );
    }
  }

  // ==========================================================
  // MOUNTAINS
  // ==========================================================

  void _paintMountains(
    Canvas canvas,
    Size size,
    double horizon,
  ) {
    // FAR

    final far =
        Path()
          ..moveTo(
            0,
            horizon,
          )
          ..lineTo(
            size.width *
                0.14,
            horizon -
                75,
          )
          ..lineTo(
            size.width *
                0.30,
            horizon -
                26,
          )
          ..lineTo(
            size.width *
                0.48,
            horizon -
                96,
          )
          ..lineTo(
            size.width *
                0.67,
            horizon -
                38,
          )
          ..lineTo(
            size.width *
                0.84,
            horizon -
                83,
          )
          ..lineTo(
            size.width,
            horizon -
                24,
          )
          ..lineTo(
            size.width,
            horizon,
          )
          ..close();

    canvas.drawPath(
      far,
      Paint()
        ..color =
            _mountainFar,
    );

    // MIDDLE

    final middle =
        Path()
          ..moveTo(
            0,
            horizon +
                12,
          )
          ..lineTo(
            size.width *
                0.18,
            horizon -
                36,
          )
          ..lineTo(
            size.width *
                0.34,
            horizon +
                2,
          )
          ..lineTo(
            size.width *
                0.60,
            horizon -
                55,
          )
          ..lineTo(
            size.width *
                0.77,
            horizon -
                8,
          )
          ..lineTo(
            size.width,
            horizon -
                42,
          )
          ..lineTo(
            size.width,
            horizon +
                25,
          )
          ..close();

    canvas.drawPath(
      middle,
      Paint()
        ..color =
            _mountainMiddle,
    );

    // NEAR

    final near =
        Path()
          ..moveTo(
            0,
            horizon +
                20,
          )
          ..lineTo(
            size.width *
                0.23,
            horizon -
                8,
          )
          ..lineTo(
            size.width *
                0.44,
            horizon +
                16,
          )
          ..lineTo(
            size.width *
                0.72,
            horizon -
                21,
          )
          ..lineTo(
            size.width,
            horizon +
                7,
          )
          ..lineTo(
            size.width,
            horizon +
                44,
          )
          ..lineTo(
            0,
            horizon +
                44,
          )
          ..close();

    canvas.drawPath(
      near,
      Paint()
        ..color =
            _mountainNear,
    );
  }

  // ==========================================================
  // LAKE
  // ==========================================================

  void _paintLake(
    Canvas canvas,
    Size size,
    double horizon,
  ) {
    final lakeRect =
        Rect.fromLTWH(
      0,
      horizon,
      size.width,
      size.height -
          horizon,
    );

    canvas.drawRect(
      lakeRect,
      Paint()
        ..shader =
            const LinearGradient(
          begin:
              Alignment.topCenter,
          end:
              Alignment.bottomCenter,
          colors: [
            Color(
              0xFF111634,
            ),
            _shore,
          ],
        ).createShader(
          lakeRect,
        ),
    );

    // Subtle moving water lines.
    for (int i = 0;
        i < 18;
        i++) {
      final y =
          horizon +
              18 +
              i *
                  18.0;

      final shift =
          math.sin(
                t *
                        math.pi *
                        2 +
                    i *
                        0.7,
              ) *
              8;

      final opacity =
          0.08 *
              (1 -
                  i /
                      22);

      canvas.drawLine(
        Offset(
          20 +
              shift,
          y,
        ),
        Offset(
          size.width *
                  0.55 +
              shift,
          y,
        ),
        Paint()
          ..color =
              _warmWhite
                  .withValues(
            alpha:
                opacity,
          )
          ..strokeWidth =
              1,
      );
    }
  }

  // ==========================================================
  // HOUSE + LIT WINDOW
  // ==========================================================

  void _paintHouse(
    Canvas canvas,
    Size size,
    double horizon,
  ) {
    final x =
        size.width *
            0.76;

    final y =
        horizon +
            7;

    final body =
        Rect.fromLTWH(
      x,
      y - 27,
      31,
      27,
    );

    canvas.drawRect(
      body,
      Paint()
        ..color =
            _shore,
    );

    final roof =
        Path()
          ..moveTo(
            x - 5,
            y - 27,
          )
          ..lineTo(
            x +
                15.5,
            y - 43,
          )
          ..lineTo(
            x + 36,
            y - 27,
          )
          ..close();

    canvas.drawPath(
      roof,
      Paint()
        ..color =
            _shore,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        x + 9,
        y - 19,
        8,
        8,
      ),
      Paint()
        ..color =
            const Color(
          0xFFFFCE82,
        ),
    );
  }

  @override
  bool shouldRepaint(
    covariant _NightScenePainter
        oldDelegate,
  ) {
    return oldDelegate.t !=
        t;
  }
}