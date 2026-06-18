import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../models/product_models.dart';
import '../../services/notification_services.dart';
import '../../features/payment/transaction_page.dart';
import '../providers/cart_provider.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  final ValueNotifier<String> searchQuery = ValueNotifier("");

  @override
  void initState() {
    super.initState();
    NotificationService.init();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchQuery.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Belum ada produk"));
            }

            final allProducts = snapshot.data!.docs;

            return CustomScrollView(
              slivers: [
                //  header
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFB347), Color(0xFFFF8C42)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront, color: Colors.white),
                            const SizedBox(width: 10),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Semangat Mandiri",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Belanja mudah & terpercaya",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TransactionPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.receipt_long,
                                color: Colors.white,
                              ),
                            ),

                            IconButton(
                              onPressed: logout,
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        //  search
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: searchController,
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (value) {
                              searchQuery.value = value.toLowerCase();
                            },
                            decoration: const InputDecoration(
                              hintText: "Cari produk...",
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // banner
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB347), Color(0xFFFF8C42)],
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Diskon Hingga 50%",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Belanja lebih hemat",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // category
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kategori",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: const [
                              CategoryChip("Beras"),
                              CategoryChip("Minyak"),
                              CategoryChip("Telur"),
                              CategoryChip("Gula"),
                              CategoryChip("Kopi"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Produk Terbaru",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                ValueListenableBuilder<String>(
                  valueListenable: searchQuery,
                  builder: (context, query, _) {
                    final filtered = allProducts.where((item) {
                      final name = item['name'].toString().toLowerCase();
                      return name.contains(query);
                    }).toList();

                    return SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = filtered[index];

                          final product = Product.fromFirestore(
                            item.data() as Map<String, dynamic>,
                            item.id,
                          );

                          return ProductCard(
                            docId: product.id,
                            image: product.image,
                            name: product.name,
                            price: "Rp ${product.price.toStringAsFixed(0)}",
                            category: product.category,
                            stock: product.stock,
                            rating: product.rating,
                            onTap: () async {
                              if (product.stock <= 0) return;

                              await FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(product.id)
                                  .update({'stock': product.stock - 1});

                              Provider.of<CartProvider>(
                                context,
                                listen: false,
                              ).addToCart(product);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${product.name} ditambahkan ke cart",
                                  ),
                                ),
                              );
                            },
                          );
                        }, childCount: filtered.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.78,
                            ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String title;

  const CategoryChip(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8C42).withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFF8C42),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
