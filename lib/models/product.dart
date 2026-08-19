import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  Product(this.image, this.name, this.description, this.price,
      {this.id, this.category = ''});

  Product.fromDocument(DocumentSnapshot document)
      : id = document.id,
        image = _firstImage(document),
        name = (document.data() as Map<String, dynamic>)['name'] as String? ?? '',
        description =
            (document.data() as Map<String, dynamic>)['description'] as String? ?? '',
        category =
            (document.data() as Map<String, dynamic>)['category'] as String? ?? '',
        price = _toDouble((document.data() as Map<String, dynamic>)['price']);

  final String? id;
  final String image;
  final String name;
  final String description;
  final String category;
  final double price;

  /// Produtos vindos do Firestore têm imagem hospedada; os de exemplo do
  /// template vêm de `assets/`, e cada caso exige um widget de imagem diferente.
  bool get hasRemoteImage => image.startsWith('http');

  /// Tag do Hero na transição carrossel → detalhe. Só pode existir um widget
  /// com esta tag por tela, por isso apenas o carrossel da home e a página de
  /// detalhe a utilizam.
  String get heroTag => 'produto-${id ?? image}';

  static String _firstImage(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final images = data['images'];
    if (images is List && images.isNotEmpty) return images.first as String;
    return data['image'] as String? ?? '';
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
