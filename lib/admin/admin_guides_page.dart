import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminGuidesPage extends StatefulWidget {
  const AdminGuidesPage({Key? key}) : super(key: key);

  @override
  State<AdminGuidesPage> createState() => _AdminGuidesPageState();
}

class _AdminGuidesPageState extends State<AdminGuidesPage> {
  final guidesRef = FirebaseFirestore.instance.collection('guides');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Guides")),
      body: StreamBuilder<QuerySnapshot>(
        stream: guidesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No guides available"));
          }

          final guides = snapshot.data!.docs;

          return ListView.builder(
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];
              final data = guide.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['title'] ?? 'No title'),
                  subtitle: Text(data['description'] ?? 'No description'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editGuide(context, guide),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGuide(guide.id),
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
        onPressed: () => _addGuide(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Add new guide ---
  Future<void> _addGuide(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final introController = TextEditingController();
    final stepsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Guide"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: introController, decoration: const InputDecoration(labelText: "Intro")),
              TextField(
                controller: stepsController,
                decoration: const InputDecoration(labelText: "Steps (comma separated)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await guidesRef.add({
                'title': titleController.text,
                'description': descriptionController.text,
                'intro': introController.text,
                'steps': stepsController.text.split(',').map((s) => s.trim()).toList(),
                'isSaved': false,
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // --- Edit existing guide ---
  Future<void> _editGuide(BuildContext context, QueryDocumentSnapshot guide) async {
    final data = guide.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: data['title']);
    final descriptionController = TextEditingController(text: data['description']);
    final introController = TextEditingController(text: data['intro']);
    final stepsController = TextEditingController(text: (data['steps'] as List<dynamic>).join(', '));

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Guide"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: introController, decoration: const InputDecoration(labelText: "Intro")),
              TextField(
                controller: stepsController,
                decoration: const InputDecoration(labelText: "Steps (comma separated)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await guide.reference.update({
                'title': titleController.text,
                'description': descriptionController.text,
                'intro': introController.text,
                'steps': stepsController.text.split(',').map((s) => s.trim()).toList(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- Delete guide ---
  Future<void> _deleteGuide(String docId) async {
    await guidesRef.doc(docId).delete();
  }
}
