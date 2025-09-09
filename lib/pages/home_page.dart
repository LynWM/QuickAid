import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quick_aid_app/admin/dashboard_page.dart';
import 'package:quick_aid_app/components/bottom_nav_bar.dart';
import 'package:quick_aid_app/pages/guides_page.dart';
import 'package:quick_aid_app/pages/hotlines_page.dart';
import 'package:quick_aid_app/pages/map_page.dart';
import 'package:quick_aid_app/pages/settings_page.dart';
import 'package:quick_aid_app/services/login_page.dart';


class HomePage extends StatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const GuidesPage(),
    const MapPage(),
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
        backgroundColor: const Color(0xFF890000),
        title: const Text('QUICK AID', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu_rounded, color: Colors.white),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      // Drawer now uses the role passed from AuthGate
      drawer: Drawer(
        backgroundColor: const Color(0xFF890000),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  child: Image.asset(
                    'lib/images/logo2.png',
                    color: Colors.white,
                  ),
                ),

                // Home
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text('HOME', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(role: widget.role),
                      ),
                    );
                  },
                ),

                // Settings
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text('SETTINGS', style: TextStyle(color: Colors.white)),
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

                // Admin Dashboard (only if role == admin)
                if (widget.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
                    title: const Text('ADMIN DASHBOARD',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    },
                  ),
              ],
            ),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('LOG OUT', style: TextStyle(color: Colors.white)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
