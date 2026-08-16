import 'package:flutter/foundation.dart';

/// Placeholder auth state until Google Sign-In is wired up.
/// TODO: replace `isSignedIn` with real GoogleSignIn state (final build stage).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ValueNotifier<bool> isSignedIn = ValueNotifier(false);
}
