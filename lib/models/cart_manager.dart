import 'package:bemestarcem/models/cart_product.dart';
import 'package:bemestarcem/models/product.dart';
import 'package:bemestarcem/models/user_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CartManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartProduct> items = [];
  String? _userId;

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Chamado pelo ChangeNotifierProxyProvider sempre que o usuário logado muda.
  void updateUser(UserManager userManager, List<Product> catalog) {
    _userId = userManager.user?.id;
    items.clear();
    if (_userId != null) {
      _loadCartItems(catalog);
    } else {
      notifyListeners();
    }
  }

  CollectionReference get _cartRef =>
      _firestore.collection('users').doc(_userId).collection('cart');

  Future<void> _loadCartItems(List<Product> catalog) async {
    try {
      final snapshot = await _cartRef.get();
      items = snapshot.docs.map((d) => CartProduct.fromDocument(d)).toList();
      for (final item in items) {
        item.product = catalog.where((p) => p.id == item.productId).firstOrNull;
      }
      items.removeWhere((item) => item.product == null);
    } catch (_) {
      items = [];
    }
    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    if (_userId == null) return;
    final existing = items.where((i) => i.productId == product.id).firstOrNull;
    if (existing != null) {
      existing.quantity++;
      await _cartRef.doc(existing.id).update(existing.toCartItemMap());
    } else {
      final cartProduct = CartProduct.fromProduct(product)..product = product;
      final doc = await _cartRef.add(cartProduct.toCartItemMap());
      cartProduct.id = doc.id;
      items.add(cartProduct);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(CartProduct item) async {
    if (_userId == null) return;
    items.remove(item);
    await _cartRef.doc(item.id).delete();
    notifyListeners();
  }

  Future<void> updateQuantity(CartProduct item, int quantity) async {
    if (_userId == null) return;
    item.quantity = quantity;
    await _cartRef.doc(item.id).update(item.toCartItemMap());
    notifyListeners();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
