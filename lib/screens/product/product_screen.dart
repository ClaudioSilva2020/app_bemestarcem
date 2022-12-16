import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:bemestarcem/models/product.dart';

class ProductScreen extends StatelessWidget {

  ProductScreen(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {

    final primaryColor  = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(product.name!),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Carousel(
              images: product.images!.map((url){
                return NetworkImage(url);
              }).toList(),
              dotSize: 4,
              dotBgColor: Colors.transparent,
              dotColor: primaryColor,
              autoplay: false,
              animationDuration: Duration(milliseconds: 1500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name!,
                  style: TextStyle(
                    fontSize: 23,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'Vendido e entrege por Bem Estar',
                    style: TextStyle(
                        fontSize: 14,
                      color: Colors.grey[500]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Por apenas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400]
                    ),
                  ),
                ),
                Text(
                  'R\$ 1850.00',
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    color: primaryColor
                  ),
                ),
                Text(
                  'Em até 10x no sem juros no cartão',
                  style: TextStyle(
                      fontSize: 14,
                      // color: primaryColor
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Descrição',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                Text(
                  product.description!,
                  style: const TextStyle(
                      fontSize: 16
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
