import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _scopes = <String>['https://www.googleapis.com/auth/tasks'];

  // Web application OAuth client ID from Cloud Console — required on
  // Android when not using google-services.json/Firebase.
  static const _serverClientId =
      '407242777659-sv1tp1ojov67lcr94167v72cor9qlm40.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final ValueNotifier<GoogleSignInAccount?> currentUser = ValueNotifier(null);

  bool get isSignedIn => currentUser.value != null;

  Future<void> init() async {
    await _googleSignIn.initialize(serverClientId: _serverClientId);
    _googleSignIn.authenticationEvents.listen(_handleAuthEvent);
    unawaited(_googleSignIn.attemptLightweightAuthentication());
  }

  void _handleAuthEvent(GoogleSignInAuthenticationEvent event) {
    currentUser.value = switch (event) {
      GoogleSignInAuthenticationEventSignIn(user: final user) => user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };
  }

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.authenticate();
      await account.authorizationClient.authorizeScopes(_scopes);
    } catch (e) {
      debugPrint('Sign-in error: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Access token scoped for Tasks API calls. Null if not authorized yet.
  Future<String?> getAccessToken() async {
    final user = currentUser.value;
    if (user == null) return null;
    final auth = await user.authorizationClient.authorizationForScopes(
      _scopes,
    );
    return auth?.accessToken;
  }
}
