import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogDetailPage extends StatelessWidget {
  final dynamic blog;
  const BlogDetailPage({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    final date = blog['createdAt']?.toDate();
    final formattedDate = date != null ? DateFormat('yMMMd').format(date) : 'Unknown date';

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Görsel
            if (blog['imageUrl'] != null && blog['imageUrl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  blog['imageUrl'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            // ✅ Başlık
            Text(
              blog['title'] ?? 'No title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ✅ Yayın tarihi
            Text(
              "Published on $formattedDate",
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 30, thickness: 1),

            // ✅ İçerik
            Text(
              blog['content'] ?? 'No content available.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
