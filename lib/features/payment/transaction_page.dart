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

      
             
     
               
}
