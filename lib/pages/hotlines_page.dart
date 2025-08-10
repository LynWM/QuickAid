import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_aid_app/subpages/ambulance_details_page.dart';
import 'package:quick_aid_app/subpages/county_selection_page.dart';
import 'package:quick_aid_app/subpages/fire_details_page.dart';
import 'package:quick_aid_app/subpages/general_emergencies_page.dart';


class HotlinesPage extends StatefulWidget {
  const HotlinesPage({super.key});

  @override
  State<HotlinesPage> createState() => _HotlinesPageState();
}

class _HotlinesPageState extends State<HotlinesPage> {
  Widget _getIcon(String? iconName) {
    switch (iconName) {
      case 'ambulance':
        return const Icon(Icons.local_hospital, color: Color(0xFF890000));
      case 'fire':
        return const Icon(
          Icons.local_fire_department,
          color: Color(0xFF890000),
        );
      case 'emergency':
        return const Icon(Icons.warning_rounded, color: Color(0xFF890000));
      case 'county':
        return const Icon(
          Icons.location_city_rounded,
          color: Color(0xFF890000),
        );
      default:
        return const Icon(Icons.phone, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Section title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hotlines',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Expanded guide list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('hotline_categories')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No categories found.'));
              }

              final categories = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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

                      //onTap functionality for each section
                      onTap: () {
                        final title = category['title'].toString().toLowerCase();

                        if (title.contains('ambulance')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AmbulanceDetailsPage(data: category),
                            ),
                          );
                        } else if (title.contains('fire')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FireDetailsPage(data: category),
                            ),
                          );
                        } else if (title.contains('county')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CountySelectionPage(data: category),
                            ));
                        } else if (title.contains('general')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GeneralEmergenciesPage(data: category),
                            ));
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
