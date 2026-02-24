import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'customer_tracking_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Position? userPosition;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // ================= LOCATION =================
  Future<void> getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) setState(() {});
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  // ================= BOOK GUARD =================
  Future<void> bookGuard(String guardId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || userPosition == null) return;

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select booking date & time")),
      );
      return;
    }

    // combine date + time
    final scheduledDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    // ⭐ SMART LOGIC
    // If booking time is within 5 minutes → instant ride
    final now = DateTime.now();
    final difference = scheduledDateTime.difference(now).inMinutes;

    final bool instantRide = difference <= 5;

    final docRef = await FirebaseFirestore.instance.collection("rides").add({
      "customerId": user.uid,
      "guardId": guardId,
      "status": instantRide ? "pending" : "scheduled",
      "scheduledTime": Timestamp.fromDate(scheduledDateTime),
      "latitude": userPosition!.latitude,
      "longitude": userPosition!.longitude,
      "timestamp": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    // ⭐ IF INSTANT → TRACKING SCREEN
    if (instantRide) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerTrackingScreen(rideId: docRef.id),
        ),
      );
    } else {
      // ⭐ IF SCHEDULED → STAY HERE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Scheduled Successfully")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Guards")),
      body: Column(
        children: [
          // DATE PICKER
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (mounted) setState(() {});
              },
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : selectedDate.toString().split(" ")[0],
              ),
            ),
          ),

          // TIME PICKER
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () async {
                selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (mounted) setState(() {});
              },
              child: Text(
                selectedTime == null
                    ? "Select Time"
                    : selectedTime!.format(context),
              ),
            ),
          ),

          // GUARD LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("guards")
                  .where("isOnline", isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (userPosition == null ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No guards online"));
                }

                final guards = snapshot.data!.docs;

                guards.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  if (dataA["latitude"] == null || dataA["longitude"] == null)
                    return 1;
                  if (dataB["latitude"] == null || dataB["longitude"] == null)
                    return -1;

                  final distA = calculateDistance(
                    userPosition!.latitude,
                    userPosition!.longitude,
                    dataA["latitude"],
                    dataA["longitude"],
                  );

                  final distB = calculateDistance(
                    userPosition!.latitude,
                    userPosition!.longitude,
                    dataB["latitude"],
                    dataB["longitude"],
                  );

                  return distA.compareTo(distB);
                });

                return ListView.builder(
                  itemCount: guards.length,
                  itemBuilder: (context, index) {
                    final doc = guards[index];
                    final data = doc.data() as Map<String, dynamic>;

                    if (data["latitude"] == null || data["longitude"] == null) {
                      return const SizedBox();
                    }

                    final distance = calculateDistance(
                      userPosition!.latitude,
                      userPosition!.longitude,
                      data["latitude"],
                      data["longitude"],
                    );

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(data["name"] ?? "Guard"),
                        subtitle: Text(
                          "Distance: ${(distance / 1000).toStringAsFixed(2)} km",
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => bookGuard(doc.id),
                          child: const Text("BOOK"),
                        ),
                      ),
                    );
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
