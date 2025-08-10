import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CountyContactPage extends StatelessWidget {
  final String countyId;
  final String countyTitle;

  const CountyContactPage({
    super.key,
    required this.countyTitle,
    required this.countyId,
  });

  @override
  Widget build(BuildContext context) {
    // You can use county['name'] and categoryId here
    return Scaffold(
      appBar: AppBar(title: Text(countyTitle)),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hotline_categories')
            .doc('county')
            .collection('contacts')
            .doc(countyId)
            .collection('services')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No services found.'));
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final name = service['name'] ?? 'No Name';
              final phone = service['phone'] ?? 'No Number';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(phone),
                  trailing: IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    onPressed: () async {
                      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch dialer')),
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
    );
  }
}
