import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quick_aid_app/components/my_button.dart';
import 'package:quick_aid_app/components/my_textfield.dart';
import 'package:quick_aid_app/services/authgate_page.dart';
import 'package:quick_aid_app/services/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Show loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  // Show error dialog
  void _showErrorDialog(String errorMessage) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Up Failed"),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Sign Up logic
  Future<void> signUserUp() async {
    _showLoadingDialog();

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user;

      if (user != null) {
        //try {
        // Save user details in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': 'user', // default role
          'createdAt': Timestamp.now(),
        });

        debugPrint("✅ Firestore write successful for user: ${user.uid}");
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // close loading

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => AuthGate())
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // close loading
      _showErrorDialog(e.message ?? "An error occurred.");
    } catch (e) {
      Navigator.of(context).pop(); //close loading
      _showErrorDialog("Unexpected error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 70, color: Colors.black),
                const SizedBox(height: 30),
                Text(
                  'Create your Quick Aid Account',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                ),
                const SizedBox(height: 25),

                MyTextField(
                  controller: nameController,
                  hintText: 'Name',
                  obscureText: false,
                ),
                const SizedBox(height: 20),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 20),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),
                MyButton(onTap: signUserUp, text: "Sign Up"),

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
