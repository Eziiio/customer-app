import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'booking_screen.dart'; // ⭐ add this

class CustomerTrackingScreen extends StatelessWidget {
  final String rideId;

  const CustomerTrackingScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking Guard")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rides")
            .doc(rideId)
            .snapshots(),
        builder: (context, rideSnapshot) {
          if (!rideSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ride = rideSnapshot.data!.data() as Map<String, dynamic>?;

          if (ride == null) {
            return const Center(child: Text("Ride not found"));
          }

          final status = ride["status"];

          /// =====================
          /// PENDING
          /// =====================
          if (status == "pending") {
            return const Center(child: Text("Waiting for guard acceptance..."));
          }

          /// =====================
          /// REJECTED → AUTO RETURN
          /// =====================
          if (status == "rejected") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const BookingScreen()),
                (route) => false,
              );
            });

            return const SizedBox();
          }

          /// =====================
          /// COMPLETED → AUTO RETURN
          /// =====================
          if (status == "completed") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const BookingScreen()),
                (route) => false,
              );
            });

            return const SizedBox();
          }

          /// =====================
          /// ACCEPTED → TRACK GUARD
          /// =====================
          if (status == "accepted") {
            final guardId = ride["guardId"];

            if (guardId == null) {
              return const Center(child: Text("Waiting for guard info..."));
            }

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("guards")
                  .doc(guardId)
                  .snapshots(),
              builder: (context, guardSnapshot) {
                if (!guardSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final guard =
                    guardSnapshot.data!.data() as Map<String, dynamic>?;

                if (guard == null ||
                    guard["latitude"] == null ||
                    guard["longitude"] == null) {
                  return const Center(
                    child: Text("Waiting for guard location..."),
                  );
                }

                final LatLng guardLatLng = LatLng(
                  guard["latitude"],
                  guard["longitude"],
                );

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: guardLatLng,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("guard"),
                      position: guardLatLng,
                    ),
                  },
                );
              },
            );
          }

          return const Center(child: Text("Unknown state"));
        },
      ),
    );
  }
}
