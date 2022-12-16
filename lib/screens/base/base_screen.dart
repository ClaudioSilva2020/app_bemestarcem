import 'package:bemestarcem/common/custom_drawer/custom_drawer.dart';
import 'package:bemestarcem/models/page_manager.dart';
import 'package:bemestarcem/screens/home/home_screen.dart';
import 'package:bemestarcem/screens/login/login_screen.dart';
import 'package:bemestarcem/screens/products/products_screen.dart';
import 'package:bemestarcem/screens/requests/requests_screen.dart';
import 'package:bemestarcem/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseScreen extends StatelessWidget {

  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => PageManager(pageController),
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          HomeScreen(),
          ProductsScreen(),
          RequestsScreen(),
          StoreScreen(),
          Container(color: Colors.blue,),
          Container(color: Colors.white,),
          Container(color: Colors.blueAccent,),
        ],
      ),
    );
  }
}
