import 'package:bemestarcem/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProduct {
  CartProduct.fromProduct(Product product)
      : product = product,
        productId = product.id,
        quantity = 1;

  CartProduct.fromDocument(DocumentSnapshot document)
      : id = document.id,
        productId = (document.data() as Map<String, dynamic>)['productId'] as String?,
        quantity = (document.data() as Map<String, dynamic>)['quantity'] as int? ?? 1;

  String? id;
  final String? productId;
  int quantity;

  Product? product;

  double get totalPrice => (product?.price ?? 0) * quantity;

  Map<String, dynamic> toCartItemMap() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
