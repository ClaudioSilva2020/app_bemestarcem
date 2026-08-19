import 'package:bemestarcem/models/cart_manager.dart';
import 'package:bemestarcem/models/product_manager.dart';
import 'package:bemestarcem/models/user_manager.dart';
import 'package:bemestarcem/screens/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('pt_BR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserManager(), lazy: false),
        ChangeNotifierProvider(create: (_) => ProductManager(), lazy: false),
        ChangeNotifierProxyProvider2<UserManager, ProductManager, CartManager>(
          create: (_) => CartManager(),
          lazy: false,
          update: (_, userManager, productManager, cartManager) =>
              cartManager!..updateUser(userManager, productManager.allProducts),
        ),
      ],
      child: MaterialApp(
        title: 'Bem Estar Cem',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        theme: ThemeData(
          brightness: Brightness.light,
          canvasColor: Colors.transparent,
          primarySwatch: Colors.blue,
          fontFamily: "Montserrat",
        ),
        home: SplashScreen(),
      ),
    );
  }
}
