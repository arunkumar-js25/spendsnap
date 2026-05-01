import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:spendsnap/core/utils/settings_service.dart';

import 'package:spendsnap/core/utils/sync_service.dart';

import 'package:spendsnap/features/category/presentation/manage_categories_screen.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  bool cloudSyncEnabled = false;

  final settingsService =
      SettingsService();

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  // =========================================================
  // 🔥 LOAD SETTINGS
  // =========================================================

  Future<void> _loadSettings() async {

    final enabled =
        await settingsService
            .isCloudSyncEnabled();

    setState(() {
      cloudSyncEnabled = enabled;
    });
  }

  // =========================================================
  // 🔥 LOGOUT
  // =========================================================

  Future<void> _logout(
      BuildContext context) async {

    await GoogleSignIn().signOut();

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context)
        .popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),

            // =================================================
            // 🔥 PROFILE IMAGE
            // =================================================

            CircleAvatar(

              radius: 45,

              backgroundImage:
                  user?.photoURL != null
                      ? NetworkImage(
                          user!.photoURL!,
                        )
                      : null,

              child:
                  user?.photoURL == null

                      ? const Icon(
                          Icons.person,
                          size: 45,
                        )

                      : null,
            ),

            const SizedBox(height: 20),

            // =================================================
            // 🔥 NAME
            // =================================================

            Text(

              user?.displayName ?? "User",

              style: const TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // =================================================
            // 🔥 EMAIL
            // =================================================

            Text(

              user?.email ?? "",

              style: const TextStyle(

                color: Colors.grey,

                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // =================================================
            // 🔥 MANAGE CATEGORIES
            // =================================================

            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.category,
                ),

                title: const Text(
                  "Manage Categories",
                ),

                subtitle: const Text(
                  "Customize your expense categories",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          const ManageCategoriesScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // =================================================
            // 🔥 CLOUD SYNC TOGGLE
            // =================================================

            Card(

              child: SwitchListTile(

                secondary: const Icon(
                  Icons.cloud_sync,
                ),

                title: const Text(
                  "Cloud Sync",
                ),

                subtitle: const Text(
                  "Backup expenses to cloud",
                ),

                value: cloudSyncEnabled,

                onChanged: (value) async {

                  // ✅ save preference
                  await settingsService
                      .setCloudSyncEnabled(
                    value,
                  );

                  setState(() {
                    cloudSyncEnabled =
                        value;
                  });

                  // ✅ immediate sync
                  if (value) {

                    await SyncService()
                        .syncAll();

                    if (!mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Cloud sync enabled",
                        ),
                      ),
                    );
                  }

                  else {

                    if (!mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Cloud sync disabled",
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            // =================================================
            // 🔥 MANUAL SYNC
            // =================================================

            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.sync,
                ),

                title: const Text(
                  "Sync Now",
                ),

                subtitle: const Text(
                  "Manually sync your data",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),

                onTap: () async {

                  if(cloudSyncEnabled)
                  {
                      await SyncService()
                      .syncAll();

                    if (!mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Sync completed",
                        ),
                      ),
                    );
                  }
                  else {

                    if (!mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Enable cloud sync to use this feature",
                        ),
                      ),
                    );

                    return;
                  }
                  
                                  },
              ),
            ),

            const Spacer(),

            // =================================================
            // 🔥 LOGOUT BUTTON
            // =================================================

            SizedBox(

              width: double.infinity,

              height: 50,

              child: ElevatedButton.icon(

                onPressed: () =>
                    _logout(context),

                icon: const Icon(
                  Icons.logout,
                ),

                label: const Text(
                  "Logout",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}