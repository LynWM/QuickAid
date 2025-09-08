import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_aid_app/components/bottom_nav_bar.dart';
import 'package:quick_aid_app/admin/dashboard_page.dart';
import 'package:quick_aid_app/pages/guides_page.dart';
import 'package:quick_aid_app/pages/hotlines_page.dart';
import 'package:quick_aid_app/pages/map_page.dart';
import 'package:quick_aid_app/pages/settings_page.dart';
import 'package:quick_aid_app/services/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //this selected index will update our selected index
  int _selectedIndex = 0;

  //this method will update our selected index
  //when the user taps on the bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //pages to display
  final List<Widget> _pages = [
    //guides page
    const GuidesPage(),

    //map page
    const MapPage(),

    //hotlines page
    const HotlinesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF890000),
        title: Text('QUICK AID', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu_rounded, color: Colors.white),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      drawer: Drawer(
        backgroundColor: Color(0xFF890000),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  "Error loading user data",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final userData =
                snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final role = userData['role'] ?? 'user';
            print("USER ROLE: $role");

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    //LOGO
                    DrawerHeader(
                      child: Image.asset(
                        'lib/images/logo2.png',
                        color: Colors.white,
                      ),
                    ),

                    //other pages
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: ListTile(
                        leading: Icon(Icons.home, color: Colors.white),
                        title: Text(
                          'HOME',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),

                      child: ListTile(
                        leading: Icon(Icons.settings, color: Colors.white),
                        title: Text(
                          'SETTINGS',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ),

                    //Admin Dashboard
                    if (role == "admin")
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),

                        child: ListTile(
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                          ),
                          title: Text(
                            'ADMIN DASHBOARD',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardPage(),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 25),

                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text(
                      'LOG OUT',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      //navigating to login page
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
