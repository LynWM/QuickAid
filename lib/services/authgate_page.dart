import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_aid_app/components/admin_dashboard.dart';
import 'package:quick_aid_app/pages/home_page.dart';
import 'package:quick_aid_app/services/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> _getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      if (doc.exists) {
        final role = doc.data()?["role"] as String?;
        if (role != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("userRole", role); //save role
        }
        return role;
      }
    } catch (e) {
      print("Error fetching role: $e");
    }
    return null;
  }

  Future<String?> _getCachedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userRole");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginPage();
        }

        final user = snapshot.data!;

        return FutureBuilder<String?>(
          future: _getCachedRole(),
          builder: (context, cacheSnapshot) {
            if (cacheSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final cachedRole = cacheSnapshot.data;

            if (cachedRole != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _getUserRole(user.uid);
              });

              if (cachedRole == "admin") {
                return AdminDashboard();
              } else {
                return HomePage();
              }
            }

            //fetching from firestore if no cached role
            return FutureBuilder<String?>(
              future: _getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return HomePage();
                }

                final role = roleSnapshot.data ?? "user";

                if (role == "admin") {
                  return AdminDashboard();
                } else {
                  return HomePage();
                }
              },
            );
          },
        );
      },
    );
  }
}
