import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class QueryDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const QueryDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final suggestion = data['suggestion'] ?? '';
    final category = data['category'] ?? '';
    final locationType = data['locationType'] ?? '';
    final addressTitle = data['addressTitle'] ?? '';
    final addressDetail = data['addressDetail'] ?? '';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Details'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🌿 Suggestion: $suggestion", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("📦 Category: $category"),
            Text("🧱 Location Type: $locationType"),
            Text("🏷️ Address: $addressTitle - $addressDetail"),
            if (timestamp != null)
              Text("🕒 Date: ${DateFormat.yMMMMd().add_Hm().format(timestamp)}"),
          ],
        ),
      ),
    );
  }
}
