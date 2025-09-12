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
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    
    final categoryId = widget.data.id;

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

          //SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 10.0,
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for a county...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),


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
                        leading: const Icon(Icons.location_city_rounded),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
