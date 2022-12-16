import 'package:bemestarcem/common/custom_drawer/custom_drawer.dart';
import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text('Nossas lojas'),
        centerTitle: true,
      ),
    );
  }
}
