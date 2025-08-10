import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_aid_app/subpages/county_contact_page.dart';


class CountySelectionPage extends StatefulWidget {
  final DocumentSnapshot data;

  const CountySelectionPage({super.key, required this.data});

  @override
  State<CountySelectionPage> createState() => _CountySelectionPageState();
}

class _CountySelectionPageState extends State<CountySelectionPage> {
  @override
  Widget build(BuildContext context) {
    final String categoryId = widget.data.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890000),
        title: Text(
          widget.data['title'] ?? 'County Specific Services',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          //add search bar with controller if needed
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Counties',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hotline_categories')
                  .doc('county')
                  .collection('contacts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final countyDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: countyDocs.length,
                  itemBuilder: (context, index) {
                    final county = countyDocs[index];
                    final title = county['title'] ?? 'No Title';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(title),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CountyContactPage(
                                countyTitle: title,
                                countyId: county.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
