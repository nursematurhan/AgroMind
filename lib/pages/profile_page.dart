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

  void changePassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🔒 Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              final currentPassword = currentPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();

              if (user?.email == null) return;

              final cred = EmailAuthProvider.credential(
                email: user!.email!,
                password: currentPassword,
              );

              try {
                await user.reauthenticateWithCredential(cred);
                await user.updatePassword(newPassword);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Password changed successfully.")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Failed to change password: $e")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
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

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Address deleted successfully.")),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
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
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.lightGreen,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    user?.email ?? "",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isAdmin)
                  const Center(
                    child: Text("👑 Admin User", style: TextStyle(color: Colors.orange)),
                  ),
                const SizedBox(height: 30),

                Center(
                  child: TextField(
                    controller: nameController,
                    enabled: isEditingName,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: "Your Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: isEditingName
                      ? ElevatedButton(
                    onPressed: updateDisplayName,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
                    child: const Text("Save Name"),
                  )
                      : OutlinedButton(
                    onPressed: () => setState(() => isEditingName = true),
                    child: const Text("Edit Name"),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: changePassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text("Change Password"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        minimumSize: const Size(150, 40),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddressDialog(context),
                      icon: const Icon(Icons.location_on),
                      label: const Text("Addresses"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        minimumSize: const Size(150, 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Center(
                  child: ElevatedButton.icon(
                      onPressed: _confirmSignOut,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      minimumSize: const Size(200, 40),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Your Addresses"),
        content: SizedBox(
          width: double.maxFinite,
          child: userAddresses.isNotEmpty
              ? ListView.builder(
            shrinkWrap: true,
            itemCount: userAddresses.length,
            itemBuilder: (context, index) {
              final addr = userAddresses[index];
              return ListTile(
                title: Text("🏠 ${addr['title']}: ${addr['address']}",
                    style: const TextStyle(fontSize: 16)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Navigator.pop(context);
                    deleteAddress(index);
                  },
                ),
              );
            },
          )
              : const Text("No address found."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
