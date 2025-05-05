import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng? selectedPosition;

  final LatLng _initialPosition = const LatLng(0.3476, 32.5825); // Uganda - Afrika örneği

  Future<void> _saveAddressToFirestore(LatLng position) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Save this location?"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Enter address title"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Save")),
          ],
        );
      },
    );

    if (title != null && title.trim().isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
      final doc = await docRef.get();
      final data = doc.data() ?? {};
      final List<dynamic> addresses = data['addresses'] ?? [];

      addresses.add({
        'title': title.trim(),
        'address': "Lat: ${position.latitude}, Lng: ${position.longitude}",
        'lat': position.latitude,
        'lng': position.longitude,
        'email': user.email,
      });

      await docRef.update({'addresses': addresses});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Address saved from map!")),
      );

      Navigator.pop(context, position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Confirm location",
            onPressed: selectedPosition != null
                ? () => _saveAddressToFirestore(selectedPosition!)
                : null,
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 6,
            ),
            onTap: (position) {
              setState(() {
                selectedPosition = position;
              });
            },
            markers: selectedPosition != null
                ? {
              Marker(
                markerId: const MarkerId("selected"),
                position: selectedPosition!,
                infoWindow: const InfoWindow(title: "Selected Location"),
              )
            }
                : {},
          ),
          if (selectedPosition != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "📍 Selected: ${selectedPosition!.latitude.toStringAsFixed(4)}, ${selectedPosition!.longitude.toStringAsFixed(4)}",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}