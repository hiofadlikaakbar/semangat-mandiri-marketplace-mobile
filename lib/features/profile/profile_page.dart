import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final username = data["username"] ?? "";
          final email = data["email"] ?? "";
          final secret = data["totpSecret"] ?? "";
          final enabled = data["authenticatorEnabled"] ?? false;

          final otpUrl =
              "otpauth://totp/SemangatMandiri:$email"
              "?secret=$secret"
              "&issuer=SemangatMandiri";

          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              const CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 45),
              ),

              const SizedBox(height: 20),

              Text(
                username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(email, textAlign: TextAlign.center),

              const SizedBox(height: 30),

              const Divider(),

              const Text(
                "Google Authenticator",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              const Text("Scan QR berikut menggunakan Google Authenticator"),

              const SizedBox(height: 20),

              Center(child: QrImageView(data: otpUrl, size: 220)),

              const SizedBox(height: 20),

              SelectableText(secret, textAlign: TextAlign.center),

              const SizedBox(height: 20),

              Row(
                children: [
                  Icon(
                    enabled ? Icons.check_circle : Icons.cancel,
                    color: enabled ? Colors.green : Colors.red,
                  ),

                  const SizedBox(width: 10),

                  Text(enabled ? "Authenticator Aktif" : "Belum Aktif"),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: enabled
                    ? null
                    : () async {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .update({"authenticatorEnabled": true});

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Google Authenticator berhasil diaktifkan",
                              ),
                            ),
                          );
                        }
                      },

                child: const Text("Saya Sudah Menghubungkan"),
              ),
            ],
          );
        },
      ),
    );
  }
}
