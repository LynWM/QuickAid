import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuideDetailsPage extends StatelessWidget {
  final DocumentSnapshot data;

  const GuideDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> steps = data['steps'] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF890000),
        title: Text(
          data['title'],
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
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'first aid illustration'
                ),
              ),
            ),
            const SizedBox(height: 20),

            //intro
            Text(
              data['intro'] ?? '', style: TextStyle(fontSize: 18),
              ),

            const SizedBox(height: 20),

            //steps
            Text(
              "Steps:", 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                ),
              ),

            const SizedBox(height: 18),

            ...steps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${index + 1}. ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child:Text(
                        step,
                        style: TextStyle(fontSize: 18),
                      ),)
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
