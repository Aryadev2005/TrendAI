import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/common/warm_button.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    setState(() => _errorMsg = null);

    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Please enter your name');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty ||
        !_emailCtrl.text.contains('@')) {
      setState(() => _errorMsg = 'Please enter a valid email');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(
          () => _errorMsg = 'Password must be at least 6 characters');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _errorMsg = 'Passwords do not match');
      return;
    }

    final ok = await ref.read(authProvider.notifier).register(
          _emailCtrl.text.trim(),
          _passCtrl.text,
          _nameCtrl.text.trim(),
        );

    if (ok && mounted) {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned(
            top: -80, right: -60,
            child: _blob(250, AppColors.primary.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -100, left: -60,
            child: _blob(280, AppColors.accent.withOpacity(0.08)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Back button
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textDark, size: 18),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        Text('Join 50,000+ Indian creators',
                            style: GoogleFonts.dmSans(
                              color: AppColors.primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Create your\naccount',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 40,
                        color: AppColors.textDark,
                        height: 1.1,
                      )),
                  const SizedBox(height: 8),
                  Text('Start knowing what to post before anyone else.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.textMid,
                        height: 1.5,
                      )),
                  const SizedBox(height: 32),

                  // Error message
                  if (_errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        Icon(Icons.error_outline_rounded,
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

                  // Fields
                  _field(
                    hint: 'Full name',
                    icon: Icons.person_outline_rounded,
                    controller: _nameCtrl,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    hint: 'Email address',
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: _passCtrl,
                    obscure: _obscurePass,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      child: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textLight,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    hint: 'Confirm password',
                    icon: Icons.lock_outline_rounded,
                    controller: _confirmCtrl,
                    obscure: _obscureConfirm,
                    suffix: GestureDetector(
                      onTap: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textLight,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By signing up you agree to our Terms & Privacy Policy',
                    style: GoogleFonts.dmSans(
                        color: AppColors.textLight,
                        fontSize: 11),
                  ),
                  const SizedBox(height: 28),

                  // Sign up button
                  authState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : WarmButton(
                          label: 'Create Account',
                          onTap: _signup,
                        ),
                  const SizedBox(height: 14),

                  // Divider
                  Row(children: [
                    Expanded(
                        child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      child: Text('or',
                          style: GoogleFonts.dmSans(
                              color: AppColors.textLight,
                              fontSize: 12)),
                    ),
                    Expanded(
                        child: Divider(color: AppColors.border)),
                  ]),
                  const SizedBox(height: 14),

                  // Google button
                  WarmButton(
                    label: 'Continue with Google',
                    isOutlined: true,
                    icon: Icons.g_mobiledata,
                    onTap: () async {
                      final ok = await ref
                          .read(authProvider.notifier)
                          .loginWithGoogle();
                      if (ok && mounted) {
                        context.go(AppRoutes.onboarding);
                      }
                    },
                  ),
                  const SizedBox(height: 28),

                  // Already have account
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.dmSans(
                              color: AppColors.textMid,
                              fontSize: 14),
                          children: [
                            const TextSpan(
                                text: 'Already have an account?  '),
                            TextSpan(
                              text: 'Sign in',
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
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
          prefixIcon:
              Icon(icon, color: AppColors.textLight, size: 20),
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
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: color),
      );
}