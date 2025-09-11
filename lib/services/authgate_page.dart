import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quick_aid_app/admin/dashboard_page.dart';
import 'package:quick_aid_app/pages/home_page.dart';
import 'package:quick_aid_app/services/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String> getUserRole(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!snapshot.exists) return "user";

    final data = snapshot.data() as Map<String, dynamic>;
    return data['role'] as String? ?? "user";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User NOT logged in → LoginPage
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // User logged in → fetch role
        final user = snapshot.data!;
        return FutureBuilder<String>(
          future: getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: Text("Error loading role")),
              );
            }

            final role = roleSnapshot.data!;
            print("✅ AuthGate sending role → $role");

            // ✅ Route based on role
            return HomePage(role: role);
          },
        );
      },
    );
  }
}
