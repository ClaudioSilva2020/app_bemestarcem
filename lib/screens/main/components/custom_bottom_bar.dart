import 'package:bemestarcem/models/cart_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Barra inferior em Material 3 (NavigationBar), com ícones nativos do Flutter
/// e contador de itens no carrinho.
class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({
    super.key,
    required this.controller,
  });

  final TabController controller;

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartManager>().totalItems;

    Widget cartIcon(IconData icon) => Badge.count(
          count: cartCount,
          isLabelVisible: cartCount > 0,
          child: Icon(icon),
        );

    return NavigationBar(
      selectedIndex: widget.controller.index,
      onDestinationSelected: widget.controller.animateTo,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 3,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: <Widget>[
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        const NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Categorias',
        ),
        NavigationDestination(
          icon: cartIcon(Icons.shopping_cart_outlined),
          selectedIcon: cartIcon(Icons.shopping_cart),
          label: 'Carrinho',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
