import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final controller = TextEditingController();

  bool loading = false;

  Future<void> verify() async {
    setState(() {
      loading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      final data = doc.data();

      if (data == null) return;

      final secret = data["totpSecret"];

      bool valid = false;

      final now = DateTime.now();

      for (int offset = -1; offset <= 1; offset++) {
        final generated = OTP.generateTOTPCodeString(
          secret,
          now.add(Duration(seconds: offset * 30)).millisecondsSinceEpoch,
          interval: 30,
          algorithm: Algorithm.SHA1,
          isGoogle: true,
        );

        if (generated == controller.text.trim()) {
          valid = true;
          break;
        }
      }

      if (!valid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kode Google Authenticator salah")),
          );
        }

        return;
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "authenticatorEnabled": true,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Google Authenticator berhasil diaktifkan"),
        ),
      );

      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Authenticator")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(Icons.security, size: 80, color: Colors.orange),

            const SizedBox(height: 20),

            const Text(
              "Masukkan kode 6 digit dari Google Authenticator",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : verify,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Verifikasi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
