import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8C42),
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // HEADER CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB347), Color(0xFFFF8C42)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 50,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Ringkasan Pesanan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "${cart.items.length} Produk",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Detail Produk",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...cart.items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.image,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

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

                              const SizedBox(height: 6),

                              Text(
                                item.category,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "${item.quantity} x Rp ${item.price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Color(0xFFFF8C42),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                const Text(
                  "Metode Pembayaran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFFFF8C42),
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "E-Money",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Pembayaran",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      "Rp ${cart.totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8C42),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text(
                      "Bayar Sekarang",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pembayaran berhasil")),
                      );

                      cart.clearCart();

                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
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
