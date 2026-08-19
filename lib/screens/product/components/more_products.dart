import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/models/product.dart';
import 'package:bemestarcem/models/product_manager.dart';
import 'package:bemestarcem/screens/main/components/recommended_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoreProducts extends StatelessWidget {
  const MoreProducts({super.key, this.currentProduct});

  final Product? currentProduct;

  @override
  Widget build(BuildContext context) {
    final products = context
        .watch<ProductManager>()
        .allProducts
        .where((p) => p.id == null || p.id != currentProduct?.id)
        .toList();

    if (products.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 20.0, bottom: 12.0),
          child: Text(
            'Mais produtos',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: darkGrey,
            ),
          ),
        ),
        SizedBox(
          height: 250.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 20.0),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12.0),
            itemBuilder: (_, index) => SizedBox(
              width: 160.0,
              child: ProductGridCard(product: products[index]),
            ),
          ),
        ),
      ],
    );
  }
}
