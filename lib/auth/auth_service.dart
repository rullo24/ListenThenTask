import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _scopes = <String>['https://www.googleapis.com/auth/tasks'];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  final ValueNotifier<GoogleSignInAccount?> currentUser = ValueNotifier(null);

  bool get isSignedIn => currentUser.value != null;

  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      currentUser.value = account;
    });
    await _googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      debugPrint('Sign-in error: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Access token scoped for Tasks API calls. Null if not signed in.
  Future<String?> getAccessToken() async {
    final user = currentUser.value;
    if (user == null) return null;
    final auth = await user.authentication;
    return auth.accessToken;
  }

  /// HTTP headers (including a fresh Authorization bearer token) for
  /// authenticated Google API calls. Null if not signed in.
  Future<Map<String, String>?> getAuthHeaders() async {
    final user = currentUser.value;
    if (user == null) return null;
    return user.authHeaders;
  }
}
