import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:service_finder/features/auth/presentation/providers/auth_provider.dart';
import 'package:service_finder/features/auth/presentation/providers/auth_state.dart';

import 'package:service_finder/shared/animations/fade_animation.dart';
import 'package:service_finder/shared/components/app_logo.dart';
import 'package:service_finder/shared/components/custom_text_field.dart';

const _primary = Color(0xFF0F766E);
const _secondary = Color(0xFF14B8A6);
const _bg = Color(0xFFF8FAFC);
const _surface = Color(0xFFFFFFFF);
const _inputBg = Color(0xFFF8FAFC);
const _onSurface = Color(0xFF0F172A);
const _textMuted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _focusBorder = Color(0xFF0F766E);
const _error = Color(0xFFEF4444);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _headerCtrl;
  late AnimationController _formCtrl;
  late AnimationController _footerCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _footerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));

    _footerFade = CurvedAnimation(parent: _footerCtrl, curve: Curves.easeOut);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 80));
    _headerCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _formCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _footerCtrl.forward();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _headerCtrl.dispose();
    _formCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  Future<void> login() async {
    await ref
        .read(authProvider.notifier)
        .login(
          usernameOrEmail: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final size = MediaQuery.of(context).size;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated) context.go('/home');
      if (next is AuthError) _showErrorSnack(next.message);
    });

    return Scaffold(
      backgroundColor: _bg,
      body: FadeAnimation(
        child: Stack(
          children: [
            // Subtle teal radial wash — same hue as brand, very soft
            Positioned(
              top: -size.width * 0.45,
              left: -size.width * 0.15,
              right: -size.width * 0.15,
              child: Container(
                height: size.width * 1.1,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFCCFBF1), // teal-100
                      Color(0xFFE0FDF9), // teal-50
                      Color(0xFFF8FAFC), // bg
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.06),

                      // Header
                      SlideTransition(
                        position: _headerSlide,
                        child: FadeTransition(
                          opacity: _headerFade,
                          child: _Header(),
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // Form card
                      SlideTransition(
                        position: _formSlide,
                        child: FadeTransition(
                          opacity: _formFade,
                          child: _FormCard(
                            usernameController: usernameController,
                            passwordController: passwordController,
                            obscurePassword: _obscurePassword,
                            rememberMe: _rememberMe,
                            isLoading: isLoading,
                            onTogglePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onToggleRemember: (v) =>
                                setState(() => _rememberMe = v ?? false),
                            onLogin: login,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      FadeTransition(opacity: _footerFade, child: _Footer()),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo — teal gradient, soft teal glow (no purple)
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primary, _secondary],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.25), // teal glow, not purple
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: _secondary.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const AppLogo(),
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Welcome back',
          style: TextStyle(
            color: _onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Sign in to find trusted professionals near you',
          style: TextStyle(color: _textMuted, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onLogin;

  const _FormCard({
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleRemember,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(label: 'Email or Username'),
          const SizedBox(height: 8),
          _InputWrapper(
            child: CustomTextField(
              hintText: 'Enter your email or username',
              controller: usernameController,
            ),
            prefixIcon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 18),

          _FieldLabel(label: 'Password'),
          const SizedBox(height: 8),
          _InputWrapper(
            child: CustomTextField(
              hintText: 'Enter your password',
              controller: passwordController,
              obscureText: obscurePassword,
            ),
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _textMuted,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Remember me — teal checkbox
              GestureDetector(
                onTap: () => onToggleRemember(!rememberMe),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: rememberMe ? _primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: rememberMe ? _primary : _border,
                          width: 1.5,
                        ),
                      ),
                      child: rememberMe
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 13,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Remember me',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () {
                  // Preserved: add forgot password route here
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          _LoginButton(isLoading: isLoading, onPressed: onLogin),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _InputWrapper extends StatefulWidget {
  final Widget child;
  final IconData prefixIcon;
  final Widget? suffixIcon;

  const _InputWrapper({
    required this.child,
    required this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<_InputWrapper> createState() => _InputWrapperState();
}

class _InputWrapperState extends State<_InputWrapper> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _inputBg, // always light
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused ? _focusBorder : _border,
            width: _focused ? 1.8 : 1.2,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: _primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 46,
                right: widget.suffixIcon != null ? 44 : 0,
              ),
              child: widget.child,
            ),
            Positioned(
              left: 14,
              child: Icon(
                widget.prefixIcon,
                color: _focused ? _primary : _textMuted,
                size: 18,
              ),
            ),
            if (widget.suffixIcon != null)
              Positioned(right: 14, child: widget.suffixIcon!),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _pressCtrl.forward(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              _pressCtrl.reverse();
              widget.onPressed();
            },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? const LinearGradient(
                    colors: [Color(0xFF5EAAA4), Color(0xFF5EAAA4)],
                  )
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [_primary, Color(0xFF0D9488)], // teal range only
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: _primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: _border, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or',
                style: TextStyle(color: _textMuted, fontSize: 13),
              ),
            ),
            const Expanded(child: Divider(color: _border, height: 1)),
          ],
        ),

        const SizedBox(height: 20),

        Container(
          height: 52,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border, width: 1.2),
          ),
          child: TextButton(
            onPressed: () => context.go('/register'),
            style: TextButton.styleFrom(
              foregroundColor: _onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: _textMuted),
                  ),
                  TextSpan(
                    text: 'Create one',
                    style: TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'By signing in, you agree to our Terms of Service\nand Privacy Policy.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textMuted.withOpacity(0.7),
            fontSize: 11,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
