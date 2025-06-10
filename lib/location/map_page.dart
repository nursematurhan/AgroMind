// 📍 Updated MapPage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng? _initialPosition;
  LatLng? selectedPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    } else {
      setState(() {
        _initialPosition = const LatLng(39.9208, 32.8541);
      });
    }
  }

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

      String fullAddress = "Lat: ${position.latitude}, Lng: ${position.longitude}";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          fullAddress = "${place.street}, ${place.locality}, ${place.country}";
        }
      } catch (_) {}

      final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
      final doc = await docRef.get();
      final List<dynamic> addresses = (doc.data()?['addresses'] ?? []) as List<dynamic>;

      addresses.add({
        'title': title.trim(),
        'address': fullAddress,
        'lat': position.latitude.toString(),
        'lng': position.longitude.toString(),
        'email': user.email,
      });

      await docRef.set({'addresses': addresses}, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Address saved from map!")));
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
      body: _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(target: _initialPosition!, zoom: 10),
            onTap: (position) {
              setState(() => selectedPosition = position);
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

