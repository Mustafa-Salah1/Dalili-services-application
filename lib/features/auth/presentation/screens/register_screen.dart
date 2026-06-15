import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:service_finder/features/auth/presentation/providers/auth_provider.dart';
import 'package:service_finder/features/auth/presentation/providers/auth_state.dart';

import 'package:service_finder/shared/components/app_logo.dart';

class _SF {
  static const primary = Color(0xFF0F766E);
  static const primaryLight = Color(0xFF14B8A6);
  static const primaryDark = Color(0xFF0D6B63);

  static const background = Color(0xFFF0FAFA);
  static const surface = Colors.white;
  static const surfaceOverlay = Color(0xFFF8FFFE);

  static const textDark = Color(0xFF0F2027);
  static const textBody = Color(0xFF334155);
  static const textMuted = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);

  static const border = Color(0xFFD1FAF5);
  static const borderNeutral = Color(0xFFE2E8F0);
  static const borderFocus = Color(0xFF14B8A6);

  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const weak = Color(0xFFEF4444);
  static const medium = Color(0xFFF59E0B);
  static const strong = Color(0xFF10B981);

  static const headerGradient = LinearGradient(
    colors: [Color(0xFF0A5C55), Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const buttonGradient = LinearGradient(
    colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Shared radii
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;

  // Shared shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withOpacity(0.08),
      blurRadius: 32,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: primaryLight.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.38),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primaryLight.withOpacity(0.18),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get logoGlow => [
    BoxShadow(
      color: primaryLight.withOpacity(0.45),
      blurRadius: 24,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];
}

enum _PasswordStrength { none, weak, medium, strong }

_PasswordStrength _evaluateStrength(String password) {
  if (password.isEmpty) return _PasswordStrength.none;
  int score = 0;
  if (password.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
  if (score <= 1) return _PasswordStrength.weak;
  if (score <= 3) return _PasswordStrength.medium;
  return _PasswordStrength.strong;
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _registrationSuccess = false;
  _PasswordStrength _passwordStrength = _PasswordStrength.none;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  late final AnimationController _headerCtrl;
  late final AnimationController _formCtrl;
  late final AnimationController _successCtrl;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;
  late final Animation<double> _successScale;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut));

    _successScale = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.elasticOut,
    );

    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formCtrl.forward();
    });

    _passwordController.addListener(() {
      setState(
        () => _passwordStrength = _evaluateStrength(_passwordController.text),
      );
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _headerCtrl.dispose();
    _formCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirm = _confirmPasswordController.text;

      if (username.isEmpty) {
        _usernameError = 'Please enter a username';
        valid = false;
      } else if (username.length < 3) {
        _usernameError = 'Username must be at least 3 characters';
        valid = false;
      }

      if (email.isEmpty) {
        _emailError = 'Please enter your email address';
        valid = false;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        _emailError = 'Please enter a valid email address';
        valid = false;
      }

      if (password.isEmpty) {
        _passwordError = 'Please create a password';
        valid = false;
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
        valid = false;
      }

      if (confirm.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
        valid = false;
      } else if (confirm != password) {
        _confirmPasswordError = "Passwords don't match — please try again";
        valid = false;
      }
    });
    return valid;
  }

  Future<void> _register() async {
    if (!_validate()) return;
    await ref
        .read(authProvider.notifier)
        .register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is AuthAuthenticated) {
        setState(() => _registrationSuccess = true);
        _successCtrl.forward();
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) context.go('/login');
        });
      }
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(next.message)),
              ],
            ),
            backgroundColor: _SF.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });

    if (_registrationSuccess) {
      return _SuccessOverlay(scaleAnimation: _successScale);
    }

    return Scaffold(
      backgroundColor: _SF.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: const _HeaderBanner(),
                ),
              ),

              FadeTransition(
                opacity: _formFade,
                child: SlideTransition(
                  position: _formSlide,
                  child: _FormCard(
                    usernameController: _usernameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    showPassword: _showPassword,
                    showConfirmPassword: _showConfirmPassword,
                    passwordStrength: _passwordStrength,
                    usernameError: _usernameError,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    confirmPasswordError: _confirmPasswordError,
                    isLoading: isLoading,
                    onTogglePassword: () =>
                        setState(() => _showPassword = !_showPassword),
                    onToggleConfirmPassword: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword,
                    ),
                    onRegister: _register,
                    onGoToLogin: () => context.go('/login'),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: _SF.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_SF.radiusXl),
          bottomRight: Radius.circular(_SF.radiusXl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
      child: Column(
        children: [
          // Logo container — teal glow, consistent with app's primary brand
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
                width: 1.5,
              ),
              boxShadow: _SF.logoGlow,
            ),
            child: const Center(child: AppLogo()),
          ),

          const SizedBox(height: 22),

          // Title
          const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 7),

          // Subtitle — slightly more readable opacity
          Text(
            'Join thousands finding trusted services',
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),

          const SizedBox(height: 28),

          // Service icon pills
          const _ServicePillRow(),
        ],
      ),
    );
  }
}

class _ServicePillRow extends StatelessWidget {
  const _ServicePillRow();

  static const _items = [
    (icon: Icons.handyman_outlined, label: 'Repairs'),
    (icon: Icons.design_services_outlined, label: 'Design'),
    (icon: Icons.cleaning_services_outlined, label: 'Cleaning'),
    (icon: Icons.electrical_services_outlined, label: 'Electric'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < _items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          _ServicePill(icon: _items[i].icon, label: _items[i].label),
        ],
      ],
    );
  }
}

