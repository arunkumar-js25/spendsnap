import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:spendsnap/features/auth/presentation/login_screen.dart';
import 'package:spendsnap/features/expense/presentation/screens/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // 🔄 Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ✅ Logged in
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // ❌ Not logged in
        return const LoginScreen();
      },
    );
  }
}