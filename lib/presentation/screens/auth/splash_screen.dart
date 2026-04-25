import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _pulseCtrl;

  // Animations
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _float;
  late Animation<double> _shimmer;
  late Animation<double> _pulse;
  late Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // KEY FIX — wait for first frame before doing anything heavy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
      _checkAuthAfterDelay();
    });
  }

  void _setupAnimations() {
    // Fade in
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = CurvedAnimation(
        parent: _fadeCtrl, curve: Curves.easeOut);

    // Scale up (logo pop)
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack),
    );

    // Float up and down (infinite)
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _float = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    // Shimmer on logo
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    // Pulse glow
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Tagline slides up
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _fadeCtrl, curve: Curves.easeOutCubic));
  }

  void _startAnimations() {
    // Staggered start — each animation starts slightly after previous
    _fadeCtrl.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _scaleCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _floatCtrl.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _shimmerCtrl.repeat();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _pulseCtrl.repeat(reverse: true);
    });
  }

  void _checkAuthAfterDelay() {
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        final user = authState.user;
        if (user?.primaryPlatform != null) {
          context.go(AppRoutes.dashboard);
        } else {
          context.go(AppRoutes.onboarding);
        }
      } else {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _floatCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background blobs
          _AnimatedBlob(
            size: 280,
            color: AppColors.primary.withOpacity(0.07),
            top: -80,
            right: -60,
            delay: 0,
          ),
          _AnimatedBlob(
            size: 220,
            color: AppColors.accent.withOpacity(0.09),
            bottom: -60,
            left: -60,
            delay: 300,
          ),
          _AnimatedBlob(
            size: 140,
            color: AppColors.primaryGlow.withOpacity(0.1),
            top: 180,
            left: -30,
            delay: 600,
          ),

          // Main content
          FadeTransition(
            opacity: _fade,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Floating + pulsing logo
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _float,
                      _pulse,
                      _shimmer,
                    ]),
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(0, -_float.value),
                        child: Transform.scale(
                          scale: _pulse.value,
                          child: child,
                        ),
                      );
                    },
                    child: ScaleTransition(
                      scale: _scale,
                      child: _LogoBox(shimmer: _shimmer),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name with scale
                  ScaleTransition(
                    scale: _scale,
                    child: Text(
                      'TrendAI',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 44,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline slides up
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _fade,
                      child: Text(
                        'Know what to post.\nBefore anyone else.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: AppColors.textMid,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading dots
                  FadeTransition(
                    opacity: _fade,
                    child: _LoadingDots(),
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

// ─── Logo Box with Shimmer ─────────────────────────────────
class _LogoBox extends StatelessWidget {
  final Animation<double> shimmer;
  const _LogoBox({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, child) {
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.primaryGlow.withOpacity(0.3),
                blurRadius: 50,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Shimmer sweep
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.25),
                        Colors.transparent,
                      ],
                      stops: [
                        (shimmer.value - 0.3).clamp(0.0, 1.0),
                        shimmer.value.clamp(0.0, 1.0),
                        (shimmer.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds);
                  },
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Icon
              const Center(
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Animated Blob ─────────────────────────────────────────
class _AnimatedBlob extends StatefulWidget {
  final double size;
  final Color color;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final int delay;

  const _AnimatedBlob({
    required this.size,
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.delay,
  });

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      left: widget.left,
      right: widget.right,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

// ─── Loading Dots ──────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _anims = _ctrls
        .map((c) => Tween<double>(begin: 0, end: -8).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _anims[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == 1
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}