import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController pinController = TextEditingController();
  bool isLoading = false;

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Masukkan PIN Wallet"),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Contoh: 1702005"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _processPayment();
              },
              child: const Text("Bayar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPayment() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final walletRef = FirebaseFirestore.instance
          .collection('wallet_users')
          .doc(user.uid);

      final walletSnap = await walletRef.get();

      if (!walletSnap.exists) {
        throw "Wallet tidak ditemukan";
      }

      final data = walletSnap.data() as Map<String, dynamic>;

      final savedPin = data['pin'];
      final balance = data['balance'] ?? 0;
      final total = cart.totalPrice.toInt();

      // 🔐 cek PIN
      if (pinController.text != savedPin) {
        throw "PIN salah";
      }

      // 💰 cek saldo
      if (balance < total) {
        throw "Saldo tidak cukup";
      }

      // ➖ update saldo wallet
      await walletRef.update({'balance': balance - total});

      // 📦 create transaction
      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': user.uid,
        'amount': total,
        'status': 'success',
        'createdAt': Timestamp.now(),
      });

      // 🧹 clear cart
      cart.clearCart();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil")));

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C42),
        title: const Text("Checkout"),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Ringkasan Pesanan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...cart.items.map((item) {
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text("${item.quantity} x Rp ${item.price}"),
                      trailing: Text(
                        "Rp ${(item.price * item.quantity).toInt()}",
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rp ${cart.totalPrice.toInt()}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFFF8C42),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C42),
                    ),
                    onPressed: isLoading ? null : _showPinDialog,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Bayar Sekarang",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
