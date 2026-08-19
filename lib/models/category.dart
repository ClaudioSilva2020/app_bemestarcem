import 'package:flutter/material.dart';

class Category {
  const Category(this.begin, this.end, this.category, this.image);

  final Color begin;
  final Color end;
  final String category;

  /// URL da imagem representativa da categoria.
  final String image;

  /// Categorias da loja. O campo [category] precisa bater com o campo
  /// `category` dos documentos da coleção `products` no Firestore.
  static const List<Category> all = [
    Category(
      Color(0xff42A5F5),
      Color(0xff1565C0),
      'Cama',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=400&q=70&fm=jpg&fit=crop',
    ),
    Category(
      Color(0xff26C6DA),
      Color(0xff00838F),
      'Sala',
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=70&fm=jpg&fit=crop',
    ),
    Category(
      Color(0xff5C6BC0),
      Color(0xff283593),
      'Cozinha',
      'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=400&q=70&fm=jpg&fit=crop',
    ),
    Category(
      Color(0xff29B6F6),
      Color(0xff0277BD),
      'Eletrodomésticos',
      'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=400&q=70&fm=jpg&fit=crop',
    ),
  ];
}
