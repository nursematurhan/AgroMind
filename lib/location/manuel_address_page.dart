import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

const String kGoogleApiKey = 'AIzaSyBKOI6LDfurMaU2ybiZy1r18eiUTFwOUx8';

class ManuelAddressPage extends StatefulWidget {
  const ManuelAddressPage({super.key});

  @override
  State<ManuelAddressPage> createState() => _ManuelAddressPageState();
}

class _ManuelAddressPageState extends State<ManuelAddressPage> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(kGoogleApiKey);
  }

  void autoCompleteSearch(String value) async {
    if (value.isNotEmpty) {
      var result = await googlePlace.autocomplete.get(value, components: [Component("country", "tr")]);
      if (result != null && result.predictions != null) {
        setState(() {
          predictions = result.predictions!;
        });
      }
    } else {
      setState(() {
        predictions = [];
      });
    }
  }

  void getPlaceDetails(String placeId) async {
    var details = await googlePlace.details.get(placeId);
    if (details != null && details.result != null) {
      final lat = details.result!.geometry?.location?.lat;
      final lng = details.result!.geometry?.location?.lng;
      final address = details.result!.formattedAddress;

      if (lat != null && lng != null) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("📍 Selected Address"),
            content: Text("Address: $address\nLatitude: $lat\nLongitude: $lng"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Use this"),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          Navigator.pop(context, {
            'address': address,
            'lat': lat,
            'lng': lng,
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Address"),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search for a place...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: autoCompleteSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(prediction.description ?? ''),
                  onTap: () {
                    getPlaceDetails(prediction.placeId!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
