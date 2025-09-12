import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminGeneralEmergenciesPage extends StatefulWidget {

  @override
  State<AdminGeneralEmergenciesPage> createState() => _AdminGeneralEmergenciesPageState();
}

class _AdminGeneralEmergenciesPageState extends State<AdminGeneralEmergenciesPage> {
  final CollectionReference generalContacts = FirebaseFirestore.instance
      .collection('hotline_categories')
      .doc('general')
      .collection('contacts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage General Emergencies"),
        backgroundColor: Color(0xFF890000),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: generalContacts.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No general emergency contacts yet."));
          }

          final contacts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final name = contact['name'];
              final phone = contact['phone'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.warning_rounded, color: Colors.orangeAccent, size: 30),
                  title: Text(name),
                  subtitle: Text(phone),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () {
                          _showContactDialog(context, contact.id, name, phone);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          generalContacts.doc(contact.id).delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: const Icon(Icons.add),
        onPressed: () {
          _showContactDialog(context, null, "", "");
        },
      ),
    );
  }

  void _showContactDialog(BuildContext context, String? docId, String name, String phone) {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docId == null ? "Add Contact" : "Edit Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newPhone = phoneController.text.trim();

              if (newName.isNotEmpty && newPhone.isNotEmpty) {
                if (docId == null) {
                  generalContacts.add({"name": newName, "phone": newPhone});
                } else {
                  generalContacts.doc(docId).update({"name": newName, "phone": newPhone});
                }
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
