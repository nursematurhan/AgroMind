import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddBlogPage extends StatefulWidget {
  final DocumentSnapshot? blog;

  const AddBlogPage({super.key, this.blog});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController summaryController;
  late TextEditingController contentController;
  late TextEditingController imageUrlController;

  String selectedCategory = "Vegetables & Fruits";

  final categories = [
    "Vegetables & Fruits",
    "Grains",
    "Seedlings",
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.blog?['title'] ?? '');
    summaryController = TextEditingController(text: widget.blog?['summary'] ?? '');
    contentController = TextEditingController(text: widget.blog?['content'] ?? '');
    imageUrlController = TextEditingController(text: widget.blog?['imageUrl'] ?? '');
    selectedCategory = widget.blog?['category'] ?? categories.first;
  }

  void submitBlog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email != "admin@gmail.com") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only admin can add or edit blogs.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        "title": titleController.text.trim(),
        "summary": summaryController.text.trim(),
        "content": contentController.text.trim(),
        "imageUrl": imageUrlController.text.trim(),
        "category": selectedCategory,
        "authorId": user.uid,
        "authorEmail": user.email,
      };


      if (widget.blog == null) {
        data["createdAt"] = Timestamp.now();
        await FirebaseFirestore.instance.collection("blogs").add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Blog added successfully.")),
        );
      } else {
        data["updatedAt"] = Timestamp.now();
        await FirebaseFirestore.instance.collection("blogs").doc(widget.blog!.id).update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✏️ Blog updated successfully.")),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.blog != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Blog" : "Add New Blog"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (val) => val == null || val.isEmpty ? "Title is required" : null,
              ),
              TextFormField(
                controller: summaryController,
                decoration: const InputDecoration(labelText: "Short Description"),
                validator: (val) => val == null || val.isEmpty ? "Summary is required" : null,
              ),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Content"),
                maxLines: 6,
                validator: (val) => val == null || val.isEmpty ? "Content is required" : null,
              ),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL (optional)"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: selectedCategory,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitBlog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEdit ? "Update Blog" : "Add Blog"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
