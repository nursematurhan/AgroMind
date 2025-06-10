import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QueryDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const QueryDetailPage({super.key, required this.data});

  String getConfidenceMessage(double confidence) {
    if (confidence < 0.3) {
      return "🔍 Consider this crop as one option, but confidence is low. Explore alternatives.";
    } else if (confidence < 0.6) {
      return "🤔 This crop shows moderate suitability. You can consider it alongside others.";
    } else {
      return "✅ This crop is highly recommended for your soil and climate conditions.";
    }
  }

  Color getConfidenceColor(String level) {
    switch (level) {
      case 'Very High': return Colors.green.shade700;
      case 'High': return Colors.green;
      case 'Medium': return Colors.yellow.shade800;
      case 'Low': return Colors.orange;
      case 'Very Low': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = data['suggestion'] ?? '';
    final confidence = (data['confidence'] ?? 0.0).toDouble();
    final top3 = List<Map<String, dynamic>>.from(data['top_3_predictions'] ?? []);
    final locationType = data['locationType'] ?? '';
    final addressTitle = data['addressTitle'] ?? '';
    final addressDetail = data['addressDetail'] ?? '';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final soil = Map<String, dynamic>.from(data['soil_data'] ?? {});
    final climate = Map<String, dynamic>.from(data['climate_data'] ?? {});
    final soilType = data['soil_type'] ?? 'Unknown';
    final locationName = data['location_name'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Details'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🌿 Suggestion: $suggestion",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: getConfidenceColor(top3.isNotEmpty ? top3[0]['confidence_level'] ?? '' : ''),
                )),
            const SizedBox(height: 10),
            Text(getConfidenceMessage(confidence), style: const TextStyle(fontSize: 14)),
            const Divider(height: 30),

            Text("📦 Top 3 Predictions:", style: const TextStyle(fontWeight: FontWeight.bold)),
            ...top3.map((item) => ListTile(
              title: Text("${item['crop']} (${(item['probability'] * 100).toStringAsFixed(1)}%)"),
              trailing: Text(item['confidence_level'] ?? '',
                  style: TextStyle(color: getConfidenceColor(item['confidence_level'] ?? ''))),
            )),
            const Divider(height: 30),

            Text("📍 Location: $addressTitle - $addressDetail"),
            Text("📌 Type: $locationType"),
            Text("🗺️ Name: $locationName"),
            if (timestamp != null)
              Text("🕒 Date: ${DateFormat.yMMMMd().add_Hm().format(timestamp)}"),
            const Divider(height: 30),

            Text("🌱 Soil Info:", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Type: $soilType"),
            Text("pH: ${soil['ph']}"),
            Text("NPK: ${soil['n']}-${soil['p']}-${soil['k']}"),
            Text("Texture: Clay ${soil['clay']}%, Sand ${soil['sand']}%, Silt ${soil['silt']}%"),
            const Divider(height: 30),

            Text("🌤 Climate Info:", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Temperature: ${climate['temperature']} °C"),
            Text("Humidity: ${climate['humidity']} %"),
          ],
        ),
      ),
    );
  }
}
