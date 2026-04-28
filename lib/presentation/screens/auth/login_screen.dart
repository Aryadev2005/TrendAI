import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/common/warm_button.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _errorMsg = null);

    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Please enter your email');
      return;
    }
    if (_passCtrl.text.isEmpty) {
      setState(() => _errorMsg = 'Please enter your password');
      return;
    }

    final ok = await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );

    if (!mounted) return;
if (ok) {
  final user = ref.read(authProvider).user;
  if (user?.primaryPlatform != null) {
    context.go(AppRoutes.dashboard);
  } else {
    context.go(AppRoutes.onboarding);
  }
} else {
  setState(() =>
      _errorMsg = ref.read(authProvider).error ?? 'Login failed');
}
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -80, right: -60,
            child: _blob(250, AppColors.primary.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -100, left: -60,
            child: _blob(280, AppColors.accent.withValues(alpha: 0.08)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppColors.primary, size: 13),
                        const SizedBox(width: 6),
                        Text('AI-Powered Trend Engine',
                            style: GoogleFonts.dmSans(
                              color: AppColors.primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  Text('Welcome\nBack',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 46,
                        color: AppColors.textDark,
                        height: 1.05,
                      )),
                  const SizedBox(height: 12),
                  Text(
                    'Your personalised trend feed\nis waiting for you.',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppColors.textMid,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Error message
                  if (_errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD),
                        border: Border.all(
                            color:
                                AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMsg!,
                              style: GoogleFonts.dmSans(
                                  color: AppColors.error,
                                  fontSize: 13)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email field
                  _field(
                    hint: 'Email address',
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // Password field
                  _field(
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: _passCtrl,
                    obscure: _obscurePass,
                    suffix: GestureDetector(
                      onTap: () => setState(
                          () => _obscurePass = !_obscurePass),
                      child: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textLight,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Forgot password?',
                        style: GoogleFonts.dmSans(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  authState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : WarmButton(
                          label: 'Get Started',
                          onTap: _login,
                        ),
                  const SizedBox(height: 14),

                  // Divider
                  Row(children: [
                    const Expanded(
                        child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      child: Text('or',
                          style: GoogleFonts.dmSans(
                              color: AppColors.textLight,
                              fontSize: 12)),
                    ),
                    const Expanded(
                        child: Divider(color: AppColors.border)),
                  ]),
                  const SizedBox(height: 14),

                  // Google button
                  WarmButton(
                    label: 'Continue with Google',
                    isOutlined: true,
                    icon: Icons.g_mobiledata,
                    onTap: () async {
                      await ref.read(authProvider.notifier).loginWithGoogle();
                      if (!mounted) return;
                      context.go(AppRoutes.dashboard);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sign up link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.signup),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.dmSans(
                              color: AppColors.textMid,
                              fontSize: 14),
                          children: [
                            const TextSpan(
                                text:
                                    "Don't have an account?  "),
                            TextSpan(
                              text: 'Sign up free',
                              style: GoogleFonts.dmSans(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius:
            BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.dmSans(
            color: AppColors.textDark, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
              color: AppColors.textLight, fontSize: 15),
          prefixIcon: Icon(icon,
              color: AppColors.textLight, size: 20),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color),
      );
}