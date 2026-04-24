import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_text_field.dart';
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Positioned(top: -120, right: -80, child: _glow(350, AppColors.primary.withOpacity(0.12))),
          Positioned(bottom: -100, left: -60, child: _glow(280, AppColors.purple.withOpacity(0.1))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  _badge(),
                  const SizedBox(height: 28),
                  const Text('Welcome\nBack', style: TextStyle(fontSize: AppDimensions.fontHero, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                  const SizedBox(height: 12),
                  const Text('Your personalised trend feed is waiting.', style: TextStyle(fontSize: AppDimensions.fontMD, color: Colors.white38)),
                  const SizedBox(height: 44),
                  AppTextField(hint: 'Email address', icon: Icons.email_outlined, controller: _emailCtrl),
                  const SizedBox(height: 14),
                  AppTextField(hint: 'Password', icon: Icons.lock_outline, obscure: true, controller: _passCtrl),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Forgot password?', style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: AppDimensions.fontSM)),
                  ),
                  const SizedBox(height: 30),
                  authState.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : AppButton(
                          label: 'Get Started',
                          onTap: () async {
                            await ref.read(authProvider.notifier).login(_emailCtrl.text, _passCtrl.text);
                            if (mounted) context.go(AppRoutes.onboarding);
                          },
                        ),
                  const SizedBox(height: 16),
                  AppButton(label: 'Continue with Google', isOutlined: true, onTap: () {}),
                  const Spacer(),
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Text("Don't have an account?  Sign up free", style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withOpacity(0.35)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome, color: AppColors.primary, size: 13),
        SizedBox(width: 6),
        Text('AI-Powered Trend Engine', style: TextStyle(color: AppColors.primary, fontSize: 12)),
      ],
    ),
  );

  Widget _glow(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}