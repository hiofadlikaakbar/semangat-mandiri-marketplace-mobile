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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Konfirmasi Pembayaran",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Masukkan PIN",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFFF8C42),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _processPayment();
                  },
                  child: const Text(
                    "Konfirmasi Bayar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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

      if (pinController.text != savedPin) {
        throw "PIN salah";
      }

      if (balance < total) {
        throw "Saldo tidak cukup";
      }

      await walletRef.update({'balance': balance - total});

      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': user.uid,
        'amount': total,
        'status': 'success',
        'createdAt': Timestamp.now(),
      });

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
      backgroundColor: const Color(0xFFF7F8FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C42),
        elevation: 0,
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // SUMMARY HEADER
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB347), Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 8),

                Text(
                  "Rp ${cart.totalPrice.toInt()}",
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "${cart.items.length} item di keranjang",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // LIST ITEMS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.quantity} x Rp ${item.price}",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "Rp ${(item.price * item.quantity).toInt()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8C42),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // BOTTOM CHECKOUT BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: isLoading ? null : _showPinDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Bayar Sekarang",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
