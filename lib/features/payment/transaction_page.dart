import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "success":
        return Colors.green;

      case "failed":
        return Colors.red;

      default:
        return const Color(0xFFFF8C42);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "success":
        return Icons.check_circle;

      case "failed":
        return Icons.cancel;

      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User belum login")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFF8C42),
        centerTitle: true,
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8C42)),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Tidak ada data"));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Belum ada transaksi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];

              final amount = data['amount'] ?? 0;
              final status = data['status'] ?? 'pending';

              final statusColor = getStatusColor(status.toString());

              return Container(
                margin: const EdgeInsets.only(bottom: 14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: statusColor.withOpacity(0.15),
                    child: Icon(
                      getStatusIcon(status.toString()),
                      color: statusColor,
                    ),
                  ),

                  title: Text(
                    "Rp $amount",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Transaksi Marketplace",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),

                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toString().toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
