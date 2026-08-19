import 'package:bemestarcem/models/category.dart';
import 'package:bemestarcem/models/product_manager.dart';
import 'package:bemestarcem/screens/category/category_products_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_card.dart';
import 'recommended_list.dart';

class TabView extends StatelessWidget {
  const TabView({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final categories = Category.all;

    Widget categoryStrip = SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        itemBuilder: (_, index) => CategoryCard(
          category: categories[index],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  CategoryProductsPage(category: categories[index].category))),
        ),
      ),
    );

    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: <Widget>[
          // "Em alta" — catálogo completo, com o atalho de categorias
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 12.0),
              categoryStrip,
              const SizedBox(height: 20.0),
              Flexible(child: RecommendedList()),
            ],
          ),
          ...categories.map((c) => _CategoryTab(category: c.category)),
        ]);
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductManager>().byCategory(category);
    if (products.isEmpty) {
      return const Center(child: Text('Nenhum produto nesta categoria.'));
    }
    return Column(children: <Widget>[
      SizedBox(height: 16.0),
      Flexible(child: RecommendedList(products: products)),
    ]);
  }
}
