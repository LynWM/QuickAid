import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_aid_app/components/admin_dashboard.dart';
import 'package:quick_aid_app/pages/home_page.dart';
import 'package:quick_aid_app/services/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // User not logged in → LoginPage
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // User is logged in → HomePage
        final user = snapshot.data!;
        return FutureBuilder<String?>(
          future: _getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data ?? "user"; // default if missing

            if (role == "admin") {
              return const AdminDashboard();
            } else {
              return const HomePage();
            }
          },
        );
      },
    );
  }
}

//helper function
Future<String?> _getUserRole(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    if (doc.exists) {
      return doc.data()?["role"] as String?;
    }
  } catch (e) {
    print("Error fetching role: $e");
  }
  return null; 
}
