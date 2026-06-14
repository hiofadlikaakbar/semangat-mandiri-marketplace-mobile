import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product_models.dart';

class CartProvider extends ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => _items;

  CartProvider() {
    loadCart();
  }

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.id == product.id);

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(product);
    }

    saveCart();
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.removeWhere((item) => item.id == product.id);
    saveCart();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void clearCart() {
    _items.clear();
    saveCart();
    notifyListeners();
  }

  void increaseQty(Product product) {
    final index = _items.indexWhere((item) => item.id == product.id);

    if (index != -1) {
      _items[index].quantity++;
      saveCart();
      notifyListeners();
    }
  }

  void decreaseQty(Product product) {
    final index = _items.indexWhere((item) => item.id == product.id);

    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      saveCart();
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> cartJson = _items.map((item) {
      return jsonEncode({
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'rating': item.rating,
        'stock': item.stock,
        'quantity': item.quantity,
        'category': item.category,
        'description': item.description,
        'image': item.image,
      });
    }).toList();

    await prefs.setStringList('cart', cartJson);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cartJson = prefs.getStringList('cart');

    if (cartJson != null) {
      _items = cartJson.map((item) {
        final data = jsonDecode(item);

        return Product(
          id: data['id'],
          name: data['name'],
          price: (data['price']).toDouble(),
          rating: (data['rating']).toDouble(),
          stock: data['stock'],
          quantity: data['quantity'] ?? 1,
          category: data['category'],
          description: data['description'],
          image: data['image'],
        );
      }).toList();

      notifyListeners();
    }
  }
}
