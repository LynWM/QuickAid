import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_aid_app/admin/admin_ambulance.dart';
import 'package:quick_aid_app/admin/admin_county.dart';
import 'package:quick_aid_app/admin/admin_emergencies.dart';
import 'package:quick_aid_app/admin/admin_fire.dart';

class AdminHotlinesPage extends StatefulWidget {
  const AdminHotlinesPage({super.key});

  @override
  State<AdminHotlinesPage> createState() => _AdminHotlinesPageState();
}

class _AdminHotlinesPageState extends State<AdminHotlinesPage> {
  Widget _getIcon(String? iconName) {
    switch (iconName) {
      case 'ambulance':
        return const Icon(Icons.local_hospital, color: Color(0xFF890000));
      case 'fire':
        return const Icon(Icons.local_fire_department, color: Color(0xFF890000));
      case 'emergency':
        return const Icon(Icons.warning_rounded, color: Color(0xFF890000));
      case 'county':
        return const Icon(Icons.location_city_rounded, color: Color(0xFF890000));
      default:
        return const Icon(Icons.phone, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,   // make sure page isn't black
      appBar: AppBar(
        title: const Text("Manage Hotlines"),
        backgroundColor: const Color(0xFF890000),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('hotline_categories')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No categories found."));
            }
        
            final categories = snapshot.data!.docs;
        
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final icon = category['icon'];
                final title = category['title'];
        
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: _getIcon(icon),
                    title: Text(title ?? 'No Title'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final lowerTitle = (title ?? "").toLowerCase();
        
                      if (lowerTitle.contains('ambulance')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminAmbulancePage(),
                          ),
                        );
                      } else if (lowerTitle.contains('fire')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminFirePage(),
                          ),
                        );
                      } else if (lowerTitle.contains('county')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminCountyHotlinesPage(),
                          ),
                        );
                      } else if (lowerTitle.contains('general')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminGeneralEmergenciesPage(),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
