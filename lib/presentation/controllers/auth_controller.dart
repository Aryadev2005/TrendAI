import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AuthState()) {
    _restoreSession();
  }

  // Restore session on app launch
  Future<void> _restoreSession() async {
    try {
      final cached = await _repo.getCachedUser();
      if (cached != null) {
        state = state.copyWith(
          user: cached,
          isAuthenticated: true,
        );
      }
    } catch (_) {}
  }

  // Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(email, password);
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Register
  Future<bool> register(
      String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.register(email, password, name);
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Google Sign In
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.loginWithGoogle();
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google Sign In coming soon!',
      );
      return false;
    }
  }

  // Update profile after onboarding
  Future<void> updateProfile({
    String? followerRange,
    String? primaryPlatform,
    List<String>? niches,
  }) async {
    if (state.user == null) return;
    try {
      final updated = await _repo.updateProfile(
        state.user!,
        followerRange: followerRange,
        primaryPlatform: primaryPlatform,
        niches: niches,
      );
      state = state.copyWith(user: updated);
    } catch (_) {}
  }

  // Logout
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authRepositoryProvider =
    Provider((ref) => AuthRepository());

final authProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.read(authRepositoryProvider)),
);