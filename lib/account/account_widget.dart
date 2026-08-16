import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../auth/auth_service.dart';

class AccountWidget extends StatelessWidget {
  const AccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GoogleSignInAccount?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (context, account, _) {
        if (account == null) {
          return IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Sign in with Google',
            onPressed: () => AuthService.instance.signIn(),
          );
        }

        return PopupMenuButton<String>(
          tooltip: account.email,
          onSelected: (value) {
            if (value == 'sign_out') {
              AuthService.instance.signOut();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Text(account.email),
            ),
            const PopupMenuItem(
              value: 'sign_out',
              child: Text('Sign out'),
            ),
          ],
          child: CircleAvatar(
            backgroundImage: account.photoUrl != null
                ? NetworkImage(account.photoUrl!)
                : null,
            child: account.photoUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
        );
      },
    );
  }
}
