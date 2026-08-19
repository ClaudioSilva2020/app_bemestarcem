import 'package:card_swiper/card_swiper.dart';
import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/models/product.dart';
import 'package:bemestarcem/screens/product/product_page.dart';
import 'package:bemestarcem/common/product_image.dart';
import 'package:bemestarcem/helpers/formatters.dart';
import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;

  final SwiperController swiperController = SwiperController();

  ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height / 3;
    double cardWidth = MediaQuery.of(context).size.width / 1.8;

    return SizedBox(
      // altura do card + respiro para os pontinhos de paginação
      height: cardHeight + 40,
      child: Swiper(
        itemCount: products.length,
        itemBuilder: (_, index) {
          return ProductCard(
              height: cardHeight, width: cardWidth, product: products[index]);
        },
        scale: 0.8,
        controller: swiperController,
        viewportFraction: 0.6,
        loop: false,
        fade: 0.5,
        pagination: const SwiperPagination(
          margin: EdgeInsets.only(bottom: 6.0),
          builder: DotSwiperPaginationBuilder(
            activeColor: mediumYellow,
            color: Colors.black26,
            size: 7.0,
            activeSize: 9.0,
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final double height;
  final double width;

  const ProductCard({
    required this.product,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 8.0, right: 8.0, top: 8.0, bottom: 32.0),
      child: Material(
        color: Colors.white,
        elevation: 4.0,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductPage(product: product))),
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Hero(
                  tag: product.heroTag,
                  child: ProductImage(product, fit: BoxFit.cover),
                ),
                // Faixa escura sob o texto: o preço fica sempre legível, na
                // frente da imagem.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatPrice(product.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
