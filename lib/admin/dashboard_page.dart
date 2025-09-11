import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quick_aid_app/pages/home_page.dart';
import 'package:quick_aid_app/pages/settings_page.dart';
import 'package:quick_aid_app/admin/admin_guides_page.dart';
import 'package:quick_aid_app/admin/admin_hotlines_page.dart';
import 'package:quick_aid_app/services/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<DashboardPage> {
  int _guidesCount = 0;
  int _hotlinesCount = 0;
  Map<String, int> _hotlineCategories = {
    "fire": 0,
    "ambulance": 0,
    "county": 0,
    "general": 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      int guidesCount = 0;
      int hotlinesCount = 0;

      // --- Count Guides ---
      var guidesSnapshot = await FirebaseFirestore.instance
          .collection('guides')
          .get();
      guidesCount = guidesSnapshot.size;

      // --- Count Hotlines by Category ---
      var categoriesSnapshot = await FirebaseFirestore.instance
          .collection('hotline_categories')
          .get();

      Map<String, int> categoryCounts = {
        "Fire": 0,
        "Ambulance": 0,
        "General": 0,
        "County": 0,
      };

      for (var doc in categoriesSnapshot.docs) {
        final title = (doc['title'] ?? "").toString().toLowerCase();

        if (title.contains("fire")) {
          var fireSnapshot = await doc.reference.collection('contacts').get();
          hotlinesCount += fireSnapshot.size;
          categoryCounts["Fire"] = fireSnapshot.size;
        } else if (title.contains("ambulance")) {
          var ambSnapshot = await doc.reference.collection('contacts').get();
          hotlinesCount += ambSnapshot.size;
          categoryCounts["Ambulance"] = ambSnapshot.size;
        } else if (title.contains("general")) {
          var genSnapshot = await doc.reference.collection('contacts').get();
          hotlinesCount += genSnapshot.size;
          categoryCounts["General"] = genSnapshot.size;
        } else if (title.contains("county")) {
          var countiesSnapshot = await doc.reference
              .collection('contacts')
              .get();
          for (var countyDoc in countiesSnapshot.docs) {
            var servicesSnapshot = await countyDoc.reference
                .collection('services')
                .get();
            hotlinesCount += servicesSnapshot.size;
            categoryCounts["County"] =
                (categoryCounts["County"] ?? 0) + servicesSnapshot.size;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _guidesCount = guidesCount;
        _hotlinesCount = hotlinesCount;
        _hotlineCategories = categoryCounts;
      });
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF890000),
        title: Text('ADMIN DASHBOARD', style: TextStyle(color: Colors.white)),
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
        child: Column(
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
                    title: Text('HOME', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(role: "admin"),
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
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Management cards ---
            Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                leading: const Icon(
                  Icons.menu_book,
                  size: 32,
                  color: Color(0xFF890000),
                ),
                title: const Text(
                  "Manage Guides",
                  style: TextStyle(fontSize: 21),
                  ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminGuidesPage()),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),

            Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                leading: const Icon(Icons.phone, color: Color(0xFF890000), size: 32),
                title: const Text(
                  "Manage Hotlines",
                  style: TextStyle(fontSize: 21),
                  ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminHotlinesPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 26),

            // --- Analytics section ---
            Text(
              "Analytics",
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),

            const SizedBox(height: 16),

            // Quick stats row
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Guides",
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$_guidesCount",
                            style: theme.textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Hotlines",
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$_hotlinesCount",
                            style: theme.textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // Pie Chart for hotline breakdown
            Text(
              "Hotlines Breakdown",
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 23,
              ),
            ),
            const SizedBox(height: 5),

            // Pie chart for hotline breakdown
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _hotlineCategories.entries
                      .map((entry) {
                        final category = entry.key;
                        final count = entry.value;

                        if (count == 0) return null; // Skip empty categories

                        return PieChartSectionData(
                          color: _getCategoryColor(category),
                          value: count.toDouble(),
                          title: "$count",
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      })
                      .whereType<PieChartSectionData>()
                      .toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Legend for categories
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _hotlineCategories.keys.map((category) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      color: _getCategoryColor(category),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "$category (${_hotlineCategories[category]})",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Fire":
        return Colors.red;
      case "Ambulance":
        return Colors.green;
      case "County":
        return Colors.orange;
      case "General":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
