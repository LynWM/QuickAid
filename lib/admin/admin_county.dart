import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCountyHotlinesPage extends StatefulWidget {
  const AdminCountyHotlinesPage({Key? key}) : super(key: key);

  @override
  State<AdminCountyHotlinesPage> createState() => _AdminCountyHotlinesPageState();
}

class _AdminCountyHotlinesPageState extends State<AdminCountyHotlinesPage> {
  String? _selectedCountyId;
  // ignore: unused_field
  String? _selectedCountyName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage County Hotlines")),
      body: Column(
        children: [
          // --- Counties Dropdown ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('hotline_categories')
                .doc('county')
                .collection('contacts')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final counties = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCountyId,
                        hint: const Text("Select County"),
                        items: counties.map((doc) {
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(doc['title']),
                          );
                        }).toList()
                          ..add(
                            const DropdownMenuItem(
                              value: "new",
                              child: Text("➕ Add New County"),
                            ),
                          ),
                        onChanged: (value) {
                          if (value == "new") {
                            _addCounty();
                          } else {
                            setState(() {
                              _selectedCountyId = value;
                              _selectedCountyName = counties
                                  .firstWhere((c) => c.id == value)['title'];
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // --- Services list for selected county ---
          Expanded(
            child: _selectedCountyId == null
                ? const Center(child: Text("Select a county"))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('hotline_categories')
                        .doc('county')
                        .collection('contacts')
                        .doc(_selectedCountyId)
                        .collection('services')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final services = snapshot.data!.docs;

                      return ListView(
                        children: services.map((doc) {
                          return Card(
                            child: ListTile(
                              title: Text(doc['name']),
                              subtitle: Text(doc['phone']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editService(doc),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => doc.reference.delete(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedCountyId == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: _addService,
            ),
    );
  }

  // --- Add new county ---
  void _addCounty() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add County"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "County name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final newDoc = await FirebaseFirestore.instance
                  .collection('hotline_categories')
                  .doc('county')
                  .collection('contacts')
                  .add({'title': controller.text});

              setState(() {
                _selectedCountyId = newDoc.id;
                _selectedCountyName = controller.text;
              });

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // --- Edit existing county ---
  // ignore: unused_element
  void _editCounty(QueryDocumentSnapshot doc) {
    final controller = TextEditingController(text: doc['title']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit County"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "County name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await doc.reference.update({'title': controller.text});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- Add new service ---
  void _addService() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('hotline_categories')
                  .doc('county')
                  .collection('contacts')
                  .doc(_selectedCountyId)
                  .collection('services')
                  .add({
                'name': nameController.text,
                'phone': phoneController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // --- Edit existing service ---
  void _editService(QueryDocumentSnapshot doc) {
    final nameController = TextEditingController(text: doc['name']);
    final phoneController = TextEditingController(text: doc['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await doc.reference.update({
                'name': nameController.text,
                'phone': phoneController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
