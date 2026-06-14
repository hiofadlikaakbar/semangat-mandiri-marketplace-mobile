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
      case "pending":
      default:
        return Colors.orange;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "success":
        return Icons.check_circle;
      case "failed":
        return Icons.cancel;
      case "pending":
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8C42),
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

       
             
     
               
}
