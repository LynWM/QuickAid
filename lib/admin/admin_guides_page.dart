import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      appBar: AppBar(title: const Text("Manage Guides"),
      backgroundColor: const Color(0xFF890000),
       centerTitle: true),
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
            padding: EdgeInsets.all(16),
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];
              final data = guide.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10),
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

    final ImagePicker picker = ImagePicker();
    XFile? pickedImage;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Guide"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: introController,
                    decoration: const InputDecoration(labelText: "Intro"),
                  ),
                  TextField(
                    controller: stepsController,
                    decoration: const InputDecoration(
                      labelText: "Steps (comma separated)",
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() => pickedImage = image);
                      }
                    },
                    icon: Icon(Icons.image),
                    label: Text("Pick Image"),
                  ),
                  if (pickedImage != null)
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Image.file(File(pickedImage!.path), height: 120),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  String? imageUrl;
                  if (pickedImage != null) {
                    final storageRef = FirebaseStorage.instance.ref().child(
                      "guides_images/${DateTime.now().millisecondsSinceEpoch}.png",
                    );

                    await storageRef.putFile(File(pickedImage!.path));
                    imageUrl = await storageRef.getDownloadURL();
                  }

                  await guidesRef.add({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'intro': introController.text,
                    'steps': stepsController.text
                        .split(',')
                        .map((s) => s.trim())
                        .toList(),
                    'isSaved': false,
                  });
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Edit existing guide ---
  Future<void> _editGuide(
    BuildContext context,
    QueryDocumentSnapshot guide,
  ) async {
    final data = guide.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: data['title']);
    final descriptionController = TextEditingController(
      text: data['description'],
    );
    final introController = TextEditingController(text: data['intro']);
    final stepsController = TextEditingController(
      text: (data['steps'] as List<dynamic>).join(', '),
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Guide"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //title
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              const SizedBox(height: 10),
              //Description
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 12),

              //Intro
              TextField(
                controller: introController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(labelText: "Intro"),
              ),
              const SizedBox(height: 12),

              //Steps (multiline, comma seperated)
              TextField(
                controller: stepsController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Steps (comma separated)",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await guide.reference.update({
                'title': titleController.text,
                'description': descriptionController.text,
                'intro': introController.text,
                'steps': stepsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .toList(),
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
