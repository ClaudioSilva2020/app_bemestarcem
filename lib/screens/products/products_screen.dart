import 'package:bemestarcem/common/custom_drawer/custom_drawer.dart';
import 'package:bemestarcem/models/product_manager.dart';
import 'package:bemestarcem/screens/products/components/products_list_tile.dart';
import 'package:bemestarcem/screens/products/components/search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Consumer<ProductManager>(
          builder: (_, productManager, __){
            if(productManager.search.isEmpty){
              return const Text('Produtos');
            }else{
              return LayoutBuilder(
                builder: (_, constraints){
                  return GestureDetector(
                    onTap: () async {
                      final search = await showDialog<String>(context: context,
                          builder: (_) => SearchDialog(
                            productManager.search
                          ));
                      if (search != null) {
                        productManager.search = search;
                      }
                    },
                    child: Container(
                      width: constraints.biggest.width,
                      child: Text(
                        productManager.search,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          Consumer<ProductManager>(
            builder: (_, productManager, __) {
              if(productManager.search.isEmpty){
                return IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    final search = await showDialog<String>(context: context,
                        builder: (_) => SearchDialog(
                          productManager.search
                        ));
                    if(search != null) {
                      context.read<ProductManager>().search = search;
                    }
                  },
                );
              }else{
                return IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () async {
                    context.read<ProductManager>().search = '';
                  },
                );
              }
            },
          )
        ],
      ),
      body: Consumer<ProductManager>(
        builder: (_, productManager, __){
          return ListView.builder(
            padding: const EdgeInsets.all(3),
            itemCount: productManager.filteredProducts.length,
            itemBuilder: (_, index){
              return ProductListTile(productManager.filteredProducts[index]);
            },
          );
        },
      ),
    );
  }
}
