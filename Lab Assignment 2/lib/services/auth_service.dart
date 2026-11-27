import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign Up with Email and Password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during registration. Please check your connection.';
    }
  }

  // Sign In with Email and Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during login. Please check your connection.';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Resend Confirmation Email
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to resend confirmation email. Please try again.';
    }
  }

  // Helper method to map AuthException to user-friendly messages
  String _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('invalid login credentials') || message.contains('invalid email or password')) {
      return 'Incorrect email or password. Please check your credentials.';
    } else if (message.contains('email not confirmed')) {
      return 'Email address is not confirmed. Please check your inbox or request a new confirmation email.';
    } else if (message.contains('user already registered') || message.contains('already registered')) {
      return 'An account with this email already exists. Please log in instead.';
    } else if (message.contains('password should be') || message.contains('weak password')) {
      return 'Password is too weak. Please use at least 6 characters with letters and numbers.';
    } else if (message.contains('rate limit') || message.contains('too many requests')) {
      return 'Too many attempts. Please try again later.';
    } else {
      return e.message;
    }
  }
}
