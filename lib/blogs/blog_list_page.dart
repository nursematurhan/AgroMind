import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/filter_widget.dart';
import 'add_blog_page.dart';
import 'blog_detail_page.dart';

class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  String selectedCategory = "All";
  String searchQuery = "";

  final categories = [
    "All",
    "Soil Health",
    "Sustainable Farming",
    "Climate-Smart Agriculture",
    "Beginner to Advanced",
    "Crop Guides",
    "Composting and Soil Enrichment",
    "Pest and Disease Management ",
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.email == "admin@gmail.com";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          FilterWidget(
            onSearchChanged: (value) {
              setState(() => searchQuery = value.toLowerCase());
            },
            onFilterPressed: _showCategoryDialog,
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('blogs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBlogs = snapshot.data!.docs;

                final filtered = allBlogs.where((doc) {
                  final title = doc['title'].toString().toLowerCase();
                  final categoryMatch = selectedCategory == "All" || doc['category'] == selectedCategory;
                  final searchMatch = searchQuery.isEmpty || title.contains(searchQuery);
                  return categoryMatch && searchMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No result found."));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final blog = filtered[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (blog['imageUrl'] != null && blog['imageUrl'].toString().isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                blog['imageUrl'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ListTile(
                            title: Text(blog['title']),
                            subtitle: Text(
                              blog['summary'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              DateFormat('yMMMd').format(blog['createdAt'].toDate()),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlogDetailPage(blog: blog),
                                      ),
                                    );
                                  },
                                  child: const Text("Details"),
                                ),
                                if (isAdmin) ...[
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddBlogPage(blog: blog),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    label: const Text("Edit", style: TextStyle(color: Colors.orange)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteBlog(blog.id),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBlogPage()),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((category) {
            final isSelected = category == selectedCategory;
            return ListTile(
              tileColor: isSelected ? Colors.green[800] : null,
              title: Text(category),
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _deleteBlog(String docId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this blog?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('blogs').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Blog deleted")),
      );
    }
  }
}
