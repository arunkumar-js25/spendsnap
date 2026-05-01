import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);

  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            // 🔥 Profile Image
            CircleAvatar(
              radius: 45,
              backgroundImage:
                  user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,

              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 45)
                  : null,
            ),

            const SizedBox(height: 20),

            // 🔥 Name
            Text(
              user?.displayName ?? "User",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // 🔥 Email
            Text(
              user?.email ?? "",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // 🔥 Manage Categories
            Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text("Manage Categories"),
                subtitle: const Text("Customize your expense categories"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                onTap: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Coming soon 🚀"),
                    ),
                  );

                },
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 Cloud Sync
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_sync),
                title: const Text("Cloud Sync"),
                subtitle: const Text("Backup your expenses securely"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                onTap: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Coming soon 🚀"),
                    ),
                  );

                },
              ),
            ),

            const Spacer(),

            // 🔥 Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: () => _logout(context),

                icon: const Icon(Icons.logout),

                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}