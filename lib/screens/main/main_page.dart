import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/custom_background.dart';
import 'package:bemestarcem/models/category.dart';
import 'package:bemestarcem/models/product_manager.dart';
import 'package:bemestarcem/screens/category/category_list_page.dart';
import 'package:bemestarcem/screens/notifications_page.dart';
import 'package:bemestarcem/screens/profile_page.dart';
import 'package:bemestarcem/screens/search_page.dart';
import 'package:bemestarcem/screens/shop/check_out_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/custom_bottom_bar.dart';
import 'components/product_list.dart';
import 'components/tab_view.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin<MainPage> {
  late TabController tabController;
  late TabController bottomTabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: Category.all.length + 1, vsync: this);
    bottomTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    bottomTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => NotificationsPage())),
            icon: const Icon(Icons.notifications_outlined),
            color: darkGrey,
            tooltip: 'Notificações',
          ),
          Text(
            'Bem Estar Cem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => SearchPage())),
            icon: const Icon(Icons.search),
            color: darkGrey,
            tooltip: 'Buscar',
          ),
        ],
      ),
    );

    Widget topHeader = Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Destaques',
          style: TextStyle(fontSize: 20, color: darkGrey),
        ),
      ),
    );

    Widget tabBar = TabBar(
      tabs: [
        const Tab(text: 'Em alta'),
        ...Category.all.map((c) => Tab(text: c.category)),
      ],
      labelStyle: TextStyle(fontSize: 16.0),
      unselectedLabelStyle: TextStyle(
        fontSize: 14.0,
      ),
      labelColor: darkGrey,
      unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.5),
      isScrollable: true,
      controller: tabController,
    );

    return Scaffold(
      bottomNavigationBar: CustomBottomBar(controller: bottomTabController),
      body: CustomPaint(
        painter: MainBackground(),
        child: TabBarView(
          controller: bottomTabController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            SafeArea(
              child: Consumer<ProductManager>(
                builder: (_, productManager, __) {
                  if (productManager.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (productManager.error != null) {
                    return _CatalogMessage(
                      message: productManager.error!,
                      onRetry: productManager.loadProducts,
                    );
                  }
                  if (productManager.allProducts.isEmpty) {
                    return _CatalogMessage(
                      message: 'Nenhum produto cadastrado ainda.',
                      onRetry: productManager.loadProducts,
                    );
                  }
                  return NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return <Widget>[
                        SliverToBoxAdapter(child: appBar),
                        SliverToBoxAdapter(child: topHeader),
                        SliverToBoxAdapter(
                          child: ProductList(
                            products: productManager.allProducts,
                          ),
                        ),
                        SliverToBoxAdapter(child: tabBar)
                      ];
                    },
                    body: TabView(tabController: tabController),
                  );
                },
              ),
            ),
            CategoryListPage(),
            CheckOutPage(),
            ProfilePage()
          ],
        ),
      ),
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
