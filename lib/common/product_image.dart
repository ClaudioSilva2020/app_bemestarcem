import 'package:bemestarcem/models/product.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage(
    this.product, {
    super.key,
    this.height,
    this.width,
    this.fit,
  });

  final Product product;
  final double? height;
  final double? width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    if (product.hasRemoteImage) {
      return Image.network(
        product.image,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.grey[400],
        ),
      );
    }
    return Image.asset(product.image, height: height, width: width, fit: fit);
  }
}
