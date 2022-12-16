import 'package:bemestarcem/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class ProductManager extends ChangeNotifier{

  ProductManager(){
    _loadAllProduct();

  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Product>? allProducts = [];

  String _search = '';
  String get search => _search;

  set search(String value){
    _search = value;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    final List<Product> filteredProducts = [];
    
    if(search.isEmpty){
      filteredProducts.addAll(allProducts!);
    }else{
      filteredProducts.addAll(
          allProducts!.where(
                  (p) => p.name!.toLowerCase().contains(search.toLowerCase()))
      );
    }
    return filteredProducts;
  }

  Future<void> _loadAllProduct() async {
    final QuerySnapshot snapProduct =
        await firestore.collection('products').get();
    allProducts = snapProduct.docs.map(
            (d) => Product.fromDocument(d)).toList();
    notifyListeners();
  }
}