import 'package:bemestarcem/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProductManager extends ChangeNotifier {
  ProductManager() {
    loadProducts();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> allProducts = [];
  bool loading = false;
  String? error;

  String _search = '';
  String get search => _search;

  set search(String value) {
    _search = value;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (_search.isEmpty) return allProducts;
    return allProducts
        .where((p) => p.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  List<Product> byCategory(String category) =>
      allProducts.where((p) => p.category == category).toList();

  Future<void> loadProducts() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('products').get();
      allProducts =
          snapshot.docs.map((d) => Product.fromDocument(d)).toList();
    } catch (e) {
      error = 'Não foi possível carregar os produtos.';
    }
    loading = false;
    notifyListeners();
  }
}
