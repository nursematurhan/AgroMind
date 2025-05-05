import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  String selectedLocationType = 'Garden';
  String selectedCategory = 'Vegetables & Fruits';
  List<Map<String, String>> userAddresses = [];
  Map<String, String>? selectedAddress;

  final categoryOptions = [
    'Vegetables & Fruits',
    'Grains',
    'Seedlings',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserAddresses();
  }

  Future<void> _fetchUserAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    final data = doc.data();
    final List<dynamic> addresses = data?['addresses'] ?? [];

    setState(() {
      userAddresses = addresses.map<Map<String, String>>((e) => {
        'title': e['title']?.toString() ?? '',
        'address': e['address']?.toString() ?? '',

      }).toList();

      if (userAddresses.isNotEmpty) {
        selectedAddress = userAddresses.first;
      }
    });
  }

  Future<void> _addAddress() async {
    final titleController = TextEditingController();
    final addressController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Choose how to add address", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text("Select from Map"),
              onPressed: () async {
                Navigator.pop(context); // Close bottom sheet
                final selectedLocation = await Navigator.pushNamed(context, '/map') as LatLng?;
                if (selectedLocation != null) {
                  final titleInput = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      final titleCtrl = TextEditingController();
                      return AlertDialog(
                        title: const Text("Add Title for This Location"),
                        content: TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(labelText: "Title"),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                          TextButton(onPressed: () => Navigator.pop(context, titleCtrl.text), child: const Text("Save")),
                        ],
                      );
                    },
                  );

                  if (titleInput != null && titleInput.trim().isNotEmpty) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
                    final doc = await docRef.get();
                    final List<dynamic> addresses = (doc.data()?['addresses'] ?? []) as List<dynamic>;

                    addresses.add({
                      'title': titleInput.trim(),
                      'address': "Lat: ${selectedLocation.latitude}, Lng: ${selectedLocation.longitude}",
                      'lat': selectedLocation.latitude,
                      'lng': selectedLocation.longitude,
                      'email': user.email,
                    });

                    if (doc.exists) {
                      await docRef.update({'addresses': addresses});
                    } else {
                      await docRef.set({'addresses': addresses});
                    }

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ Address saved from map!")),
                    );
                    _fetchUserAddresses();
                  }
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_location_alt),
              label: const Text("Enter Manually"),
              onPressed: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Add Address"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        TextField(
                          controller: addressController,
                          decoration: const InputDecoration(labelText: 'Address'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Save")),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
                  final doc = await docRef.get();
                  final List<dynamic> addresses = (doc.data()?['addresses'] ?? []) as List<dynamic>;

                  addresses.add({
                    'title': titleController.text.trim(),
                    'address': addressController.text.trim(),
                    'email': user.email,
                  });

                  if (doc.exists) {
                    await docRef.update({'addresses': addresses});
                  } else {
                    await docRef.set({'addresses': addresses});
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Address saved successfully!")),
                  );
                  _fetchUserAddresses();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _saveQueryToFirestore(String suggestion) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('queries').add({
      'userId': user.uid,
      'locationType': selectedLocationType,
      'category': selectedCategory,
      'addressTitle': selectedAddress?['title'] ?? '',
      'addressDetail': selectedAddress?['address'] ?? '',
      'suggestion': suggestion,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String _getSuggestion() {
    switch (selectedCategory) {
      case 'Vegetables & Fruits':
        return 'Tomato';
      case 'Grains':
        return 'Wheat';
      case 'Seedlings':
        return 'Pepper Seedling';
      default:
        return 'Lettuce';
    }
  }

  IconData _getCategoryIcon(String suggestion) {
    switch (suggestion) {
      case 'Tomato':
        return FontAwesomeIcons.carrot;
      case 'Wheat':
        return FontAwesomeIcons.seedling;
      case 'Pepper Seedling':
        return FontAwesomeIcons.leaf;
      default:
        return Icons.eco;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get Advice'), backgroundColor: Colors.green[800]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("👋 Welcome! Let's help you decide what to grow!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButton<Map<String, String>>(
                    isExpanded: true,
                    value: selectedAddress,
                    hint: const Text("Select your address"),
                    items: userAddresses.map((addr) {
                      return DropdownMenuItem(
                        value: addr,
                        child: Text("${addr['title']}: ${addr['address']}", overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedAddress = val),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  onPressed: _addAddress,
                )
              ],
            ),

            const SizedBox(height: 20),
            const Text("1. Where do you want to grow your product?"),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Garden'),
                  selected: selectedLocationType == 'Garden',
                  onSelected: (_) => setState(() => selectedLocationType = 'Garden'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Field'),
                  selected: selectedLocationType == 'Field',
                  onSelected: (_) => setState(() => selectedLocationType = 'Field'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("2. Select a category"),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedCategory,
              items: categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => selectedCategory = val!),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final suggestion = _getSuggestion();
                await _saveQueryToFirestore(suggestion);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("🌱 Product Suggestion"),
                    content: Row(
                      children: [
                        Icon(_getCategoryIcon(suggestion), size: 30, color: Colors.green[800]),
                        const SizedBox(width: 10),
                        Text("We suggest: $suggestion"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Get Suggestion"),
            ),
          ],
        ),
      ),
    );
  }
}
