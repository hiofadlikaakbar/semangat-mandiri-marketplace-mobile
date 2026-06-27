import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/product_models.dart';
import '../../services/notification_services.dart';
import '../../features/payment/transaction_page.dart';
import '../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../profile/profile_page.dart';

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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F9FB),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProducts = snapshot.data!.docs;

                return ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,

                    slivers: [
                      // ================= HEADER =================
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
                              // TOP BAR
                              Row(
                                children: [
                                  const Icon(
                                    Icons.storefront,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                                  // TRANSACTION
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TransactionPage(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.receipt_long,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ProfilePage(),
                                        ),
                                      );
                                    },
                                  ),
                                  // CART
                                  Consumer<CartProvider>(
                                    builder: (context, cart, _) {
                                      return Stack(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/cart',
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.shopping_cart_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (cart.items.isNotEmpty)
                                            Positioned(
                                              right: 5,
                                              top: 5,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  cart.items.length.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),

                                  // LOGOUT
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

                              // SEARCH
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
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.search,
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
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final item = filtered[index];

                                final product = Product.fromFirestore(
                                  item.data() as Map<String, dynamic>,
                                  item.id,
                                );

                                return ProductCard(
                                  docId: product.id,
                                  image: product.image,
                                  name: product.name,
                                  price:
                                      "Rp ${product.price.toStringAsFixed(0)}",
                                  category: product.category,
                                  stock: product.stock,
                                  rating: product.rating,
                                  onTap: () async {
                                    if (product.stock <= 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Stok habis"),
                                        ),
                                      );
                                      return;
                                    }

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
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio:
                                        MediaQuery.of(context).size.width < 360
                                        ? 0.72
                                        : 0.78,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
