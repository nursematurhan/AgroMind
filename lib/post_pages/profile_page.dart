import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final nameController = TextEditingController();
  bool isEditingName = false;
  List<Map<String, dynamic>> userAddresses = [];

  void updateDisplayName() async {
    try {
      await user!.updateDisplayName(nameController.text.trim());
      await user!.reload();
      setState(() {
        isEditingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Name updated successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to update name: $e")),
      );
    }
  }

  void changePassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📧 Password reset link sent to your email.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send reset email: $e")),
      );
    }
  }

  void fetchUserAddresses() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      final data = doc.data();
      if (data != null && data['addresses'] != null) {
        List<dynamic> rawAddresses = data['addresses'];
        setState(() {
          userAddresses = rawAddresses.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to load addresses: $e")),
      );
    }
  }

  Future<void> deleteAddress(int index) async {
    final uid = user?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    userAddresses.removeAt(index);
    await docRef.update({'addresses': userAddresses});
    fetchUserAddresses();
  }

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? "";
    fetchUserAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user?.email == "admin@gmail.com";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.account_circle, size: 100, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  user?.email ?? "",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (isAdmin)
                const Center(
                  child: Text("👑 Admin User", style: TextStyle(color: Colors.orange)),
                ),
              const SizedBox(height: 30),

              const Text("📍 Addresses:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              userAddresses.isNotEmpty
                  ? Column(
                children: userAddresses.asMap().entries.map((entry) {
                  int index = entry.key;
                  var addr = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text("🏠 ${addr['title']}: ${addr['address']}", style: const TextStyle(fontSize: 16)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteAddress(index),
                      ),
                    ),
                  );
                }).toList(),
              )
                  : const Text("No address found.", style: TextStyle(fontSize: 16)),

              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                enabled: isEditingName,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              isEditingName
                  ? ElevatedButton(
                onPressed: updateDisplayName,
                child: const Text("Save Name"),
              )
                  : OutlinedButton(
                onPressed: () => setState(() => isEditingName = true),
                child: const Text("Edit Name"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: changePassword,
                icon: const Icon(Icons.lock_reset),
                label: const Text("Change Password"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }
}
