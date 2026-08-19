import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/common/product_image.dart';
import 'package:bemestarcem/helpers/formatters.dart';
import 'package:bemestarcem/models/product.dart';
import 'package:bemestarcem/models/product_manager.dart';
import 'package:bemestarcem/screens/product/product_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecommendedList extends StatelessWidget {
  const RecommendedList({super.key, this.products});

  /// Quando nulo, mostra o catálogo inteiro.
  final List<Product>? products;

  @override
  Widget build(BuildContext context) {
    final products =
        this.products ?? context.watch<ProductManager>().allProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: mediumYellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Produtos',
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              childAspectRatio: 0.68,
            ),
            itemCount: products.length,
            itemBuilder: (_, index) => ProductGridCard(product: products[index]),
          ),
        ),
      ],
    );
  }
}

/// Card de produto usado nas grades: imagem com cantos arredondados, nome e
/// preço em destaque.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2.0,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductPage(product: product))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF2F4F7),
                child: ProductImage(product, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(product.price),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: darkYellow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
