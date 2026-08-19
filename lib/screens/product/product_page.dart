import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/common/product_image.dart';
import 'package:bemestarcem/helpers/formatters.dart';
import 'package:bemestarcem/models/cart_manager.dart';
import 'package:bemestarcem/models/product.dart';
import 'package:bemestarcem/screens/rating/rating_page.dart';
import 'package:bemestarcem/screens/search_page.dart';
import 'package:bemestarcem/screens/shop/check_out_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/more_products.dart';

/// Página de detalhe do produto — tela única: foto grande, preço em destaque,
/// descrição e as ações de compra fixas no rodapé.
class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.product});

  final Product product;

  Future<void> _addToCart(BuildContext context,
      {required bool goToCart}) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<CartManager>().addToCart(product);
    if (goToCart) {
      navigator.push(MaterialPageRoute(builder: (_) => CheckOutPage()));
    } else {
      messenger.showSnackBar(const SnackBar(
        content: Text('Produto adicionado ao carrinho'),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 340.0,
            pinned: true,
            elevation: 0.0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: _CircleIcon(
              icon: Icons.arrow_back,
              tooltip: 'Voltar',
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: <Widget>[
              _CircleIcon(
                icon: Icons.search,
                tooltip: 'Buscar',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => SearchPage())),
              ),
              const SizedBox(width: 8.0),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: product.heroTag,
                child: Container(
                  color: const Color(0xFFF2F4F7),
                  child: ProductImage(product, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (product.category.isNotEmpty)
                    Chip(
                      label: Text(product.category),
                      side: BorderSide.none,
                      backgroundColor: yellow.withOpacity(0.12),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      labelStyle: const TextStyle(
                        color: darkYellow,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 12.0),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22.0,
                      height: 1.25,
                      fontWeight: FontWeight.bold,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    formatPrice(product.price),
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: darkYellow,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(height: 1.0),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.star_outline, color: darkYellow),
                    title: const Text(
                      'Avaliações',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => RatingPage())),
                  ),
                  const Divider(height: 1.0),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      height: 1.55,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 28.0),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MoreProducts(currentProduct: product),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black12, offset: Offset(0, -2), blurRadius: 8.0),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addToCart(context, goToCart: false),
                    icon: const Icon(Icons.add_shopping_cart, size: 20.0),
                    label: const Text('Adicionar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkYellow,
                      side: const BorderSide(color: darkYellow),
                      minimumSize: const Size.fromHeight(52.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _addToCart(context, goToCart: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: yellow,
                      minimumSize: const Size.fromHeight(52.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Comprar agora',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão redondo translúcido usado sobre a foto do produto, para o ícone ficar
/// legível independente da imagem.
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white.withOpacity(0.85),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: Icon(icon, size: 20.0),
          color: darkGrey,
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 40.0, height: 40.0),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
