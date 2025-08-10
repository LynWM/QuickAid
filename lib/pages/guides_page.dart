import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_aid_app/subpages/guide_details_page.dart';

class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key});

  @override
  State<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 20),

        //search bar for filtering guides
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
              hintText: 'Search guides...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),

        const SizedBox(height: 20),

        // Section title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('First Aid Guides'),
          ),
        ),

        const SizedBox(height: 10),

        // Expanded guide list
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('guides')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No guides found.'));
                }

                final guides = snapshot.data!.docs;

                final filteredGuides = searchQuery.isEmpty
                    ? guides
                    : guides.where((guide) {
                        final title = guide['title']?.toLowerCase() ?? '';
                        final description =
                            guide['description']?.toLowerCase() ?? '';
                        return title.contains(searchQuery) ||
                            description.contains(searchQuery);
                      }).toList();

                if (filteredGuides.isEmpty) {
                  return const Center(child: Text('No matching guides found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredGuides.length,
                  itemBuilder: (context, index) {
                    final guide = filteredGuides[index];

                    final title = guide['title'];
                    final description = guide['description'];

                    return Card(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          title ?? 'No Title',
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          description ?? 'No Description',
                          style: theme.textTheme.bodyLarge,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GuideDetailsPage(data: guide),
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
        ),
      ],
    );
  }
}
