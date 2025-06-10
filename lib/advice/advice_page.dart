import 'dart:convert';

import 'package:agromind/advice/query_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  List<Map<String, dynamic>> userAddresses = [];
  Map<String, dynamic>? selectedAddress;

  String selectedMonth = 'January';
  final List<String> monthOptions = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
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

    final parsedAddresses = addresses.map<Map<String, dynamic>>((e) => {
      'title': e['title'] ?? '',
      'address': e['address'] ?? '',
      'lat': e['lat'],
      'lng': e['lng'],

    }).toList();

    if (!mounted) return;
    setState(() {
      userAddresses = parsedAddresses;
      selectedAddress = parsedAddresses.isNotEmpty ? parsedAddresses.last : null;
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
                Navigator.pop(context);
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

                    await _fetchUserAddresses();

                  }
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_location_alt),
              label: const Text("Enter Manually"),
              onPressed: () async {
                final selected = await Navigator.pushNamed(context, '/manual') as Map<String, dynamic>?;

                if (selected != null) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
                  final doc = await docRef.get();
                  final List<dynamic> addresses = (doc.data()?['addresses'] ?? []) as List<dynamic>;

                  addresses.add({
                    'title': selected['address'],
                    'address': selected['address'],
                    'lat': selected['lat'],
                    'lng': selected['lng'],
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
                  await _fetchUserAddresses();
                }
              },
            )

          ],
        ),
      ),
    );
  }

  Future<DocumentReference?> _saveQueryToFirestore(Map<String, dynamic> apiResult) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final locationInfo = apiResult['location_info'] ?? {};
    final soilData = locationInfo['soil_data'] ?? {};
    final climateData = locationInfo['climate_data'] ?? {};
    final dataQuality = locationInfo['data_quality'] ?? {};

    final clay = soilData['clay'] ?? soilData['clay_percent'] ?? 0.0;
    final sand = soilData['sand'] ?? soilData['sand_percent'] ?? 0.0;
    final silt = soilData['silt'] ?? soilData['silt_percent'] ?? 0.0;

    return await FirebaseFirestore.instance.collection('queries').add({
      'userId': user.uid,
      'month': selectedMonth,
      'addressTitle': selectedAddress?['title'] ?? '',
      'addressDetail': selectedAddress?['address'] ?? '',
      'locationType': selectedAddress?['source'] ?? '',
      'suggestion': apiResult['prediction'] ?? '',
      'confidence': apiResult['confidence'] ?? 0.0,
      'top_3_predictions': apiResult['top_3_predictions'] ?? [],
      'soil_data': {
        ...soilData,
        'clay': clay,
        'sand': sand,
        'silt': silt,
      },
      'climate_data': climateData,
      'soil_type': apiResult['soil_type'] ?? '',
      'location_name': locationInfo['location_name'] ?? '',
      'data_quality': dataQuality,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> fetchCropSuggestionFromAPI(double lat, double lng, int month) async {
    final url = Uri.parse("http://10.0.2.2:8000/predict");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "latitude": lat,
          "longitude": lng,
          "month": month,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print("API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Request failed: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green[800]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child:

        ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'lib/images/farmer.png',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text("👋 Welcome! Let's help you decide what to grow!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    value: selectedAddress,
                    hint: const Text("Select your address"),
                    items: userAddresses.map((addr) {
                      final label = '${addr['title']}: ${addr['address']}';
                      return DropdownMenuItem(
                        value: addr,
                        child: Text(label, overflow: TextOverflow.ellipsis),
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
            const Text("📅 Which month do you plan to plant?"),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedMonth,
              items: monthOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => selectedMonth = val!),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedAddress == null) return;

                final lat = double.tryParse(selectedAddress?['lat'].toString() ?? '');
                final lng = double.tryParse(selectedAddress?['lng'].toString() ?? '');

                if (lat == null || lng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❗ Latitude/Longitude data is invalid.")),
                  );
                  return;
                }

                final monthIndex = monthOptions.indexOf(selectedMonth) + 1;

                // ⏳ Gösterilen loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    content: Row(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Expanded(child: Text("⏳ Getting suggestion, please wait...")),
                      ],
                    ),
                  ),
                );

                final result = await fetchCropSuggestionFromAPI(lat, lng, monthIndex);

                // ⛔ Loading dialog kapat
                Navigator.pop(context);

                if (result != null) {
                  final docRef = await _saveQueryToFirestore(result);

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("🌱 Product Suggestion"),
                      content: Row(
                        children: [
                          const Icon(Icons.spa, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(child: Text("We suggest: ${result['prediction'] ?? 'Unknown'}")),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                        if (docRef != null)
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context); // dialog kapanır

                              final doc = await docRef.get();
                              if (!context.mounted) return;

                              if (doc.exists && doc.data() != null) {
                                final data = doc.data() as Map<String, dynamic>;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QueryDetailPage(data: data),
                                  ),
                                );
                              }
                            },
                            child: const Text("See Details"),
                          ),
                      ],
                    ),
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Could not get recommendation from API.")),
                  );
                }
              },
              child: const Text("Get Suggestion"),
            ),
          ],
        ),
      ),
    );
  }
}
