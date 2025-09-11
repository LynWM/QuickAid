import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuideDetailsPage extends StatelessWidget {
  final DocumentSnapshot data;

  const GuideDetailsPage({super.key, required this.data});

  get progress => null;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> steps = data['steps'] ?? [];
    final String? imageUrl = data['imageUrl']; //firestore field
    if (imageUrl != null && imageUrl.isNotEmpty) {
      Image.network(imageUrl, fit: BoxFit.cover);
    } else {
      _imagePlaceholder();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF890000),
        title: Text(
          data['title'] ?? 'Guide',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //illustration placeholder
            // Container(
            // height: 180,
            // width: double.infinity,
            // decoration: BoxDecoration(
            // color: Colors.grey[200],
            // borderRadius: BorderRadius.circular(12),
            //),
            //child: Center(child: Text('first aid illustration')),
            //),
            const SizedBox(height: 20),

            //Illustration(firestore)
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  loadingBuilder: (context, child, loadingProgress) =>
                      progress == null
                      ? child
                      : SizedBox(
                          height: 200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ),
              )
            else
              _imagePlaceholder(),

            const SizedBox(height: 30),

            //intro
            if ((data['intro'] ?? '').toString().isNotEmpty)
              Text(data['intro'], style: TextStyle(fontSize: 18, height: 1.7)),

            const SizedBox(height: 15),

            const Divider(),

            const SizedBox(height: 15),

            //steps
            if (steps.isNotEmpty)
              Text(
                "Steps:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),

            const SizedBox(height: 16),

            //numbered steps
            ...steps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //CIRCLE STEP INDICATOR
                    Center(
                      child: Text(
                        "${index + 1}. ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'No illustration available',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
