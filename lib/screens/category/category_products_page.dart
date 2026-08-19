import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/common/product_image.dart';
import 'package:bemestarcem/helpers/formatters.dart';
import 'package:bemestarcem/models/product_manager.dart';
import 'package:bemestarcem/screens/product/product_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryProductsPage extends StatelessWidget {
  const CategoryProductsPage({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductManager>().byCategory(category);

    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkGrey),
        title: Text(category, style: TextStyle(color: darkGrey)),
      ),
      body: products.isEmpty
          ? const Center(child: Text('Nenhum produto nesta categoria.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final product = products[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProductPage(product: product))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 72,
                              width: 72,
                              child: ProductImage(product, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(formatPrice(product.price),
                                    style: TextStyle(
                                        color: darkYellow,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: yellow),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