class _ServicePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ServicePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.92), size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool showPassword;
  final bool showConfirmPassword;
  final _PasswordStrength passwordStrength;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onRegister;
  final VoidCallback onGoToLogin;

  const _FormCard({
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.passwordStrength,
    required this.usernameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onRegister,
    required this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _SF.surface,
          borderRadius: BorderRadius.circular(_SF.radiusLg),
          boxShadow: _SF.cardShadow,
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section eyebrow
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_SF.primary, _SF.primaryLight],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'YOUR DETAILS',
                  style: TextStyle(
                    color: _SF.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Username
            _SFTextField(
              controller: usernameController,
              hintText: 'Username',
              prefixIcon: Icons.person_outline_rounded,
              errorText: usernameError,
            ),

            const SizedBox(height: 14),

            // Email
            _SFTextField(
              controller: emailController,
              hintText: 'Email address',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              errorText: emailError,
            ),

            const SizedBox(height: 14),

            // Password
            _SFTextField(
              controller: passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !showPassword,
              errorText: passwordError,
              suffix: _EyeButton(
                visible: showPassword,
                onTap: onTogglePassword,
              ),
            ),

            // Strength bar — only when typing
            if (passwordStrength != _PasswordStrength.none) ...[
              const SizedBox(height: 10),
              _PasswordStrengthBar(strength: passwordStrength),
            ],

            const SizedBox(height: 14),

            // Confirm password
            _SFTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !showConfirmPassword,
              errorText: confirmPasswordError,
              suffix: _EyeButton(
                visible: showConfirmPassword,
                onTap: onToggleConfirmPassword,
              ),
            ),

            const SizedBox(height: 28),

            // CTA button
            _RegisterButton(isLoading: isLoading, onPressed: onRegister),

            const SizedBox(height: 18),

            // Terms
            Center(
              child: Text(
                'By registering, you agree to our Terms & Privacy Policy',
                style: TextStyle(
                  color: _SF.textLight,
                  fontSize: 11.5,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 22),

            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: _SF.borderNeutral, height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: _SF.textLight,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: _SF.borderNeutral, height: 1)),
              ],
            ),

            const SizedBox(height: 22),

            // Sign-in CTA
            GestureDetector(
              onTap: onGoToLogin,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _SF.surfaceOverlay,
                  borderRadius: BorderRadius.circular(_SF.radiusMd),
                  border: Border.all(color: _SF.border, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: _SF.textMuted,
                        fontSize: 14,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Sign in',
                      style: TextStyle(
                        color: _SF.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SFTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final Widget? suffix;

  const _SFTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.suffix,
  });

  @override
  State<_SFTextField> createState() => _SFTextFieldState();
}

class _SFTextFieldState extends State<_SFTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _focused ? _SF.surfaceOverlay : _SF.surface,
            borderRadius: BorderRadius.circular(_SF.radiusMd),
            border: Border.all(
              color: hasError
                  ? _SF.error.withOpacity(0.8)
                  : _focused
                  ? _SF.borderFocus
                  : _SF.borderNeutral,
              width: _focused ? 1.8 : 1.2,
            ),
            boxShadow: (_focused && !hasError)
                ? [
                    BoxShadow(
                      color: _SF.primaryLight.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Focus(
            onFocusChange: (f) => setState(() => _focused = f),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              style: const TextStyle(
                color: _SF.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: _SF.textLight,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Icon(
                    widget.prefixIcon,
                    color: _focused ? _SF.primary : _SF.textLight,
                    size: 20,
                  ),
                ),
                suffixIcon: widget.suffix,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline, color: _SF.error, size: 13),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                    color: _SF.error,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EyeButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;
  const _EyeButton({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: _SF.textLight,
          size: 20,
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final _PasswordStrength strength;
  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    const labels = {
      _PasswordStrength.weak: 'Weak',
      _PasswordStrength.medium: 'Medium',
      _PasswordStrength.strong: 'Strong',
    };
    const colors = {
      _PasswordStrength.weak: _SF.weak,
      _PasswordStrength.medium: _SF.medium,
      _PasswordStrength.strong: _SF.strong,
    };
    const fills = {
      _PasswordStrength.weak: 1,
      _PasswordStrength.medium: 2,
      _PasswordStrength.strong: 3,
    };

    final color = colors[strength] ?? _SF.weak;
    final fill = fills[strength] ?? 1;

    return Row(
      children: [
        ...List.generate(
          3,
          (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 4),
              height: 3.5,
              decoration: BoxDecoration(
                color: i < fill ? color : _SF.borderNeutral,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            labels[strength] ?? '',
            key: ValueKey(strength),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _RegisterButton({required this.isLoading, required this.onPressed});

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.forward();
        widget.onPressed();
      },
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _pressCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? const LinearGradient(
                    colors: [Color(0xFFB0C4BB), Color(0xFFCBD5E1)],
                  )
                : _SF.buttonGradient,
            borderRadius: BorderRadius.circular(_SF.radiusMd),
            boxShadow: widget.isLoading ? [] : _SF.buttonShadow,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatelessWidget {
  final Animation<double> scaleAnimation;
  const _SuccessOverlay({required this.scaleAnimation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SF.background,
      body: Center(
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with glow
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _SF.success.withOpacity(0.10),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _SF.success.withOpacity(0.22),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _SF.success,
                    size: 54,
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  'Account Created!',
                  style: TextStyle(
                    color: _SF.textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Welcome aboard.\nRedirecting you to sign in…',
                  style: TextStyle(
                    color: _SF.textMuted,
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(_SF.primary),
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
