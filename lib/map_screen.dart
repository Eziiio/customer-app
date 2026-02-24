import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("guards")
        .where("isOnline", isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          Set<Marker> newMarkers = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();

            if (data["latitude"] == null || data["longitude"] == null) {
              continue;
            }

            newMarkers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(data["latitude"], data["longitude"]),
                infoWindow: InfoWindow(title: data["name"] ?? "Guard"),
              ),
            );
          }

          setState(() {
            markers = newMarkers;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Guards")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(10.0, 76.0),
          zoom: 14,
        ),
        markers: markers,
      ),
    );
  }
}
