import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(seconds: 1)); // Replace with Firebase
      final user = UserModel(
        id: 'user_001',
        name: 'Priya Sharma',
        email: email,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = const AuthState();
  }

  void updateProfile({
    String? followerRange,
    String? primaryPlatform,
    List<String>? niches,
  }) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(
        followerRange: followerRange,
        primaryPlatform: primaryPlatform,
        niches: niches,
      ),
    );
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
