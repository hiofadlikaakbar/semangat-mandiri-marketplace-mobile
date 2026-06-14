class Product {
  final String id;
  final String name;
  final double price;
  final double rating;
  final int stock;
  int quantity;
  final String category;
  final String description;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.stock,
    this.quantity = 1,
    required this.category,
    required this.description,
    required this.image,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      quantity: 1,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
