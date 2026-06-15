import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:service_finder/core/storage/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _loaderCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;

  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;

  late Animation<double> _loaderFade;

  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    // Force light status bar so icons are visible on gradient
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _loaderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loaderFade = CurvedAnimation(parent: _loaderCtrl, curve: Curves.easeIn);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut);

    _runSequence();

    checkLoginStatus();
  }

  Future<void> _runSequence() async {
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 50));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _loaderCtrl.forward();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = await SecureStorageService.getAccessToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _loaderCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoCtrl,
          _textCtrl,
          _loaderCtrl,
          _shimmerCtrl,
        ]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A5C55),
                      Color(0xFF0F766E),
                      Color(0xFF0D8C82),
                      Color(0xFF0EA89A),
                    ],
                    stops: [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),

              Positioned(
                top: -size.width * 0.25,
                right: -size.width * 0.2,
                child: Opacity(
                  opacity: 0.18 + (_shimmer.value * 0.08),
                  child: Container(
                    width: size.width * 0.75,
                    height: size.width * 0.75,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF14B8A6),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -size.width * 0.3,
                left: -size.width * 0.15,
                child: Opacity(
                  opacity: 0.12 + (_shimmer.value * 0.06),
                  child: Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),

              Opacity(
                opacity: 0.03,
                child: CustomPaint(painter: _GridPainter()),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Pushes logo to ~38% from top
                    SizedBox(height: size.height * 0.16),

                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Soft glow ring behind logo
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              // Logo — tries logo_full.png, falls back
                              Container(
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo_full.png',
                                    width: 108,
                                    height: 108,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/images/logo.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.handyman_rounded,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.055),

                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          children: [
                            // Arabic name
                            const Text(
                              'دليلي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Brand divider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 28,
                                  height: 1.5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'SERVICE FINDER',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 3.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 28,
                                  height: 1.5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    FadeTransition(
                      opacity: _taglineFade,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: Text(
                          'Find Trusted Service Providers Near You',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    FadeTransition(
                      opacity: _loaderFade,
                      child: Column(
                        children: [
                          // Segmented dot loader
                          _DotLoader(),
                          const SizedBox(height: 12),
                          Text(
                            'Loading…',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.08),

                    FadeTransition(
                      opacity: _taglineFade,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Connecting people with skilled professionals',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 11,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DotLoader extends StatefulWidget {
  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Each dot peaks at a different phase
            final phase = (i / 3.0);
            final t = ((_ctrl.value - phase) % 1.0);
            // Bounce up then down within window [0, 0.5]
            final inWindow = t < 0.5;
            final scale = inWindow
                ? 1.0 + (0.5 * (1.0 - (t / 0.25 - 1).abs().clamp(0, 1)))
                : 1.0;
            final opacity = inWindow
                ? 0.55 + 0.45 * (1 - (t / 0.25 - 1).abs().clamp(0, 1))
                : 0.3;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 7 * scale,
              height: 7 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(opacity.clamp(0.3, 1.0)),
              ),
            );
          }),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    const step = 36.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
