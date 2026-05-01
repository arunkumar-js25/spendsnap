import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:spendsnap/core/utils/settings_service.dart';
import 'package:spendsnap/core/utils/sync_service.dart';

import 'package:spendsnap/data/db/database.dart';

import 'package:spendsnap/features/auth/presentation/login_screen.dart';
import 'package:spendsnap/features/expense/presentation/screens/main_screen.dart';

class AuthWrapper extends StatefulWidget {

  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() =>
      _AuthWrapperState();
}

class _AuthWrapperState
    extends State<AuthWrapper> {

  Future<void>? _initFuture;

  // =========================================================
  // 🔥 INITIALIZE USER
  // =========================================================

  Future<void> _initializeUser(
      User user) async {

   final db = appDatabase;

    final settingsService =  SettingsService();

    final syncService = SyncService();

    final isCloudSyncEnabled = await settingsService.isCloudSyncEnabled();

    // =====================================================
    // 🔥 CLOUD MODE
    // =====================================================

    if (isCloudSyncEnabled) {

      // ✅ FIRST pull cloud data
      await syncService.pullCategories();

      await syncService.pullExpenses();

      // ✅ THEN seed defaults if empty
      await db.seedDefaultCategories(
        user.uid,
      );

      // ✅ THEN push local unsynced
      await syncService.syncAll();
    }

    // =====================================================
    // 🔥 OFFLINE MODE
    // =====================================================

    else {

      // ✅ only local defaults
      await db.seedDefaultCategories(
        user.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(

      stream:
          FirebaseAuth.instance
              .authStateChanges(),

      builder: (context, snapshot) {

        // =================================================
        // 🔄 AUTH LOADING
        // =================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Scaffold(

            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        // =================================================
        // ❌ NOT LOGGED IN
        // =================================================

        if (!snapshot.hasData) {

          _initFuture = null;

          return const LoginScreen();
        }

        // =================================================
        // ✅ LOGGED IN
        // =================================================

        final user = snapshot.data!;

        // ✅ IMPORTANT
        // only initialize ONCE
        _initFuture ??=
            _initializeUser(user);

        return FutureBuilder(

          future: _initFuture,

          builder: (
            context,
            syncSnapshot,
          ) {

            // =============================================
            // 🔄 INITIALIZATION LOADING
            // =============================================

            if (syncSnapshot.connectionState ==
                ConnectionState.waiting) {

              return const Scaffold(

                body: Center(

                  child:
                      CircularProgressIndicator(),
                ),
              );
            }

            // =============================================
            // ❌ INITIALIZATION ERROR
            // =============================================

            if (syncSnapshot.hasError) {

              return Scaffold(

                body: Center(

                  child: Text(

                    'Sync Error:\n${syncSnapshot.error}',

                    textAlign:
                        TextAlign.center,
                  ),
                ),
              );
            }

            // =============================================
            // ✅ READY
            // =============================================

            return const MainScreen();
          },
        );
      },
    );
  }
}