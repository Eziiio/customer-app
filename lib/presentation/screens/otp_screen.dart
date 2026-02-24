import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_screen.dart';

class OtpScreen extends StatelessWidget {
  final String verificationId;

  OtpScreen({super.key, required this.verificationId});

  final TextEditingController otpController = TextEditingController();

  void verifyOTP(BuildContext context) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => verifyOTP(context),
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
