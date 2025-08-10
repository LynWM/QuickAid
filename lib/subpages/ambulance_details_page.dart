import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AmbulanceDetailsPage extends StatefulWidget {
  final DocumentSnapshot data;

  const AmbulanceDetailsPage({super.key, required this.data});

  @override
  State<AmbulanceDetailsPage> createState() => _AmbulanceDetailsPageState();
}

class _AmbulanceDetailsPageState extends State<AmbulanceDetailsPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoryId = widget.data.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF890000),
        title: Text(
          widget.data['title'] ?? 'Ambulance Services',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search for ambulance...',
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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Ambulance Services',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance
                  .collection('hotline_categories')
                  .doc(categoryId)
                  .collection('contacts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child:Text('No contacts found.'));
                }

                final contacts = snapshot.data!.docs.where((doc) {
                  final name = (doc['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final name = contact['name'] ?? 'No Name';
                    final phone = contact['phone'] ?? 'No Number';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text(phone),
                        trailing: IconButton(
                          icon: Icon(Icons.call, color: Colors.green),
                          onPressed: () async {
                            final Uri callUri = Uri(scheme: 'tel', path: phone);
                            if (await canLaunchUrl(callUri)) {
                              await launchUrl(callUri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cannot place call'),
                                ),
                              );
                            }
                          },
                        ),
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
